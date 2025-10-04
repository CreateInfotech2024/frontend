import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class ApiTesterScreen extends StatefulWidget {
  const ApiTesterScreen({super.key});

  @override
  State<ApiTesterScreen> createState() => _ApiTesterScreenState();
}

class TestResult {
  final String test;
  final bool success;
  final dynamic data;
  final String? error;
  final String timestamp;

  TestResult({
    required this.test,
    required this.success,
    this.data,
    this.error,
    required this.timestamp,
  });
}

class _ApiTesterScreenState extends State<ApiTesterScreen> {
  final List<TestResult> _testResults = [];
  bool _testing = false;

  void _addResult(String test, bool success, {dynamic data, String? error}) {
    setState(() {
      _testResults.add(TestResult(
        test: test,
        success: success,
        data: data,
        error: error,
        timestamp: DateTime.now().toIso8601String(),
      ));
    });
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _testing = true;
    });
    _clearResults();

    // Test 1: Health Check
    try {
      final healthResponse = await ApiService.healthCheck();
      _addResult('Health Check', healthResponse.success,
          data: healthResponse.data, error: healthResponse.error);
    } catch (e) {
      _addResult('Health Check', false, error: e.toString());
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Test 2: Get All Live Courses
    try {
      final coursesResponse = await ApiService.getAllCourses();
      _addResult('Get All Live Courses', coursesResponse.success,
          data: coursesResponse.data, error: coursesResponse.error);
    } catch (e) {
      _addResult('Get All Live Courses', false, error: e.toString());
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Test 3: Get Specific Live Course
    try {
      final courseResponse = await ApiService.getCourseById('test123');
      _addResult('Get Live Course by ID', courseResponse.success,
          data: courseResponse.data, error: courseResponse.error);
    } catch (e) {
      _addResult('Get Live Course by ID', false, error: e.toString());
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Test 4: Start Live Course (creates meeting room)
    String testCourseId = 'test789';
    String meetingCode = '';
    try {
      final startResponse = await ApiService.startCourse(
        testCourseId,
        instructorId: 'test_instructor_123',
        instructorName: 'API Test Instructor',
      );
      
      if (startResponse.success && startResponse.data != null) {
        meetingCode = startResponse.data!.meetingCode ?? '';
      }
      
      _addResult('Start Live Course', startResponse.success,
          data: startResponse.data, error: startResponse.error);
    } catch (e) {
      _addResult('Start Live Course', false, error: e.toString());
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Test 5: Socket.IO Connection (if meeting code is available)
    if (meetingCode.isNotEmpty) {
      try {
        final socketService = SocketService();
        socketService.connect();
        
        await Future.delayed(const Duration(seconds: 2));
        
        if (socketService.isConnected) {
          socketService.joinMeetingRoom(
            meetingCode,
            'API Test User',
            participantId: 'test_participant_123',
          );
          
          _addResult('Socket.IO Connection', true,
              data: {'meetingCode': meetingCode, 'status': 'Connected'});
        } else {
          _addResult('Socket.IO Connection', false,
              error: 'Failed to connect to Socket.IO server');
        }
      } catch (e) {
        _addResult('Socket.IO Connection', false, error: e.toString());
      }
    }

    setState(() {
      _testing = false;
    });
  }

  int get _passedTests => _testResults.where((r) => r.success).length;
  int get _failedTests => _testResults.where((r) => !r.success).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Testing'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '🧪 Beauty LMS API Tester',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Test backend APIs and Socket.IO connections',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testing ? null : _runAllTests,
                        icon: _testing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(_testing ? 'Running Tests...' : '🚀 Run All Tests'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _testResults.isEmpty ? null : _clearResults,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_testResults.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Total', _testResults.length, Colors.blue),
                        _buildStat('Passed', _passedTests, Colors.green),
                        _buildStat('Failed', _failedTests, Colors.red),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _testResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No test results yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click "Run All Tests" to start testing',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      final result = _testResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: Icon(
                            result.success ? Icons.check_circle : Icons.error,
                            color: result.success ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            result.test,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            result.success ? 'Success' : 'Failed',
                            style: TextStyle(
                              color: result.success ? Colors.green : Colors.red,
                            ),
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey.shade50,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (result.error != null) ...[
                                    const Text(
                                      'Error:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      result.error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (result.data != null) ...[
                                    const Text(
                                      'Response Data:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      result.data.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
