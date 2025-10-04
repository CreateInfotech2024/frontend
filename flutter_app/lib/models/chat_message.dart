class ChatMessage {
  final String sender;
  final String message;
  final String timestamp;
  final String? senderId;
  final bool? isSystemMessage;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    this.senderId,
    this.isSystemMessage,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      senderId: json['senderId'],
      isSystemMessage: json['isSystemMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
      'senderId': senderId,
      'isSystemMessage': isSystemMessage,
    };
  }
}
