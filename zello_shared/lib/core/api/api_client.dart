import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_endpoints.dart';
import '../demo_data.dart';

class ApiClient {
  late final Dio _dio;
  late final SupabaseClient _supabase;
  bool _useDemoData = false;
  String? _currentPatientId;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(AuthInterceptor());
    _supabase = Supabase.instance.client;
  }

  bool get useDemoData => _useDemoData;
  String? get currentPatientId => _currentPatientId;

  void enableDemo() {
    _useDemoData = true;
  }

  void disableDemo() {
    _useDemoData = false;
  }

  Future<void> loadCurrentPatient(String userId) async {
    try {
      final data = await _supabase
          .from('patients')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      _currentPatientId = data?['id'] as String?;
    } catch (_) {
      _currentPatientId = null;
    }
  }

  void clearPatientContext() {
    _currentPatientId = null;
  }

  Future<void> _ensurePatientLoaded() async {
    if (_currentPatientId != null) return;
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await loadCurrentPatient(session.user.id);
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _tryOrDemo<T>(
    Future<T> Function() request,
    T demoData,
  ) async {
    if (_useDemoData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return demoData as Map<String, dynamic>;
    }
    try {
      return (await request()) as Map<String, dynamic>;
    } on DioException {
      if (_useDemoData) return demoData as Map<String, dynamic>;
      rethrow;
    }
  }

  Future<List<dynamic>> _tryOrDemoList<T>(
    Future<T> Function() request,
    List<dynamic> demoData,
  ) async {
    if (_useDemoData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return demoData;
    }
    try {
      return (await request()) as List<dynamic>;
    } on DioException {
      if (_useDemoData) return demoData;
      rethrow;
    }
  }

  Future<void> _tryOrDemoVoid(
    Future<void> Function() request,
  ) async {
    if (_useDemoData) return;
    try {
      await request();
    } on DioException {
      if (_useDemoData) return;
      rethrow;
    }
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    return _tryOrDemo(
      () async {
        final response =
            await _supabase.auth.signInWithPassword(email: email, password: password);
        final user = response.user!;
        final session = response.session!;
        final meta = user.userMetadata ?? {};
        return {
          'id': user.id,
          'name': meta['name'] ?? email.split('@').first,
          'email': email,
          'phone': meta['phone'] ?? '',
          'token': session.accessToken,
        };
      },
      demoUser.toJson(),
    );
  }

  Future<void> signUp(String email, String password, {String? name}) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Conversations
  Future<List<dynamic>> getConversations() async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('conversations')
            .select('conv_key, user_id, phone, status, last_message_at')
            .order('last_message_at', ascending: false);

        final userIds = data
            .map((row) => row['user_id'] as String?)
            .where((id) => id != null)
            .toList();

        Map<String, String> nameMap = {};
        if (userIds.isNotEmpty) {
          final profiles = await _supabase
              .from('profiles')
              .select('user_id, name')
              .filter('user_id', 'in', '(${userIds.join(",")})');
          nameMap = {
            for (var p in profiles)
              p['user_id'] as String: (p['name'] as String?) ?? '',
          };
        }

        final convKeys = data.map((row) => row['conv_key'] as String).toList();
        final Map<String, String> lastMsgs = {};
        final Map<String, String> lastTimes = {};
        if (convKeys.isNotEmpty) {
          final msgs = await _supabase
              .from('inbound_messages')
              .select('conv_key, text, received_at')
              .filter('conv_key', 'in',
                  '(${convKeys.map((k) => "\"$k\"").join(",")})')
              .order('received_at', ascending: false);
          for (final m in msgs) {
            final key = m['conv_key'] as String;
            if (!lastMsgs.containsKey(key)) {
              lastMsgs[key] = (m['text'] as String?) ?? '';
              lastTimes[key] = m['received_at'] as String;
            }
          }
        }

        return data.map((row) => {
          'id': row['conv_key'],
          'userId': row['user_id'],
          'userName': nameMap[row['user_id'] as String?] ?? '',
          'userPhone': row['phone'] ?? '',
          'lastMessage': lastMsgs[row['conv_key']] ?? '',
          'lastMessageTime': lastTimes[row['conv_key']] ?? row['last_message_at'],
          'status': row['status'] == 'ongoing' ? 'active' : row['status'],
          'unreadCount': 0,
        }).toList();
      },
      demoConversations,
    );
  }

  Future<List<dynamic>> getConversationMessages(String conversationId) async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('inbound_messages')
            .select('id, text, received_at, type')
            .eq('conv_key', conversationId)
            .order('received_at', ascending: true);
        return data.map((row) => {
          'id': row['id'].toString(),
          'conversationId': conversationId,
          'content': row['text'] ?? '',
          'sender': 'user',
          'timestamp': row['received_at'],
        }).toList();
      },
      demoConversationMessages,
    );
  }

  // Patients
  Future<List<dynamic>> getPatients() async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('patients')
            .select('id, name, phone, email, cpf, last_access, total_conversations, professional_id, city, state')
            .order('name');
        return data.map((row) => {
          'id': row['id'],
          'name': row['name'],
          'phone': row['phone'] ?? '',
          'email': row['email'] ?? '',
          'cpf': row['cpf'] ?? '',
          'lastAccess': row['last_access']?.toIso8601String(),
          'totalConversations': row['total_conversations'] ?? 0,
          'professionalId': row['professional_id'] as String?,
          'city': row['city'] as String?,
          'state': row['state'] as String?,
        }).toList();
      },
      demoPatients,
    );
  }

  Future<List<dynamic>> getUnassignedPatients() async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('patients')
            .select('id, name, phone, email, cpf')
            .filter('professional_id', 'is', 'null')
            .order('name');
        return data.map((row) => {
          'id': row['id'],
          'name': row['name'],
          'phone': row['phone'] ?? '',
          'email': row['email'] ?? '',
          'cpf': row['cpf'] ?? '',
        }).toList();
      },
      [],
    );
  }

  Future<void> assignPatient(String patientId, String professionalId) async {
    await _tryOrDemoVoid(() async {
      await _supabase
          .from('patients')
          .update({'professional_id': professionalId})
          .eq('id', patientId);
    });
  }

  Future<Map<String, dynamic>> getPatient(String id) async {
    return _tryOrDemo(
      () async {
        final data = await _supabase
            .from('patients')
            .select('id, name, phone, email, cpf, last_access, total_conversations, professional_id, city, state')
            .eq('id', id)
            .single();
        return {
          'id': data['id'],
          'name': data['name'],
          'phone': data['phone'] ?? '',
          'email': data['email'] ?? '',
          'cpf': data['cpf'] ?? '',
          'lastAccess': data['last_access'],
          'totalConversations': data['total_conversations'] ?? 0,
          'professionalId': data['professional_id'] as String?,
          'city': data['city'] as String?,
          'state': data['state'] as String?,
        };
      },
      Map<String, dynamic>.from(demoPatients.first),
    );
  }

  // Agents
  Future<List<dynamic>> getAgents() async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('agents')
            .select('id, name, type, status, active_conversations, total_handled, avg_response_time')
            .order('name');
        return data.map((row) => {
          'id': row['id'],
          'name': row['name'],
          'type': row['type'] ?? 'medico',
          'status': row['status'] ?? 'offline',
          'activeConversations': row['active_conversations'] ?? 0,
          'totalHandled': row['total_handled'] ?? 0,
          'avgResponseTime': (row['avg_response_time'] as num?)?.toDouble() ?? 0.0,
        }).toList();
      },
      demoAgents,
    );
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    return _tryOrDemo(
      () async {
        final convs = await _supabase
            .from('conversations')
            .select('conv_key')
            .eq('status', 'ongoing');
        final pats = await _supabase.from('patients').select('id');
        final unassigned = await _supabase
            .from('patients')
            .select('id')
            .filter('professional_id', 'is', 'null');
        final agts = await _supabase
            .from('agents')
            .select('id')
            .eq('status', 'online');
        return {
          'activeConversations': convs.length,
          'totalPatients': pats.length,
          'agentsOnline': agts.length,
          'avgResponseTime': 0.0,
          'unassignedPatients': unassigned.length,
        };
      },
      demoDashboardStats,
    );
  }

  // Hospitals
  Future<List<dynamic>> searchHospitals({
    String? cep,
    String? address,
    String? plan,
  }) async {
    return _tryOrDemoList(
      () async {
        dynamic query = _supabase
            .from('hospitals')
            .select('id, name, address, phone, latitude, longitude, distance, plan, specialties');
        if (plan != null && plan.isNotEmpty) {
          query = query.eq('plan', plan);
        }
        query = query.order('distance');
        final data = await query;
        return data.map((row) => {
          'id': row['id'],
          'name': row['name'],
          'address': row['address'] ?? '',
          'phone': row['phone'] ?? '',
          'latitude': (row['latitude'] as num?)?.toDouble() ?? 0.0,
          'longitude': (row['longitude'] as num?)?.toDouble() ?? 0.0,
          'distance': (row['distance'] as num?)?.toDouble() ?? 0.0,
          'plan': row['plan'] ?? '',
          'specialties': row['specialties'] ?? [],
        }).toList();
      },
      demoHospitals,
    );
  }

  // Medications
  Future<List<dynamic>> getMedications() async {
    await _ensurePatientLoaded();
    return _tryOrDemoList(
      () async {
        dynamic query = _supabase
            .from('medications')
            .select('id, name, dosage, frequency, prescribing_doctor, start_date, end_date, is_active, next_dose');
        if (_currentPatientId != null) {
          query = query.eq('patient_id', _currentPatientId);
        }
        final data = await query.order('name');
        return data.map((row) => {
          'id': row['id'],
          'name': row['name'],
          'dosage': row['dosage'] ?? '',
          'frequency': row['frequency'] ?? '',
          'prescribingDoctor': row['prescribing_doctor'] ?? '',
          'startDate': row['start_date'],
          'endDate': row['end_date'],
          'isActive': row['is_active'] ?? true,
          'nextDose': row['next_dose'],
        }).toList();
      },
      demoMedications,
    );
  }


  // Exams
  Future<List<dynamic>> getExams() async {
    await _ensurePatientLoaded();
    return _tryOrDemoList(
      () async {
        dynamic query = _supabase.from('exams').select(
            'id, patient_id, title, exam_type, status, result_url, requested_by, requested_at, notes');
        if (_currentPatientId != null) {
          query = query.eq('patient_id', _currentPatientId);
        }
        final data = await query.order('requested_at', ascending: false);
        return data.map((row) => {
              'id': row['id'],
              'patient_id': row['patient_id'],
              'title': row['title'] ?? '',
              'exam_type': row['exam_type'] ?? '',
              'status': row['status'] ?? 'solicitado',
              'result_url': row['result_url'],
              'requested_by': row['requested_by'],
              'requested_at': row['requested_at'],
              'notes': row['notes'],
            }).toList();
      },
      demoExams,
    );
  }

  Future<void> createExam(Map<String, dynamic> data) async {
    await _tryOrDemoVoid(() async {
      await _supabase.from('exams').insert({
        'patient_id': data['patient_id'],
        'title': data['title'],
        'exam_type': data['exam_type'] ?? '',
        'status': data['status'] ?? 'solicitado',
        'notes': data['notes'] ?? '',
        'requested_at': DateTime.now().toUtc().toIso8601String(),
      });
    });
  }

  // Consultations
  Future<List<dynamic>> getConsultations() async {
    await _ensurePatientLoaded();
    return _tryOrDemoList(
      () async {
        dynamic query = _supabase
            .from('consultations')
            .select('id, doctor_name, specialty, date, type, notes, prescriptions, status');
        if (_currentPatientId != null) {
          query = query.eq('patient_id', _currentPatientId);
        }
        final data = await query.order('date', ascending: false);
        return data.map((row) => {
          'id': row['id'],
          'doctorName': row['doctor_name'] ?? '',
          'specialty': row['specialty'] ?? '',
          'date': row['date'],
          'type': row['type'] ?? 'in_person',
          'notes': row['notes'] ?? '',
          'prescriptions': row['prescriptions'] ?? [],
          'status': row['status'] ?? 'scheduled',
        }).toList();
      },
      demoConsultations,
    );
  }

  // Therapies
  Future<List<dynamic>> getTherapies() async {
    await _ensurePatientLoaded();
    return _tryOrDemoList(
      () async {
        dynamic query = _supabase
            .from('therapies')
            .select('id, name, professional, type, frequency, start_date, end_date, status, notes');
        if (_currentPatientId != null) {
          query.eq('patient_id', _currentPatientId);
        }
        final data = await query.order('name');
        return data.map((row) => {
          'id': row['id'],
          'name': row['name'] ?? '',
          'professional': row['professional'] ?? '',
          'type': row['type'] ?? 'outro',
          'frequency': row['frequency'] ?? '',
          'startDate': row['start_date'],
          'endDate': row['end_date'],
          'status': row['status'] ?? 'ativa',
          'notes': row['notes'] ?? '',
        }).toList();
      },
      demoTherapies,
    );
  }

  // Treatments
  Future<List<dynamic>> getTreatments() async {
    await _ensurePatientLoaded();
    return _tryOrDemoList(
      () async {
        dynamic query = _supabase
            .from('treatments')
            .select('id, name, description, professional, start_date, end_date, status, notes');
        if (_currentPatientId != null) {
          query.eq('patient_id', _currentPatientId);
        }
        final data = await query.order('name');
        return data.map((row) => {
          'id': row['id'],
          'name': row['name'] ?? '',
          'description': row['description'] ?? '',
          'professional': row['professional'] ?? '',
          'startDate': row['start_date'],
          'endDate': row['end_date'],
          'status': row['status'] ?? 'ativo',
          'notes': row['notes'] ?? '',
        }).toList();
      },
      demoTreatments,
    );
  }

  // Anamneses
  Future<List<dynamic>> getAnamneses() async {
    await _ensurePatientLoaded();
    return _tryOrDemoList(
      () async {
        dynamic query = _supabase.from('anamneses').select(
            'id, date, professional, chief_complaint, history_present_illness, past_history, continuous_medication, allergies, habits, family_history, completed, rg, altura, has_depression, has_suicide_attempts, has_self_harm, mental_health_notes, allergies_details, surgeries_description, has_insurance, insurance_provider, insurance_plan, address_street, address_number, address_neighborhood, address_city, address_state, address_zip');
        if (_currentPatientId != null) {
          query.eq('patient_id', _currentPatientId);
        }
        final data = await query.order('date', ascending: false);
        return data.map((row) => {
          'id': row['id'],
          'date': row['date'],
          'professional': row['professional'] ?? '',
          'chiefComplaint': row['chief_complaint'] ?? '',
          'historyOfPresentIllness': row['history_present_illness'] ?? '',
          'pastHistory': row['past_history'] ?? '',
          'continuousMedication': row['continuous_medication'] ?? '',
          'allergies': row['allergies'] ?? '',
          'habits': row['habits'] ?? '',
          'familyHistory': row['family_history'] ?? '',
          'completed': row['completed'] ?? false,
          'rg': row['rg'] ?? '',
          'altura': row['altura'],
          'has_depression': row['has_depression'] ?? false,
          'has_suicide_attempts': row['has_suicide_attempts'] ?? false,
          'has_self_harm': row['has_self_harm'] ?? false,
          'mental_health_notes': row['mental_health_notes'] ?? '',
          'allergies_details': row['allergies_details'] ?? '',
          'surgeries_description': row['surgeries_description'] ?? '',
          'has_insurance': row['has_insurance'] ?? false,
          'insurance_provider': row['insurance_provider'] ?? '',
          'insurance_plan': row['insurance_plan'] ?? '',
          'address_street': row['address_street'] ?? '',
          'address_number': row['address_number'] ?? '',
          'address_neighborhood': row['address_neighborhood'] ?? '',
          'address_city': row['address_city'] ?? '',
          'address_state': row['address_state'] ?? '',
          'address_zip': row['address_zip'] ?? '',
        }).toList();
      },
      demoAnamneses,
    );
  }

  Future<void> saveAnamnesis(Map<String, dynamic> data) async {
    await _ensurePatientLoaded();
    if (_currentPatientId == null) return;
    final existing = await _supabase
        .from('anamneses')
        .select('id')
        .eq('patient_id', _currentPatientId!)
        .maybeSingle();
    if (existing != null) {
      await _supabase
          .from('anamneses')
          .update(data)
          .eq('id', existing['id']);
    } else {
      await _supabase.from('anamneses').insert({
        ...data,
        'patient_id': _currentPatientId,
        'date': DateTime.now().toIso8601String().split('T')[0],
      });
    }
  }

  // Send message
  Future<void> sendMessage(String conversationId, String content) async {
    await _tryOrDemoVoid(
      () async {
        await _supabase.from('inbound_messages').insert({
          'conv_key': conversationId,
          'received_at': DateTime.now().toUtc().toIso8601String(),
          'type': 'text',
          'text': content,
          'raw': {},
        });
      },
    );
  }

  // Professionals
  Future<List<dynamic>> getProfessionals() async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('professionals')
            .select('id, profile_id, type, specialty, council, council_uf, bio, created_at')
            .order('created_at', ascending: false);
        return data;
      },
      [],
    );
  }

  Future<Map<String, dynamic>> createProfessional(Map<String, dynamic> data) async {
    return _tryOrDemo(
      () async {
        final email = data['email'] as String;
        final name = data['name'] as String;
        final phone = data['phone'] as String? ?? '';

        final tempPassword =
            'prof${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}!';

        final currentSession = _supabase.auth.currentSession;

        final response = await _supabase.auth.signUp(
          email: email,
          password: tempPassword,
          data: {'name': name, 'phone': phone},
        );

        final userId = response.user?.id;
        if (userId == null) {
          throw Exception('Falha ao criar conta. Verifique se o email já está cadastrado.');
        }

        // Restaurar sessão do admin IMEDIATAMENTE após signUp,
        // pois o Supabase troca a sessão para o novo usuário automaticamente
        if (currentSession != null && currentSession.refreshToken != null) {
          try {
            await _supabase.auth.setSession(currentSession.refreshToken!);
          } catch (_) {
            await _supabase.auth.signOut();
            throw Exception(
              'Sessão do administrador expirou durante a criação do profissional. '
              'Faça login novamente.',
            );
          }
        }

        // O trigger handle_new_user já criou um profile com role 'patient'.
        // Precisamos ATUALIZAR a role para 'professional' em vez de inserir novo.
        final profileResult = await _supabase.from('profiles')
            .update({
              'role': 'professional',
              'name': name,
              'phone': phone,
            })
            .eq('user_id', userId)
            .select('id')
            .single();

        final profResult = await _supabase.from('professionals').insert({
          'profile_id': profileResult['id'],
          'type': data['type'],
          'specialty': data['specialty'] ?? '',
          'council': data['council'],
          'council_uf': data['council_uf'],
          'bio': data['bio'] ?? '',
        }).select().single();

        return {
          ...profResult,
          'temp_password': tempPassword,
        };
      },
      {},
    );
  }

  // Permissions
  Future<List<dynamic>> getProfessionalPermissions(String professionalId) async {
    return _tryOrDemoList(
      () async {
        return await _supabase
            .from('permissions')
            .select()
            .eq('professional_id', professionalId);
      },
      [],
    );
  }

  Future<void> grantPermission(String professionalId, String permission, {String? grantedBy}) async {
    await _tryOrDemoVoid(() async {
      if (grantedBy == null) {
        // Fallback: busca o profile_id do admin logado
        final profile = await _supabase
            .from('profiles')
            .select('id')
            .eq('user_id', _supabase.auth.currentUser!.id)
            .maybeSingle();
        grantedBy = profile?['id'] as String?;
        if (grantedBy == null) {
          throw Exception('Perfil do administrador não encontrado');
        }
      }
      await _supabase.from('permissions').insert({
        'professional_id': professionalId,
        'permission': permission,
        'granted_by': grantedBy,
      });
    });
  }

  Future<void> revokePermission(String professionalId, String permission) async {
    await _tryOrDemoVoid(() async {
      await _supabase
          .from('permissions')
          .delete()
          .eq('professional_id', professionalId)
          .eq('permission', permission);
    });
  }

  // Professional Availability
  Future<List<dynamic>> getAvailability(String professionalId) async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('professional_availability')
            .select()
            .eq('professional_id', professionalId)
            .order('date')
            .order('start_time');
        return data;
      },
      [],
    );
  }

  Future<List<dynamic>> getAvailableSlots(String professionalId) async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('professional_availability')
            .select()
            .eq('professional_id', professionalId)
            .eq('is_booked', false)
            .gte('date', DateTime.now().toIso8601String().split('T')[0])
            .order('date')
            .order('start_time');
        return data;
      },
      [],
    );
  }

  Future<void> createAvailabilitySlot(Map<String, dynamic> data) async {
    await _tryOrDemoVoid(() async {
      await _supabase.from('professional_availability').insert(data);
    });
  }

  // Insurances
  Future<List<dynamic>> getInsurances(String patientId) async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('insurances')
            .select()
            .eq('patient_id', patientId)
            .eq('is_active', true)
            .order('created_at', ascending: false);
        return data;
      },
      [],
    );
  }

  Future<void> createInsurance(Map<String, dynamic> data) async {
    await _tryOrDemoVoid(() async {
      await _supabase.from('insurances').insert(data);
    });
  }

  // AI Recommendations
  Future<Map<String, dynamic>> createAIRecommendation(Map<String, dynamic> data) async {
    return _tryOrDemo(
      () async {
        final result = await _supabase
            .from('ai_recommendations')
            .insert(data)
            .select()
            .single();
        return result;
      },
      {},
    );
  }

  // Config
  Future<Map<String, dynamic>> getConfig() async {
    return _tryOrDemo(
      () async {
        return {'autoReply': true, 'notifications': true, 'analytics': false};
      },
      {'autoReply': true, 'notifications': true, 'analytics': false},
    );
  }

  Future<void> updateConfig(Map<String, dynamic> config) async {
    await _tryOrDemoVoid(() async {});
  }

  // Patient-scoped queries (admin)
  Future<List<dynamic>> getPatientConsultations(String patientId) async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('consultations')
            .select('id, doctor_name, specialty, date, type, notes, prescriptions, status')
            .eq('patient_id', patientId)
            .order('date', ascending: false);
        return data.map((row) => {
          'id': row['id'],
          'doctorName': row['doctor_name'] ?? '',
          'specialty': row['specialty'] ?? '',
          'date': row['date'],
          'type': row['type'] ?? 'in_person',
          'notes': row['notes'] ?? '',
          'prescriptions': row['prescriptions'] ?? [],
          'status': row['status'] ?? 'scheduled',
        }).toList();
      },
      demoConsultations,
    );
  }

  Future<List<dynamic>> getPatientMedications(String patientId) async {
    return _tryOrDemoList(
      () async {
        final data = await _supabase
            .from('medications')
            .select('id, name, dosage, frequency, prescribing_doctor, start_date, end_date, is_active, next_dose')
            .eq('patient_id', patientId)
            .order('name');
        return data.map((row) => {
          'id': row['id'],
          'name': row['name'],
          'dosage': row['dosage'] ?? '',
          'frequency': row['frequency'] ?? '',
          'prescribingDoctor': row['prescribing_doctor'] ?? '',
          'startDate': row['start_date'],
          'endDate': row['end_date'],
          'isActive': row['is_active'] ?? true,
          'nextDose': row['next_dose'],
        }).toList();
      },
      demoMedications,
    );
  }


  // Create methods (admin)

  Future<void> createConsultation(Map<String, dynamic> data) async {
    await _tryOrDemoVoid(() async {
      await _supabase.from('consultations').insert({
        'patient_id': data['patient_id'],
        'doctor_name': data['doctor_name'],
        'specialty': data['specialty'] ?? '',
        'date': data['date'],
        'type': data['type'] ?? 'in_person',
        'notes': data['notes'] ?? '',
        'prescriptions': data['prescriptions'] ?? [],
        'status': data['status'] ?? 'scheduled',
      });
    });
  }

  Future<void> createMedication(Map<String, dynamic> data) async {
    await _tryOrDemoVoid(() async {
      await _supabase.from('medications').insert({
        'patient_id': data['patient_id'],
        'name': data['name'],
        'dosage': data['dosage'] ?? '',
        'frequency': data['frequency'] ?? '',
        'prescribing_doctor': data['prescribing_doctor'] ?? '',
        'prescribed_by': data['prescribed_by'],
        'start_date': data['start_date'],
        'end_date': data['end_date'],
        'is_active': data['is_active'] ?? true,
        'observations': data['observations'] ?? '',
      });
    });
  }

  // Create patient (admin - no auth user required)
  Future<void> createPatient(Map<String, dynamic> data) async {
    await _tryOrDemoVoid(() async {
      await _supabase.from('patients').insert({
        'name': data['name'],
        'email': data['email'],
        'phone': data['phone'],
        'cpf': data['cpf'],
        'birth_date': data['birth_date'],
      });
    });
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {}
    handler.next(err);
  }
}