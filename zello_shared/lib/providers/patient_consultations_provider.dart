import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/consultation.dart';
import 'api_client_provider.dart';

final patientConsultationsProvider =
    FutureProvider.family<List<Consultation>, String>((ref, patientId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getPatientConsultations(patientId);
  return data
      .map((json) => Consultation.fromJson(json as Map<String, dynamic>))
      .toList();
});
