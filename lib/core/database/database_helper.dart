import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vaccine_hub.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        phone TEXT NULL,
        registration_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vaccines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        total_doses INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vaccine_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vaccine_id INTEGER NOT NULL,
        dose_number INTEGER NOT NULL,
        days_to_next_dose INTEGER NOT NULL,
        FOREIGN KEY (vaccine_id) REFERENCES vaccines (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        vaccine_id INTEGER NOT NULL,
        dose_number INTEGER NOT NULL,
        batch_group TEXT NULL,
        status TEXT NOT NULL,
        is_paid INTEGER NOT NULL DEFAULT 0,
        application_date TEXT NULL,
        next_dose_date TEXT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE,
        FOREIGN KEY (vaccine_id) REFERENCES vaccines (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
