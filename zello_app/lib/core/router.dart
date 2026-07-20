import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';
import 'admin_shell.dart';
import 'patient_shell.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/admin/dashboard/screens/dashboard_screen.dart';
import '../features/admin/patients/screens/patients_screen.dart';
import '../features/admin/patients/screens/patient_detail_screen.dart';
import '../features/admin/patients/screens/unassigned_patients_screen.dart';
import '../features/admin/conversations/screens/conversations_screen.dart';
import '../features/admin/conversations/screens/conversation_detail_screen.dart';
import '../features/admin/agents/screens/agents_screen.dart';
import '../features/admin/hospitals/screens/hospitals_screen.dart';
import '../features/admin/settings/screens/settings_screen.dart';
import '../features/admin/professionals/screens/professionals_screen.dart';
import '../features/admin/professionals/screens/professional_detail_screen.dart';
import '../features/admin/professionals/screens/create_professional_screen.dart';
import '../features/admin/professionals/screens/professional_permissions_screen.dart';
import '../features/admin/agenda/screens/agenda_screen.dart';
import '../features/patient/home/screens/home_screen.dart';
import '../features/patient/medications/screens/medications_screen.dart';
import '../features/patient/consultations/screens/consultations_screen.dart';
import '../features/patient/therapies/screens/therapies_screen.dart';
import '../features/patient/treatments/screens/treatments_screen.dart';
import '../features/patient/anamnesis/screens/anamnesis_screen.dart';
import '../features/patient/hospitals/screens/hospitals_screen.dart';
import '../features/patient/profile/screens/profile_screen.dart';
import '../features/patient/settings/screens/settings_screen.dart';
import '../features/patient/agenda/screens/agenda_screen.dart';
import '../features/patient/convenio/screens/convenio_screen.dart';
import '../features/patient/exams/screens/exams_screen.dart';
import '../features/patient/convenio/screens/convenio_result_screen.dart';
import '../features/patient/prontuario/screens/prontuario_screen.dart';
import '../features/ai_hub/screens/ai_hub_screen.dart';

Page<void> _slideFadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final auth = ProviderScope.containerOf(context).read(authProvider);

    if (auth.status == ZelloAuthStatus.initial) return null;

    final isLoggedIn = auth.status == ZelloAuthStatus.authenticated;
    final location = state.matchedLocation;
    final isOnLogin = location == '/login' || location == '/signup';

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (!isLoggedIn) return null;

    if (isLoggedIn && isOnLogin) {
      if (auth.isAdmin || auth.isProfessional) return '/admin/dashboard';
      return '/home';
    }

    final isPatient = auth.isPatient;
    final isAdmin = auth.isAdmin;
    final isProfessional = auth.isProfessional;

    if (isPatient && location.startsWith('/admin/')) {
      return '/home';
    }

    if ((isAdmin || isProfessional) && !location.startsWith('/admin/') && location != '/forgot-password' && location != '/change-password') {
      return '/admin/dashboard';
    }

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
              path: '/admin/conversations/:id',
              builder: (context, state) =>
                  ConversationDetailScreen(convKey: state.pathParameters['id']!),
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
            GoRoute(
              path: '/admin/ai',
              builder: (context, state) => const AiHubScreen(),
            ),
          ],
        ),
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
                  ProfessionalDetailScreen(professionalId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/admin/professionals/:id/permissions',
              builder: (context, state) =>
                  ProfessionalPermissionsScreen(professionalId: state.pathParameters['id']!),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin/agenda',
              builder: (context, state) => const AgendaScreen(),
            ),
          ],
        ),
      ],
    ),

    // === Patient Shell ===
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          PatientShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => _slideFadePage(const HomeScreen()),
            ),
            GoRoute(
              path: '/medications',
              pageBuilder: (context, state) =>
                  _slideFadePage(const MedicationsScreen()),
            ),
            GoRoute(
              path: '/consultations',
              pageBuilder: (context, state) =>
                  _slideFadePage(const ConsultationsScreen()),
            ),
            GoRoute(
              path: '/therapies',
              pageBuilder: (context, state) =>
                  _slideFadePage(const TherapiesScreen()),
            ),
            GoRoute(
              path: '/treatments',
              pageBuilder: (context, state) =>
                  _slideFadePage(const TreatmentsScreen()),
            ),
            GoRoute(
              path: '/anamnesis',
              pageBuilder: (context, state) =>
                  _slideFadePage(const AnamnesisScreen()),
            ),
            GoRoute(
              path: '/hospitals',
              pageBuilder: (context, state) =>
                  _slideFadePage(const HospitalsScreen()),
            ),
            GoRoute(
              path: '/convenio',
              pageBuilder: (context, state) =>
                  _slideFadePage(const ConvenioScreen()),
            ),
            GoRoute(
              path: '/convenio/resultado',
              pageBuilder: (context, state) =>
                  _slideFadePage(const ConvenioResultScreen()),
            ),
            GoRoute(
              path: '/exams',
              pageBuilder: (context, state) =>
                  _slideFadePage(const ExamsScreen()),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) =>
                  _slideFadePage(const SettingsScreen()),
            ),
            GoRoute(
              path: '/ai',
              pageBuilder: (context, state) =>
                  _slideFadePage(const AiHubScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/agenda',
              pageBuilder: (context, state) =>
                  _slideFadePage(const PatientAgendaScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/prontuario',
              pageBuilder: (context, state) =>
                  _slideFadePage(const ProntuarioScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  _slideFadePage(const ProfileScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);