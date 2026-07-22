import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/exam.dart';

final patientExamsProvider =
    FutureProvider.family<List<Exam>, String>((ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('exams')
      .select('id, patient_id, title, exam_type, status, result_url, requested_by, requested_at, notes')
      .eq('patient_id', patientId)
      .order('requested_at', ascending: false);
  final rows = List<Map<String, dynamic>>.from(data as List);
  return rows.map((row) => Exam.fromJson(row)).toList();
});
