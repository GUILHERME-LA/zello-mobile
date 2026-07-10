class Anamnesis {
  final String id;
  final DateTime? date;
  final String professional;
  final String chiefComplaint;
  final String historyOfPresentIllness;
  final String pastHistory;
  final String continuousMedication;
  final String allergies;
  final String habits;
  final String familyHistory;
  final bool completed;

  const Anamnesis({
    required this.id,
    this.date,
    this.professional = '',
    this.chiefComplaint = '',
    this.historyOfPresentIllness = '',
    this.pastHistory = '',
    this.continuousMedication = '',
    this.allergies = '',
    this.habits = '',
    this.familyHistory = '',
    this.completed = false,
  });

  factory Anamnesis.fromJson(Map<String, dynamic> json) {
    return Anamnesis(
      id: json['id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      professional: json['professional'] as String? ?? '',
      chiefComplaint: json['chiefComplaint'] as String? ?? '',
      historyOfPresentIllness: json['historyOfPresentIllness'] as String? ?? '',
      pastHistory: json['pastHistory'] as String? ?? '',
      continuousMedication: json['continuousMedication'] as String? ?? '',
      allergies: json['allergies'] as String? ?? '',
      habits: json['habits'] as String? ?? '',
      familyHistory: json['familyHistory'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'professional': professional,
      'chiefComplaint': chiefComplaint,
      'historyOfPresentIllness': historyOfPresentIllness,
      'pastHistory': pastHistory,
      'continuousMedication': continuousMedication,
      'allergies': allergies,
      'habits': habits,
      'familyHistory': familyHistory,
      'completed': completed,
    };
  }

  Anamnesis copyWith({
    String? id,
    DateTime? date,
    String? professional,
    String? chiefComplaint,
    String? historyOfPresentIllness,
    String? pastHistory,
    String? continuousMedication,
    String? allergies,
    String? habits,
    String? familyHistory,
    bool? completed,
  }) {
    return Anamnesis(
      id: id ?? this.id,
      date: date ?? this.date,
      professional: professional ?? this.professional,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      historyOfPresentIllness:
          historyOfPresentIllness ?? this.historyOfPresentIllness,
      pastHistory: pastHistory ?? this.pastHistory,
      continuousMedication: continuousMedication ?? this.continuousMedication,
      allergies: allergies ?? this.allergies,
      habits: habits ?? this.habits,
      familyHistory: familyHistory ?? this.familyHistory,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Anamnesis && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Anamnesis(id: $id, completed: $completed)';
}
