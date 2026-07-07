import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/professional.dart';

class ProfessionalsNotifier extends StateNotifier<AsyncValue<List<Professional>>> {
  final SupabaseClient _supabase;

  ProfessionalsNotifier(this._supabase) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _supabase
          .from('professionals')
          .select('*, profiles!inner(name, phone)')
          .order('created_at', ascending: false);
      final list = data.map((row) => Professional.fromJson(row)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> create(Professional professional) async {
    await _supabase.from('professionals').insert(professional.toJson()..remove('id'));
    await load();
  }

  Future<void> update(Professional professional) async {
    await _supabase
        .from('professionals')
        .update(professional.toJson())
        .eq('id', professional.id);
    await load();
  }

  Future<void> delete(String id) async {
    await _supabase.from('professionals').delete().eq('id', id);
    await load();
  }
}

final professionalsProvider =
    StateNotifierProvider<ProfessionalsNotifier, AsyncValue<List<Professional>>>((ref) {
  final supabase = Supabase.instance.client;
  return ProfessionalsNotifier(supabase);
});
