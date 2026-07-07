import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent.dart';
import 'api_client_provider.dart';

final agentsProvider = FutureProvider<List<Agent>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getAgents();
  return data
      .map((json) => Agent.fromJson(json as Map<String, dynamic>))
      .toList();
});
