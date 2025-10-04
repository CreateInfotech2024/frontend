import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/live_course.dart';
import '../models/participant.dart';
import '../models/chat_message.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import '../services/webrtc_service.dart';
import '../widgets/chat_panel.dart';
import '../widgets/participants_list.dart';

class MeetingRoomScreen extends StatefulWidget {
  final LiveCourse course;
  final Participant currentParticipant;

  const MeetingRoomScreen({
    super.key,
    required this.course,
    required this.currentParticipant,
  });

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  final SocketService _socketService = SocketService();
  final WebRTCService _webrtcService = WebRTCService();
  final List<ChatMessage> _chatMessages = [];
  final List<Participant> _participants = [];
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  
  bool _showChat = true;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isInitializingMedia = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _initializeSocket();
    _initializeMedia();
    _addParticipant(widget.currentParticipant);
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> _initializeMedia() async {
    setState(() {
      _isInitializingMedia = true;
    });

    try {
      // Initialize local media
      final stream = await _webrtcService.initializeLocalMedia();
      if (stream != null) {
        _localRenderer.srcObject = stream;
      }

      // Setup WebRTC signaling
      _webrtcService.setupSignaling();

      // Setup remote stream handling
      _webrtcService.onRemoteStreamAdded = (stream, participantId) {
        setState(() {
          final renderer = RTCVideoRenderer();
          renderer.initialize().then((_) {
            renderer.srcObject = stream;
            _remoteRenderers[participantId] = renderer;
            setState(() {}); // Trigger rebuild
          });
        });
      };

      _webrtcService.onRemoteStreamRemoved = (participantId) {
        setState(() {
          final renderer = _remoteRenderers[participantId];
          if (renderer != null) {
            renderer.dispose();
            _remoteRenderers.remove(participantId);
          }
        });
      };
    } catch (e) {
      print('❌ Failed to initialize media: $e');
      _showDialog('Media Error', 
        'Failed to access camera/microphone. Please check permissions.');
    } finally {
      setState(() {
        _isInitializingMedia = false;
      });
    }
  }

  void _initializeSocket() {
    _socketService.connect();

    if (widget.course.meetingCode != null) {
      _socketService.joinMeetingRoom(
        widget.course.meetingCode!,
        widget.currentParticipant.name,
        participantId: widget.currentParticipant.id,
        isHost: widget.currentParticipant.isHost ?? false,
      );

      _socketService.onChatMessage((message) {
        setState(() {
          _chatMessages.add(message);
        });
      });

      _socketService.onParticipantJoined((data) {
        final participant = Participant(
          id: data['participantId'] ?? '',
          name: data['participantName'] ?? '',
          joinedAt: data['timestamp'] ?? '',
          isHost: data['isHost'] ?? false,
        );
        _addParticipant(participant);

        // Create WebRTC connection for new participant
        if (participant.id != widget.currentParticipant.id) {
          _webrtcService.createOffer(participant.id);
        }

        // Add system message
        setState(() {
          _chatMessages.add(ChatMessage(
            sender: 'System',
            message: '${participant.name} joined the meeting',
            timestamp: DateTime.now().toIso8601String(),
            isSystemMessage: true,
          ));
        });
      });

      _socketService.onParticipantLeft((data) {
        final name = data['participantName'] ?? '';
        final participantId = data['participantId'] ?? '';
        _removeParticipant(name);

        // Remove WebRTC connection
        if (participantId.isNotEmpty) {
          _webrtcService.removeParticipant(participantId);
        }

        // Add system message
        setState(() {
          _chatMessages.add(ChatMessage(
            sender: 'System',
            message: '$name left the meeting',
            timestamp: DateTime.now().toIso8601String(),
            isSystemMessage: true,
          ));
        });
      });

      _socketService.onMeetingEnded((data) {
        _showDialog('Meeting Ended', 'The meeting has been ended by the host.');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      });
    }
  }

  void _addParticipant(Participant participant) {
    setState(() {
      if (!_participants.any((p) => p.id == participant.id)) {
        _participants.add(participant);
      }
    });
  }

  void _removeParticipant(String name) {
    setState(() {
      _participants.removeWhere((p) => p.name == name);
    });
  }

