import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_analysis_result.dart';

/// Estados possíveis da análise de convênio
enum AiAnalysisStatus { idle, loading, success, error }

class AiAnalysisState {
  final AiAnalysisStatus status;
  final AiAnalysisResult? result;
  final String? error;

  const AiAnalysisState({
    this.status = AiAnalysisStatus.idle,
    this.result,
    this.error,
  });
}

class AiAnalysisNotifier extends StateNotifier<AiAnalysisState> {
  final SupabaseClient _supabase;

  AiAnalysisNotifier(this._supabase)
      : super(const AiAnalysisState());

  /// Chama a Edge Function analyze-convenio no Supabase
  Future<void> analyze({
    required String provider,
    required String planName,
    String planType = '',
    String symptoms = '',
    String uf = '',
  }) async {
    state = const AiAnalysisState(status: AiAnalysisStatus.loading);

    try {
      // Chama a Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'analyze-convenio',
        body: {
          'provider': provider,
          'planName': planName,
          'planType': planType,
          'symptoms': symptoms,
          'state': uf,
        },
      );

      final data = response.data as Map<String, dynamic>?;

      if (data == null) {
        state = AiAnalysisState(
          status: AiAnalysisStatus.error,
          error: 'Resposta vazia do servidor',
        );
        return;
      }

      if (data.containsKey('error')) {
        state = AiAnalysisState(
          status: AiAnalysisStatus.error,
          error: data['error'] as String? ?? 'Erro desconhecido',
        );
        return;
      }

      final result = AiAnalysisResult.fromJson(data);
      state = AiAnalysisState(
        status: AiAnalysisStatus.success,
        result: result,
      );

      // Salva o resultado no histórico (se usuário estiver logado)
      _saveToHistory(result, provider, planName, planType, symptoms, uf);
    } catch (e) {
      state = AiAnalysisState(
        status: AiAnalysisStatus.error,
        error: 'Erro ao consultar IA: ${e.toString()}',
      );
    }
  }

  Future<void> _saveToHistory(
    AiAnalysisResult result,
    String provider,
    String planName,
    String planType,
    String symptoms,
    String uf,
  ) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return;

      // Busca o patient_id do usuário logado
      final patientData = await _supabase
          .from('patients')
          .select('id')
          .eq('user_id', session.user.id)
          .maybeSingle();

      if (patientData == null) return;

      final patientId = patientData['id'] as String;

      await _supabase.from('ai_recommendations').insert({
        'patient_id': patientId,
        'input_text':
            'Operadora: $provider | Plano: $planName | Tipo: $planType | Estado: $uf | Sintomas: $symptoms',
        'recommended_hospitals': result.hospitals.map((h) => h.toJson()).toList(),
        'plan_suggestion': result.planAnalysis.toJson(),
        'disclaimer_version': '1.0',
      });
    } catch (_) {
      // Falha ao salvar histórico não deve bloquear a exibição do resultado
    }
  }

  void reset() {
    state = const AiAnalysisState();
  }
}

final aiAnalysisProvider =
    StateNotifierProvider<AiAnalysisNotifier, AiAnalysisState>((ref) {
  final supabase = Supabase.instance.client;
  return AiAnalysisNotifier(supabase);
});
