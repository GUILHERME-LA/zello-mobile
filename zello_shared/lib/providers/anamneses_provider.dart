import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anamnesis.dart';
import 'api_client_provider.dart';

final anamnesesProvider = FutureProvider<List<Anamnesis>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getAnamneses();
  return data.map((json) => Anamnesis.fromJson(json as Map<String, dynamic>)).toList();
});

final anamnesisSaveProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiClientProvider);
  await api.saveAnamnesis(data);
  ref.invalidate(anamnesesProvider);
});

final currentAnamnesisProvider = FutureProvider<Anamnesis?>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getAnamneses();
  final list = data.map((json) => Anamnesis.fromJson(json as Map<String, dynamic>)).toList();
  if (list.isEmpty) return null;
  return list.first;
});