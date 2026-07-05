import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'eventkuy.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        category TEXT,
        date TEXT,
        quota TEXT,
        isOnline INTEGER,
        locationOrLink TEXT,
        price REAL,
        speaker TEXT,
        benefits TEXT
      )
    ''');
  }

  Future<int> insertEvent(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('events', row);
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    Database db = await database;
    return await db.query('events', orderBy: 'id DESC');
  }

  Future<int> updateEvent(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update(
      'events',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
