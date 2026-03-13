import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/vaccine_schedule.dart';

class VaccineScheduleRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<VaccineSchedule>> getSchedulesForVaccine(int vaccineId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vaccine_schedules',
      where: 'vaccine_id = ?',
      whereArgs: [vaccineId],
      orderBy: 'dose_number ASC',
    );
    return maps.map((map) => VaccineSchedule.fromMap(map)).toList();
  }

  Future<int> insertSchedule(VaccineSchedule schedule) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'vaccine_schedules',
      schedule.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
