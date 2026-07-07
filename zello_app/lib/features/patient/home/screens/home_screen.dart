import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia!';
    if (hour < 18) return 'Boa tarde!';
    return 'Boa noite!';
  }

  static String _formatName(String name) {
    if (name.isEmpty) return 'João';
    return name[0].toUpperCase() + name.substring(1);
  }

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
                _buildHeader(userName, consultCount),
                const SizedBox(height: 20),
                _buildHealthOverview(medCount, examCount, consultCount),
                const SizedBox(height: 4),
                const SectionHeader(
                  title: 'Ações Rápidas',
                  subtitle: 'O que você precisa fazer hoje',
                ),
                _buildQuickActions(),
                const SizedBox(height: 8),
                _buildAgentCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, int consultCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Olá, $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () => _showNotifications(context),
                  ),
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
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology,
                    color: Colors.white.withAlpha(179), size: 20),
                const SizedBox(width: 10),
                Text(
                  consultCount > 0
                      ? 'Consultas hoje: $consultCount'
                      : 'Nenhuma consulta hoje',
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 13,
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

  Widget _buildHealthOverview(int medCount, int examCount, int consultCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: AnimatedCard(
              onTap: () => context.push('/medications'),
              child: _IndicatorContent(
                icon: Icons.medication,
                iconColor: const Color(0xFF1565C0),
                iconBgColor: const Color(0xFF1565C0).withAlpha(25),
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
                icon: Icons.science,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFF10B981).withAlpha(25),
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
                icon: Icons.calendar_today,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFF59E0B).withAlpha(25),
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

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat com agente',
                  color: const Color(0xFF1565C0),
                  bgColor: const Color(0xFF1565C0).withAlpha(20),
                  onTap: () => context.push('/chat'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.event_outlined,
                  label: 'Agenda profissional',
                  color: const Color(0xFF0891B2),
                  bgColor: const Color(0xFF0891B2).withAlpha(20),
                  onTap: () => context.push('/agenda'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.science_outlined,
                  label: 'Status de exames',
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFD97706).withAlpha(20),
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
                  icon: Icons.health_and_safety_outlined,
                  label: 'Análise de convênio',
                  color: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFF7C3AED).withAlpha(20),
                  onTap: () => context.push('/convenio'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.local_hospital_outlined,
                  label: 'Hospitais próximos',
                  color: const Color(0xFF0D9488),
                  bgColor: const Color(0xFF0D9488).withAlpha(20),
                  onTap: () => context.push('/hospitals'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.folder_outlined,
                  label: 'Prontuário',
                  color: const Color(0xFF4338CA),
                  bgColor: const Color(0xFF4338CA).withAlpha(20),
                  onTap: () => context.push('/prontuario'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard() {
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Agente de Saúde',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Assistente online. Clique para conversar.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
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
            const Text(
              'Notificações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            _notifItem(Icons.calendar_today, 'Consulta amanhã às 14:30',
                'Dr. Carlos Silva - Cardiologia'),
            const SizedBox(height: 12),
            _notifItem(Icons.medication, 'Hora do Losartana 50mg',
                'Próxima dose em 30 min'),
            const SizedBox(height: 12),
            _notifItem(Icons.science, 'Exame disponível', 'Hemograma completo'),
          ],
        ),
      ),
    );
  }

  static Widget _notifItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact indicator content for health overview cards.
/// Number beside label instead of stacked vertically.
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
    final numberColor = isEmpty ? Colors.grey.shade400 : const Color(0xFF1A1A2E);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + number side by side
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: numberColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 10,
              color: isEmpty ? Colors.grey.shade300 : Colors.grey.shade500,
            ),
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
