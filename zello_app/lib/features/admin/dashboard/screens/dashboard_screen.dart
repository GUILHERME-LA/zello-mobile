import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final auth = ref.watch(authProvider);
    final isProfessional = auth.isProfessional;
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

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
                  title:
                      isProfessional ? 'Bem-vindo, Profissional' : 'Bem-vindo, Admin',
                  bottomPadding: 24,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('Resumo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                ),
                const SizedBox(height: 12),
                statsAsync.when(
                  data: (stats) => _buildMetricsGrid(context, ref, stats, isWide),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SkeletonCard(lines: 2),
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
                  child: Text('Gerenciamento',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                ),
                const SizedBox(height: 12),
                _buildManagementList(context, ref),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('Atividade Recente',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                ),
                const SizedBox(height: 12),
                _buildActivityTimeline(context, ref),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Métricas (grid responsivo)
  // ──────────────────────────────────────────────
  Widget _buildMetricsGrid(
      BuildContext context, WidgetRef ref, DashboardStats stats, bool isWide) {
    final isProfessional = ref.watch(authProvider).isProfessional;
    final canPatients = ref.watch(canAccessProvider('patients'));

    final metrics = <_MetricTile>[
      _MetricTile(
        title: 'Pacientes',
        value: '${stats.totalPatients}',
        icon: LucideIcons.users,
        color: ZelloColors.primary,
        onTap: canPatients ? () => context.push('/admin/patients') : null,
      ),
      if (isProfessional && stats.unassignedPatients > 0)
        _MetricTile(
          title: 'Pendentes',
          value: '${stats.unassignedPatients}',
          icon: LucideIcons.userPlus,
          color: ZelloColors.primaryLighter,
          onTap: canPatients ? () => context.push('/admin/patients/unassigned') : null,
        )
      else
        _MetricTile(
          title: 'Conversas',
          value: '${stats.activeConversations}',
          icon: LucideIcons.messageCircle,
          color: ZelloColors.primaryLight,
          onTap: () => context.push('/admin/conversations'),
        ),
      _MetricTile(
        title: 'Agentes Ativos',
        value: '${stats.agentsOnline}',
        icon: LucideIcons.bot,
        color: ZelloColors.primary,
        onTap: () => context.push('/admin/agents'),
        alert: stats.agentsOnline == 0,
      ),
      _MetricTile(
        title: 'Tempo Médio',
        value: '${stats.avgResponseTime.toStringAsFixed(1)}min',
        icon: LucideIcons.clock,
        color: ZelloColors.primaryDark,
        onTap: null,
      ),
    ];

    if (isWide) {
      // Linha horizontal com 4 cards
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: metrics
              .map((m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _AdminMetricCard(metric: m),
                    ),
                  ))
              .toList(),
        ),
      );
    }

    // Grid 2×2 no celular
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: metrics.sublist(0, 2).map((m) {
              final idx = metrics.indexOf(m);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: idx.isEven ? 6.0 : 0, left: idx.isOdd ? 6.0 : 0),
                  child: _AdminMetricCard(metric: m),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: metrics.sublist(2).map((m) {
              final idx = metrics.indexOf(m);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: idx % 2 == 0 ? 6.0 : 0, left: idx % 2 == 1 ? 6.0 : 0),
                  child: _AdminMetricCard(metric: m),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Gerenciamento (ListTile-style)
  // ──────────────────────────────────────────────
  Widget _buildManagementList(BuildContext context, WidgetRef ref) {
    final canConsultations = ref.watch(canAccessProvider('consultations'));

    final tiles = [
      _ManagementTile(
        title: 'Profissionais',
        subtitle: 'Gerenciar médicos e psicólogos',
        icon: LucideIcons.stethoscope,
        color: ZelloColors.primary,
        onTap: () => context.push('/admin/professionals'),
      ),
      _ManagementTile(
        title: 'Agenda',
        subtitle: 'Consultas e horários',
        icon: LucideIcons.calendar,
        color: ZelloColors.primaryLight,
        onTap: canConsultations ? () => context.push('/admin/agenda') : null,
      ),
      _ManagementTile(
        title: 'Solicitações',
        subtitle: 'Pendências e requisições',
        icon: LucideIcons.inbox,
        color: ZelloColors.primaryLighter,
        onTap: () => context.push('/admin/solicitacoes'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: tiles
            .map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ManagementCard(tile: t),
                ))
            .toList(),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Atividade Recente (Timeline)
  // ──────────────────────────────────────────────
  Widget _buildActivityTimeline(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: statsAsync.when(
        data: (stats) {
          final activities = <_Activity>[];

          if (stats.totalPatients > 0) {
            activities.add(_Activity(
              text: 'Total de pacientes cadastrados: ${stats.totalPatients}',
              time: 'hoje',
              status: 'ativo',
              isFirst: activities.isEmpty,
            ));
          }
          if (stats.activeConversations > 0) {
            activities.add(_Activity(
              text: '${stats.activeConversations} conversa(s) ativa(s)',
              time: 'hoje',
              status: 'ativo',
              isFirst: activities.isEmpty,
            ));
          }
          if (stats.agentsOnline > 0) {
            activities.add(_Activity(
              text: '${stats.agentsOnline} agente(s) online',
              time: 'agora',
              status: 'ativo',
              isFirst: activities.isEmpty,
            ));
          }
          if (stats.avgResponseTime > 0) {
            activities.add(_Activity(
              text: 'Tempo médio de resposta: ${stats.avgResponseTime.toStringAsFixed(1)} min',
              time: 'hoje',
              status: 'info',
              isFirst: activities.isEmpty,
            ));
          }

          if (activities.isEmpty) {
            return AnimatedCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(LucideIcons.inbox, color: Colors.grey.shade300, size: 40),
                    const SizedBox(height: 12),
                    Text('Nenhuma atividade recente',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text('As atividades aparecerão aqui quando houver dados.',
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            );
          }

          return AnimatedCard(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              children: activities
                  .asMap()
                  .entries
                  .map((e) => _buildTimelineRow(e.value, e.key == activities.length - 1))
                  .toList(),
            ),
          );
        },
        loading: () => const SkeletonCard(lines: 3),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildTimelineRow(_Activity a, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna do indicador (bolinha + linha vertical)
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    color: a.isFirst
                        ? ZelloColors.primary
                        : const Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          ),
          // Conteúdo
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 12, top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.text,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 2),
                        Text(a.time,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: a.status == 'ativo'
                          ? ZelloColors.primaryLight.withAlpha(25)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      a.status == 'ativo' ? 'sucesso' : a.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: a.status == 'ativo'
                            ? ZelloColors.primaryLight
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Data classes
// ══════════════════════════════════════════════

class _MetricTile {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool alert;
  const _MetricTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.alert = false,
  });
}

class _ManagementTile {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ManagementTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

class _Activity {
  final String text;
  final String time;
  final String status;
  final bool isFirst;
  const _Activity({
    required this.text,
    required this.time,
    required this.status,
    required this.isFirst,
  });
}

// ══════════════════════════════════════════════
// Widgets
// ══════════════════════════════════════════════

/// Card de métrica compacto (Row: ícone | label + valor)
class _AdminMetricCard extends StatelessWidget {
  final _MetricTile metric;
  const _AdminMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: metric.onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: metric.color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(metric.icon, color: metric.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        metric.title,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (metric.alert)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de gerenciamento estilo ListTile
class _ManagementCard extends StatelessWidget {
  final _ManagementTile tile;
  const _ManagementCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: tile.onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: tile.color.withAlpha(25),
            child: Icon(tile.icon, color: tile.color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tile.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 1),
                Text(tile.subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight,
              size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
