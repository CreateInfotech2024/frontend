import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_message.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect() {
    if (_socket?.connected ?? false) {
      return;
    }

    const backendUrl = 'https://krishnabarasiya.space';
    _socket = IO.io(backendUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .setTimeout(10000)
        .build()
    );

    _socket?.on('connect', (_) {
      print('✅ Connected to Socket.IO server');
      _isConnected = true;
    });

    _socket?.on('disconnect', (_) {
      print('❌ Disconnected from Socket.IO server');
      _isConnected = false;
    });

    _socket?.on('connect_error', (error) {
      print('❌ Socket.IO connection error: $error');
      _isConnected = false;
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  // Join a meeting room for real-time updates
  void joinMeetingRoom(
    String meetingCode,
    String participantName, {
    String? participantId,
    bool isHost = false,
  }) {
    if (_socket != null) {
      _socket!.emit('join-meeting', {
        'meetingCode': meetingCode,
        'participantId': participantId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'participantName': participantName,
        'isHost': isHost,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Leave a meeting room
  void leaveMeetingRoom(String meetingCode, String participantName) {
    if (_socket != null) {
      _socket!.emit('leave-meeting', {
        'meetingCode': meetingCode,
        'participantName': participantName,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Send a chat message
  void sendChatMessage(String meetingCode, String sender, String message) {
    if (_socket != null) {
      _socket!.emit('chat-message', {
        'meetingCode': meetingCode,
        'sender': sender,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Listen for chat messages
  void onChatMessage(Function(ChatMessage) callback) {
    _socket?.on('chat-message', (data) {
      callback(ChatMessage.fromJson(data));
    });
  }

  // Listen for participant joined events
  void onParticipantJoined(Function(Map<String, dynamic>) callback) {
    _socket?.on('participant-joined', (data) {
      callback(data);
    });
  }

  // Listen for participant left events
  void onParticipantLeft(Function(Map<String, dynamic>) callback) {
    _socket?.on('participant-left', (data) {
      callback(data);
    });
  }

  // Listen for meeting ended events
  void onMeetingEnded(Function(Map<String, dynamic>) callback) {
    _socket?.on('meeting-ended', (data) {
      callback(data);
    });
  }

  // WebRTC Signaling - Send offer
  void sendOffer(Map<String, dynamic> offer, String to) {
    if (_socket != null) {
      _socket!.emit('webrtc-offer', {
        'offer': offer,
        'to': to,
      });
    }
  }

  // WebRTC Signaling - Send answer
  void sendAnswer(Map<String, dynamic> answer, String to) {
    if (_socket != null) {
      _socket!.emit('webrtc-answer', {
        'answer': answer,
        'to': to,
      });
    }
  }

  // WebRTC Signaling - Send ICE candidate
  void sendIceCandidate(Map<String, dynamic> candidate, String to) {
    if (_socket != null) {
      _socket!.emit('webrtc-ice-candidate', {
        'candidate': candidate,
        'to': to,
      });
    }
  }

  // WebRTC Signaling - Listen for offers
  void onOffer(Function(Map<String, dynamic>) callback) {
    _socket?.on('webrtc-offer', (data) {
      callback(data);
    });
  }

  // WebRTC Signaling - Listen for answers
  void onAnswer(Function(Map<String, dynamic>) callback) {
    _socket?.on('webrtc-answer', (data) {
      callback(data);
    });
  }

  // WebRTC Signaling - Listen for ICE candidates
  void onIceCandidate(Function(Map<String, dynamic>) callback) {
    _socket?.on('webrtc-ice-candidate', (data) {
      callback(data);
    });
  }

  // Audio/Video toggle notifications
  void toggleAudio(bool enabled) {
    if (_socket != null) {
      _socket!.emit('participant-audio-toggle', {
        'audioEnabled': enabled,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void toggleVideo(bool enabled) {
    if (_socket != null) {
      _socket!.emit('participant-video-toggle', {
        'videoEnabled': enabled,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void onParticipantAudioToggle(Function(Map<String, dynamic>) callback) {
    _socket?.on('participant-audio-toggle', (data) {
      callback(data);
    });
  }

  void onParticipantVideoToggle(Function(Map<String, dynamic>) callback) {
    _socket?.on('participant-video-toggle', (data) {
      callback(data);
    });
  }

  // Remove all listeners
  void removeAllListeners() {
    _socket?.off('chat-message');
    _socket?.off('participant-joined');
    _socket?.off('participant-left');
    _socket?.off('meeting-ended');
    _socket?.off('webrtc-offer');
    _socket?.off('webrtc-answer');
    _socket?.off('webrtc-ice-candidate');
    _socket?.off('participant-audio-toggle');
    _socket?.off('participant-video-toggle');
  }
}
