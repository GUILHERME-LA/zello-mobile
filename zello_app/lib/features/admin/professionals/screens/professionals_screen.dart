import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class ProfessionalsScreen extends ConsumerWidget {
  const ProfessionalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final professionalsAsync = ref.watch(professionalsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/professionals/create'),
        child: const Icon(LucideIcons.plus),
      ),
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              title: 'Profissionais',
              subtitle: 'Gerencie médicos e psicólogos',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(professionalsProvider);
                  await ref.read(professionalsProvider.notifier).load();
                },
                child: professionalsAsync.when(
                  data: (professionals) {
                    if (professionals.isEmpty) {
                      return ListView(
                        children: const [
                          EmptyState(
                            icon: LucideIcons.stethoscope,
                            title: 'Nenhum profissional cadastrado',
                            subtitle: 'Toque + para cadastrar o primeiro',
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: professionals.length,
                      itemBuilder: (context, index) {
                        final prof = professionals[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedCard(
                            onTap: () => context.push('/admin/professionals/${prof.id}'),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: (prof.type == 'medico'
                                            ? ZelloColors.primaryLighter
                                            : ZelloColors.primary)
                                        .withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    prof.type == 'medico'
                                        ? LucideIcons.building2
                                        : LucideIcons.brain,
                                    color: prof.type == 'medico'
                                        ? ZelloColors.primaryLighter
                                        : ZelloColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prof.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${prof.council}/${prof.councilUf}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ZelloBadge(
                                  label: prof.type == 'medico' ? 'Médico' : 'Psicólogo',
                                  variant: prof.type == 'medico'
                                      ? ZelloBadgeVariant.medical
                                      : ZelloBadgeVariant.psychology,
                                ),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.chevronRight, color: Color(0xFF9CA3AF)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(
                    message: 'Não foi possível carregar os profissionais.',
                    technicalDetails: '$e',
                    onRetry: () {
                      ref.invalidate(professionalsProvider);
                      ref.read(professionalsProvider.notifier).load();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
