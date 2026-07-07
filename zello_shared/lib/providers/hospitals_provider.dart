import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hospital.dart';
import 'api_client_provider.dart';

final hospitalsProvider = FutureProvider<List<Hospital>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.searchHospitals();
  return data
      .map((json) => Hospital.fromJson(json as Map<String, dynamic>))
      .toList();
});
