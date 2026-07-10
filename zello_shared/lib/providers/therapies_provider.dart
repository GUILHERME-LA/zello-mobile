import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/therapy.dart';
import 'api_client_provider.dart';

final therapiesProvider = FutureProvider<List<Therapy>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getTherapies();
  return data.map((json) => Therapy.fromJson(json as Map<String, dynamic>)).toList();
});
