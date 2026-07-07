import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/professional_availability.dart';

class AvailabilityNotifier extends StateNotifier<AsyncValue<List<ProfessionalAvailability>>> {
  final SupabaseClient _supabase;

  AvailabilityNotifier(this._supabase) : super(const AsyncValue.loading());

  Future<void> load(String professionalId, {DateTime? date}) async {
    state = const AsyncValue.loading();
    try {
      dynamic query = _supabase
          .from('professional_availability')
          .select()
          .eq('professional_id', professionalId);
      if (date != null) {
        query = query.eq('date', date.toIso8601String().split('T')[0]);
      }
      final data = await query.order('date').order('start_time');
      final list = data.map((row) => ProfessionalAvailability.fromJson(row)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadAvailable(String professionalId) async {
    state = const AsyncValue.loading();
    try {
      final data = await _supabase
          .from('professional_availability')
          .select()
          .eq('professional_id', professionalId)
          .eq('is_booked', false)
          .gte('date', DateTime.now().toIso8601String().split('T')[0])
          .order('date')
          .order('start_time');
      final list = data.map((row) => ProfessionalAvailability.fromJson(row)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> create(ProfessionalAvailability slot) async {
    await _supabase.from('professional_availability').insert(slot.toJson()..remove('id'));
  }

  Future<void> markBooked(String slotId) async {
    await _supabase
        .from('professional_availability')
        .update({'is_booked': true}).eq('id', slotId);
  }

  Future<void> markFree(String slotId) async {
    await _supabase
        .from('professional_availability')
        .update({'is_booked': false}).eq('id', slotId);
  }

  Future<void> delete(String id) async {
    await _supabase.from('professional_availability').delete().eq('id', id);
  }
}

final availabilityProvider =
    StateNotifierProvider<AvailabilityNotifier, AsyncValue<List<ProfessionalAvailability>>>((ref) {
  return AvailabilityNotifier(Supabase.instance.client);
});
