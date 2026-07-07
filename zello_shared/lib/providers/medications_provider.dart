import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication.dart';
import 'api_client_provider.dart';

final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getMedications();
  return data
      .map((json) => Medication.fromJson(json as Map<String, dynamic>))
      .toList();
});
