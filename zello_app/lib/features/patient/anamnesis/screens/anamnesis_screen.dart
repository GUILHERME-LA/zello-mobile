import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class AnamnesisScreen extends ConsumerWidget {
  const AnamnesisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(anamnesesProvider);
    return async.when(
      data: (all) {
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(anamnesesProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientHeader(greeting: 'Prontuário', title: 'Anamnese'),
                    const SizedBox(height: 8),
                    if (all.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Text('Nenhuma anamnese registrada',
                            style: TextStyle(color: Color(0xFF6B7280))),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: all
                              .map((a) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _AnamnesisCard(item: a),
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
              GradientHeader(greeting: 'Prontuário', title: 'Anamnese'),
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
}

class _AnamnesisCard extends StatelessWidget {
  final Anamnesis item;
  const _AnamnesisCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.clipboardList,
                    color: Color(0xFF1565C0), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.completed ? 'Anamnese concluída' : 'Anamnese em aberto',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 2),
                    Text(item.professional.isNotEmpty ? item.professional : 'Profissional não informado',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: item.completed
                      ? const Color(0xFF10B981).withAlpha(25)
                      : const Color(0xFFF59E0B).withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.completed ? 'Concluída' : 'Em aberto',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: item.completed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _field('Queixa principal', item.chiefComplaint),
          _field('História da doença atual', item.historyOfPresentIllness),
          _field('Histórico pregresso', item.pastHistory),
          _field('Uso contínuo de medicamentos', item.continuousMedication),
          _field('Alergias', item.allergies),
          _field('Hábitos', item.habits),
          _field('Histórico familiar', item.familyHistory),
        ],
      ),
    );
  }

  static Widget _field(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF1A1A2E), height: 1.4)),
        ],
      ),
    );
  }
}
