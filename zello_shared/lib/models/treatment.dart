// ignore_for_file: constant_identifier_names

enum TreatmentStatus { ativo, concluido, suspenso }

class Treatment {
  final String id;
  final String name;
  final String description;
  final String professional;
  final DateTime? startDate;
  final DateTime? endDate;
  final TreatmentStatus status;
  final String notes;

  const Treatment({
    required this.id,
    required this.name,
    this.description = '',
    this.professional = '',
    this.startDate,
    this.endDate,
    this.status = TreatmentStatus.ativo,
    this.notes = '',
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      professional: json['professional'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      status: _parseStatus(json['status'] as String? ?? 'ativo'),
      notes: json['notes'] as String? ?? '',
    );
  }

  static TreatmentStatus _parseStatus(String value) {
    return TreatmentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TreatmentStatus.ativo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'professional': professional,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  Treatment copyWith({
    String? id,
    String? name,
    String? description,
    String? professional,
    DateTime? startDate,
    DateTime? endDate,
    TreatmentStatus? status,
    String? notes,
  }) {
    return Treatment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      professional: professional ?? this.professional,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Treatment && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Treatment(id: $id, name: $name, status: ${status.name})';
}
