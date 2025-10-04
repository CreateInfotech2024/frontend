import 'package:flutter/material.dart';
import '../widgets/course_creator.dart';
import '../widgets/meeting_joiner.dart';
import '../models/live_course.dart';
import '../models/participant.dart';
import 'meeting_room_screen.dart';
import 'live_courses_screen.dart';
import 'api_tester_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _errorMessage = '';

  void _showError(String error) {
    setState(() {
      _errorMessage = error;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }

  void _handleCourseCreated(LiveCourse course, Participant participant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingRoomScreen(
          course: course,
          currentParticipant: participant,
        ),
      ),
    );
  }

  void _handleMeetingJoined(LiveCourse course, Participant participant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingRoomScreen(
          course: course,
          currentParticipant: participant,
        ),
      ),
    );
  }

  void _goToLiveCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveCoursesScreen(),
      ),
    );
  }

  void _goToTesting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ApiTesterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎥 Beauty LMS - Video Conferencing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library),
            tooltip: 'Live Courses',
            onPressed: _goToLiveCourses,
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'API Testing',
            onPressed: _goToTesting,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text(
                                'Welcome to Beauty LMS Video Conferencing',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Create or join meetings to test video conferencing, chat, and participant features.',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CourseCreator(
                        onCourseCreated: _handleCourseCreated,
                        onError: _showError,
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: TextStyle(color: Colors.white70)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MeetingJoiner(
                        onMeetingJoined: _handleMeetingJoined,
                        onError: _showError,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Beauty LMS © 2024 | Backend running on krishnabarasiya.space',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
