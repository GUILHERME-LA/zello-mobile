import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class TreatmentsScreen extends ConsumerWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(treatmentsProvider);
    return async.when(
      data: (all) {
        final active = all.where((t) => t.status == TreatmentStatus.ativo).toList();
        final history = all.where((t) => t.status != TreatmentStatus.ativo).toList();
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(treatmentsProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientHeader(greeting: 'Acompanhamento', title: 'Tratamentos'),
                    const SizedBox(height: 8),
                    SectionHeader(
                      title: 'Tratamentos Ativos',
                      subtitle: '${active.length} em andamento',
                    ),
                    if (active.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text('Nenhum tratamento ativo',
                            style: TextStyle(color: Color(0xFF6B7280))),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: active
                              .map((t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _TreatmentCard(item: t, onTap: () => _showDetail(context, t)),
                                  ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const SectionHeader(title: 'Histórico'),
                    if (history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text('Nenhum tratamento encerrado',
                            style: TextStyle(color: Color(0xFF6B7280))),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: history
                              .map((t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _TreatmentCard(item: t, onTap: () => _showDetail(context, t)),
                                  ))
                              .toList(),
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
      loading: () => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GradientHeader(greeting: 'Acompanhamento', title: 'Tratamentos'),
              ...List.generate(
                  4,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: SkeletonCard(),
                  )),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }

  void _showDetail(BuildContext context, Treatment t) {
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
            Text(t.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 16),
            _row('Profissional', t.professional),
            _row('Status', _statusLabel(t.status)),
            if (t.description.isNotEmpty) _row('Descrição', t.description),
            if (t.notes.isNotEmpty) _row('Observações', t.notes),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(TreatmentStatus status) {
    return {
      TreatmentStatus.ativo: 'Ativo',
      TreatmentStatus.concluido: 'Concluído',
      TreatmentStatus.suspenso: 'Suspenso',
    }[status]!;
  }
}

class _TreatmentCard extends StatelessWidget {
  final Treatment item;
  final VoidCallback? onTap;
  const _TreatmentCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = item.status == TreatmentStatus.ativo;
    final color = active ? const Color(0xFF0D47A1) : const Color(0xFF9CA3AF);
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(14)),
            child: Icon(LucideIcons.heartPulse, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                if (item.description.isNotEmpty)
                  Text(item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                if (item.professional.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.professional,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF0D47A1) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              TreatmentsScreen._statusLabel(item.status),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
