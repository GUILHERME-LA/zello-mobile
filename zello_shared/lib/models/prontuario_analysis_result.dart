class ProntuarioAnalysisResult {
  final String summary;
  final List<String> attentionPoints;
  final List<String> suggestions;
  final List<String> preventiveCare;
  final List<String> lifestyleRecommendations;
  final String overallRisk;

  const ProntuarioAnalysisResult({
    required this.summary,
    required this.attentionPoints,
    required this.suggestions,
    required this.preventiveCare,
    required this.lifestyleRecommendations,
    required this.overallRisk,
  });

  factory ProntuarioAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ProntuarioAnalysisResult(
      summary: json['summary'] as String? ?? '',
      attentionPoints: (json['attentionPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preventiveCare: (json['preventiveCare'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lifestyleRecommendations: (json['lifestyleRecommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      overallRisk: json['overallRisk'] as String? ?? 'moderado',
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'attentionPoints': attentionPoints,
        'suggestions': suggestions,
        'preventiveCare': preventiveCare,
        'lifestyleRecommendations': lifestyleRecommendations,
        'overallRisk': overallRisk,
      };
}
