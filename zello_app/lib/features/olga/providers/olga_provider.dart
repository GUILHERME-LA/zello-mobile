import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zello_shared/zello_shared.dart';

class OlgaMessage {
  final String id;
  final bool isUser;
  final String content;
  final DateTime timestamp;

  OlgaMessage({
    required this.id,
    required this.isUser,
    required this.content,
    required this.timestamp,
  });
}

class OlgaRecord {
  final String id;
  final String kind;
  final String inputText;
  final Map<String, dynamic>? fileMeta;
  final String aiReply;
  final DateTime createdAt;

  OlgaRecord({
    required this.id,
    required this.kind,
    required this.inputText,
    this.fileMeta,
    required this.aiReply,
    required this.createdAt,
  });

  factory OlgaRecord.fromJson(Map<String, dynamic> json) {
    return OlgaRecord(
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
      case 'doctor':
        return 'Recomendação médica';
      default:
        return 'Pergunta';
    }
  }
}

class OlgaState {
  final bool isLoading;
  final List<OlgaMessage> messages;
  final List<OlgaRecord> history;
  final String? error;

  const OlgaState({
    this.isLoading = false,
    this.messages = const [],
    this.history = const [],
    this.error,
  });

  OlgaState copyWith({
    bool? isLoading,
    List<OlgaMessage>? messages,
    List<OlgaRecord>? history,
    String? error,
  }) {
    return OlgaState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      history: history ?? this.history,
      error: error,
    );
  }
}

class OlgaNotifier extends StateNotifier<OlgaState> {
  final SupabaseClient _supabase;
  final Ref _ref;

  OlgaNotifier(this._supabase, this._ref) : super(const OlgaState());

  String _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png': return 'image/png';
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'webp': return 'image/webp';
      case 'pdf': return 'application/pdf';
      default: return 'application/octet-stream';
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

  Future<String> _buildPatientContext() async {
    final patientId = await _currentPatientId();
    if (patientId == null) return '';

    final buf = StringBuffer();

    final anamnese = await _supabase
        .from('anamneses')
        .select()
        .eq('patient_id', patientId)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();
    if (anamnese != null) {
      buf.writeln('DADOS DO PACIENTE:');
      if (anamnese['rg'] != null) buf.writeln('RG: ${anamnese['rg']}');
      if (anamnese['altura'] != null) buf.writeln('Altura: ${anamnese['altura']}m');
      if (anamnese['surgeries_description'] != null && (anamnese['surgeries_description'] as String).isNotEmpty) {
        buf.writeln('Cirurgias: ${anamnese['surgeries_description']}');
      }
      if (anamnese['allergies_details'] != null && (anamnese['allergies_details'] as String).isNotEmpty) {
        buf.writeln('Alergias: ${anamnese['allergies_details']}');
      }
      if (anamnese['has_depression'] == true) buf.writeln('Diagnóstico de depressão: Sim');
      if (anamnese['has_suicide_attempts'] == true) buf.writeln('Tentativas de suicídio: Sim');
      if (anamnese['has_self_harm'] == true) buf.writeln('Automutilação: Sim');
      if (anamnese['has_insurance'] == true) {
        buf.writeln('Plano de saúde: ${anamnese['insurance_provider']} / ${anamnese['insurance_plan']}');
      } else {
        buf.writeln('Sem plano de saúde.');
        if (anamnese['address_city'] != null) {
          buf.writeln('Endereço: ${anamnese['address_street']}, ${anamnese['address_number']} - ${anamnese['address_neighborhood']}, ${anamnese['address_city']}/${anamnese['address_state']} - CEP: ${anamnese['address_zip']}');
        }
      }
    }

    final medications = await _supabase
        .from('medications')
        .select('name, dosage, frequency')
        .eq('patient_id', patientId);
    if (medications.isNotEmpty) {
      buf.writeln('MEDICAÇÕES:');
      for (final m in medications) {
        buf.writeln('- ${m['name']} ${m['dosage'] ?? ''} ${m['frequency'] ?? ''}');
      }
    }

    return buf.toString();
  }

  Future<void> sendMessage({
    required String text,
    PlatformFile? file,
  }) async {
    final userMsg = OlgaMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: true,
      content: text.isNotEmpty ? text : (file != null ? '📎 ${file.name}' : ''),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(isLoading: true, error: null, messages: [...state.messages, userMsg]);

    try {
      String? fileData;
      String? fileMime;
      Map<String, dynamic>? fileMeta;
      if (file != null && file.bytes != null) {
        fileData = base64Encode(file.bytes!);
        fileMime = _mimeFromName(file.name);
        fileMeta = {'name': file.name, 'mime': fileMime};
      }

      final patientContext = await _buildPatientContext();

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
          'kind': 'olga',
          'patientContext': patientContext,
          if (fileData != null)
            'file': {'name': file?.name, 'mime': fileMime, 'data': fileData},
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data.containsKey('error')) {
        throw Exception(data?['error'] as String? ?? 'Resposta vazia do servidor');
      }

      final reply = data['reply'] as String? ?? '';
      final assistantMsg = OlgaMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}-a',
        isUser: false,
        content: reply,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(isLoading: false, messages: [...state.messages, assistantMsg]);

      await _saveToHistory(inputText: userMsg.content, fileMeta: fileMeta, aiReply: reply);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao falar com a Olga: ${e.toString()}');
    }
  }

  Future<void> _saveToHistory({
    required String inputText,
    Map<String, dynamic>? fileMeta,
    required String aiReply,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      await _supabase.from('ai_hub').insert({
        'owner_id': userId,
        'role': 'patient',
        'kind': 'olga',
        'input_text': inputText,
        if (fileMeta != null) 'file_meta': fileMeta,
        'ai_reply': aiReply,
      });
    } catch (_) {}
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
      final records = (rows as List).map((r) => OlgaRecord.fromJson(r)).toList();
      state = state.copyWith(history: records);
    } catch (_) {}
  }

  void clearError() => state = state.copyWith(error: null);
}

final olgaProvider = StateNotifierProvider<OlgaNotifier, OlgaState>((ref) {
  return OlgaNotifier(Supabase.instance.client, ref);
});