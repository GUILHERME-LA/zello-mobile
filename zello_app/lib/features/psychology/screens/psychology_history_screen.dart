import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class PsychologyHistoryScreen extends ConsumerWidget {
  const PsychologyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientIdAsync = ref.watch(currentPatientIdProvider);
    final patientId = patientIdAsync.valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (patientId == null)
              const Expanded(child: Center(child: Text('Faça login para acessar seu histórico.', style: TextStyle(color: Color(0xFF6B7280)))))
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(patientTherapiesProvider(patientId));
                    ref.invalidate(patientSurgeriesProvider(patientId));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTherapiesSection(ref, patientId),
                        const SizedBox(height: 20),
                        _buildAnamnesisSection(ref),
                      ],
                    ),
                  ),
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
          child: const Icon(LucideIcons.folderOpen, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Meu Histórico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
          Text('Acompanhamento psicológico', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _buildTherapiesSection(WidgetRef ref, String patientId) {
    final therapiesAsync = ref.watch(patientTherapiesProvider(patientId));
    return therapiesAsync.when(
      data: (therapies) {
        if (therapies.isEmpty) return const SizedBox.shrink();
        return _sectionCard('Terapias', LucideIcons.activity, const Color(0xFF7C3AED), therapies.map((t) => _PsychoItem(
          title: t.name,
          subtitle: '${t.frequency.isNotEmpty ? "${t.frequency} — " : ""}${t.professional}',
          trailing: t.status == TherapyStatus.ativa ? 'Ativa' : t.status == TherapyStatus.concluida ? 'Concluída' : 'Pausada',
        )).toList());
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAnamnesisSection(WidgetRef ref) {
    final anamnesisAsync = ref.watch(currentAnamnesisProvider);
    return anamnesisAsync.when(
      data: (anamnesis) {
        if (anamnesis == null || !anamnesis.completed) return const SizedBox.shrink();
        return _sectionCard('Anamnese', LucideIcons.clipboardList, const Color(0xFF8B5CF6), [
          _PsychoItem(title: 'Saúde Mental', subtitle: anamnesis.hasDepression ? 'Com depressão' : 'Sem depressão'),
          if (anamnesis.mentalHealthNotes.isNotEmpty)
            _PsychoItem(title: 'Observações', subtitle: anamnesis.mentalHealthNotes),
        ]);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _sectionCard(String title, IconData icon, Color color, List<Widget> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 8),
        ...items,
      ]),
    );
  }
}

class _PsychoItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  const _PsychoItem({required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (subtitle.isNotEmpty) const SizedBox(height: 2),
          if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ])),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(trailing!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7C3AED))),
          ),
      ]),
    );
  }
}
