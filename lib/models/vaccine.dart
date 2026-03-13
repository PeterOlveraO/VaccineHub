// vaccine.dart

class Vaccine {
  final int? id;
  final String name;
  final int totalDoses;

  Vaccine({
    this.id,
    required this.name,
    required this.totalDoses,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'total_doses': totalDoses,
    };
  }

  factory Vaccine.fromMap(Map<String, dynamic> map) {
    return Vaccine(
      id: map['id'] as int?,
      name: map['name'] as String,
      totalDoses: map['total_doses'] as int,
    );
  }
}
