import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prontuario_analysis_result.dart';

/// Estados possíveis da análise de prontuário
enum ProntuarioAnalysisStatus { idle, loading, success, error }

class ProntuarioAnalysisState {
  final ProntuarioAnalysisStatus status;
  final ProntuarioAnalysisResult? result;
  final String? error;

  const ProntuarioAnalysisState({
    this.status = ProntuarioAnalysisStatus.idle,
    this.result,
    this.error,
  });
}

class ProntuarioAnalysisNotifier extends StateNotifier<ProntuarioAnalysisState> {
  final SupabaseClient _supabase;

  ProntuarioAnalysisNotifier(this._supabase)
      : super(const ProntuarioAnalysisState());

  /// Monta o payload com todos os dados de saúde do paciente e chama a Edge Function
  Future<void> analyze(String patientId) async {
    state = const ProntuarioAnalysisState(status: ProntuarioAnalysisStatus.loading);

    try {
      // Coleta todos os dados de saúde
      final profile = await _supabase
          .from('health_profiles')
          .select()
          .eq('patient_id', patientId)
          .maybeSingle();

      final surgeries = await _supabase
          .from('surgeries')
          .select()
          .eq('patient_id', patientId)
          .order('date', ascending: false);

      final hospitalizations = await _supabase
          .from('hospitalizations')
          .select()
          .eq('patient_id', patientId)
          .order('start_date', ascending: false);

      final symptoms = await _supabase
          .from('symptoms')
          .select()
          .eq('patient_id', patientId);

      final allergies = await _supabase
          .from('allergies')
          .select()
          .eq('patient_id', patientId);

      final vaccines = await _supabase
          .from('vaccines')
          .select()
          .eq('patient_id', patientId);

      // Monta o body da requisição
      final body = {
        'profile': {
          'weight': (profile?['weight'] as num?)?.toDouble() ?? 0,
          'height': (profile?['height'] as num?)?.toDouble() ?? 0,
          'bloodType': profile?['blood_type'] as String? ?? '',
          'medicalConditions': profile?['medical_conditions'] as String? ?? '',
          'familyHistory': profile?['family_history'] as String? ?? '',
          'chronicConditions': profile?['chronic_conditions'] as String? ?? '',
          'medications': profile?['medications'] as String? ?? '',
        },
        'surgeries': (surgeries as List<dynamic>).map((s) => {
          'name': s['name'] as String? ?? '',
          'date': _formatDate(s['date']),
          'hospital': s['hospital'] as String? ?? '',
          'doctor': s['doctor'] as String? ?? '',
          'notes': s['notes'] as String? ?? '',
        }).toList(),
        'hospitalizations': (hospitalizations as List<dynamic>).map((h) => {
          'reason': h['reason'] as String? ?? '',
          'hospital': h['hospital'] as String? ?? '',
          'startDate': _formatDate(h['start_date']),
          'endDate': _formatDate(h['end_date']),
          'notes': h['notes'] as String? ?? '',
        }).toList(),
        'symptoms': (symptoms as List<dynamic>).map((s) => {
          'name': s['name'] as String? ?? '',
          'frequency': s['frequency'] as String? ?? '',
          'intensity': s['intensity'] as String? ?? '',
          'notes': s['notes'] as String? ?? '',
        }).toList(),
        'allergies': (allergies as List<dynamic>).map((a) => {
          'name': a['name'] as String? ?? '',
          'type': a['type'] as String? ?? '',
          'reaction': a['reaction'] as String? ?? '',
          'notes': a['notes'] as String? ?? '',
        }).toList(),
        'vaccines': (vaccines as List<dynamic>).map((v) => {
          'name': v['name'] as String? ?? '',
          'date': _formatDate(v['date']),
          'dose': v['dose'] as String? ?? '',
          'location': v['location'] as String? ?? '',
          'notes': v['notes'] as String? ?? '',
          'isPending': v['is_pending'] as bool? ?? false,
        }).toList(),
      };

      // Chama a Edge Function
      final response = await _supabase.functions.invoke(
        'analyze-prontuario',
        body: body,
      );

      final data = response.data as Map<String, dynamic>?;

      if (data == null) {
        state = const ProntuarioAnalysisState(
          status: ProntuarioAnalysisStatus.error,
          error: 'Resposta vazia do servidor',
        );
        return;
      }

      if (data.containsKey('error')) {
        state = ProntuarioAnalysisState(
          status: ProntuarioAnalysisStatus.error,
          error: data['error'] as String? ?? 'Erro desconhecido',
        );
        return;
      }

      final result = ProntuarioAnalysisResult.fromJson(data);
      state = ProntuarioAnalysisState(
        status: ProntuarioAnalysisStatus.success,
        result: result,
      );
    } catch (e) {
      state = ProntuarioAnalysisState(
        status: ProntuarioAnalysisStatus.error,
        error: 'Erro ao analisar prontuário: ${e.toString()}',
      );
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is String) return date;
    return date.toString();
  }

  void reset() {
    state = const ProntuarioAnalysisState();
  }
}

final prontuarioAnalysisProvider =
    StateNotifierProvider<ProntuarioAnalysisNotifier, ProntuarioAnalysisState>((ref) {
  final supabase = Supabase.instance.client;
  return ProntuarioAnalysisNotifier(supabase);
});
