import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  
  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize database
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'study_planner.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        code TEXT,
        professor TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE assignments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER,
        title TEXT,
        description TEXT,
        due_date TEXT,
        priority INTEGER,
        is_completed INTEGER
      )
    ''');
  }
  
  // Simple CRUD operations
  Future<int> insertCourse(Map<String, dynamic> course) async {
    final db = await database;
    return await db.insert('courses', course);
  }
  
  Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await database;
    return await db.query('courses');
  }
  
  Future<int> insertAssignment(Map<String, dynamic> assignment) async {
    final db = await database;
    return await db.insert('assignments', assignment);
  }
  
  Future<List<Map<String, dynamic>>> getAssignments() async {
    final db = await database;
    return await db.query('assignments');
  }
}