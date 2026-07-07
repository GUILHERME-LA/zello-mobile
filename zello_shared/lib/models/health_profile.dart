class HealthProfile {
  final String id;
  final String patientId;
  final double weight;
  final double height;
  final String bloodType;
  final String medicalConditions;
  final String familyHistory;
  final String chronicConditions;
  final String medications;
  final DateTime? updatedAt;

  const HealthProfile({
    required this.id,
    required this.patientId,
    this.weight = 0,
    this.height = 0,
    this.bloodType = '',
    this.medicalConditions = '',
    this.familyHistory = '',
    this.chronicConditions = '',
    this.medications = '',
    this.updatedAt,
  });

  double get imc {
    if (height <= 0 || weight <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  String get imcCategory {
    final i = imc;
    if (i <= 0) return '';
    if (i < 18.5) return 'Abaixo do peso';
    if (i < 25) return 'Peso normal';
    if (i < 30) return 'Sobrepeso';
    if (i < 35) return 'Obesidade grau I';
    if (i < 40) return 'Obesidade grau II';
    return 'Obesidade grau III';
  }

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      bloodType: json['blood_type'] as String? ?? '',
      medicalConditions: json['medical_conditions'] as String? ?? '',
      familyHistory: json['family_history'] as String? ?? '',
      chronicConditions: json['chronic_conditions'] as String? ?? '',
      medications: json['medications'] as String? ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'weight': weight,
        'height': height,
        'blood_type': bloodType,
        'medical_conditions': medicalConditions,
        'family_history': familyHistory,
        'chronic_conditions': chronicConditions,
        'medications': medications,
        'updated_at': updatedAt?.toIso8601String(),
      };
}
