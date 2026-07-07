import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';
import '../widgets/add_patient_dialog.dart';

class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

  void _showAddPatient(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AddPatientDialog(
        professionalId: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(patientsProvider);
                  await ref.read(patientsProvider.future);
                },
                child: patientsAsync.when(
                  data: (patients) {
                    if (patients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.users,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('Nenhum paciente cadastrado',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF6B7280))),
                            const SizedBox(height: 8),
                            const Text(
                                'Toque + para cadastrar o primeiro paciente',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF9CA3AF))),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: patients.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PatientCard(
                          patient: patients[index],
                          onTap: () =>
                              context.push('/patients/${patients[index].id}'),
                        ),
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatient(context, ref),
        child: const Icon(LucideIcons.plus),
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
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
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
              Icon(LucideIcons.users,
                  color: Colors.white, size: 28),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pacientes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22)),
                  SizedBox(height: 2),
                  Text('Gerenciar pacientes',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar pacientes...',
              hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
              prefixIcon: Icon(LucideIcons.search,
                  color: Colors.white.withAlpha(179), size: 22),
              filled: true,
              fillColor: Colors.white.withAlpha(30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback? onTap;
  const _PatientCard({required this.patient, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = patient.lastAccess != null &&
        DateTime.now().difference(patient.lastAccess!).inDays < 30;
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          ZelloAvatar(name: patient.name, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(patient.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF1A1A2E))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? ZelloColors.primaryLight.withAlpha(25)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(isActive ? 'Ativo' : 'Inativo',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? ZelloColors.primaryLight
                                  : const Color(0xFF6B7280))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.phone, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(patient.phone,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
