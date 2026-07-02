import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zello Saúde'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Olá! Como está sua saúde?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ZelloColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildHealthCards(context),
            const SizedBox(height: 24),
            const Text(
              'Ações Rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ZelloColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCards(BuildContext context) {
    return Column(
      children: [
        _HealthCard(
          icon: Icons.medication,
          title: 'Medicações de Hoje',
          subtitle: '2 medicamentos pendentes',
          color: ZelloColors.secondary,
          onTap: () => context.push('/medications'),
        ),
        const SizedBox(height: 12),
        _HealthCard(
          icon: Icons.calendar_today,
          title: 'Próxima Consulta',
          subtitle: 'Dr. Silva - Cardiologia',
          color: ZelloColors.primary,
          onTap: () => context.push('/consultations'),
        ),
        const SizedBox(height: 12),
        _HealthCard(
          icon: Icons.science,
          title: 'Último Exame',
          subtitle: 'Hemograma completo - Disponível',
          color: ZelloColors.accent,
          onTap: () => context.push('/exams'),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _QuickAction(
          icon: Icons.chat_bubble_outline,
          label: 'Chat com\nDra. Olga',
          onTap: () => context.push('/chat'),
        ),
        _QuickAction(
          icon: Icons.local_hospital_outlined,
          label: 'Hospital\nPróximo',
          onTap: () => context.push('/hospitals'),
        ),
        _QuickAction(
          icon: Icons.person_outline,
          label: 'Meu\nPerfil',
          onTap: () => context.push('/profile'),
        ),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _HealthCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ZelloColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ZelloColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ZelloColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
