import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/insurance.dart';

class InsurancesNotifier extends StateNotifier<AsyncValue<List<Insurance>>> {
  final SupabaseClient _supabase;

  InsurancesNotifier(this._supabase) : super(const AsyncValue.loading());

  Future<void> loadByPatient(String patientId) async {
    state = const AsyncValue.loading();
    try {
      final data = await _supabase
          .from('insurances')
          .select()
          .eq('patient_id', patientId)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      final rows = List<Map<String, dynamic>>.from(data as List);
      final list = rows.map((row) => Insurance.fromJson(row)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> create(Insurance insurance) async {
    await _supabase.from('insurances').insert(insurance.toJson()..remove('id'));
    await loadByPatient(insurance.patientId);
  }

  Future<void> deactivate(String id, String patientId) async {
    await _supabase.from('insurances').update({'is_active': false}).eq('id', id);
    await loadByPatient(patientId);
  }
}

final insurancesProvider =
    StateNotifierProvider<InsurancesNotifier, AsyncValue<List<Insurance>>>((ref) {
  return InsurancesNotifier(Supabase.instance.client);
});
