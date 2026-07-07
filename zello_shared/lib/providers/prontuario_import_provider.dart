import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prontuario_import_result.dart';

/// Estados possíveis da importação de prontuário
enum ProntuarioImportStatus { idle, loading, success, error }

class ProntuarioImportState {
  final ProntuarioImportStatus status;
  final ProntuarioImportResult? result;
  final String? error;

  const ProntuarioImportState({
    this.status = ProntuarioImportStatus.idle,
    this.result,
    this.error,
  });
}

class ProntuarioImportNotifier extends StateNotifier<ProntuarioImportState> {
  final SupabaseClient _supabase;

  ProntuarioImportNotifier(this._supabase)
      : super(const ProntuarioImportState());

  /// Envia o texto extraído de um arquivo para a Edge Function import-prontuario
  Future<void> import(String text, String fileName) async {
    state = const ProntuarioImportState(status: ProntuarioImportStatus.loading);

    try {
      final response = await _supabase.functions.invoke(
        'import-prontuario',
        body: {
          'text': text,
          'fileName': fileName,
        },
      );

      final data = response.data as Map<String, dynamic>?;

      if (data == null) {
        state = const ProntuarioImportState(
          status: ProntuarioImportStatus.error,
          error: 'Resposta vazia do servidor',
        );
        return;
      }

      if (data.containsKey('error')) {
        state = ProntuarioImportState(
          status: ProntuarioImportStatus.error,
          error: data['error'] as String? ?? 'Erro desconhecido',
        );
        return;
      }

      final result = ProntuarioImportResult.fromJson(data);
      state = ProntuarioImportState(
        status: ProntuarioImportStatus.success,
        result: result,
      );
    } catch (e) {
      state = ProntuarioImportState(
        status: ProntuarioImportStatus.error,
        error: 'Erro ao importar: ${e.toString()}',
      );
    }
  }

  void reset() {
    state = const ProntuarioImportState();
  }
}

final prontuarioImportProvider =
    StateNotifierProvider<ProntuarioImportNotifier, ProntuarioImportState>((ref) {
  final supabase = Supabase.instance.client;
  return ProntuarioImportNotifier(supabase);
});
