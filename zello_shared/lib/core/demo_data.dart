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

List<Map<String, dynamic>> demoTherapies = [
  {
    'id': 'ther-1',
    'name': 'Fisioterapia Respiratória',
    'professional': 'Dra. Helena Souza',
    'type': 'fisica',
    'frequency': '3x por semana',
    'startDate': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
    'endDate': DateTime.now().add(const Duration(days: 40)).toIso8601String(),
    'status': 'ativa',
    'notes': 'Exercícios de expansão pulmonar',
  },
  {
    'id': 'ther-2',
    'name': 'Terapia Cognitivo-Comportamental',
    'professional': 'Psicólogo Ricardo Antunes',
    'type': 'psicologica',
    'frequency': '1x por semana',
    'startDate': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
    'endDate': null,
    'status': 'ativa',
    'notes': 'Acompanhamento de ansiedade',
  },
  {
    'id': 'ther-3',
    'name': 'Fonoaudiologia',
    'professional': 'Dra. Paula Nunes',
    'type': 'fonoaudiologica',
    'frequency': '2x por semana',
    'startDate': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
    'endDate': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    'status': 'concluida',
    'notes': 'Tratamento de disfagia encerrado',
  },
];

List<Map<String, dynamic>> demoTreatments = [
  {
    'id': 'treat-1',
    'name': 'Controle de Hipertensão',
    'description': 'Acompanhamento e ajuste de medicação para pressão arterial',
    'professional': 'Dra. Beatriz Almeida',
    'startDate': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
    'endDate': null,
    'status': 'ativo',
    'notes': 'Reavaliar pressão mensalmente',
  },
  {
    'id': 'treat-2',
    'name': 'Tratamento de Diabetes Tipo 2',
    'description': 'Gestão glicêmica e orientação nutricional',
    'professional': 'Dr. Carlos Mendes',
    'startDate': DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
    'endDate': null,
    'status': 'ativo',
    'notes': 'Hemoglobina glicada em acompanhamento',
  },
  {
    'id': 'treat-3',
    'name': 'Pós-operatório de Apendicectomia',
    'description': 'Recuperação cirúrgica e cuidados de ferida',
    'professional': 'Dr. Marcos Lima',
    'startDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    'endDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    'status': 'concluido',
    'notes': 'Cicatrização completa',
  },
];

List<Map<String, dynamic>> demoAnamneses = [
  {
    'id': 'anam-1',
    'date': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    'professional': 'Dra. Beatriz Almeida',
    'chiefComplaint': 'Cefaleia recorrente',
    'historyOfPresentIllness': 'Episódios de dor de cabeça 3x por semana, intensidade moderada',
    'pastHistory': 'Hipertensão arterial desde 2020',
    'continuousMedication': 'Losartana 50mg, Omeprazol 20mg',
    'allergies': 'Penicilina',
    'habits': 'Não fumante, etilismo social aos fins de semana',
    'familyHistory': 'Pai com histórico de hipertensão',
    'completed': true,
  },
];
