import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';
import 'section_card.dart';
import 'prontuario_helpers.dart';
import '../screens/add_dialogs.dart';

class PerfilSection extends ConsumerWidget {
  final AsyncValue<HealthProfile?> profileAsync;
  final String patientId;

  const PerfilSection({super.key, required this.profileAsync, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return profileAsync.when(
      data: (profile) {
        final p = profile ?? const HealthProfile(id: '', patientId: '');
        final imc = p.imc;
        return SectionCard(
          icon: Icons.person,
          iconColor: ZelloColors.primary,
          title: 'Perfil de Saúde',
          trailing: OutlinedButton(
            onPressed: () => showEditProfileDialog(context, ref, patientId, p),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: const Text('Editar'),
          ),
          child: Column(
            children: [
              infoRow('Peso', p.weight > 0 ? '${p.weight.toStringAsFixed(0)} kg' : 'Não informado'),
              infoRow('Altura', p.height > 0 ? '${p.height.toStringAsFixed(0)} cm' : 'Não informado'),
              if (imc > 0) infoRow('IMC', '${imc.toStringAsFixed(1)} — ${p.imcCategory}'),
              infoRow('Tipo Sanguíneo', p.bloodType.isNotEmpty ? p.bloodType : 'Não informado'),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              multiLineInfo('Condições Médicas', p.medicalConditions.isNotEmpty ? p.medicalConditions : 'Nenhuma'),
              const SizedBox(height: 8),
              multiLineInfo('Condições Crônicas', p.chronicConditions.isNotEmpty ? p.chronicConditions : 'Nenhuma'),
              const SizedBox(height: 8),
              multiLineInfo('Medicações em Uso', p.medications.isNotEmpty ? p.medications : 'Nenhuma'),
              const SizedBox(height: 8),
              multiLineInfo('Histórico Familiar', p.familyHistory.isNotEmpty ? p.familyHistory : 'Nenhum'),
            ],
          ),
        );
      },
      loading: () => const SectionCard(
        icon: Icons.person,
        iconColor: ZelloColors.primary,
        title: 'Perfil de Saúde',
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => SectionCard(
        icon: Icons.person,
        iconColor: ZelloColors.primary,
        title: 'Perfil de Saúde',
        child: Text('Erro ao carregar: $e', style: TextStyle(fontSize: 12, color: ZelloColors.danger)),
      ),
    );
  }
}
