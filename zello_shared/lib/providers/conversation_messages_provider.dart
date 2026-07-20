import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message.dart';
import 'supabase_client_provider.dart';

class ConversationMessagesState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  final bool isGenerating;
  final bool isSending;

  const ConversationMessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isGenerating = false,
    this.isSending = false,
  });

  ConversationMessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    bool? isGenerating,
    bool? isSending,
  }) {
    return ConversationMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isGenerating: isGenerating ?? this.isGenerating,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ConversationMessagesNotifier
    extends StateNotifier<ConversationMessagesState> {
  final SupabaseClient _supabase;
  String? _convKey;

  ConversationMessagesNotifier(this._supabase)
      : super(const ConversationMessagesState());

  Future<void> loadMessages(String convKey) async {
    _convKey = convKey;
    state = const ConversationMessagesState(isLoading: true);
    try {
      final data = await _supabase
          .from('inbound_messages')
          .select('id, conv_key, text, sender, type, received_at')
          .eq('conv_key', convKey)
          .order('received_at', ascending: true);
      final messages = (data as List)
          .map((r) => Message(
                id: r['id'].toString(),
                conversationId: r['conv_key'] as String,
                content: r['text'] as String? ?? '',
                sender: (r['sender'] as String? ?? 'user') == 'agent'
                    ? MessageSender.agent
                    : MessageSender.user,
                timestamp: DateTime.tryParse(r['received_at'] as String? ?? '') ??
                    DateTime.now(),
                type: MessageType.values.firstWhere(
                  (e) => e.name == (r['type'] as String? ?? 'text'),
                  orElse: () => MessageType.text,
                ),
              ))
          .toList();
      state = ConversationMessagesState(messages: messages);
    } catch (e) {
      state = ConversationMessagesState(error: e.toString());
    }
  }

  /// Pede a IA (Edge Function chat-qa) para gerar uma sugestao de resposta
  /// com base no historico da conversa. NAO persiste — o admin revisa e envia.
  Future<String?> generateAgentReply() async {
    if (_convKey == null) return null;
    state = state.copyWith(isGenerating: true, error: null);
    try {
      final history = state.messages
          .map((m) => {
                'role': m.sender == MessageSender.user ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();

      final response = await _supabase.functions.invoke(
        'chat-qa',
        body: {
          'messages': history,
          'kind': 'qa',
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data.containsKey('error')) {
        throw Exception(data?['error'] as String? ?? 'Resposta vazia do servidor');
      }

      final reply = data['reply'] as String? ?? '';
      state = state.copyWith(isGenerating: false);
      return reply;
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
      return null;
    }
  }

  /// Envia a mensagem do agente (clinica) para o banco e atualiza a conversa.
  Future<void> sendAgentMessage(String text) async {
    if (_convKey == null || text.trim().isEmpty) return;
    state = state.copyWith(isSending: true, error: null);
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _supabase.from('inbound_messages').insert({
        'conv_key': _convKey,
        'sender': 'agent',
        'text': text.trim(),
        'type': 'text',
        'received_at': now,
        'raw': {},
      });
      await _supabase
          .from('conversations')
          .update({'last_message_at': now}).eq('conv_key', _convKey!);
      await loadMessages(_convKey!);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }
}

final conversationMessagesProvider = StateNotifierProvider.autoDispose
    .family<ConversationMessagesNotifier, ConversationMessagesState, String>(
        (ref, convKey) {
  final notifier =
      ConversationMessagesNotifier(ref.read(supabaseClientProvider));
  notifier.loadMessages(convKey);
  return notifier;
});
