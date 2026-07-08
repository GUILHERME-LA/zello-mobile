import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class AdminShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isProfessional = auth.isProfessional;
    final userName = auth.user?.name ?? 'Admin';
    final initials = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : 'A';

    // Mapeia índices do bottom nav para branches reais do GoRouter
    // Admin:   0→Dashboard, 1→Profissionais, 2→Agenda,      3→Solicitações
    // Prof.:   0→Dashboard,                  1→Agenda,      2→Solicitações
    final branchMap = isProfessional ? [0, 2, 3] : [0, 1, 2, 3];

    final destinations = isProfessional
        ? const [
            NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard),
              selectedIcon: Icon(LucideIcons.layoutDashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              selectedIcon: Icon(LucideIcons.calendar),
              label: 'Agenda',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.inbox),
              selectedIcon: Icon(LucideIcons.inbox),
              label: 'Solicitações',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard),
              selectedIcon: Icon(LucideIcons.layoutDashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.stethoscope),
              selectedIcon: Icon(LucideIcons.stethoscope),
              label: 'Profissionais',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              selectedIcon: Icon(LucideIcons.calendar),
              label: 'Agenda',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.inbox),
              selectedIcon: Icon(LucideIcons.inbox),
              label: 'Solicitações',
            ),
          ];

    final currentNavIndex = branchMap.indexOf(navigationShell.currentIndex);

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,

          // ── Profile / logout button (top‑right) ───────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: PopupMenuButton<_AdminMenuAction>(
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              color: Theme.of(context).colorScheme.surface,
              shadowColor: Theme.of(context).colorScheme.primary.withAlpha(30),
              onSelected: (action) async {
                switch (action) {
                  case _AdminMenuAction.settings:
                    context.push('/admin/settings');
                  case _AdminMenuAction.logout:
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _AdminMenuAction.settings,
                  child: Row(
                    children: [
                      Icon(LucideIcons.settings,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Text('Configurações',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: _AdminMenuAction.logout,
                  child: Row(
                    children: [
                      Icon(LucideIcons.logOut,
                          size: 16, color: ZelloColors.danger),
                      const SizedBox(width: 10),
                      Text('Sair',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: ZelloColors.danger)),
                    ],
                  ),
                ),
              ],
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withAlpha(35),
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentNavIndex,
        onDestinationSelected: (index) {
          final branch = branchMap[index];
          navigationShell.goBranch(
            branch,
            initialLocation: branch == navigationShell.currentIndex,
          );
        },
        destinations: destinations,
      ),
    );
  }
}

enum _AdminMenuAction { settings, logout }
