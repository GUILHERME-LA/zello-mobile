import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/exam_request.dart';

class ExamRequestsNotifier extends StateNotifier<AsyncValue<List<ExamRequest>>> {
  final SupabaseClient _supabase;

  ExamRequestsNotifier(this._supabase) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _supabase
          .from('exam_requests')
          .select('*, patients(name, phone)')
          .order('created_at', ascending: false);
      final list = data.map((row) => ExamRequest.fromJson(row)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadByProfessional(String professionalId) async {
    state = const AsyncValue.loading();
    try {
      final data = await _supabase
          .from('exam_requests')
          .select('*, patients(name, phone)')
          .eq('professional_id', professionalId)
          .order('created_at', ascending: false);
      final list = data.map((row) => ExamRequest.fromJson(row)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadByPatient(String patientId) async {
    state = const AsyncValue.loading();
    try {
      final data = await _supabase
          .from('exam_requests')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);
      final list = data.map((row) => ExamRequest.fromJson(row)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> request(ExamRequest request) async {
    await _supabase.from('exam_requests').insert(request.toJson()..remove('id'));
  }

  Future<void> confirm(String requestId) async {
    await _supabase
        .from('exam_requests')
        .update({
          'status': 'confirmado',
          'confirmed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', requestId);
  }

  Future<void> refuse(String requestId, String reason) async {
    await _supabase
        .from('exam_requests')
        .update({
          'status': 'recusado',
          'refused_reason': reason,
        })
        .eq('id', requestId);
  }

  Future<void> complete(String requestId) async {
    await _supabase
        .from('exam_requests')
        .update({'status': 'concluido'}).eq('id', requestId);
  }

  Future<void> cancel(String requestId) async {
    await _supabase
        .from('exam_requests')
        .update({'status': 'cancelado'}).eq('id', requestId);
  }
}

final examRequestsProvider =
    StateNotifierProvider<ExamRequestsNotifier, AsyncValue<List<ExamRequest>>>((ref) {
  return ExamRequestsNotifier(Supabase.instance.client);
});
