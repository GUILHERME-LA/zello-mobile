import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam.dart';
import 'api_client_provider.dart';

final examsProvider = FutureProvider<List<Exam>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getExams();
  return data
      .map((json) => Exam.fromJson(json as Map<String, dynamic>))
      .toList();
});
