class SessionNote {
  final String id;
  final String patientId;
  final String professionalId;
  final DateTime date;
  final String content;
  final String mood;
  final String status;
  final DateTime? createdAt;

  const SessionNote({
    required this.id,
    required this.patientId,
    required this.professionalId,
    required this.date,
    this.content = '',
    this.mood = '',
    this.status = 'realizada',
    this.createdAt,
  });

  factory SessionNote.fromJson(Map<String, dynamic> json) {
    return SessionNote(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      professionalId: json['professional_id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      content: json['content'] as String? ?? '',
      mood: json['mood'] as String? ?? '',
      status: json['status'] as String? ?? 'realizada',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'professional_id': professionalId,
        'date': date.toIso8601String().split('T')[0],
        'content': content,
        'mood': mood,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}
