import 'package:flutter/material.dart';
import '../models/live_course.dart';
import '../models/participant.dart';
import '../models/chat_message.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
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
  final List<ChatMessage> _chatMessages = [];
  final List<Participant> _participants = [];
  bool _showChat = true;
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _addParticipant(widget.currentParticipant);
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
        _removeParticipant(name);

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
                // Video placeholder
                Expanded(
                  child: Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off,
                            size: 80,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Video feed placeholder',
                            style: TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'WebRTC integration coming soon',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
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
}
