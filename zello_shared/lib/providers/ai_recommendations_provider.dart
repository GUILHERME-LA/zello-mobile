import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/ai_recommendation.dart';

class AIRecommendationsNotifier extends StateNotifier<AsyncValue<List<AIRecommendation>>> {
  final SupabaseClient _supabase;

  AIRecommendationsNotifier(this._supabase) : super(const AsyncValue.loading());

  Future<void> loadByPatient(String patientId) async {
    state = const AsyncValue.loading();
    try {
      final data = await _supabase
          .from('ai_recommendations')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);
      final rows = List<Map<String, dynamic>>.from(data as List);
      final list = rows.map((row) => AIRecommendation.fromJson(row)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AIRecommendation> create(AIRecommendation recommendation) async {
    final data = (await _supabase
            .from('ai_recommendations')
            .insert(recommendation.toJson()..remove('id'))
            .select()
            .single());
    return AIRecommendation.fromJson(data);
  }
}

final aiRecommendationsProvider =
    StateNotifierProvider<AIRecommendationsNotifier, AsyncValue<List<AIRecommendation>>>((ref) {
  return AIRecommendationsNotifier(Supabase.instance.client);
});
