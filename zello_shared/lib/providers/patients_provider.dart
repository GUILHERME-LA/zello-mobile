import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient.dart';
import 'api_client_provider.dart';

final patientsProvider = FutureProvider<List<Patient>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getPatients();
  return data
      .map((json) => Patient.fromJson(json as Map<String, dynamic>))
      .toList();
});

final unassignedPatientsProvider = FutureProvider<List<Patient>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getUnassignedPatients();
  return data
      .map((json) => Patient.fromJson(json as Map<String, dynamic>))
      .toList();
});
