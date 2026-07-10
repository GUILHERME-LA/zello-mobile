import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/treatment.dart';
import 'api_client_provider.dart';

final treatmentsProvider = FutureProvider<List<Treatment>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getTreatments();
  return data.map((json) => Treatment.fromJson(json as Map<String, dynamic>)).toList();
});
