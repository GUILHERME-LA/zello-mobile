import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zello_shared/zello_shared.dart';

/// Mensagem do chat local (não persiste; o resultado é salvo em ai_hub).
class AiMessage {
  final String id;
  final bool isUser;
  final String content;
  final DateTime timestamp;

  AiMessage({
    required this.id,
    required this.isUser,
    required this.content,
    required this.timestamp,
  });
}

/// Registro persistido no banco (ai_hub) para visualização posterior.
class AiHubRecord {
  final String id;
  final String kind;
  final String inputText;
  final Map<String, dynamic>? fileMeta;
  final String aiReply;
  final DateTime createdAt;

  AiHubRecord({
    required this.id,
    required this.kind,
    required this.inputText,
    this.fileMeta,
    required this.aiReply,
    required this.createdAt,
  });

  factory AiHubRecord.fromJson(Map<String, dynamic> json) {
    return AiHubRecord(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? 'qa',
      inputText: json['input_text'] as String? ?? '',
      fileMeta: json['file_meta'] as Map<String, dynamic>?,
      aiReply: json['ai_reply'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get kindLabel {
    switch (kind) {
      case 'exam':
        return 'Análise de exame';
      case 'plan':
        return 'Análise de plano';
      default:
        return 'Pergunta';
    }
  }
}

class AiHubState {
  final bool isLoading;
  final List<AiMessage> messages;
  final List<AiHubRecord> history;
  final String? error;

  const AiHubState({
    this.isLoading = false,
    this.messages = const [],
    this.history = const [],
    this.error,
  });

  AiHubState copyWith({
    bool? isLoading,
    List<AiMessage>? messages,
    List<AiHubRecord>? history,
    String? error,
  }) {
    return AiHubState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      history: history ?? this.history,
      error: error,
    );
  }
}

class AiHubNotifier extends StateNotifier<AiHubState> {
  final SupabaseClient _supabase;
  final String _role;

  AiHubNotifier(this._supabase, this._role) : super(const AiHubState());

  String _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  Future<String?> _currentPatientId() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await _supabase
        .from('patients')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    return data?['id'] as String?;
  }

  /// Envia uma mensagem (texto e/ou arquivo) para a Edge Function chat-qa.
  Future<void> sendMessage({
    required String text,
    PlatformFile? file,
    required String kind,
    Map<String, dynamic>? planContext,
  }) async {
    final userMsg = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: true,
      content: text.isNotEmpty
          ? text
          : (file != null ? '📎 ${file.name}' : ''),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      isLoading: true,
      error: null,
      messages: [...state.messages, userMsg],
    );

    try {
      String? fileData;
      String? fileMime;
      Map<String, dynamic>? fileMeta;
      if (file != null && file.bytes != null) {
        fileData = base64Encode(file.bytes!);
        fileMime = _mimeFromName(file.name);
        fileMeta = {'name': file.name, 'mime': fileMime};
      }

      final history = state.messages
          .where((m) => m.id != userMsg.id)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();

      final response = await _supabase.functions.invoke(
        'chat-qa',
        body: {
          'messages': [
            ...history,
            {'role': 'user', 'content': text},
          ],
          'kind': kind,
          if (planContext != null) 'planContext': planContext,
          if (fileData != null)
            'file': {'name': file?.name, 'mime': fileMime, 'data': fileData},
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data.containsKey('error')) {
        throw Exception(data?['error'] as String? ?? 'Resposta vazia do servidor');
      }

      final reply = data['reply'] as String? ?? '';
      final assistantMsg = AiMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}-a',
        isUser: false,
        content: reply,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        messages: [...state.messages, assistantMsg],
      );

      await _saveToHistory(
        kind: kind,
        inputText: userMsg.content,
        fileMeta: fileMeta,
        aiReply: reply,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao falar com a IA: ${e.toString()}',
      );
    }
  }

  /// Atalho: analisa o convênio (plano de saúde) do paciente logado.
  Future<void> analyzePlan() async {
    final patientId = await _currentPatientId();
    List<Map<String, dynamic>> plans = [];
    if (patientId != null) {
      final rows = await _supabase
          .from('insurances')
          .select('provider, plan_name, plan_type, card_number, is_active')
          .eq('patient_id', patientId);
      plans = (rows as List)
          .map((r) => {
                'operadora': r['provider'],
                'plano': r['plan_name'],
                'tipo': r['plan_type'],
                'carteirinha': r['card_number'],
                'ativo': r['is_active'],
              })
          .toList();
    }

    final contextText = plans.isNotEmpty
        ? 'Planos de saúde do usuário:\n${plans.map((p) => '- ${p['operadora']} / ${p['plano']} (${p['tipo']})').join('\n')}'
        : 'O usuário ainda não cadastrou um convênio no app.';

    await sendMessage(
      text: 'Por favor, analise o meu plano de saúde e me explique a cobertura, '
          'a rede credenciada e como aproveitá-lo melhor.\n\n$contextText',
      kind: 'plan',
      planContext: {'plans': plans},
    );
  }

  Future<void> _saveToHistory({
    required String kind,
    required String inputText,
    Map<String, dynamic>? fileMeta,
    required String aiReply,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      await _supabase.from('ai_hub').insert({
        'owner_id': userId,
        'role': _role,
        'kind': kind,
        'input_text': inputText,
        if (fileMeta != null) 'file_meta': fileMeta,
        'ai_reply': aiReply,
      });
    } catch (_) {
      // Falha ao salvar não deve bloquear a exibição da resposta.
    }
  }

  Future<void> loadHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      final rows = await _supabase
          .from('ai_hub')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      final records =
          (rows as List).map((r) => AiHubRecord.fromJson(r)).toList();
      state = state.copyWith(history: records);
    } catch (_) {
      // ignora erros de histórico
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

final aiHubProvider =
    StateNotifierProvider<AiHubNotifier, AiHubState>((ref) {
  final role = ref.read(authProvider).user?.role.name ?? 'patient';
  return AiHubNotifier(Supabase.instance.client, role);
});
