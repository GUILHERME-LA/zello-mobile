import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final name = user?.name ?? 'João Pereira';
    final email = user?.email ?? 'joao@email.com';
    final phone = user?.phone ?? '(11) 98888-7777';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, name, email),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(name, email, phone),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Opções'),
                    _buildMenuOptions(context, ref),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHeader(BuildContext context, String name, String email) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white.withAlpha(38), borderRadius: BorderRadius.circular(14)),
                child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop())),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Container(width: 88, height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38), shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(76), width: 3)),
            child: const Icon(Icons.person, color: Colors.white, size: 44)),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(email, style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 13)),
        ],
      ),
    );
  }

  static Widget _buildInfoCard(String name, String email, String phone) {
    return AnimatedCard(
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Nome', name),
          const Divider(height: 1),
          _buildInfoRow(Icons.email_outlined, 'Email', email),
          const Divider(height: 1),
          _buildInfoRow(Icons.phone, 'Telefone', phone),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E))),
          ]),
        ],
      ),
    );
  }

  static void _showMenuOption(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
          ],
        ),
      ),
    );
  }

  static Widget _buildMenuOptions(BuildContext context, WidgetRef ref) {
    final options = [
      _MenuOption(LucideIcons.settings, 'Configurações', 'Preferências do app', route: '/settings'),
      _MenuOption(LucideIcons.activity, 'Terapias', 'Acompanhamento terapêutico', route: '/therapies'),
      _MenuOption(LucideIcons.heartPulse, 'Tratamentos', 'Tratamentos em curso', route: '/treatments'),
      _MenuOption(LucideIcons.clipboardList, 'Anamnese', 'Histórico clínico', route: '/anamnesis'),
    ];
    return Column(
      children: [...options.map((o) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedCard(
          onTap: () {
            if (o.route != null) {
              context.push(o.route!);
            } else {
              _showMenuOption(context, o.title, o.subtitle);
            }
          },
          child: Row(
            children: [
              Icon(o.icon, size: 20, color: const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A2E))),
                Text(o.subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ])),
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      )).toList(),
      // Logout option at bottom
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedCard(
          onTap: () => _showLogoutDialog(context, ref),
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: const Color(0xFFDC2626)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sair da conta', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFFDC2626))),
                Text('Fazer logout da sua conta', style: const TextStyle(fontSize: 11, color: const Color(0xFFD16D6D))),
              ])),
              const Icon(Icons.chevron_right, size: 16, color: const Color(0xFFD16D6D)),
            ],
          ),
        ),
      ),
      ],
    );
  }

  static void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('SAIR', style: TextStyle(color: const Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

}

class _MenuOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  const _MenuOption(this.icon, this.title, this.subtitle, {this.route});
}
