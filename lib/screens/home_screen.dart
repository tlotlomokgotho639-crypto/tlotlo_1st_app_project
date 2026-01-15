import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseHelper _dbHelper;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadData();
  }

  Future<void> _loadData() async {
    final courses = await _dbHelper.getCourses();
    final assignments = await _dbHelper.getAssignments();
    
    setState(() {
      _courses = courses;
      _assignments = assignments;
    });
  }

  Future<void> _addSampleData() async {
    // Add a sample course
    await _dbHelper.insertCourse({
      'name': 'Computer Science 101',
      'code': 'CS101',
      'professor': 'Dr. Smith',
    });
    
    // Add a sample assignment
    await _dbHelper.insertAssignment({
      'course_id': 1,
      'title': 'Final Project',
      'description': 'Build a Flutter app',
      'due_date': '2024-12-15',
      'priority': 4,
      'is_completed': 0,
    });
    
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSampleData,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.school, size: 50, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      'Study Planner Pro',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_courses.length} courses • ${_assignments.length} assignments',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Courses Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'My Courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          if (_courses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No courses yet. Tap the + button to add sample data.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._courses.map((course) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.school, color: Colors.blue),
                title: Text(course['name'] ?? 'No Name'),
                subtitle: Text(course['code'] ?? 'No Code'),
                trailing: Text(course['professor'] ?? 'No Professor'),
              ),
            )),
          
          // Assignments Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Assignments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          if (_assignments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No assignments yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._assignments.map((assignment) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: assignment['is_completed'] == 1,
                  onChanged: null,
                ),
                title: Text(assignment['title'] ?? 'No Title'),
                subtitle: Text('Due: ${assignment['due_date'] ?? 'No date'}'),
                trailing: Chip(
                  label: Text('P${assignment['priority'] ?? 3}'),
                  backgroundColor: Colors.orange[100],
                ),
              ),
            )),
        ],
      ),
    );
  }
}