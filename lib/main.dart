import 'package:flutter/material.dart';
import 'models/patient.dart';
import 'models/vaccine.dart';
import 'models/vaccine_schedule.dart';
import 'models/appointment.dart';
import 'repositories/patient_repository.dart';
import 'repositories/vaccine_repository.dart';
import 'repositories/vaccine_schedule_repository.dart';
import 'repositories/appointment_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaccineHub BD Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Prueba de BD')),
        body: Center(
          child: ElevatedButton(
            onPressed: _runDatabaseTest,
            child: const Text('Ejecutar Prueba de BD'),
          ),
        ),
      ),
    );
  }
}

Future<void> _runDatabaseTest() async {
  print('--- INICIANDO PRUEBA DE BD ---');

  final patientRepo = PatientRepository();
  final vaccineRepo = VaccineRepository();
  final scheduleRepo = VaccineScheduleRepository();
  final appointmentRepo = AppointmentRepository();

  final today = DateTime.now();
  final todayStr = today.toIso8601String().split('T')[0];

  // Paso 1: Insertar Vacuna
  final vaccine = Vaccine(name: 'VPH', totalDoses: 3);
  final vaccineId = await vaccineRepo.insertVaccine(vaccine);
  print('Vacuna insertada con ID: $vaccineId');

  // Paso 2: Insertar esquemas de dosis
  final schedule1 = VaccineSchedule(
    vaccineId: vaccineId,
    doseNumber: 1,
    daysToNextDose: 30,
  );
  await scheduleRepo.insertSchedule(schedule1);

  final schedule2 = VaccineSchedule(
    vaccineId: vaccineId,
    doseNumber: 2,
    daysToNextDose: 60,
  );
  await scheduleRepo.insertSchedule(schedule2);

  // Paso 3: Insertar Paciente
  final patient = Patient(
    fullName: 'María López',
    phone: '555-1234',
    registrationDate: todayStr,
  );
  final patientId = await patientRepo.insertPatient(patient);
  print('Paciente insertado con ID: $patientId');

  // Paso 4: Insertar Cita
  final appointment = Appointment(
    patientId: patientId,
    vaccineId: vaccineId,
    doseNumber: 1,
    batchGroup: 'Lote-Prueba',
    status: 'scheduled',
    isPaid: false,
    createdAt: todayStr,
  );
  final appointmentId = await appointmentRepo.insertAppointment(appointment);
  print('Cita inicial creada con ID: $appointmentId');

  // Paso 5: Completar cita
  await appointmentRepo.completeAppointment(appointmentId, todayStr);

  // Paso 6: Buscar nueva cita por mes
  final nextMonth = DateTime.now().add(const Duration(days: 30));
  final monthNumber = nextMonth.month.toString().padLeft(2, '0');
  final pendingAppointments = await appointmentRepo.getPendingAppointmentsByMonth(monthNumber);

  if (pendingAppointments.isNotEmpty) {
    final newAppointment = pendingAppointments.first;
    print('--- NUEVA CITA GENERADA ---');
    print('Patient ID: ${newAppointment.patientId}');
    print('Vaccine ID: ${newAppointment.vaccineId}');
    print('Dosis: ${newAppointment.doseNumber}');
    print('Status: ${newAppointment.status}');
    print('Next Dose Date: ${newAppointment.nextDoseDate}');
  }

  print('--- PRUEBA FINALIZADA ---');
}
