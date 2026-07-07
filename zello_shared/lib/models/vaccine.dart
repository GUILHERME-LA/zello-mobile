class Vaccine {
  final String id;
  final String patientId;
  final String name;
  final DateTime date;
  final String dose;
  final String location;
  final String notes;
  final bool isPending;

  const Vaccine({
    required this.id,
    required this.patientId,
    this.name = '',
    required this.date,
    this.dose = '',
    this.location = '',
    this.notes = '',
    this.isPending = false,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      dose: json['dose'] as String? ?? '',
      location: json['location'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isPending: json['is_pending'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'name': name,
        'date': date.toIso8601String().split('T')[0],
        'dose': dose,
        'location': location,
        'notes': notes,
        'is_pending': isPending,
      };
}
