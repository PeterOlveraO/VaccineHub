import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/patient.dart';

class PatientRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertPatient(Patient patient) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'patients',
      patient.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      orderBy: 'full_name ASC',
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  Future<List<Patient>> searchPatients(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'full_name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'full_name ASC',
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  Future<int> deletePatient(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
