class AIRecommendation {
  final String id;
  final String patientId;
  final String? insuranceId;
  final String inputText;
  final List<Map<String, dynamic>> recommendedHospitals;
  final Map<String, dynamic>? planSuggestion;
  final String disclaimerVersion;
  final DateTime? createdAt;

  const AIRecommendation({
    required this.id,
    required this.patientId,
    this.insuranceId,
    this.inputText = '',
    this.recommendedHospitals = const [],
    this.planSuggestion,
    this.disclaimerVersion = '1.0',
    this.createdAt,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      insuranceId: json['insurance_id'] as String?,
      inputText: json['input_text'] as String? ?? '',
      recommendedHospitals: (json['recommended_hospitals'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      planSuggestion: json['plan_suggestion'] != null
          ? Map<String, dynamic>.from(json['plan_suggestion'] as Map)
          : null,
      disclaimerVersion: json['disclaimer_version'] as String? ?? '1.0',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'insurance_id': insuranceId,
      'input_text': inputText,
      'recommended_hospitals': recommendedHospitals,
      'plan_suggestion': planSuggestion,
      'disclaimer_version': disclaimerVersion,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIRecommendation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AIRecommendation(id: $id, hospitals: ${recommendedHospitals.length})';
}
