import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam.dart';
import 'api_client_provider.dart';

final patientExamsProvider =
    FutureProvider.family<List<Exam>, String>((ref, patientId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getPatientExams(patientId);
  return data
      .map((json) => Exam.fromJson(json as Map<String, dynamic>))
      .toList();
});
