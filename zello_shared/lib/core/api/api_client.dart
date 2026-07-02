import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

class ApiClient {
  late final Dio _dio;

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
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  // Conversations
  Future<List<dynamic>> getConversations() async {
    final response = await _dio.get(ApiEndpoints.conversations);
    return response.data;
  }

  Future<List<dynamic>> getConversationMessages(String conversationId) async {
    final response = await _dio.get(
      ApiEndpoints.conversationMessages(conversationId),
    );
    return response.data;
  }

  // Patients
  Future<List<dynamic>> getPatients() async {
    final response = await _dio.get(ApiEndpoints.patients);
    return response.data;
  }

  Future<Map<String, dynamic>> getPatient(String id) async {
    final response = await _dio.get(ApiEndpoints.patient(id));
    return response.data;
  }

  // Agents
  Future<List<dynamic>> getAgents() async {
    final response = await _dio.get(ApiEndpoints.agents);
    return response.data;
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _dio.get(ApiEndpoints.dashboardStats);
    return response.data;
  }

  // Hospitals
  Future<List<dynamic>> searchHospitals({
    String? cep,
    String? address,
    String? plan,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.hospitalSearch,
      data: {'cep': cep, 'address': address, 'plan': plan},
    );
    return response.data;
  }

  // Medications
  Future<List<dynamic>> getMedications() async {
    final response = await _dio.get(ApiEndpoints.medications);
    return response.data;
  }

  // Exams
  Future<List<dynamic>> getExams() async {
    final response = await _dio.get(ApiEndpoints.exams);
    return response.data;
  }

  // Consultations
  Future<List<dynamic>> getConsultations() async {
    final response = await _dio.get(ApiEndpoints.consultations);
    return response.data;
  }

  // Config
  Future<Map<String, dynamic>> getConfig() async {
    final response = await _dio.get(ApiEndpoints.config);
    return response.data;
  }

  Future<void> updateConfig(Map<String, dynamic> config) async {
    await _dio.post(ApiEndpoints.config, data: config);
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
    if (err.response?.statusCode == 401) {
      // Token expired or invalid
    }
    handler.next(err);
  }
}
