import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

const _staggerBaseDelay = Duration(milliseconds: 80);
const _staggerDuration = Duration(milliseconds: 500);

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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final userName = _formatName(auth.user?.name ?? '');
    final medsAsync = ref.watch(medicationsProvider);

    final allMeds = medsAsync.valueOrNull ?? [];
    final activeMeds = allMeds.where((m) => m.isActive).toList();
    final medCount = allMeds.length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(medicationsProvider);
            await ref.read(medicationsProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(userName: userName),
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
                if (activeMeds.isNotEmpty)
                  _StaggerItem(
                    index: 0,
                    child: _MedicationHeroCard(meds: activeMeds),
                  ),
                if (medCount == 0)
                  _StaggerItem(
                    index: 1,
                    child: _EmptyWelcome(userName: userName),
                  ),
                const SizedBox(height: 4),
                _StaggerItem(
                  index: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                    child: _buildSectionHeader(context,
                        title: 'Ações Rápidas',
                        subtitle: 'O que você precisa fazer hoje'),
                  ),
                ),
                _StaggerItem(
                  index: 3,
                  child: _QuickActionsGrid(),
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

class _AnimatedCount extends StatefulWidget {
  final int target;
  final TextStyle? style;
  const _AnimatedCount({required this.target, this.style});

  @override
  State<_AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<_AnimatedCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _display = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.addListener(() {
      final value = (_animation.value * widget.target).round();
      if (value != _display) {
        setState(() => _display = value);
      }
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _display = 0;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_display', style: widget.style);
  }
}

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

class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

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
                  icon: LucideIcons.heartPulse,
                  label: 'Análise de convênio',
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
                  label: 'Meu Histórico',
                  color: const Color(0xFF1976D2),
                  bgColor: const Color(0xFF1976D2).withAlpha(20),
                  onTap: () => context.push('/prontuario'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.sparkles,
                  label: 'Olga',
                  color: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFF7C3AED).withAlpha(20),
                  onTap: () => context.push('/olga'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.activity,
                  label: 'Terapias',
                  color: const Color(0xFF1565C0),
                  bgColor: const Color(0xFF1565C0).withAlpha(20),
                  onTap: () => context.push('/therapies'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.heartPulse,
                  label: 'Tratamentos',
                  color: const Color(0xFF0D47A1),
                  bgColor: const Color(0xFF0D47A1).withAlpha(20),
                  onTap: () => context.push('/treatments'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.clipboardList,
                  label: 'Anamnese',
                  color: const Color(0xFF1976D2),
                  bgColor: const Color(0xFF1976D2).withAlpha(20),
                  onTap: () => context.push('/anamnesis'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: LucideIcons.flaskConical,
                  label: 'Exames',
                  color: const Color(0xFF1565C0),
                  bgColor: const Color(0xFF1565C0).withAlpha(20),
                  onTap: () => context.push('/exams'),
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

class _MedicationHeroCard extends StatelessWidget {
  final List<Medication> meds;
  const _MedicationHeroCard({required this.meds});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = meds
        .where((m) => m.nextDose != null && m.nextDose!.isAfter(now))
        .toList()
      ..sort((a, b) => a.nextDose!.compareTo(b.nextDose!));
    final next =
        upcoming.isNotEmpty ? upcoming.first : (meds.isNotEmpty ? meds.first : null);
    final cs = Theme.of(context).colorScheme;

    return AnimatedCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: ZelloGradients.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.pill, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próxima dose',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  next?.name ?? 'Nenhuma medicação',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(next),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context.push('/medications'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Gerenciar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitle(Medication? med) {
    if (med == null) return 'Toque para adicionar';
    if (med.nextDose != null) {
      return '${_formatNextDose(med.nextDose)} • ${med.dosage}';
    }
    if (med.frequency.isNotEmpty) return med.frequency;
    return med.dosage.isNotEmpty ? med.dosage : 'Sem horário definido';
  }

  static String _formatNextDose(DateTime? nextDose) {
    if (nextDose == null) return '';
    final now = DateTime.now();
    final diff = nextDose.difference(now);
    if (diff.isNegative) return 'já passou';
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'em ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return 'em ${h}h${m > 0 ? ' $m' : ''}';
    }
    final hh = nextDose.hour.toString().padLeft(2, '0');
    final mm = nextDose.minute.toString().padLeft(2, '0');
    return 'às $hh:$mm';
  }
}