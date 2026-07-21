import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PatientShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const PatientShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const destinations = [
      NavigationDestination(
        icon: Icon(LucideIcons.home),
        selectedIcon: Icon(LucideIcons.home),
        label: 'Início',
      ),
      NavigationDestination(
        icon: Icon(LucideIcons.fileText),
        selectedIcon: Icon(LucideIcons.fileText),
        label: 'Prontuário',
      ),
      NavigationDestination(
        icon: Icon(LucideIcons.bot),
        selectedIcon: Icon(LucideIcons.bot),
        label: 'Olga',
      ),
      NavigationDestination(
        icon: Icon(LucideIcons.user),
        selectedIcon: Icon(LucideIcons.user),
        label: 'Perfil',
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: destinations,
      ),
    );
  }
}
