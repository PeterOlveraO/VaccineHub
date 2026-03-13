import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/vaccine.dart';

class VaccineRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Vaccine>> getAllVaccines() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vaccines',
      orderBy: 'name ASC',
    );
    return maps.map((map) => Vaccine.fromMap(map)).toList();
  }

  Future<int> insertVaccine(Vaccine vaccine) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'vaccines',
      vaccine.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
