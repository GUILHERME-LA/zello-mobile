class Symptom {
  final String id;
  final String patientId;
  final String name;
  final String frequency;
  final String intensity;
  final String notes;
  final DateTime? createdAt;

  const Symptom({
    required this.id,
    required this.patientId,
    this.name = '',
    this.frequency = '',
    this.intensity = '',
    this.notes = '',
    this.createdAt,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      intensity: json['intensity'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'name': name,
        'frequency': frequency,
        'intensity': intensity,
        'notes': notes,
        'created_at': createdAt?.toIso8601String(),
      };
}
