import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';
import 'shell.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/conversations/screens/conversations_screen.dart';
import '../features/patients/screens/patients_screen.dart';
import '../features/patients/screens/patient_detail_screen.dart';
import '../features/patients/screens/unassigned_patients_screen.dart';
import '../features/agents/screens/agents_screen.dart';
import '../features/hospitals/screens/hospitals_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/professionals/screens/professionals_screen.dart';
import '../features/professionals/screens/professional_detail_screen.dart';
import '../features/professionals/screens/create_professional_screen.dart';
import '../features/professionals/screens/professional_permissions_screen.dart';
import '../features/agenda/screens/agenda_screen.dart';
import '../features/solicitacoes/screens/solicitacoes_screen.dart';

final adminRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final auth = ProviderScope.containerOf(context).read(authProvider);

    // Aguarda recuperação de sessão (app reaberto)
    if (auth.status == ZelloAuthStatus.initial) return null;

    final isLoggedIn = auth.status == ZelloAuthStatus.authenticated;
    final isOnLogin = state.matchedLocation == '/login';

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (isLoggedIn && isOnLogin) {
      if (auth.isAdmin || auth.isProfessional) return '/dashboard';
      return '/login';
    }

    if (isLoggedIn && auth.isProfessional) {
      final adminOnlyRoutes = ['/agents', '/settings'];
      final location = state.matchedLocation;
      if (adminOnlyRoutes.any((r) => location.startsWith(r))) return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const AdminLoginScreen()),
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ZelloShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
            GoRoute(path: '/patients', builder: (context, state) => const PatientsScreen()),
            GoRoute(path: '/patients/unassigned',
                builder: (context, state) => const UnassignedPatientsScreen()),
            GoRoute(
              path: '/patients/:id',
              builder: (context, state) =>
                  PatientDetailScreen(patientId: state.pathParameters['id']!),
            ),
            GoRoute(path: '/conversations', builder: (context, state) => const ConversationsScreen()),
            GoRoute(path: '/agents', builder: (context, state) => const AgentsScreen()),
            GoRoute(path: '/hospitals', builder: (context, state) => const AdminHospitalsScreen()),
            GoRoute(path: '/settings', builder: (context, state) => const AdminSettingsScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/professionals', builder: (context, state) => const ProfessionalsScreen()),
            GoRoute(path: '/professionals/create',
                builder: (context, state) => const CreateProfessionalScreen()),
            GoRoute(
              path: '/professionals/:id',
              builder: (context, state) =>
                  ProfessionalDetailScreen(professionalId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/professionals/:id/permissions',
              builder: (context, state) =>
                  ProfessionalPermissionsScreen(professionalId: state.pathParameters['id']!),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/agenda', builder: (context, state) => const AgendaScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/solicitacoes', builder: (context, state) => const SolicitacoesScreen()),
          ],
        ),
      ],
    ),
  ],
);
