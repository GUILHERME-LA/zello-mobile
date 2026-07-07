import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final isProfessional = ref.watch(authProvider).isProfessional;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
            await ref.read(dashboardStatsProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientHeader(
                  greeting: 'Dashboard',
                  title: isProfessional ? 'Bem-vindo, Profissional' : 'Bem-vindo, Admin',
                  bottomPadding: 24,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('Resumo',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                ),
                const SizedBox(height: 12),
                statsAsync.when(
                  data: (stats) => _buildStatsGrid(context, ref, stats),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SkeletonCard(lines: 4),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ErrorState(
                      message: 'Não foi possível carregar as estatísticas.',
                      technicalDetails: '$e',
                      onRetry: () => ref.invalidate(dashboardStatsProvider),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('Atividade Recente',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                ),
                const SizedBox(height: 12),
                _buildActivityList(context, ref),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref, DashboardStats stats) {
    final isProfessional = ref.watch(authProvider).isProfessional;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Pacientes',
                  value: '${stats.totalPatients}',
                  icon: Icons.people,
                  color: const Color(0xFF1565C0),
                  onTap: () => context.push('/patients'),
                ),
              ),
              const SizedBox(width: 12),
              if (isProfessional && stats.unassignedPatients > 0)
                Expanded(
                  child: _StatCard(
                    title: 'Pendentes',
                    value: '${stats.unassignedPatients}',
                    icon: Icons.person_add,
                    color: const Color(0xFFEF4444),
                    onTap: () => context.push('/patients/unassigned'),
                  ),
                )
              else
                Expanded(
                  child: _StatCard(
                    title: 'Conversas',
                    value: '${stats.activeConversations}',
                    icon: Icons.chat,
                    color: const Color(0xFF42A5F5),
                    onTap: () => context.push('/conversations'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Agentes Ativos',
                  value: '${stats.agentsOnline}',
                  icon: Icons.smart_toy,
                  color: const Color(0xFF10B981),
                  onTap: () => context.push('/agents'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Tempo Médio',
                  value: '${stats.avgResponseTime.toStringAsFixed(1)}min',
                  icon: Icons.timer_outlined,
                  color: const Color(0xFFF59E0B),
                  onTap: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NavCard(
                  title: 'Profissionais',
                  icon: Icons.medical_services,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.push('/professionals'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavCard(
                  title: 'Agenda',
                  icon: Icons.event,
                  color: const Color(0xFF0D47A1),
                  onTap: () => context.push('/agenda'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NavCard(
                  title: 'Solicitações',
                  icon: Icons.inbox,
                  color: const Color(0xFFEC4899),
                  onTap: () => context.push('/solicitacoes'),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: statsAsync.when(
        data: (stats) {
          // Montar atividades reais a partir dos dados do dashboard
          final activities = <(String, String)>[];

          if (stats.totalPatients > 0) {
            activities.add(('Total de pacientes cadastrados: ${stats.totalPatients}', 'ativo'));
          }
          if (stats.activeConversations > 0) {
            activities.add(('${stats.activeConversations} conversa(s) ativa(s)', 'ativo'));
          }
          if (stats.agentsOnline > 0) {
            activities.add(('${stats.agentsOnline} agente(s) online', 'ativo'));
          }
          if (stats.avgResponseTime > 0) {
            activities.add(('Tempo médio de resposta: ${stats.avgResponseTime.toStringAsFixed(1)} min', 'info'));
          }

          if (activities.isEmpty) {
            return AnimatedCard(
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade400, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma atividade recente',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'As atividades aparecerão aqui quando houver dados.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: activities
                .asMap()
                .entries
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ActivityItem(
                        text: e.value.$1,
                        time: e.value.$2,
                        isFirst: e.key == 0,
                      ),
                    ))
                .toList(),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: SkeletonCard(lines: 3),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _NavCard({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String text;
  final String time;
  final bool isFirst;

  const _ActivityItem(
      {required this.text, required this.time, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isFirst
                  ? const Color(0xFF1565C0)
                  : const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF1A1A2E))),
          ),
          Text(time,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
