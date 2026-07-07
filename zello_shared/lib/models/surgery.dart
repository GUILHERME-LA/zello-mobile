class Surgery {
  final String id;
  final String patientId;
  final String name;
  final DateTime date;
  final String hospital;
  final String doctor;
  final String notes;

  const Surgery({
    required this.id,
    required this.patientId,
    this.name = '',
    required this.date,
    this.hospital = '',
    this.doctor = '',
    this.notes = '',
  });

  factory Surgery.fromJson(Map<String, dynamic> json) {
    return Surgery(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      hospital: json['hospital'] as String? ?? '',
      doctor: json['doctor'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'name': name,
        'date': date.toIso8601String().split('T')[0],
        'hospital': hospital,
        'doctor': doctor,
        'notes': notes,
      };
}
