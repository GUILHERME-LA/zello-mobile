import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';
import 'patient_shell.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/role_selection_screen.dart';
import '../features/patient/home/screens/home_gateway.dart';
import '../features/patient/prontuario/screens/prontuario_screen.dart';
import '../features/patient/medications/screens/medications_screen.dart';
import '../features/patient/therapies/screens/therapies_screen.dart';
import '../features/patient/treatments/screens/treatments_screen.dart';
import '../features/patient/anamnesis/screens/initial_anamnesis_screen.dart';
import '../features/patient/hospitals/screens/hospitals_screen.dart';
import '../features/patient/profile/screens/profile_screen.dart';
import '../features/patient/convenio/screens/convenio_screen.dart';
import '../features/patient/exams/screens/exams_screen.dart';
import '../features/patient/convenio/screens/convenio_result_screen.dart';
import '../features/patient/settings/screens/settings_screen.dart';
import '../features/olga/screens/olga_screen.dart';
import '../features/psychology/psychologist_shell.dart';
import '../features/psychology/screens/psychology_home_screen.dart';
import '../features/psychology/screens/psychology_history_screen.dart';
import '../features/psychology/screens/psychology_consultations_screen.dart';

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
    final authPaths = ['/login', '/signup', '/role-select', '/forgot-password', '/change-password'];

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (!isLoggedIn) return null;

    if (isLoggedIn && isOnLogin) return '/role-select';

    final area = ProviderScope.containerOf(context).read(areaProvider);
    if (area == null && !authPaths.contains(location)) return '/role-select';

    if (area == AreaType.psychology && location.startsWith('/home')) return '/psicologia';
    if (area == AreaType.medical && location.startsWith('/psicologia')) return '/home';

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(path: '/role-select', builder: (context, state) => const RoleSelectionScreen()),
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
    GoRoute(
      path: '/anamnesis',
      builder: (context, state) => const InitialAnamnesisScreen(),
    ),

    // Medical shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          PatientShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => _slideFadePage(const HomeGateway()),
            ),
            GoRoute(
              path: '/medications',
              pageBuilder: (context, state) => _slideFadePage(const MedicationsScreen()),
            ),
            GoRoute(
              path: '/therapies',
              pageBuilder: (context, state) => _slideFadePage(const TherapiesScreen()),
            ),
            GoRoute(
              path: '/treatments',
              pageBuilder: (context, state) => _slideFadePage(const TreatmentsScreen()),
            ),
            GoRoute(
              path: '/hospitals',
              pageBuilder: (context, state) => _slideFadePage(const HospitalsScreen()),
            ),
            GoRoute(
              path: '/convenio',
              pageBuilder: (context, state) => _slideFadePage(const ConvenioScreen()),
            ),
            GoRoute(
              path: '/convenio/resultado',
              pageBuilder: (context, state) => _slideFadePage(const ConvenioResultScreen()),
            ),
            GoRoute(
              path: '/exams',
              pageBuilder: (context, state) => _slideFadePage(const ExamsScreen()),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => _slideFadePage(const SettingsScreen()),
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
              path: '/olga',
              pageBuilder: (context, state) => _slideFadePage(const OlgaScreen()),
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

    // Psychology shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          PsychologistShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/psicologia',
              pageBuilder: (context, state) => _slideFadePage(const PsychologyHomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/psicologia/historico',
              pageBuilder: (context, state) => _slideFadePage(const PsychologyHistoryScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/psicologia/consultas',
              pageBuilder: (context, state) => _slideFadePage(const PsychologyConsultationsScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/psicologia/olga',
              pageBuilder: (context, state) => _slideFadePage(const OlgaScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/psicologia/perfil',
              pageBuilder: (context, state) => _slideFadePage(const ProfileScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);
