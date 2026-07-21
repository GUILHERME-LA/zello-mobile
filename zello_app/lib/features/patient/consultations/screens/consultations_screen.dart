import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class ConsultationsScreen extends ConsumerWidget {
  const ConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(consultationsProvider);
    return async.when(
      data: (all) {
        final upcoming = all.where((c) => c.status == ConsultationStatus.scheduled).toList();
        final history = all.where((c) => c.status == ConsultationStatus.completed).toList();
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(consultationsProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 8),
                    SectionHeader(title: 'Próximas Consultas', subtitle: '${upcoming.length} consultas agendadas'),
                    if (upcoming.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text('Nenhuma consulta agendada', style: TextStyle(color: Color(0xFF6B7280))),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: upcoming.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ConsultationCard(
                              item: c,
                              onTap: () => _showDetail(context, c),
                            ),
                          )).toList(),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const SectionHeader(title: 'Histórico'),
                    if (history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text('Nenhuma consulta realizada', style: TextStyle(color: Color(0xFF6B7280))),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: history.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ConsultationCard(
                              item: c,
                              onTap: () => _showDetail(context, c),
                            ),
                          )).toList(),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }

  static void _showDetail(BuildContext context, Consultation c) {
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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(width: 48, height: 48, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]), borderRadius: BorderRadius.all(Radius.circular(14))),
                  child: const Icon(Icons.person, color: Colors.white, size: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.doctorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      Text(c.specialty, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.type == ConsultationType.tele ? const Color(0xFF8B5CF6).withAlpha(25) : const Color(0xFF42A5F5).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(c.type == ConsultationType.tele ? 'Teleconsulta' : 'Presencial',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: c.type == ConsultationType.tele ? const Color(0xFF8B5CF6) : const Color(0xFF42A5F5))),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _detailRow(Icons.schedule, c.date != null ? Formatters.formatDate(c.date!) : 'Data não informada'),
            if (c.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailRow(Icons.notes, c.notes),
            ],
            const SizedBox(height: 12),
            _detailRow(Icons.info_outline, c.status == ConsultationStatus.scheduled ? 'Confirmada' : 'Realizada'),
          ],
        ),
      ),
    );
  }

  static Widget _detailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w500)),
      ],
    );
  }

  static Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 14),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Consultas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
            SizedBox(height: 2),
            Text('Gerencie seus agendamentos', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final Consultation item;
  final VoidCallback? onTap;
  const _ConsultationCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = item.status == ConsultationStatus.scheduled;
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(width: 52, height: 52,
            decoration: BoxDecoration(
              color: isUpcoming ? const Color(0xFF1565C0).withAlpha(25) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(14)),
            child: Icon(isUpcoming ? Icons.event : Icons.check_circle_outline,
                color: isUpcoming ? const Color(0xFF1565C0) : const Color(0xFF6B7280), size: 26)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.doctorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(item.specialty, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.type == ConsultationType.tele ? const Color(0xFF8B5CF6).withAlpha(25) : const Color(0xFF42A5F5).withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item.type == ConsultationType.tele ? 'Teleconsulta' : 'Presencial',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: item.type == ConsultationType.tele ? const Color(0xFF8B5CF6) : const Color(0xFF42A5F5))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
