import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/live_course.dart';
import '../models/participant.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'],
      message: json['message'],
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://krishnabarasiya.space/api';
  static const Duration timeout = Duration(seconds: 10);

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Create a new live course
  static Future<ApiResponse<LiveCourse>> createCourse({
    required String name,
    String? description,
    required String instructorId,
    required String instructorName,
    required String category,
    required int duration,
    String? scheduledDateTime,
    bool? recordingEnabled,
    List<String>? enrolledUsers,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/live_courses'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'description': description,
              'instructorId': instructorId,
              'instructorName': instructorName,
              'category': category,
              'duration': duration,
              'scheduledDateTime': scheduledDateTime,
              'recordingEnabled': recordingEnabled ?? false,
              'enrolledUsers': enrolledUsers ?? [],
            }),
          )
          .timeout(timeout);

      final jsonResponse = jsonDecode(response.body);
      return ApiResponse<LiveCourse>(
        success: jsonResponse['success'] ?? false,
        data: jsonResponse['data'] != null
            ? LiveCourse.fromJson(jsonResponse['data'])
            : null,
        error: jsonResponse['error'],
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResponse<LiveCourse>(
        success: false,
        error: 'Backend server is not available',
        message: e.toString(),
      );
    }
  }

  // Get all live courses
  static Future<ApiResponse<List<LiveCourse>>> getAllCourses({
    String? status,
    String? category,
  }) async {
    try {
      var url = '$baseUrl/live_courses';
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(timeout);

      final jsonResponse = jsonDecode(response.body);
      return ApiResponse<List<LiveCourse>>(
        success: jsonResponse['success'] ?? false,
        data: jsonResponse['data'] != null
            ? (jsonResponse['data'] as List)
                .map((item) => LiveCourse.fromJson(item))
                .toList()
            : null,
        error: jsonResponse['error'],
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResponse<List<LiveCourse>>(
        success: false,
        error: 'Failed to fetch courses',
        message: e.toString(),
      );
    }
  }

  // Get course by ID
  static Future<ApiResponse<LiveCourse>> getCourseById(String courseId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/live_courses/$courseId'),
            headers: _headers,
          )
          .timeout(timeout);

      final jsonResponse = jsonDecode(response.body);
      return ApiResponse<LiveCourse>(
        success: jsonResponse['success'] ?? false,
        data: jsonResponse['data'] != null
            ? LiveCourse.fromJson(jsonResponse['data'])
            : null,
        error: jsonResponse['error'],
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResponse<LiveCourse>(
        success: false,
        error: 'Failed to fetch course',
        message: e.toString(),
      );
    }
  }

  // Start a course (creates meeting room)
  static Future<ApiResponse<LiveCourse>> startCourse(
    String courseId, {
    required String instructorId,
    String? instructorName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/live_courses/$courseId/start'),
            headers: _headers,
            body: jsonEncode({
              'instructorId': instructorId,
              'instructorName': instructorName,
            }),
          )
          .timeout(timeout);

      final jsonResponse = jsonDecode(response.body);
      return ApiResponse<LiveCourse>(
        success: jsonResponse['success'] ?? false,
        data: jsonResponse['data'] != null
            ? LiveCourse.fromJson(jsonResponse['data'])
            : null,
        error: jsonResponse['error'],
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResponse<LiveCourse>(
        success: false,
        error: 'Failed to start course',
        message: e.toString(),
      );
    }
  }

  // Join a course
  static Future<ApiResponse<Map<String, dynamic>>> joinCourse({
    required String meetingCode,
    required String participantName,
    String? userId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/live_courses/join'),
            headers: _headers,
            body: jsonEncode({
              'meetingCode': meetingCode,
              'participantName': participantName,
              'userId': userId,
            }),
          )
          .timeout(timeout);

      final jsonResponse = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: jsonResponse['success'] ?? false,
        data: jsonResponse['data'] != null
            ? {
                'participant': Participant.fromJson(jsonResponse['data']['participant']),
                'course': LiveCourse.fromJson(jsonResponse['data']['course']),
              }
            : null,
        error: jsonResponse['error'],
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'Failed to join course',
        message: e.toString(),
      );
    }
  }

  // Leave a course
  static Future<ApiResponse<dynamic>> leaveCourse({
    required String courseId,
    required String participantId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/live_courses/$courseId/leave'),
            headers: _headers,
            body: jsonEncode({
              'participantId': participantId,
            }),
          )
          .timeout(timeout);

      final jsonResponse = jsonDecode(response.body);
      return ApiResponse<dynamic>(
        success: jsonResponse['success'] ?? false,
        data: jsonResponse['data'],
        error: jsonResponse['error'],
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        error: 'Failed to leave course',
        message: e.toString(),
      );
    }
  }

  // Complete a course
  static Future<ApiResponse<LiveCourse>> completeCourse(String courseId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/live_courses/$courseId/complete'),
            headers: _headers,
          )
          .timeout(timeout);

      final jsonResponse = jsonDecode(response.body);
      return ApiResponse<LiveCourse>(
        success: jsonResponse['success'] ?? false,
        data: jsonResponse['data'] != null
            ? LiveCourse.fromJson(jsonResponse['data'])
            : null,
        error: jsonResponse['error'],
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResponse<LiveCourse>(
        success: false,
        error: 'Failed to complete course',
        message: e.toString(),
      );
    }
  }

  // Health check
  static Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://krishnabarasiya.space/health'),
            headers: _headers,
          )
          .timeout(timeout);

      final jsonResponse = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        data: jsonResponse,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        error: 'Backend server is not available',
        message: e.toString(),
      );
    }
  }
}
