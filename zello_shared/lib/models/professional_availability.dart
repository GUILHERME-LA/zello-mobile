class ProfessionalAvailability {
  final String id;
  final String professionalId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isBooked;
  final DateTime? createdAt;

  const ProfessionalAvailability({
    required this.id,
    required this.professionalId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
    this.createdAt,
  });

  factory ProfessionalAvailability.fromJson(Map<String, dynamic> json) {
    return ProfessionalAvailability(
      id: json['id'] as String? ?? '',
      professionalId: json['professional_id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      isBooked: json['is_booked'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional_id': professionalId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'is_booked': isBooked,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ProfessionalAvailability copyWith({
    String? id,
    String? professionalId,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isBooked,
    DateTime? createdAt,
  }) {
    return ProfessionalAvailability(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfessionalAvailability && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProfessionalAvailability(id: $id, date: $date, $startTime-$endTime, booked: $isBooked)';
}
