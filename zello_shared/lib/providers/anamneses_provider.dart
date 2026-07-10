import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/anamnesis.dart';
import 'api_client_provider.dart';

final anamnesesProvider = FutureProvider<List<Anamnesis>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getAnamneses();
  return data.map((json) => Anamnesis.fromJson(json as Map<String, dynamic>)).toList();
});
