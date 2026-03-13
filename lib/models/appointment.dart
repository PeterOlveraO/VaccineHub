// appointment.dart

class Appointment {
  final int? id;
  final int patientId;
  final int vaccineId;
  final int doseNumber;
  final String? batchGroup;
  final String status;
  final bool isPaid;
  final String? applicationDate;
  final String? nextDoseDate;
  final String createdAt;

  Appointment({
    this.id,
    required this.patientId,
    required this.vaccineId,
    required this.doseNumber,
    this.batchGroup,
    required this.status,
    required this.isPaid,
    this.applicationDate,
    this.nextDoseDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'vaccine_id': vaccineId,
      'dose_number': doseNumber,
      'batch_group': batchGroup,
      'status': status,
      'is_paid': isPaid ? 1 : 0,
      'application_date': applicationDate,
      'next_dose_date': nextDoseDate,
      'created_at': createdAt,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      vaccineId: map['vaccine_id'] as int,
      doseNumber: map['dose_number'] as int,
      batchGroup: map['batch_group'] as String?,
      status: map['status'] as String,
      isPaid: (map['is_paid'] as int) == 1,
      applicationDate: map['application_date'] as String?,
      nextDoseDate: map['next_dose_date'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
