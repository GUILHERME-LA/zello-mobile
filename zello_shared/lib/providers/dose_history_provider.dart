import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_dose.dart';
import 'api_client_provider.dart';

final doseHistoryProvider = FutureProvider.family<List<MedicationDose>, String>((ref, medicationId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getDoseHistory(medicationId);
  return data.map((json) => MedicationDose.fromJson(json as Map<String, dynamic>)).toList();
});

final patientDoseHistoryProvider = FutureProvider.family<List<MedicationDose>, String>((ref, patientId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getPatientDoseHistory(patientId);
  return data.map((json) => MedicationDose.fromJson(json as Map<String, dynamic>)).toList();
});

final saveDoseProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiClientProvider);
  await api.saveDose(data);
  // Invalidate dose history for the medication
  final medicationId = data['medication_id'] as String?;
  if (medicationId != null) {
    ref.invalidate(doseHistoryProvider(medicationId));
  }
  // Invalidate patient dose history
  final patientId = data['patient_id'] as String?;
  if (patientId != null) {
    ref.invalidate(patientDoseHistoryProvider(patientId));
  }
});
