class Exam {
  final String id;
  final String patientId;
  final String title;
  final String examType;
  final String status;
  final String? resultUrl;
  final String? requestedBy;
  final DateTime? requestedAt;
  final String? notes;

  const Exam({
    required this.id,
    required this.patientId,
    required this.title,
    this.examType = '',
    this.status = 'solicitado',
    this.resultUrl,
    this.requestedBy,
    this.requestedAt,
    this.notes,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      examType: json['exam_type'] as String? ?? '',
      status: json['status'] as String? ?? 'solicitado',
      resultUrl: json['result_url'] as String?,
      requestedBy: json['requested_by'] as String?,
      requestedAt: json['requested_at'] != null
          ? DateTime.tryParse(json['requested_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'title': title,
      'exam_type': examType,
      'status': status,
      'result_url': resultUrl,
      'requested_by': requestedBy,
      'requested_at': requestedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  Exam copyWith({
    String? id,
    String? patientId,
    String? title,
    String? examType,
    String? status,
    String? resultUrl,
    String? requestedBy,
    DateTime? requestedAt,
    String? notes,
  }) {
    return Exam(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      title: title ?? this.title,
      examType: examType ?? this.examType,
      status: status ?? this.status,
      resultUrl: resultUrl ?? this.resultUrl,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      notes: notes ?? this.notes,
    );
  }

  static const List<String> statuses = [
    'solicitado',
    'confirmado',
    'recusado',
    'concluido',
    'cancelado',
  ];

  static const Map<String, String> statusLabels = {
    'solicitado': 'Solicitado',
    'confirmado': 'Confirmado',
    'recusado': 'Recusado',
    'concluido': 'Concluído',
    'cancelado': 'Cancelado',
  };

  String get statusLabel => statusLabels[status] ?? status;
}
