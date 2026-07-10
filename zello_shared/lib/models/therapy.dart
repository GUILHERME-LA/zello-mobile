// ignore_for_file: constant_identifier_names

enum TherapyType { fisica, ocupacional, fonoaudiologica, psicologica, outro }

enum TherapyStatus { ativa, concluida, pausada }

class Therapy {
  final String id;
  final String name;
  final String professional;
  final TherapyType type;
  final String frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final TherapyStatus status;
  final String notes;

  const Therapy({
    required this.id,
    required this.name,
    this.professional = '',
    this.type = TherapyType.outro,
    this.frequency = '',
    this.startDate,
    this.endDate,
    this.status = TherapyStatus.ativa,
    this.notes = '',
  });

  factory Therapy.fromJson(Map<String, dynamic> json) {
    return Therapy(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      professional: json['professional'] as String? ?? '',
      type: _parseType(json['type'] as String? ?? 'outro'),
      frequency: json['frequency'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      status: _parseStatus(json['status'] as String? ?? 'ativa'),
      notes: json['notes'] as String? ?? '',
    );
  }

  static TherapyType _parseType(String value) {
    return TherapyType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TherapyType.outro,
    );
  }

  static TherapyStatus _parseStatus(String value) {
    return TherapyStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TherapyStatus.ativa,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'professional': professional,
      'type': type.name,
      'frequency': frequency,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  Therapy copyWith({
    String? id,
    String? name,
    String? professional,
    TherapyType? type,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    TherapyStatus? status,
    String? notes,
  }) {
    return Therapy(
      id: id ?? this.id,
      name: name ?? this.name,
      professional: professional ?? this.professional,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Therapy && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Therapy(id: $id, name: $name, status: ${status.name})';
}
