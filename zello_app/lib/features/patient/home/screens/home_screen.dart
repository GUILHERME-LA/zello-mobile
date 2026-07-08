import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

// ─────────────────────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────────────────────

const _staggerBaseDelay = Duration(milliseconds: 80);
const _staggerDuration = Duration(milliseconds: 500);

// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static String _formatName(String name) {
    if (name.isEmpty) return 'João';
    return name[0].toUpperCase() + name.substring(1);
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final userName = _formatName(auth.user?.name ?? '');
    final medsAsync = ref.watch(medicationsProvider);
    final examsAsync = ref.watch(examsProvider);
    final consultationsAsync = ref.watch(consultationsProvider);

    final medCount = medsAsync.valueOrNull?.length ?? 0;
    final examCount = examsAsync.valueOrNull?.length ?? 0;
    final consultCount = consultationsAsync.valueOrNull?.length ?? 0;
    final totalItems = medCount + examCount + consultCount;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(medicationsProvider);
            ref.invalidate(examsProvider);
            ref.invalidate(consultationsProvider);
            await Future.wait([
              ref.read(medicationsProvider.future),
              ref.read(examsProvider.future),
              ref.read(consultationsProvider.future),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(userName: userName, consultCount: consultCount),
                SizedBox(
                  height: 24,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(30),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                // ── Empty-state welcome ────────────────────────
                if (totalItems == 0)
                  _StaggerItem(
                    index: 0,
                    child: _EmptyWelcome(userName: userName),
                  ),
                // ── Health overview ────────────────────────────
                if (totalItems > 0)
                  _StaggerItem(
                    index: 0,
                    child: _HealthOverview(
                      medCount: medCount,
                      examCount: examCount,
                      consultCount: consultCount,
                    ),
                  ),
                const SizedBox(height: 4),
                // ── Quick actions ──────────────────────────────
                _StaggerItem(
                  index: totalItems > 0 ? 1 : 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                    child: _buildSectionHeader(context,
                        title: 'Ações Rápidas',
                        subtitle: 'O que você precisa fazer hoje'),
                  ),
                ),
                _StaggerItem(
                  index: totalItems > 0 ? 2 : 2,
                  child: _QuickActionsGrid(),
                ),
                const SizedBox(height: 8),
                _StaggerItem(
                  index: totalItems > 0 ? 3 : 3,
                  child: _AgentCard(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      {required String title, String? subtitle}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: ZelloGradients.sectionBar,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STAGGER ENTRY ANIMATION
// ─────────────────────────────────────────────────────────────

class _StaggerItem extends StatelessWidget {
  final int index;
  final Widget child;
  const _StaggerItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: _staggerDuration,
      curve: Curves.easeOutCubic,
      // stagger delay per item
      builder: (context, value, child) {
        final delay = index * _staggerBaseDelay.inMilliseconds;
        final delayed =
            ((value * _staggerDuration.inMilliseconds) - delay)
                .clamp(0, _staggerDuration.inMilliseconds) /
            _staggerDuration.inMilliseconds;
        return Transform.translate(
          offset: Offset(0, 24 * (1 - delayed)),
          child: Opacity(opacity: delayed, child: child),
        );
      },
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String userName;
  final int consultCount;
  const _Header({required this.userName, required this.consultCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        gradient: ZelloGradients.header,
        borderRadius: ZelloRadius.headerRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting row ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Olá, $userName',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                    _HeaderIconButton(
                    icon: LucideIcons.bell,
                    onTap: () => _showNotifications(context),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.user,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Glassmorphism consultation chip ────────────────
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withAlpha(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.brain,
                    color: Colors.white.withAlpha(179), size: 20),
                const SizedBox(width: 10),
                Text(
                  consultCount > 0
                      ? 'Consultas hoje: $consultCount'
                      : 'Nenhuma consulta hoje',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(230),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia!';
    if (hour < 18) return 'Boa tarde!';
    return 'Boa noite!';
  }

  static void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Notificações',
              style:
                  Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
            ),
            const SizedBox(height: 16),
            _notifItem(context, LucideIcons.calendar,
                'Consulta amanhã às 14:30', 'Dr. Carlos Silva - Cardiologia'),
            const SizedBox(height: 12),
            _notifItem(context, LucideIcons.pill, 'Hora do Losartana 50mg',
                'Próxima dose em 30 min'),
            const SizedBox(height: 12),
            _notifItem(context, LucideIcons.flaskConical, 'Exame disponível',
                'Hemograma completo'),
          ],
        ),
      ),
    );
  }

  static Widget _notifItem(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _HeaderIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(25),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withAlpha(30),
        highlightColor: Colors.white.withAlpha(15),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EMPTY WELCOME
// ─────────────────────────────────────────────────────────────

class _EmptyWelcome extends StatelessWidget {
  final String userName;
  const _EmptyWelcome({required this.userName});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedCard(
        onTap: () => context.push('/prontuario'),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: ZelloGradients.accentGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(LucideIcons.heart,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo, $userName!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Você não tem pendências hoje. Que tal revisar seu prontuário?',
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HEALTH OVERVIEW
// ─────────────────────────────────────────────────────────────

class _HealthOverview extends StatelessWidget {
  final int medCount;
  final int examCount;
  final int consultCount;
  const _HealthOverview({
    required this.medCount,
    required this.examCount,
    required this.consultCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: AnimatedCard(
              onTap: () => context.push('/medications'),
              child: _IndicatorContent(
                icon: LucideIcons.pill,
                iconColor: Theme.of(context).colorScheme.primary,
                iconBgColor:
                    Theme.of(context).colorScheme.primary.withAlpha(25),
                count: medCount,
                label: 'Medicação${medCount == 1 ? '' : 'ões'}',
                sublabel: medCount == 1 ? 'cadastrada' : 'cadastradas',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedCard(
              onTap: () => context.push('/exams'),
              child: _IndicatorContent(
                icon: LucideIcons.flaskConical,
                iconColor: const Color(0xFF42A5F5),
                iconBgColor: const Color(0xFF42A5F5).withAlpha(25),
                count: examCount,
                label: 'Exame${examCount == 1 ? '' : 'ns'}',
                sublabel: examCount == 1 ? 'disponível' : 'disponíveis',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedCard(
              onTap: () => context.push('/consultations'),
              child: _IndicatorContent(
                icon: LucideIcons.calendar,
                iconColor: const Color(0xFF0D47A1),
                iconBgColor: const Color(0xFF0D47A1).withAlpha(25),
                count: consultCount,
                label: 'Consulta${consultCount == 1 ? '' : 's'}',
                sublabel: consultCount == 1 ? 'agendada' : 'agendadas',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicatorContent extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int count;
  final String label;
  final String sublabel;

  const _IndicatorContent({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = count == 0;
    final cs = Theme.of(context).colorScheme;
    final numberColor =
        isEmpty ? cs.onSurfaceVariant.withAlpha(120) : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: numberColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
          ),
          const SizedBox(height: 1),
          Text(
            sublabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isEmpty
                      ? cs.onSurfaceVariant.withAlpha(80)
                      : cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  QUICK ACTIONS GRID
// ─────────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.messageCircle,
                  label: 'Chat com agente',
                  color: Theme.of(context).colorScheme.primary,
                  bgColor:
                      Theme.of(context).colorScheme.primary.withAlpha(20),
                  onTap: () => context.push('/chat'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.calendarCheck,
                  label: 'Agenda',
                  color: const Color(0xFF1E88E5),
                  bgColor: const Color(0xFF1E88E5).withAlpha(20),
                  onTap: () => context.push('/agenda'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.testTube,
                  label: 'Status exames',
                  color: const Color(0xFF42A5F5),
                  bgColor: const Color(0xFF42A5F5).withAlpha(20),
                  onTap: () => context.push('/exam-status'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.heartPulse,
                  label: 'Análise convênio',
                  color: const Color(0xFF0D47A1),
                  bgColor: const Color(0xFF0D47A1).withAlpha(20),
                  onTap: () => context.push('/convenio'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.building2,
                  label: 'Hospitais',
                  color: const Color(0xFF1565C0),
                  bgColor: const Color(0xFF1565C0).withAlpha(20),
                  onTap: () => context.push('/hospitals'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.folder,
                  label: 'Prontuário',
                  color: const Color(0xFF1976D2),
                  bgColor: const Color(0xFF1976D2).withAlpha(20),
                  onTap: () => context.push('/prontuario'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  AGENT CARD
// ─────────────────────────────────────────────────────────────

class _AgentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedCard(
        onTap: () => context.push('/chat'),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: ZelloGradients.avatar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(LucideIcons.bot,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Agente de Saúde',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.circle,
                          size: 8, color: ZelloColors.online),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Assistente online. Clique para conversar.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                color: cs.onSurfaceVariant.withAlpha(120)),
          ],
        ),
      ),
    );
  }
}
