import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/medications/screens/medications_screen.dart';
import '../features/exams/screens/exams_screen.dart';
import '../features/consultations/screens/consultations_screen.dart';
import '../features/hospitals/screens/hospitals_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/agenda/screens/agenda_screen.dart';
import '../features/exames/screens/exam_status_screen.dart';
import '../features/convenio/screens/convenio_screen.dart';
import '../features/convenio/screens/convenio_result_screen.dart';

final patientRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final auth = ProviderScope.containerOf(context).read(authProvider);
    final isLoggedIn = auth.status == ZelloAuthStatus.authenticated;
    final isOnLogin = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (isLoggedIn && isOnLogin) return '/home';

    return null;
  },
  routes: [
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
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(path: '/medications', builder: (context, state) => const MedicationsScreen()),
    GoRoute(path: '/exams', builder: (context, state) => const ExamsScreen()),
    GoRoute(path: '/consultations', builder: (context, state) => const ConsultationsScreen()),
    GoRoute(path: '/hospitals', builder: (context, state) => const HospitalsScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/agenda', builder: (context, state) => const PatientAgendaScreen()),
    GoRoute(path: '/exam-status', builder: (context, state) => const ExamStatusScreen()),
    GoRoute(path: '/convenio', builder: (context, state) => const ConvenioScreen()),
    GoRoute(path: '/convenio/resultado', builder: (context, state) => const ConvenioResultScreen()),
  ],
);
