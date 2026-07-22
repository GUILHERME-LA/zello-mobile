import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PsychologistShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PsychologistShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.home), label: 'Início'),
          NavigationDestination(icon: Icon(LucideIcons.folderOpen), label: 'Histórico'),
          NavigationDestination(icon: Icon(LucideIcons.calendar), label: 'Sessões'),
          NavigationDestination(icon: Icon(LucideIcons.bot), label: 'Olga'),
          NavigationDestination(icon: Icon(LucideIcons.user), label: 'Perfil'),
        ],
      ),
    );
  }
}
