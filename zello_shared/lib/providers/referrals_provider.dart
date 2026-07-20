import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/referral.dart';

/// Provider de encaminhamentos por paciente
final patientReferralsProvider =
    FutureProvider.family<List<Referral>, String>((ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('referrals')
      .select()
      .eq('patient_id', patientId)
      .order('created_at', ascending: false);
  final rows = List<Map<String, dynamic>>.from(data as List);
  return rows.map((row) => Referral.fromJson(row)).toList();
});

class ReferralsNotifier {
  final SupabaseClient _supabase;

  ReferralsNotifier(this._supabase);

  Future<void> create(Referral referral) async {
    await _supabase.from('referrals').insert(referral.toJson()..remove('id'));
  }
}

final referralsProvider = Provider<ReferralsNotifier>((ref) {
  return ReferralsNotifier(Supabase.instance.client);
});
