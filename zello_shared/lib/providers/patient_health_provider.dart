import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/surgery.dart';
import '../models/hospitalization.dart';
import '../models/symptom.dart';
import '../models/allergy.dart';
import '../models/vaccine.dart';
import '../models/health_profile.dart';
import 'auth_provider.dart';
import 'api_client_provider.dart';

// ============================================================
// Provider que resolve o patient_id real da tabela patients
// ============================================================

final currentPatientIdProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(authProvider);
  final api = ref.read(apiClientProvider);

  // Demo mode — não tem Supabase real
  if (api.useDemoData || auth.status == ZelloAuthStatus.unauthenticated) {
    return null;
  }

  final userId = auth.user?.id;
  final userName = auth.user?.name;
  final userEmail = auth.user?.email;
  if (userId == null || userId.isEmpty) return null;

  final supabase = Supabase.instance.client;

  // Tenta encontrar o patient_id existente
  final data = await supabase
      .from('patients')
      .select('id')
      .eq('user_id', userId)
      .maybeSingle();

  if (data != null) {
    return data['id'] as String;
  }

  // Não achou — cria um registro novo (mesmo fluxo do signUp)
  try {
    final newPatient = await supabase
        .from('patients')
        .insert({
          'user_id': userId,
          'name': userName ?? userEmail?.split('@').first ?? 'Paciente',
          'email': userEmail ?? '',
          'phone': auth.user?.phone ?? '',
        })
        .select('id')
        .single();
    return newPatient['id'] as String;
  } catch (_) {
    // Se falhou (ex: sem permissão), retorna null
    return null;
  }
});

// ============================================================
// Providers Individuais (cada um observa uma tabela)
// ============================================================

final patientSurgeriesProvider =
    FutureProvider.family<List<Surgery>, String>((ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('surgeries')
      .select()
      .eq('patient_id', patientId)
      .order('date', ascending: false);
  final rows = List<Map<String, dynamic>>.from(data as List);
  return rows.map((row) => Surgery.fromJson(row)).toList();
});

final patientHospitalizationsProvider =
    FutureProvider.family<List<Hospitalization>, String>(
        (ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('hospitalizations')
      .select()
      .eq('patient_id', patientId)
      .order('start_date', ascending: false);
  final rows = List<Map<String, dynamic>>.from(data as List);
  return rows.map((row) => Hospitalization.fromJson(row)).toList();
});

final patientSymptomsProvider =
    FutureProvider.family<List<Symptom>, String>((ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('symptoms')
      .select()
      .eq('patient_id', patientId)
      .order('created_at', ascending: false);
  final rows = List<Map<String, dynamic>>.from(data as List);
  return rows.map((row) => Symptom.fromJson(row)).toList();
});

final patientAllergiesProvider =
    FutureProvider.family<List<Allergy>, String>((ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('allergies')
      .select()
      .eq('patient_id', patientId)
      .order('name');
  final rows = List<Map<String, dynamic>>.from(data as List);
  return rows.map((row) => Allergy.fromJson(row)).toList();
});

final patientVaccinesProvider =
    FutureProvider.family<List<Vaccine>, String>((ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('vaccines')
      .select()
      .eq('patient_id', patientId)
      .order('date', ascending: false);
  final rows = List<Map<String, dynamic>>.from(data as List);
  return rows.map((row) => Vaccine.fromJson(row)).toList();
});

final patientHealthProfileProvider =
    FutureProvider.family<HealthProfile?, String>((ref, patientId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('health_profiles')
      .select()
      .eq('patient_id', patientId)
      .maybeSingle();
  if (data == null) return null;
  return HealthProfile.fromJson(data);
});

// ============================================================
// Notifiers (CRUD)
// ============================================================

class PatientHealthNotifier {
  final SupabaseClient _supabase;

  PatientHealthNotifier(this._supabase);

  // Medicacoes
  Future<void> deleteMedication(String id) async {
    await _supabase.from('medications').delete().eq('id', id);
  }

  // Cirurgias
  Future<void> addSurgery(Surgery surgery) async {
    await _supabase.from('surgeries').insert(surgery.toJson()..remove('id'));
  }

  Future<void> deleteSurgery(String id) async {
    await _supabase.from('surgeries').delete().eq('id', id);
  }

  // Internacoes
  Future<void> addHospitalization(Hospitalization h) async {
    await _supabase.from('hospitalizations').insert(h.toJson()..remove('id'));
  }

  Future<void> deleteHospitalization(String id) async {
    await _supabase.from('hospitalizations').delete().eq('id', id);
  }

  // Sintomas
  Future<void> addSymptom(Symptom symptom) async {
    await _supabase.from('symptoms').insert(symptom.toJson()..remove('id'));
  }

  Future<void> deleteSymptom(String id) async {
    await _supabase.from('symptoms').delete().eq('id', id);
  }

  // Alergias
  Future<void> addAllergy(Allergy allergy) async {
    await _supabase.from('allergies').insert(allergy.toJson()..remove('id'));
  }

  Future<void> deleteAllergy(String id) async {
    await _supabase.from('allergies').delete().eq('id', id);
  }

  // Vacinas
  Future<void> addVaccine(Vaccine vaccine) async {
    await _supabase.from('vaccines').insert(vaccine.toJson()..remove('id'));
  }

  Future<void> deleteVaccine(String id) async {
    await _supabase.from('vaccines').delete().eq('id', id);
  }

  // HealthProfile
  Future<void> saveHealthProfile(HealthProfile profile) async {
    final existing = await _supabase
        .from('health_profiles')
        .select('id')
        .eq('patient_id', profile.patientId)
        .maybeSingle();
    if (existing != null) {
      await _supabase
          .from('health_profiles')
          .update(profile.toJson()..remove('id'))
          .eq('id', existing['id']);
    } else {
      await _supabase
          .from('health_profiles')
          .insert(profile.toJson()..remove('id'));
    }
  }
}

final patientHealthProvider = Provider<PatientHealthNotifier>((ref) {
  return PatientHealthNotifier(Supabase.instance.client);
});
