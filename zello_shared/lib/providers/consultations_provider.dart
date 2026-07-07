import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/consultation.dart';
import 'api_client_provider.dart';

final consultationsProvider =
    FutureProvider<List<Consultation>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getConsultations();
  return data
      .map((json) => Consultation.fromJson(json as Map<String, dynamic>))
      .toList();
});
