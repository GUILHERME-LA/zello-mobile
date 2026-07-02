class ApiEndpoints {
  static const String baseUrl = 'https://honorix.app.n8n.cloud';

  static const String login = '/webhook/auth/login';

  static const String conversations = '/webhook/conversas';
  static String conversationMessages(String id) =>
      '/webhook/conversas/$id/mensagens';

  static const String patients = '/webhook/pacientes';
  static String patient(String id) => '/webhook/pacientes/$id';

  static const String agents = '/webhook/agentes/status';

  static const String dashboardStats = '/webhook/dashboard/stats';

  static const String hospitalSearch = '/webhook/hospitais/buscar';

  static const String medications = '/webhook/medications';
  static String medication(String id) => '/webhook/medications/$id';

  static const String exams = '/webhook/exams';
  static String exam(String id) => '/webhook/exams/$id';

  static const String consultations = '/webhook/consultations';
  static String consultation(String id) => '/webhook/consultations/$id';

  static const String config = '/webhook/config';
}
