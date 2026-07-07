import '../models/user.dart';

User demoUser = const User(
  id: 'demo-user-1',
  name: 'João Pereira',
  email: 'joao@email.com',
  phone: '(11) 98888-7777',
  token: 'demo-token',
);

List<Map<String, dynamic>> demoMedications = [
  {
    'id': 'med-1',
    'name': 'Losartana Potássica',
    'dosage': '50mg',
    'frequency': '1x ao dia',
    'prescribingDoctor': 'Dra. Beatriz Almeida',
    'startDate': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
    'endDate': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
    'isActive': true,
    'nextDose': DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
  },
  {
    'id': 'med-2',
    'name': 'Omeprazol',
    'dosage': '20mg',
    'frequency': '1x ao dia - jejum',
    'prescribingDoctor': 'Dra. Beatriz Almeida',
    'startDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    'endDate': null,
    'isActive': true,
    'nextDose': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
  },
  {
    'id': 'med-3',
    'name': 'Vitamina D',
    'dosage': '2000 UI',
    'frequency': '1x ao dia',
    'prescribingDoctor': 'Dr. Carlos Mendes',
    'startDate': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
    'endDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    'isActive': true,
    'nextDose': DateTime.now().add(const Duration(hours: 10)).toIso8601String(),
  },
];

List<Map<String, dynamic>> demoExams = [
  {
    'id': 'exam-1',
    'name': 'Hemograma Completo',
    'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    'requestingPhysician': 'Dra. Beatriz Almeida',
    'labFacility': 'Lab Saúde Plus',
    'status': 'available',
    'resultUrl': '',
    'notes': 'Resultados dentro da normalidade. Hemoglobina: 14.2 g/dL',
  },
  {
    'id': 'exam-2',
    'name': 'Glicemia em Jejum',
    'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    'requestingPhysician': 'Dra. Beatriz Almeida',
    'labFacility': 'Lab Saúde Plus',
    'status': 'available',
    'resultUrl': '',
    'notes': 'Glicemia: 92 mg/dL - Normal',
  },
  {
    'id': 'exam-3',
    'name': 'Colesterol Total',
    'date': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
    'requestingPhysician': 'Dr. Carlos Mendes',
    'labFacility': 'Diagnósticos Brasil',
    'status': 'pending',
    'resultUrl': '',
    'notes': '',
  },
  {
    'id': 'exam-4',
    'name': 'Ultrassom Abdome',
    'date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    'requestingPhysician': 'Dr. Carlos Mendes',
    'labFacility': 'Imagem Center',
    'status': 'pending',
    'resultUrl': '',
    'notes': '',
  },
];

List<Map<String, dynamic>> demoConsultations = [
  {
    'id': 'cons-1',
    'doctorName': 'Dra. Beatriz Almeida',
    'specialty': 'Clínico Geral',
    'date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
    'type': 'tele',
    'notes': 'Retorno para avaliar exames de sangue',
    'prescriptions': <String>[],
    'status': 'scheduled',
  },
  {
    'id': 'cons-2',
    'doctorName': 'Dr. Carlos Mendes',
    'specialty': 'Cardiologista',
    'date': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
    'type': 'in_person',
    'notes': 'Avaliação anual de rotina',
    'prescriptions': <String>[],
    'status': 'scheduled',
  },
  {
    'id': 'cons-3',
    'doctorName': 'Dra. Fernanda Lima',
    'specialty': 'Dermatologista',
    'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
    'type': 'in_person',
    'notes': 'Consulta de rotina - tudo ok',
    'prescriptions': <String>['Protetor solar FPS 50'],
    'status': 'completed',
  },
];

