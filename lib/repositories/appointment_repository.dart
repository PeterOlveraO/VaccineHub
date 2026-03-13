import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertAppointment(Appointment appointment) async {
    final db = await _databaseHelper.database;

    // Verificar límite de batch group
    if (appointment.batchGroup != null && appointment.batchGroup!.isNotEmpty) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM appointments WHERE batch_group = ?',
        [appointment.batchGroup],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      if (count >= 10) {
        throw Exception('Batch group is full (10/10)');
      }
    }

    return await db.insert(
      'appointments',
      appointment.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Appointment>> getPendingAppointmentsByMonth(
    String monthNumber,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: "status = 'scheduled' AND strftime('%m', next_dose_date) = ?",
      whereArgs: [monthNumber],
      orderBy: 'next_dose_date ASC',
    );
    return maps.map((map) => Appointment.fromMap(map)).toList();
  }

  Future<void> completeAppointment(
    int appointmentId,
    String applicationDate,
  ) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // Paso A: Actualizar cita actual
      await txn.update(
        'appointments',
        {
          'status': 'completed',
          'application_date': applicationDate,
          'is_paid': 1,
        },
        where: 'id = ?',
        whereArgs: [appointmentId],
      );

      // Paso B: Obtener vaccine_id y dose_number
      final result = await txn.query(
        'appointments',
        where: 'id = ?',
        whereArgs: [appointmentId],
      );

      if (result.isEmpty) return;

      final appointment = Appointment.fromMap(result.first);
      final patientId = appointment.patientId;
      final vaccineId = appointment.vaccineId;
      final currentDoseNumber = appointment.doseNumber;

      // Paso C: Buscar días para siguiente dosis
      final scheduleResult = await txn.query(
        'vaccine_schedules',
        columns: ['days_to_next_dose'],
        where: 'vaccine_id = ? AND dose_number = ?',
        whereArgs: [vaccineId, currentDoseNumber],
      );

      if (scheduleResult.isEmpty) return;

      final daysToNextDose = scheduleResult.first['days_to_next_dose'] as int;

      // Paso D: Crear siguiente cita si hay días definidos
      if (daysToNextDose > 0) {
        final parsedDate = DateTime.parse(applicationDate);
        final nextDoseDate = parsedDate.add(Duration(days: daysToNextDose));
        final nextDoseDateStr = nextDoseDate.toIso8601String().split('T')[0];
        final createdAt = DateTime.now().toIso8601String().split('T')[0];

        await txn.insert('appointments', {
          'patient_id': patientId,
          'vaccine_id': vaccineId,
          'dose_number': currentDoseNumber + 1,
          'status': 'scheduled',
          'is_paid': 0,
          'next_dose_date': nextDoseDateStr,
          'created_at': createdAt,
        });
      }
    });
  }
}
