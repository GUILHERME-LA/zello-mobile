import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/medications/screens/medications_screen.dart';
import '../features/exams/screens/exams_screen.dart';
import '../features/consultations/screens/consultations_screen.dart';
import '../features/hospitals/screens/hospitals_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';

class PatientShell extends StatelessWidget {
  final Widget child;
  const PatientShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

final patientRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/medications',
      builder: (context, state) => const MedicationsScreen(),
    ),
    GoRoute(
      path: '/exams',
      builder: (context, state) => const ExamsScreen(),
    ),
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
  ],
);
