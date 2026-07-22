import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/therapy.dart';

final patientTherapiesProvider =
    FutureProvider.family<List<Therapy>, String>((ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('therapies')
      .select('id, name, professional, type, frequency, start_date, end_date, status, notes')
      .eq('patient_id', patientId)
      .order('name');
  final rows = List<Map<String, dynamic>>.from(data as List);
  return rows.map((row) {
    return Therapy.fromJson({
      'id': row['id'],
      'name': row['name'] ?? '',
      'professional': row['professional'] ?? '',
      'type': row['type'] ?? 'outro',
      'frequency': row['frequency'] ?? '',
      'startDate': row['start_date'],
      'endDate': row['end_date'],
      'status': row['status'] ?? 'ativa',
      'notes': row['notes'] ?? '',
    });
  }).toList();
});
