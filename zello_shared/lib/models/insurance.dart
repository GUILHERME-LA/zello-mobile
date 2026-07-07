class Insurance {
  final String id;
  final String patientId;
  final String provider;
  final String planName;
  final String planType;
  final String cardNumber;
  final bool isActive;
  final DateTime? createdAt;

  const Insurance({
    required this.id,
    required this.patientId,
    required this.provider,
    required this.planName,
    this.planType = '',
    this.cardNumber = '',
    this.isActive = true,
    this.createdAt,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      planName: json['plan_name'] as String? ?? '',
      planType: json['plan_type'] as String? ?? '',
      cardNumber: json['card_number'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'provider': provider,
      'plan_name': planName,
      'plan_type': planType,
      'card_number': cardNumber,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Insurance copyWith({
    String? id,
    String? patientId,
    String? provider,
    String? planName,
    String? planType,
    String? cardNumber,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Insurance(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      provider: provider ?? this.provider,
      planName: planName ?? this.planName,
      planType: planType ?? this.planType,
      cardNumber: cardNumber ?? this.cardNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Insurance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Insurance(id: $id, provider: $provider, plan: $planName)';
}
