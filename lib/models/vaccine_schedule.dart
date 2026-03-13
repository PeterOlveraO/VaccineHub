// vaccine_schedule.dart

class VaccineSchedule {
  final int? id;
  final int vaccineId;
  final int doseNumber;
  final int daysToNextDose;

  VaccineSchedule({
    this.id,
    required this.vaccineId,
    required this.doseNumber,
    required this.daysToNextDose,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vaccine_id': vaccineId,
      'dose_number': doseNumber,
      'days_to_next_dose': daysToNextDose,
    };
  }

  factory VaccineSchedule.fromMap(Map<String, dynamic> map) {
    return VaccineSchedule(
      id: map['id'] as int?,
      vaccineId: map['vaccine_id'] as int,
      doseNumber: map['dose_number'] as int,
      daysToNextDose: map['days_to_next_dose'] as int,
    );
  }
}
