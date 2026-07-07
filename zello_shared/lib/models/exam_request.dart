class ExamRequest {
  final String id;
  final String patientId;
  final String professionalId;
  final String? availabilitySlotId;
  final String examType;
  final String notes;
  final String status;
  final String? refusedReason;
  final DateTime? confirmedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExamRequest({
    required this.id,
    required this.patientId,
    required this.professionalId,
    this.availabilitySlotId,
    required this.examType,
    this.notes = '',
    this.status = 'solicitado',
    this.refusedReason,
    this.confirmedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ExamRequest.fromJson(Map<String, dynamic> json) {
    return ExamRequest(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      professionalId: json['professional_id'] as String? ?? '',
      availabilitySlotId: json['availability_slot_id'] as String?,
      examType: json['exam_type'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String? ?? 'solicitado',
      refusedReason: json['refused_reason'] as String?,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.tryParse(json['confirmed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'professional_id': professionalId,
      'availability_slot_id': availabilitySlotId,
      'exam_type': examType,
      'notes': notes,
      'status': status,
      'refused_reason': refusedReason,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ExamRequest copyWith({
    String? id,
    String? patientId,
    String? professionalId,
    String? availabilitySlotId,
    String? examType,
    String? notes,
    String? status,
    String? refusedReason,
    DateTime? confirmedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamRequest(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      professionalId: professionalId ?? this.professionalId,
      availabilitySlotId: availabilitySlotId ?? this.availabilitySlotId,
      examType: examType ?? this.examType,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      refusedReason: refusedReason ?? this.refusedReason,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isSolicitado => status == 'solicitado';
  bool get isConfirmado => status == 'confirmado';
  bool get isRecusado => status == 'recusado';
  bool get isConcluido => status == 'concluido';
  bool get isCancelado => status == 'cancelado';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExamRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ExamRequest(id: $id, type: $examType, status: $status)';
}
