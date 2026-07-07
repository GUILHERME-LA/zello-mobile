class ProntuarioImportResult {
  final String summary;
  final List<Map<String, String>> surgeries;
  final List<Map<String, String>> hospitalizations;
  final List<Map<String, String>> symptoms;
  final List<Map<String, String>> allergies;
  final List<Map<String, String>> vaccines;
  final String medications;
  final String conditions;

  const ProntuarioImportResult({
    required this.summary,
    this.surgeries = const [],
    this.hospitalizations = const [],
    this.symptoms = const [],
    this.allergies = const [],
    this.vaccines = const [],
    this.medications = '',
    this.conditions = '',
  });

  factory ProntuarioImportResult.fromJson(Map<String, dynamic> json) {
    return ProntuarioImportResult(
      summary: json['summary'] as String? ?? '',
      surgeries: _parseList(json['surgeries']),
      hospitalizations: _parseList(json['hospitalizations']),
      symptoms: _parseList(json['symptoms']),
      allergies: _parseList(json['allergies']),
      vaccines: _parseList(json['vaccines']),
      medications: json['medications'] as String? ?? '',
      conditions: json['conditions'] as String? ?? '',
    );
  }

  static List<Map<String, String>> _parseList(dynamic list) {
    if (list == null || list is! List) return [];
    return list.map((item) {
      if (item is Map) {
        return item.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
      }
      return <String, String>{};
    }).toList();
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'surgeries': surgeries,
        'hospitalizations': hospitalizations,
        'symptoms': symptoms,
        'allergies': allergies,
        'vaccines': vaccines,
        'medications': medications,
        'conditions': conditions,
      };
}
