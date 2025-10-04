class Participant {
  final String id;
  final String name;
  final String joinedAt;
  final bool? isHost;

  Participant({
    required this.id,
    required this.name,
    required this.joinedAt,
    this.isHost,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      joinedAt: json['joinedAt'] ?? '',
      isHost: json['isHost'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'joinedAt': joinedAt,
      'isHost': isHost,
    };
  }
}
