import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.heartPulse, size: 48, color: Color(0xFF1565C0)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo ao Zello',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione sua área de atendimento',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const Spacer(flex: 1),
              _AreaCard(
                icon: LucideIcons.stethoscope,
                title: 'Médico',
                subtitle: 'Consultas, exames, medicamentos e histórico clínico',
                color: const Color(0xFF0D9488),
                onTap: () {
                  ref.read(areaProvider.notifier).state = AreaType.medical;
                  context.go('/home');
                },
              ),
              const SizedBox(height: 16),
              _AreaCard(
                icon: LucideIcons.brain,
                title: 'Psicologia',
                subtitle: 'Sessões, terapias, acompanhamento e saúde mental',
                color: const Color(0xFF7C3AED),
                onTap: () {
                  ref.read(areaProvider.notifier).state = AreaType.psychology;
                  context.go('/psicologia');
                },
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AreaCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(40), width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withAlpha(20), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color.withAlpha(120)),
            ],
          ),
        ),
      ),
    );
  }
}
