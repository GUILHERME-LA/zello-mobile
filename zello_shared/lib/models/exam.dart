enum ExamStatus { pending, available, reviewed }

class Exam {
  final String id;
  final String name;
  final DateTime? date;
  final String requestingPhysician;
  final String labFacility;
  final ExamStatus status;
  final String resultUrl;
  final String notes;

  const Exam({
    required this.id,
    required this.name,
    this.date,
    this.requestingPhysician = '',
    this.labFacility = '',
    this.status = ExamStatus.pending,
    this.resultUrl = '',
    this.notes = '',
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      requestingPhysician: json['requestingPhysician'] as String? ?? '',
      labFacility: json['labFacility'] as String? ?? '',
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      resultUrl: json['resultUrl'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  static ExamStatus _parseStatus(String value) {
    return ExamStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExamStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date?.toIso8601String(),
      'requestingPhysician': requestingPhysician,
      'labFacility': labFacility,
      'status': status.name,
      'resultUrl': resultUrl,
      'notes': notes,
    };
  }

  Exam copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? requestingPhysician,
    String? labFacility,
    ExamStatus? status,
    String? resultUrl,
    String? notes,
  }) {
    return Exam(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      requestingPhysician: requestingPhysician ?? this.requestingPhysician,
      labFacility: labFacility ?? this.labFacility,
      status: status ?? this.status,
      resultUrl: resultUrl ?? this.resultUrl,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exam && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Exam(id: $id, name: $name, status: ${status.name})';
}