List<Map<String, dynamic>> demoHospitals = [
  {
    'id': 'hosp-1',
    'name': 'Hospital São Lucas',
    'address': 'Rua Augusta, 1500 - Consolação, SP',
    'phone': '(11) 3333-1000',
    'latitude': -23.561,
    'longitude': -46.656,
    'distance': 2.3,
    'plan': 'Unimed',
    'specialties': <String>['Cardiologia', 'Pediatria', 'Ortopedia'],
  },
  {
    'id': 'hosp-2',
    'name': 'Hospital Albert Einstein',
    'address': 'Av. Albert Einstein, 627 - Morumbi, SP',
    'phone': '(11) 2151-1233',
    'latitude': -23.598,
    'longitude': -46.719,
    'distance': 5.8,
    'plan': 'Unimed',
    'specialties': <String>['Oncologia', 'Cardiologia', 'Neurologia'],
  },
  {
    'id': 'hosp-3',
    'name': 'Hospital Sírio-Libanês',
    'address': 'Rua Dona Adma Jafet, 91 - Bela Vista, SP',
    'phone': '(11) 3394-0100',
    'latitude': -23.560,
    'longitude': -46.643,
    'distance': 1.5,
    'plan': 'Bradesco Saúde',
    'specialties': <String>['Cardiologia', 'Cirurgia Geral'],
  },
];

List<Map<String, dynamic>> demoAgents = [
  {
    'id': 'agent-1',
    'name': 'Dra. Olga',
    'type': 'medico',
    'status': 'online',
    'activeConversations': 12,
    'totalHandled': 345,
    'avgResponseTime': 2.4,
  },
  {
    'id': 'agent-2',
    'name': 'Dr. Carlos',
    'type': 'medico',
    'status': 'online',
    'activeConversations': 8,
    'totalHandled': 234,
    'avgResponseTime': 3.1,
  },
  {
    'id': 'agent-3',
    'name': 'Psicóloga Ana',
    'type': 'psicologo',
    'status': 'busy',
    'activeConversations': 5,
    'totalHandled': 189,
    'avgResponseTime': 4.2,
  },
  {
    'id': 'agent-4',
    'name': 'Dra. Beatriz',
    'type': 'medico',
    'status': 'offline',
    'activeConversations': 0,
    'totalHandled': 156,
    'avgResponseTime': 1.8,
  },
];

List<Map<String, dynamic>> demoConversations = [
  {
    'id': 'conv-1',
    'userId': 'user-1',
    'userName': 'Ana Beatriz',
    'userPhone': '(11) 98888-0001',
    'lastMessage': 'Preciso de ajuda urgente com minha medicação',
    'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
    'agentType': 'medico',
    'status': 'active',
    'unreadCount': 3,
  },
  {
    'id': 'conv-2',
    'userId': 'user-2',
    'userName': 'Carlos Eduardo',
    'userPhone': '(11) 97777-0002',
    'lastMessage': 'Obrigado pela orientação, Dra. Olga',
    'lastMessageTime': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    'agentType': 'medico',
    'status': 'active',
    'unreadCount': 0,
  },
];

Map<String, dynamic> demoDashboardStats = {
  'activeConversations': 42,
  'totalPatients': 1234,
  'agentsOnline': 6,
  'avgResponseTime': 3.2,
};

List<Map<String, dynamic>> demoPatients = [
  {
    'id': 'pat-1',
    'name': 'Ana Beatriz Silva',
    'phone': '(11) 98888-0001',
    'email': 'ana@email.com',
    'cpf': '123.456.789-01',
    'totalConversations': 15,
    'lastAccess': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
  },
  {
    'id': 'pat-2',
    'name': 'Carlos Eduardo Santos',
    'phone': '(11) 97777-0002',
    'email': 'carlos@email.com',
    'cpf': '123.456.789-02',
    'totalConversations': 8,
    'lastAccess': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  },
];

List<Map<String, dynamic>> demoConversationMessages = [
  {
    'id': 'msg-1',
    'conversationId': 'c1',
    'content': 'Olá, preciso de ajuda com minha pressão arterial',
    'sender': 'user',
    'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
  },
  {
    'id': 'msg-2',
    'conversationId': 'c1',
    'content': 'Olá! Vou ajudar você. Poderia me informar qual foi a última medição?',
    'sender': 'agent',
    'timestamp': DateTime.now().subtract(const Duration(minutes: 9)).toIso8601String(),
  },
];
