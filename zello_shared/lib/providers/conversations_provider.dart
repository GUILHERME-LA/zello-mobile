import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import 'api_client_provider.dart';

final conversationsProvider =
    FutureProvider<List<Conversation>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getConversations();
  return data
      .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
      .toList();
});