  void _sendMessage(String message) {
    if (widget.course.meetingCode != null) {
      _socketService.sendChatMessage(
        widget.course.meetingCode!,
        widget.currentParticipant.name,
        message,
      );
    }
  }

  Future<void> _leaveMeeting() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Meeting'),
        content: const Text('Are you sure you want to leave the meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (widget.course.meetingCode != null) {
        _socketService.leaveMeetingRoom(
          widget.course.meetingCode!,
          widget.currentParticipant.name,
        );
      }

      await ApiService.leaveCourse(
        courseId: widget.course.id,
        participantId: widget.currentParticipant.id,
      );

      _socketService.removeAllListeners();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _endMeeting() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Meeting'),
        content: const Text('Are you sure you want to end the meeting for everyone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Meeting'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.completeCourse(widget.course.id);
      _socketService.removeAllListeners();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socketService.removeAllListeners();
    _webrtcService.cleanup();
    _localRenderer.dispose();
    for (var renderer in _remoteRenderers.values) {
      renderer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.name),
            Text(
              'Code: ${widget.course.meetingCode ?? "N/A"}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showChat ? Icons.chat : Icons.chat_bubble_outline),
            onPressed: () {
              setState(() {
                _showChat = !_showChat;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Main video area
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Video area
                Expanded(
                  child: Container(
                    color: Colors.black87,
                    child: _isInitializingMedia
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Initializing Camera...',
                                  style: TextStyle(color: Colors.white70, fontSize: 18),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Please allow access to camera and microphone',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              // Remote videos grid
                              _buildRemoteVideosGrid(),
                              // Local video (small overlay)
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  width: 150,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Stack(
                                      children: [
                                        RTCVideoView(
                                          _localRenderer,
                                          mirror: true,
                                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                        ),
                                        Positioned(
                                          bottom: 5,
                                          left: 5,
                                          right: 5,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'You${_isCameraOff ? ' (Camera Off)' : ''}',
                                              style: const TextStyle(color: Colors.white, fontSize: 10),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                // Controls
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade900,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        onPressed: () {
                          _webrtcService.toggleAudio();
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                        },
                        color: _isMuted ? Colors.red : Colors.white,
                      ),
                      const SizedBox(width: 16),
                      _buildControlButton(
                        icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                        label: _isCameraOff ? 'Start Video' : 'Stop Video',
                        onPressed: () {
                          _webrtcService.toggleVideo();
                          setState(() {
                            _isCameraOff = !_isCameraOff;
                          });
                        },
                        color: _isCameraOff ? Colors.red : Colors.white,
                      ),
                      const SizedBox(width: 16),
                      _buildControlButton(
                        icon: Icons.screen_share,
                        label: 'Share',
                        onPressed: () {
                          _showDialog('Coming Soon', 'Screen sharing will be available soon');
                        },
                        color: Colors.white,
                      ),
                      const SizedBox(width: 32),
                      if (widget.currentParticipant.isHost == true)
                        _buildControlButton(
                          icon: Icons.call_end,
                          label: 'End Meeting',
                          onPressed: _endMeeting,
                          color: Colors.red,
                        )
                      else
                        _buildControlButton(
                          icon: Icons.exit_to_app,
                          label: 'Leave',
                          onPressed: _leaveMeeting,
                          color: Colors.red,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sidebar with chat and participants
          if (_showChat)
            SizedBox(
              width: 350,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: ChatPanel(
                      messages: _chatMessages,
                      onSendMessage: _sendMessage,
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    flex: 1,
                    child: ParticipantsList(participants: _participants),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          iconSize: 32,
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRemoteVideosGrid() {
    if (_remoteRenderers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Waiting for participants to join...',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _remoteRenderers.length == 1 ? 1 : 2,
        childAspectRatio: 4 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _remoteRenderers.length,
      itemBuilder: (context, index) {
        final participantId = _remoteRenderers.keys.elementAt(index);
        final renderer = _remoteRenderers[participantId]!;
        final participant = _participants.firstWhere(
          (p) => p.id == participantId,
          orElse: () => Participant(
            id: participantId,
            name: 'Unknown',
            joinedAt: '',
          ),
        );

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                RTCVideoView(
                  renderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (participant.isHost ?? false)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.star, color: Colors.amber, size: 16),
                          ),
                        Expanded(
                          child: Text(
                            participant.name,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
