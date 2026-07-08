import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';
import 'admin_shell.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';

// Admin imports
import '../features/admin/dashboard/screens/dashboard_screen.dart';
import '../features/admin/patients/screens/patients_screen.dart';
import '../features/admin/patients/screens/patient_detail_screen.dart';
import '../features/admin/patients/screens/unassigned_patients_screen.dart';
import '../features/admin/conversations/screens/conversations_screen.dart';
import '../features/admin/agents/screens/agents_screen.dart';
import '../features/admin/hospitals/screens/hospitals_screen.dart';
import '../features/admin/settings/screens/settings_screen.dart';
import '../features/admin/professionals/screens/professionals_screen.dart';
import '../features/admin/professionals/screens/professional_detail_screen.dart';
import '../features/admin/professionals/screens/create_professional_screen.dart';
import '../features/admin/professionals/screens/professional_permissions_screen.dart';
import '../features/admin/agenda/screens/agenda_screen.dart';
import '../features/admin/solicitacoes/screens/solicitacoes_screen.dart';

// Patient imports
import '../features/patient/home/screens/home_screen.dart';
import '../features/patient/chat/screens/chat_screen.dart';
import '../features/patient/medications/screens/medications_screen.dart';
import '../features/patient/exams/screens/exams_screen.dart';
import '../features/patient/consultations/screens/consultations_screen.dart';
import '../features/patient/hospitals/screens/hospitals_screen.dart';
import '../features/patient/profile/screens/profile_screen.dart';
import '../features/patient/settings/screens/settings_screen.dart';
import '../features/patient/agenda/screens/agenda_screen.dart';
import '../features/patient/exames/screens/exam_status_screen.dart';
import '../features/patient/convenio/screens/convenio_screen.dart';
import '../features/patient/convenio/screens/convenio_result_screen.dart';
import '../features/patient/prontuario/screens/prontuario_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final auth = ProviderScope.containerOf(context).read(authProvider);

    // Aguarda recuperação de sessão
    if (auth.status == ZelloAuthStatus.initial) return null;

    final isLoggedIn = auth.status == ZelloAuthStatus.authenticated;
    final location = state.matchedLocation;
    final isOnLogin = location == '/login' || location == '/signup';

    // Não logado → login
    if (!isLoggedIn && !isOnLogin) return '/login';
    if (!isLoggedIn) return null;

    // Logado na página de login → redireciona conforme role
    if (isLoggedIn && isOnLogin) {
      if (auth.isAdmin || auth.isProfessional) return '/admin/dashboard';
      return '/home';
    }

    // Logado: verifica acesso baseado no role
    final isPatient = auth.isPatient;
    final isAdmin = auth.isAdmin;
    final isProfessional = auth.isProfessional;

    // Paciente tentando acessar rota admin
    if (isPatient && location.startsWith('/admin/')) {
      return '/home';
    }

    // Admin/professional tentando acessar rota de paciente
    if ((isAdmin || isProfessional) && !location.startsWith('/admin/') && location != '/forgot-password' && location != '/change-password') {
      return '/admin/dashboard';
    }

    // Professional não pode acessar telas de admin/gestão
    if (isProfessional) {
      final professionalRestricted = [
        '/admin/agents',
        '/admin/settings',
        '/admin/professionals',
      ];
      if (professionalRestricted.any((r) => location.startsWith(r))) {
        return '/admin/dashboard';
      }
    }

    return null;
  },
  routes: [
    // === Auth ===
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => ForgotPasswordScreen(
        onBackToLogin: () => context.go('/login'),
        onSuccess: () => context.go('/login'),
      ),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => ChangePasswordScreen(
        onSuccess: () => context.pop(),
      ),
    ),

    // === Admin Shell ===
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdminShell(navigationShell: navigationShell),
      branches: [
        // Branch 0: Dashboard / Pacientes / Conversas / Agentes / Hospitais / Config
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/admin/patients',
              builder: (context, state) => const PatientsScreen(),
            ),
            GoRoute(
              path: '/admin/patients/unassigned',
              builder: (context, state) => const UnassignedPatientsScreen(),
            ),
            GoRoute(
              path: '/admin/patients/:id',
              builder: (context, state) =>
                  PatientDetailScreen(patientId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/admin/conversations',
              builder: (context, state) => const ConversationsScreen(),
            ),
            GoRoute(
              path: '/admin/agents',
              builder: (context, state) => const AgentsScreen(),
            ),
            GoRoute(
              path: '/admin/hospitals',
              builder: (context, state) => const AdminHospitalsScreen(),
            ),
            GoRoute(
              path: '/admin/settings',
              builder: (context, state) => const AdminSettingsScreen(),
            ),
          ],
        ),
        // Branch 1: Profissionais
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/professionals',
              builder: (context, state) => const ProfessionalsScreen(),
            ),
            GoRoute(
              path: '/admin/professionals/create',
              builder: (context, state) => const CreateProfessionalScreen(),
            ),
            GoRoute(
              path: '/admin/professionals/:id',
              builder: (context, state) =>
                  ProfessionalDetailScreen(
                      professionalId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/admin/professionals/:id/permissions',
              builder: (context, state) =>
                  ProfessionalPermissionsScreen(
                      professionalId: state.pathParameters['id']!),
            ),
          ],
        ),
        // Branch 2: Agenda
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/agenda',
              builder: (context, state) => const AgendaScreen(),
            ),
          ],
        ),
        // Branch 3: Solicitações
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/solicitacoes',
              builder: (context, state) => const SolicitacoesScreen(),
            ),
          ],
        ),
      ],
    ),

    // === Patient Routes ===
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(
      path: '/medications',
      builder: (context, state) => const MedicationsScreen(),
    ),
    GoRoute(path: '/exams', builder: (context, state) => const ExamsScreen()),
    GoRoute(
      path: '/consultations',
      builder: (context, state) => const ConsultationsScreen(),
    ),
    GoRoute(
      path: '/hospitals',
      builder: (context, state) => const HospitalsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/agenda',
      builder: (context, state) => const PatientAgendaScreen(),
    ),
    GoRoute(
      path: '/exam-status',
      builder: (context, state) => const ExamStatusScreen(),
    ),
    GoRoute(
      path: '/convenio',
      builder: (context, state) => const ConvenioScreen(),
    ),
    GoRoute(
      path: '/convenio/resultado',
      builder: (context, state) => const ConvenioResultScreen(),
    ),
    GoRoute(
      path: '/prontuario',
      builder: (context, state) => const ProntuarioScreen(),
    ),
  ],
);
