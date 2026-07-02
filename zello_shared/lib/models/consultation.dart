enum ConsultationType { in_person, tele }

enum ConsultationStatus { scheduled, completed, cancelled, in_progress }

class Consultation {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime? date;
  final ConsultationType type;
  final String notes;
  final List<String> prescriptions;
  final ConsultationStatus status;

  const Consultation({
    required this.id,
    required this.doctorName,
    this.specialty = '',
    this.date,
    this.type = ConsultationType.in_person,
    this.notes = '',
    this.prescriptions = const [],
    this.status = ConsultationStatus.scheduled,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      type: _parseType(json['type'] as String? ?? 'in_person'),
      notes: json['notes'] as String? ?? '',
      prescriptions: (json['prescriptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: _parseStatus(json['status'] as String? ?? 'scheduled'),
    );
  }

  static ConsultationType _parseType(String value) {
    return ConsultationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConsultationType.in_person,
    );
  }

  static ConsultationStatus _parseStatus(String value) {
    return ConsultationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConsultationStatus.scheduled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'date': date?.toIso8601String(),
      'type': type.name,
      'notes': notes,
      'prescriptions': prescriptions,
      'status': status.name,
    };
  }

  Consultation copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    DateTime? date,
    ConsultationType? type,
    String? notes,
    List<String>? prescriptions,
    ConsultationStatus? status,
  }) {
    return Consultation(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      date: date ?? this.date,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      prescriptions: prescriptions ?? this.prescriptions,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Consultation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Consultation(id: $id, doctor: $doctorName, status: ${status.name})';
}
