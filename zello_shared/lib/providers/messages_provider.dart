import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/ollama/ollama_service.dart';
import '../models/message.dart';
import 'api_client_provider.dart';
import 'ollama_provider.dart';

class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  final bool isSending;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isSending = false,
  });
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  final ApiClient _api;
  final OllamaService _ollama;
  String? _conversationId;

  MessagesNotifier(this._api, this._ollama) : super(const MessagesState());

  Future<void> loadMessages(String conversationId) async {
    _conversationId = conversationId;
    state = MessagesState(isLoading: true);
    try {
      final data = await _api.getConversationMessages(conversationId);
      final messages = data
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();
      state = MessagesState(messages: messages);
    } catch (e) {
      state = MessagesState(error: e.toString());
    }
  }

  Future<void> sendMessage(String content) async {
    if (_conversationId == null) return;
    final optimistic = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: _conversationId!,
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    state = MessagesState(
      messages: [...state.messages, optimistic],
      isSending: true,
    );
    try {
      _api.sendMessage(_conversationId!, content);
      final reply = await _ollama.chatCompletion(
        userMessage: content,
        history: state.messages,
      );
      final replyMessage = Message(
        id: '${DateTime.now().millisecondsSinceEpoch}_reply',
        conversationId: _conversationId!,
        content: reply,
        sender: MessageSender.agent,
        timestamp: DateTime.now(),
      );
      state = MessagesState(
        messages: [...state.messages, replyMessage],
      );
    } catch (e) {
      state = MessagesState(
        messages: state.messages,
        error: e.toString(),
      );
    }
  }

  void addMessage(Message message) {
    state = MessagesState(messages: [...state.messages, message]);
  }
}

final messagesProvider = StateNotifierProvider.autoDispose<
    MessagesNotifier, MessagesState>((ref) {
  return MessagesNotifier(
    ref.read(apiClientProvider),
    ref.read(ollamaServiceProvider),
  );
});
