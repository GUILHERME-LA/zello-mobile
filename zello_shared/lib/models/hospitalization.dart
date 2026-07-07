class Hospitalization {
  final String id;
  final String patientId;
  final String reason;
  final String hospital;
  final DateTime startDate;
  final DateTime? endDate;
  final String notes;

  const Hospitalization({
    required this.id,
    required this.patientId,
    this.reason = '',
    this.hospital = '',
    required this.startDate,
    this.endDate,
    this.notes = '',
  });

  factory Hospitalization.fromJson(Map<String, dynamic> json) {
    return Hospitalization(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      hospital: json['hospital'] as String? ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'reason': reason,
        'hospital': hospital,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate?.toIso8601String().split('T')[0],
        'notes': notes,
      };

  int get durationDays =>
      endDate != null ? endDate!.difference(startDate).inDays : 0;
}
