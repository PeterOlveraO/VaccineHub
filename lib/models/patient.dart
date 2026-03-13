// patient.dart

class Patient {
  final int? id;
  final String fullName;
  final String? phone;
  final String registrationDate;

  Patient({
    this.id,
    required this.fullName,
    this.phone,
    required this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'registration_date': registrationDate,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String?,
      registrationDate: map['registration_date'] as String,
    );
  }
}
