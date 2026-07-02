import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatCard(title: 'Pacientes', value: '1.234', icon: Icons.people, color: ZelloColors.primary),
                const SizedBox(width: 12),
                _StatCard(title: 'Conversas', value: '892', icon: Icons.chat, color: ZelloColors.secondary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(title: 'Agentes Ativos', value: '12', icon: Icons.smart_toy, color: ZelloColors.accent),
                const SizedBox(width: 12),
                _StatCard(title: 'Hospitais', value: '48', icon: Icons.local_hospital, color: ZelloColors.warning),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Atividade Recente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(5, (i) => _ActivityItem(index: i)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12, color: ZelloColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final int index;
  const _ActivityItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final activities = [
      'Novo paciente cadastrado: Maria Oliveira',
      'Conversa #892 iniciada com Dr. Silva',
      'Agente Olga atendeu 45 conversas hoje',
      'Hospital São Lucas atualizou horários',
      'Exame de João Pereira disponível',
    ];
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.circle, size: 8)),
        title: Text(activities[index], style: const TextStyle(fontSize: 13)),
        trailing: const Text('agora', style: TextStyle(fontSize: 11, color: ZelloColors.textSecondary)),
        dense: true,
      ),
    );
  }
}
