import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/conversations/screens/conversations_screen.dart';
import '../features/patients/screens/patients_screen.dart';
import '../features/agents/screens/agents_screen.dart';
import '../features/hospitals/screens/hospitals_screen.dart';
import '../features/settings/screens/settings_screen.dart';

final adminRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const AdminLoginScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/conversations', builder: (context, state) => const ConversationsScreen()),
    GoRoute(path: '/patients', builder: (context, state) => const PatientsScreen()),
    GoRoute(path: '/agents', builder: (context, state) => const AgentsScreen()),
    GoRoute(path: '/hospitals', builder: (context, state) => const AdminHospitalsScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const AdminSettingsScreen()),
  ],
);
