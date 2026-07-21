class MedicationDose {
  final String id;
  final String medicationId;
  final String patientId;
  final DateTime takenAt;
  final String dosage;
  final String notes;

  const MedicationDose({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.takenAt,
    this.dosage = '',
    this.notes = '',
  });

  factory MedicationDose.fromJson(Map<String, dynamic> json) {
    return MedicationDose(
      id: json['id'] as String? ?? '',
      medicationId: json['medicationId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      takenAt: DateTime.tryParse(json['takenAt'] as String? ?? '') ?? DateTime.now(),
      dosage: json['dosage'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'patientId': patientId,
      'takenAt': takenAt.toIso8601String(),
      'dosage': dosage,
      'notes': notes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MedicationDose && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MedicationDose(id: $id, medicationId: $medicationId, takenAt: $takenAt)';
}
