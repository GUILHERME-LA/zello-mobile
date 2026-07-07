import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class UnassignedPatientsScreen extends ConsumerWidget {
  const UnassignedPatientsScreen({super.key});

  Future<void> _assignPatient(
      BuildContext context, WidgetRef ref, String patientId) async {
    final authState = ref.read(authProvider);
    final professionalId = authState.user?.professionalId;
    if (professionalId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil profissional não encontrado')),
        );
      }
      return;
    }

    final api = ref.read(apiClientProvider);
    try {
      await api.assignPatient(patientId, professionalId);
      ref.invalidate(unassignedPatientsProvider);
      ref.invalidate(dashboardStatsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paciente vinculado com sucesso'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao vincular paciente: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unassignedAsync = ref.watch(unassignedPatientsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_add_alt_1,
                          color: Colors.white, size: 28),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pacientes Pendentes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22)),
                          SizedBox(height: 2),
                          Text('Vincular pacientes ao seu perfil',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(unassignedPatientsProvider);
                  await ref.read(unassignedPatientsProvider.future);
                },
                child: unassignedAsync.when(
                  data: (patients) {
                    if (patients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 64, color: Colors.green.shade300),
                            const SizedBox(height: 16),
                            const Text('Nenhum paciente pendente',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF6B7280))),
                            const SizedBox(height: 8),
                            const Text(
                                'Todos os pacientes já têm profissional vinculado',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF9CA3AF))),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AnimatedCard(
                            child: Row(
                              children: [
                                ZelloAvatar(
                                    name: patient.name, size: 48),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(patient.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Color(0xFF1A1A2E))),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.phone,
                                              size: 12,
                                              color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(patient.phone,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF6B7280))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _assignPatient(
                                      context, ref, patient.id),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        const Color(0xFF1565C0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  child: const Text('Vincular'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: 5,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: SkeletonCard(),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Erro ao carregar pacientes: $e',
                        style: const TextStyle(color: Colors.red)),
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
