import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/course.dart';
import '../models/assignment.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();
  
  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'study_planner.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create courses table
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        professor TEXT,
        color TEXT,
        credits REAL
      )
    ''');

    // Create assignments table
    await db.execute('''
      CREATE TABLE assignments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT NOT NULL,
        priority INTEGER DEFAULT 3,
        is_completed INTEGER DEFAULT 0
      )
    ''');
  }

  // ========== COURSE OPERATIONS ==========
  Future<int> insertCourse(Course course) async {
    final db = await database;
    return await db.insert('courses', course.toMap());
  }

  Future<List<Course>> getCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  Future<int> updateCourse(Course course) async {
    final db = await database;
    return await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await database;
    return await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== ASSIGNMENT OPERATIONS ==========
  Future<int> insertAssignment(Assignment assignment) async {
    final db = await database;
    return await db.insert('assignments', assignment.toMap());
  }

  Future<List<Assignment>> getAssignments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('assignments');
    return maps.map((map) => Assignment.fromMap(map)).toList();
  }

  Future<List<Assignment>> getAssignmentsByCourse(int courseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assignments',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
    return maps.map((map) => Assignment.fromMap(map)).toList();
  }

  Future<List<Assignment>> getUpcomingAssignments() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'assignments',
      where: 'due_date >= ? AND is_completed = 0',
      whereArgs: [now],
      orderBy: 'due_date ASC',
    );
    return maps.map((map) => Assignment.fromMap(map)).toList();
  }

  Future<int> updateAssignment(Assignment assignment) async {
    final db = await database;
    return await db.update(
      'assignments',
      assignment.toMap(),
      where: 'id = ?',
      whereArgs: [assignment.id],
    );
  }

  Future<int> deleteAssignment(int id) async {
    final db = await database;
    return await db.delete(
      'assignments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== HELPER METHODS ==========
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}