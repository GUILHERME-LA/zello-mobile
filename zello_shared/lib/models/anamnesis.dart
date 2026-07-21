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

  final String rg;
  final double? altura;
  final bool hasDepression;
  final bool hasSuicideAttempts;
  final bool hasSelfHarm;
  final String mentalHealthNotes;
  final String allergiesDetails;
  final String surgeriesDescription;
  final bool hasInsurance;
  final String insuranceProvider;
  final String insurancePlan;
  final String addressStreet;
  final String addressNumber;
  final String addressNeighborhood;
  final String addressCity;
  final String addressState;
  final String addressZip;

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
    this.rg = '',
    this.altura,
    this.hasDepression = false,
    this.hasSuicideAttempts = false,
    this.hasSelfHarm = false,
    this.mentalHealthNotes = '',
    this.allergiesDetails = '',
    this.surgeriesDescription = '',
    this.hasInsurance = false,
    this.insuranceProvider = '',
    this.insurancePlan = '',
    this.addressStreet = '',
    this.addressNumber = '',
    this.addressNeighborhood = '',
    this.addressCity = '',
    this.addressState = '',
    this.addressZip = '',
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
      rg: json['rg'] as String? ?? '',
      altura: (json['altura'] as num?)?.toDouble(),
      hasDepression: json['has_depression'] as bool? ?? false,
      hasSuicideAttempts: json['has_suicide_attempts'] as bool? ?? false,
      hasSelfHarm: json['has_self_harm'] as bool? ?? false,
      mentalHealthNotes: json['mental_health_notes'] as String? ?? '',
      allergiesDetails: json['allergies_details'] as String? ?? '',
      surgeriesDescription: json['surgeries_description'] as String? ?? '',
      hasInsurance: json['has_insurance'] as bool? ?? false,
      insuranceProvider: json['insurance_provider'] as String? ?? '',
      insurancePlan: json['insurance_plan'] as String? ?? '',
      addressStreet: json['address_street'] as String? ?? '',
      addressNumber: json['address_number'] as String? ?? '',
      addressNeighborhood: json['address_neighborhood'] as String? ?? '',
      addressCity: json['address_city'] as String? ?? '',
      addressState: json['address_state'] as String? ?? '',
      addressZip: json['address_zip'] as String? ?? '',
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
      'rg': rg,
      'altura': altura,
      'has_depression': hasDepression,
      'has_suicide_attempts': hasSuicideAttempts,
      'has_self_harm': hasSelfHarm,
      'mental_health_notes': mentalHealthNotes,
      'allergies_details': allergiesDetails,
      'surgeries_description': surgeriesDescription,
      'has_insurance': hasInsurance,
      'insurance_provider': insuranceProvider,
      'insurance_plan': insurancePlan,
      'address_street': addressStreet,
      'address_number': addressNumber,
      'address_neighborhood': addressNeighborhood,
      'address_city': addressCity,
      'address_state': addressState,
      'address_zip': addressZip,
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
    String? rg,
    double? altura,
    bool? hasDepression,
    bool? hasSuicideAttempts,
    bool? hasSelfHarm,
    String? mentalHealthNotes,
    String? allergiesDetails,
    String? surgeriesDescription,
    bool? hasInsurance,
    String? insuranceProvider,
    String? insurancePlan,
    String? addressStreet,
    String? addressNumber,
    String? addressNeighborhood,
    String? addressCity,
    String? addressState,
    String? addressZip,
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
      rg: rg ?? this.rg,
      altura: altura ?? this.altura,
      hasDepression: hasDepression ?? this.hasDepression,
      hasSuicideAttempts: hasSuicideAttempts ?? this.hasSuicideAttempts,
      hasSelfHarm: hasSelfHarm ?? this.hasSelfHarm,
      mentalHealthNotes: mentalHealthNotes ?? this.mentalHealthNotes,
      allergiesDetails: allergiesDetails ?? this.allergiesDetails,
      surgeriesDescription: surgeriesDescription ?? this.surgeriesDescription,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePlan: insurancePlan ?? this.insurancePlan,
      addressStreet: addressStreet ?? this.addressStreet,
      addressNumber: addressNumber ?? this.addressNumber,
      addressNeighborhood: addressNeighborhood ?? this.addressNeighborhood,
      addressCity: addressCity ?? this.addressCity,
      addressState: addressState ?? this.addressState,
      addressZip: addressZip ?? this.addressZip,
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
