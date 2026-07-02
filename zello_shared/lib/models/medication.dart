class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String prescribingDoctor;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime? nextDose;

  const Medication({
    required this.id,
    required this.name,
    this.dosage = '',
    this.frequency = '',
    this.prescribingDoctor = '',
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.nextDose,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      prescribingDoctor: json['prescribingDoctor'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      nextDose: json['nextDose'] != null
          ? DateTime.tryParse(json['nextDose'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'prescribingDoctor': prescribingDoctor,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'nextDose': nextDose?.toIso8601String(),
    };
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? prescribingDoctor,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? nextDose,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      prescribingDoctor: prescribingDoctor ?? this.prescribingDoctor,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      nextDose: nextDose ?? this.nextDose,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Medication(id: $id, name: $name, dosage: $dosage, active: $isActive)';
}
