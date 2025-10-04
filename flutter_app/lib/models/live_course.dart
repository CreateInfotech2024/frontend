class LiveCourse {
  final String id;
  final String name;
  final String? description;
  final String instructorId;
  final String instructorName;
  final String category;
  final String status; // 'scheduled', 'active', 'completed'
  final String scheduledDateTime;
  final int duration;
  final List<String> enrolledUsers;
  final List<String>? joinedUsers;
  final bool recordingEnabled;
  final String? meetingCode;
  final String? meetingId;
  final String createdAt;
  final String updatedAt;

  LiveCourse({
    required this.id,
    required this.name,
    this.description,
    required this.instructorId,
    required this.instructorName,
    required this.category,
    required this.status,
    required this.scheduledDateTime,
    required this.duration,
    required this.enrolledUsers,
    this.joinedUsers,
    required this.recordingEnabled,
    this.meetingCode,
    this.meetingId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveCourse.fromJson(Map<String, dynamic> json) {
    return LiveCourse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      instructorId: json['instructorId'] ?? '',
      instructorName: json['instructorName'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'scheduled',
      scheduledDateTime: json['scheduledDateTime'] ?? '',
      duration: json['duration'] ?? 0,
      enrolledUsers: List<String>.from(json['enrolledUsers'] ?? []),
      joinedUsers: json['joinedUsers'] != null 
          ? List<String>.from(json['joinedUsers']) 
          : null,
      recordingEnabled: json['recordingEnabled'] ?? false,
      meetingCode: json['meetingCode'],
      meetingId: json['meetingId'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'category': category,
      'status': status,
      'scheduledDateTime': scheduledDateTime,
      'duration': duration,
      'enrolledUsers': enrolledUsers,
      'joinedUsers': joinedUsers,
      'recordingEnabled': recordingEnabled,
      'meetingCode': meetingCode,
      'meetingId': meetingId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
