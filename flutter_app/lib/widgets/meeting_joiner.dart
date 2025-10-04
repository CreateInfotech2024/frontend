import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/live_course.dart';
import '../models/participant.dart';

class MeetingJoiner extends StatefulWidget {
  final Function(LiveCourse course, Participant participant) onMeetingJoined;
  final Function(String error) onError;

  const MeetingJoiner({
    super.key,
    required this.onMeetingJoined,
    required this.onError,
  });

  @override
  State<MeetingJoiner> createState() => _MeetingJoinerState();
}

class _MeetingJoinerState extends State<MeetingJoiner> {
  final _formKey = GlobalKey<FormState>();
  final _meetingCodeController = TextEditingController();
  final _nameController = TextEditingController(text: 'Test Participant');
  bool _loading = false;

  @override
  void dispose() {
    _meetingCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      final response = await ApiService.joinCourse(
        meetingCode: _meetingCodeController.text,
        participantName: _nameController.text,
      );

      if (!response.success || response.data == null) {
        widget.onError(response.error ?? 'Failed to join meeting');
        return;
      }

      final participant = response.data!['participant'] as Participant;
      final course = response.data!['course'] as LiveCourse;

      widget.onMeetingJoined(course, participant);
    } catch (e) {
      widget.onError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🎯 Join Existing Meeting',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _meetingCodeController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Code',
                  hintText: 'Enter 6-digit meeting code',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter meeting code';
                  }
                  if (value.length != 6) {
                    return 'Meeting code must be 6 digits';
                  }
                  return null;
                },
                enabled: !_loading,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                enabled: !_loading,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '🚀 Join Meeting',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
