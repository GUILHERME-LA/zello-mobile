import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication.dart';
import 'api_client_provider.dart';

final patientMedicationsProvider =
    FutureProvider.family<List<Medication>, String>((ref, patientId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getPatientMedications(patientId);
  return data
      .map((json) => Medication.fromJson(json as Map<String, dynamic>))
      .toList();
});
