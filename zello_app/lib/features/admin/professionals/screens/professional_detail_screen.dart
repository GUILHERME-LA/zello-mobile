import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class ProfessionalDetailScreen extends ConsumerWidget {
  final String professionalId;
  const ProfessionalDetailScreen({super.key, required this.professionalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final professionalsAsync = ref.watch(professionalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Profissional'),
      ),
      body: professionalsAsync.when(
        data: (professionals) {
          final prof = professionals.where((p) => p.id == professionalId).firstOrNull;
          if (prof == null) {
            return const Center(child: Text('Profissional não encontrado'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: (prof.type == 'medico'
                              ? ZelloColors.primaryLighter
                              : ZelloColors.primary)
                          .withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      prof.type == 'medico'
                          ? LucideIcons.building2
                          : LucideIcons.brain,
                      size: 40,
                      color: prof.type == 'medico'
                          ? ZelloColors.primaryLighter
                          : ZelloColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ZelloBadge(
                    label: prof.type == 'medico' ? 'Médico' : 'Psicólogo',
                    variant: prof.type == 'medico'
                        ? ZelloBadgeVariant.medical
                        : ZelloBadgeVariant.psychology,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoTile('Especialidade', prof.specialty.isNotEmpty ? prof.specialty : 'Não informada'),
                _buildInfoTile('Conselho', '${prof.council}/${prof.councilUf}'),
                if (prof.bio.isNotEmpty) _buildInfoTile('Bio', prof.bio),
                  _buildInfoTile('Cadastrado em', prof.createdAt != null
                      ? '${prof.createdAt!.day}/${prof.createdAt!.month}/${prof.createdAt!.year}'
                      : '—'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/admin/professionals/${prof.id}/permissions');
                    },
                    icon: const Icon(LucideIcons.shield),
                    label: const Text('Gerenciar Permissões'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZelloColors.primaryLighter,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}
