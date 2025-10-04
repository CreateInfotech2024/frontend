import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/live_course.dart';
import '../models/participant.dart';

class CourseCreator extends StatefulWidget {
  final Function(LiveCourse course, Participant participant) onCourseCreated;
  final Function(String error) onError;

  const CourseCreator({
    super.key,
    required this.onCourseCreated,
    required this.onError,
  });

  @override
  State<CourseCreator> createState() => _CourseCreatorState();
}

class _CourseCreatorState extends State<CourseCreator> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Test Course');
  final _descriptionController = TextEditingController(text: 'Testing Beauty LMS');
  final _instructorNameController = TextEditingController(text: 'Test Instructor');
  final _categoryController = TextEditingController(text: 'Testing');
  final _durationController = TextEditingController(text: '60');
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructorNameController.dispose();
    _categoryController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      // First create the course
      final createResponse = await ApiService.createCourse(
        name: _nameController.text,
        description: _descriptionController.text,
        instructorId: 'test_instructor_${DateTime.now().millisecondsSinceEpoch}',
        instructorName: _instructorNameController.text,
        category: _categoryController.text,
        duration: int.tryParse(_durationController.text) ?? 60,
        recordingEnabled: true,
        enrolledUsers: [],
      );

      if (!createResponse.success || createResponse.data == null) {
        widget.onError(createResponse.error ?? 'Failed to create course');
        return;
      }

      final course = createResponse.data!;

      // Then start the course (this creates the meeting room)
      final startResponse = await ApiService.startCourse(
        course.id,
        instructorId: course.instructorId,
        instructorName: _instructorNameController.text,
      );

      if (!startResponse.success || startResponse.data == null) {
        widget.onError(startResponse.error ?? 'Failed to start course');
        return;
      }

      final startedCourse = startResponse.data!;

      // Create participant object for the host
      final participant = Participant(
        id: course.instructorId,
        name: _instructorNameController.text,
        joinedAt: DateTime.now().toIso8601String(),
        isHost: true,
      );

      widget.onCourseCreated(startedCourse, participant);
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
                '🚀 Create New Course',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course name';
                  }
                  return null;
                },
                enabled: !_loading,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
                enabled: !_loading,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructorNameController,
                decoration: const InputDecoration(
                  labelText: 'Instructor Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter instructor name';
                  }
                  return null;
                },
                enabled: !_loading,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      enabled: !_loading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !_loading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
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
                        '🎥 Create & Start Course',
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
