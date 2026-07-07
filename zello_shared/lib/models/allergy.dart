class Allergy {
  final String id;
  final String patientId;
  final String name;
  final String type;
  final String reaction;
  final String notes;

  const Allergy({
    required this.id,
    required this.patientId,
    this.name = '',
    this.type = '',
    this.reaction = '',
    this.notes = '',
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      reaction: json['reaction'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'name': name,
        'type': type,
        'reaction': reaction,
        'notes': notes,
      };
}
