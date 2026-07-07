class AiHospital {
  final String name;
  final String address;
  final String phone;
  final List<String> specialties;
  final bool acceptsPlan;
  final double rating;

  const AiHospital({
    required this.name,
    required this.address,
    required this.phone,
    required this.specialties,
    required this.acceptsPlan,
    required this.rating,
  });

  factory AiHospital.fromJson(Map<String, dynamic> json) {
    return AiHospital(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      acceptsPlan: json['acceptsPlan'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'phone': phone,
        'specialties': specialties,
        'acceptsPlan': acceptsPlan,
        'rating': rating,
      };
}

class AiPlanAnalysis {
  final String currentPlan;
  final String recommendation;
  final String justification;
  final String suggestedPlanType;
  final String estimatedCostImpact;

  const AiPlanAnalysis({
    required this.currentPlan,
    required this.recommendation,
    required this.justification,
    required this.suggestedPlanType,
    required this.estimatedCostImpact,
  });

  factory AiPlanAnalysis.fromJson(Map<String, dynamic> json) {
    return AiPlanAnalysis(
      currentPlan: json['currentPlan'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? 'manter',
      justification: json['justification'] as String? ?? '',
      suggestedPlanType: json['suggestedPlanType'] as String? ?? '',
      estimatedCostImpact: json['estimatedCostImpact'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'currentPlan': currentPlan,
        'recommendation': recommendation,
        'justification': justification,
        'suggestedPlanType': suggestedPlanType,
        'estimatedCostImpact': estimatedCostImpact,
      };
}

class AiAnalysisResult {
  final List<AiHospital> hospitals;
  final AiPlanAnalysis planAnalysis;

  const AiAnalysisResult({
    required this.hospitals,
    required this.planAnalysis,
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResult(
      hospitals: (json['hospitals'] as List<dynamic>?)
              ?.map((e) => AiHospital.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      planAnalysis: json['planAnalysis'] != null
          ? AiPlanAnalysis.fromJson(json['planAnalysis'] as Map<String, dynamic>)
          : AiPlanAnalysis(
              currentPlan: '',
              recommendation: 'manter',
              justification: '',
              suggestedPlanType: '',
              estimatedCostImpact: '',
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        'hospitals': hospitals.map((h) => h.toJson()).toList(),
        'planAnalysis': planAnalysis.toJson(),
      };
}
