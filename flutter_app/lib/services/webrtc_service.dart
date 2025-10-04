import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'socket_service.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  MediaStream? _localStream;
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  
  final SocketService _socketService = SocketService();
  
  // Callbacks
  Function(MediaStream, String)? onRemoteStreamAdded;
  Function(String)? onRemoteStreamRemoved;

  // Configuration for STUN servers
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  // Media constraints
  final Map<String, dynamic> _mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
      'width': {'ideal': 640},
      'height': {'ideal': 480},
    }
  };

  // Initialize local media (camera and microphone)
  Future<MediaStream?> initializeLocalMedia() async {
    try {
      final stream = await navigator.mediaDevices.getUserMedia(_mediaConstraints);
      _localStream = stream;
      print('✅ Local media initialized');
      return stream;
    } catch (e) {
      print('❌ Failed to initialize local media: $e');
      rethrow;
    }
  }

  // Get local stream
  MediaStream? getLocalStream() {
    return _localStream;
  }

  // Get remote streams
  Map<String, MediaStream> getRemoteStreams() {
    return _remoteStreams;
  }

  // Setup WebRTC signaling listeners
  void setupSignaling() {
    _socketService.onOffer((data) async {
      await _handleOffer(data);
    });

    _socketService.onAnswer((data) async {
      await _handleAnswer(data);
    });

    _socketService.onIceCandidate((data) async {
      await _handleIceCandidate(data);
    });
  }

  // Create peer connection for a participant
  Future<RTCPeerConnection> _createPeerConnection(String participantId) async {
    final peerConnection = await createPeerConnection(_configuration);

    // Handle incoming stream
    peerConnection.onTrack = (event) {
      print('📺 Received remote stream from $participantId');
      if (event.streams.isNotEmpty) {
        final stream = event.streams[0];
        _remoteStreams[participantId] = stream;
        onRemoteStreamAdded?.call(stream, participantId);
      }
    };

    // Handle ICE candidates
    peerConnection.onIceCandidate = (candidate) {
      if (candidate != null) {
        _socketService.sendIceCandidate(
          {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
          participantId,
        );
      }
    };

    // Handle connection state changes
    peerConnection.onConnectionState = (state) {
      print('🔗 Connection state with $participantId: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        removeParticipant(participantId);
      }
    };

    // Add local stream to peer connection
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        peerConnection.addTrack(track, _localStream!);
      });
    }

    _peerConnections[participantId] = peerConnection;
    return peerConnection;
  }

  // Handle incoming offer
  Future<void> _handleOffer(Map<String, dynamic> data) async {
    try {
      final offer = data['offer'];
      final from = data['from'];
      
      final peerConnection = await _createPeerConnection(from);
      
      await peerConnection.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      
      final answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);
      
      _socketService.sendAnswer(
        {
          'sdp': answer.sdp,
          'type': answer.type,
        },
        from,
      );
    } catch (e) {
      print('❌ Error handling offer: $e');
    }
  }

  // Handle incoming answer
  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    try {
      final answer = data['answer'];
      final from = data['from'];
      
      final peerConnection = _peerConnections[from];
      if (peerConnection != null) {
        await peerConnection.setRemoteDescription(
          RTCSessionDescription(answer['sdp'], answer['type']),
        );
      }
    } catch (e) {
      print('❌ Error handling answer: $e');
    }
  }

  // Handle incoming ICE candidate
  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    try {
      final candidateData = data['candidate'];
      final from = data['from'];
      
      final peerConnection = _peerConnections[from];
      if (peerConnection != null) {
        final candidate = RTCIceCandidate(
          candidateData['candidate'],
          candidateData['sdpMid'],
          candidateData['sdpMLineIndex'],
        );
        await peerConnection.addCandidate(candidate);
      }
    } catch (e) {
      print('❌ Error handling ICE candidate: $e');
    }
  }

  // Create offer for a new participant
  Future<void> createOffer(String participantId) async {
    try {
      final peerConnection = await _createPeerConnection(participantId);
      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);
      
      _socketService.sendOffer(
        {
          'sdp': offer.sdp,
          'type': offer.type,
        },
        participantId,
      );
    } catch (e) {
      print('❌ Error creating offer: $e');
    }
  }

  // Toggle audio
  void toggleAudio() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      for (var track in audioTracks) {
        track.enabled = !track.enabled;
      }
      _isAudioEnabled = !_isAudioEnabled;
      _socketService.toggleAudio(_isAudioEnabled);
    }
  }

  // Toggle video
  void toggleVideo() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      for (var track in videoTracks) {
        track.enabled = !track.enabled;
      }
      _isVideoEnabled = !_isVideoEnabled;
      _socketService.toggleVideo(_isVideoEnabled);
    }
  }

  // Get media states
  Map<String, bool> getMediaStates() {
    return {
      'audio': _isAudioEnabled,
      'video': _isVideoEnabled,
    };
  }

  // Remove participant
  void removeParticipant(String participantId) {
    final peerConnection = _peerConnections[participantId];
    if (peerConnection != null) {
      peerConnection.close();
      _peerConnections.remove(participantId);
    }
    
    final stream = _remoteStreams[participantId];
    if (stream != null) {
      stream.dispose();
      _remoteStreams.remove(participantId);
      onRemoteStreamRemoved?.call(participantId);
    }
  }

  // Clean up all resources
  Future<void> cleanup() async {
    // Stop local stream
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        track.stop();
      });
      await _localStream!.dispose();
      _localStream = null;
    }

    // Close all peer connections
    for (var peerConnection in _peerConnections.values) {
      await peerConnection.close();
    }
    _peerConnections.clear();

    // Dispose remote streams
    for (var stream in _remoteStreams.values) {
      await stream.dispose();
    }
    _remoteStreams.clear();
  }
}
