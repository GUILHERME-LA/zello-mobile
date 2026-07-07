import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/session_note.dart';

/// Provider de notas de sessão (evolução psicológica) por paciente
final patientSessionNotesProvider =
    FutureProvider.family<List<SessionNote>, String>((ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('session_notes')
      .select()
      .eq('patient_id', patientId)
      .order('date', ascending: false);
  return data.map((row) => SessionNote.fromJson(row)).toList();
});

class SessionNotesNotifier {
  final SupabaseClient _supabase;

  SessionNotesNotifier(this._supabase);

  Future<void> create(SessionNote note) async {
    await _supabase.from('session_notes').insert(note.toJson()..remove('id'));
  }
}

final sessionNotesProvider = Provider<SessionNotesNotifier>((ref) {
  return SessionNotesNotifier(Supabase.instance.client);
});
