class Referral {
  final String id;
  final String patientId;
  final String fromProfessionalId;
  final String toSpecialty;
  final String reason;
  final String status;
  final DateTime? createdAt;

  const Referral({
    required this.id,
    required this.patientId,
    required this.fromProfessionalId,
    this.toSpecialty = '',
    this.reason = '',
    this.status = 'ativo',
    this.createdAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      fromProfessionalId: json['from_professional_id'] as String? ?? '',
      toSpecialty: json['to_specialty'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'ativo',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'from_professional_id': fromProfessionalId,
        'to_specialty': toSpecialty,
        'reason': reason,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}
