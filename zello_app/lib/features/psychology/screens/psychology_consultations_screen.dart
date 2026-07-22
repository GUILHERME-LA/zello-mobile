import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class PsychologyConsultationsScreen extends ConsumerWidget {
  const PsychologyConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final therapiesAsync = ref.watch(therapiesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: therapiesAsync.when(
                data: (therapies) {
                  if (therapies.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.calendarX, size: 48, color: Color(0xFF9CA3AF)),
                          SizedBox(height: 16),
                          Text('Nenhuma sessão registrada', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                          SizedBox(height: 8),
                          Text('Suas sessões de terapia aparecerão aqui.', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(therapiesProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: therapies.length,
                      itemBuilder: (context, index) {
                        final t = therapies[index];
                        return _buildSessionCard(t);
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(12)),
          child: const Icon(LucideIcons.calendar, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Minhas Sessões', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
          Text('Acompanhamento terapêutico', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _buildSessionCard(Therapy therapy) {
    final color = therapy.status == TherapyStatus.ativa ? const Color(0xFF7C3AED) : const Color(0xFF9CA3AF);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(14)),
          child: Icon(LucideIcons.brain, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(therapy.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text(therapy.frequency, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          if (therapy.professional.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(therapy.professional, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: therapy.status == TherapyStatus.ativa ? const Color(0xFF7C3AED) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            therapy.status == TherapyStatus.ativa ? 'Ativa' : therapy.status == TherapyStatus.concluida ? 'Concluída' : 'Pausada',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: therapy.status == TherapyStatus.ativa ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ]),
    );
  }
}
