import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

/// Modos de agendamento disponíveis para o paciente
enum AgendaMode { medico, psicologo }

class PatientAgendaScreen extends ConsumerStatefulWidget {
  const PatientAgendaScreen({super.key});

  @override
  ConsumerState<PatientAgendaScreen> createState() =>
      _PatientAgendaScreenState();
}

class _PatientAgendaScreenState extends ConsumerState<PatientAgendaScreen> {
  AgendaMode _selectedMode = AgendaMode.medico;

  @override
  Widget build(BuildContext context) {
    final professionalsAsync = ref.watch(
      filteredProfessionalsProvider(_selectedMode.name),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Consulta')),
      body: Column(
        children: [
          // --- Segmented Control: Médico / Psicólogo ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: SegmentedButton<AgendaMode>(
              segments: const [
                ButtonSegment(
                  value: AgendaMode.medico,
                  label: Text('Médicos'),
                  icon: Icon(Icons.medical_services_outlined),
                ),
                ButtonSegment(
                  value: AgendaMode.psicologo,
                  label: Text('Psicólogos'),
                  icon: Icon(Icons.psychology_outlined),
                ),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (mode) {
                setState(() => _selectedMode = mode.first);
              },
              style: SegmentedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // --- Subtítulo ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedMode == AgendaMode.medico
                    ? 'Selecione um médico para agendar'
                    : 'Selecione um psicólogo para agendar',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- Lista de Profissionais ---
          Expanded(
            child: professionalsAsync.when(
              data: (professionals) {
                if (professionals.isEmpty) {
                  return EmptyState(
                    icon: _selectedMode == AgendaMode.medico
                        ? Icons.medical_services_outlined
                        : Icons.psychology_outlined,
                    title: _selectedMode == AgendaMode.medico
                        ? 'Nenhum médico disponível'
                        : 'Nenhum psicólogo disponível',
                    subtitle: 'No momento não há profissionais cadastrados.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: professionals.length,
                  itemBuilder: (context, index) {
                    final prof = professionals[index];
                    return _ProfessionalCard(
                      professional: prof,
                      mode: _selectedMode,
                      onTap: () => _showAvailableSlots(prof),
                    );
                  },
                );
              },
              loading: () => const LoadingState(),
              error: (e, _) => ErrorState(
                message: 'Erro ao carregar profissionais.',
                technicalDetails: '$e',
                onRetry: () => ref.invalidate(professionalsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Exibe bottom sheet com horários disponíveis do profissional
  void _showAvailableSlots(Professional professional) {
    // Carrega os horários disponíveis
    ref.read(availabilityProvider.notifier).loadAvailable(professional.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
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
                  const SizedBox(height: 16),

                  // Nome do profissional
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _selectedMode == AgendaMode.medico
                            ? const Color(0xFF3B82F6).withAlpha(25)
                            : const Color(0xFF8B5CF6).withAlpha(25),
                        child: Icon(
                          _selectedMode == AgendaMode.medico
                              ? Icons.medical_services
                              : Icons.psychology,
                          color: _selectedMode == AgendaMode.medico
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              professional.name.isNotEmpty
                                  ? professional.name
                                  : '${professional.type} - ${professional.council}/${professional.councilUf}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (professional.specialty.isNotEmpty)
                              Text(
                                professional.specialty,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Título da lista
                  Text(
                    'Horários Disponíveis',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Lista de horários
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final slotsAsync = ref.watch(availabilityProvider);
                        return slotsAsync.when(
                          data: (slots) {
                            if (slots.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.event_busy,
                                        size: 48, color: Colors.grey.shade400),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Nenhum horário disponível no momento',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.separated(
                              controller: scrollController,
                              itemCount: slots.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, index) {
                                final slot = slots[index];
                                return AnimatedCard(
                                  onTap: () =>
                                      _showRequestDialog(professional, slot),
                                  child: ListTile(
                                    leading: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.access_time,
                                          color: Color(0xFF10B981)),
                                    ),
                                    title: Text(
                                      '${slot.date.day}/${slot.date.month}/${slot.date.year}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      '${slot.startTime} - ${slot.endTime}',
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                    trailing: const Icon(
                                        Icons.chevron_right,
                                        color: Color(0xFF9CA3AF)),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (e, _) => Center(
                            child: Text(
                              'Erro ao carregar horários.',
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Dialog de solicitação — diferente para Médico vs Psicólogo
  void _showRequestDialog(Professional professional, ProfessionalAvailability slot) {
    if (_selectedMode == AgendaMode.medico) {
      _showMedicoRequestDialog(professional, slot);
    } else {
      _showPsicologoRequestDialog(professional, slot);
    }
  }

  /// Médico: solicitar exame
  void _showMedicoRequestDialog(
      Professional professional, ProfessionalAvailability slot) {
    final examTypeCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Solicitar Exame',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Dr(a). ${professional.name} — ${slot.date.day}/${slot.date.month}/${slot.date.year} às ${slot.startTime}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: examTypeCtrl,
              decoration: const InputDecoration(labelText: 'Tipo de exame'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration:
                  const InputDecoration(labelText: 'Observações (opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitMedicoRequest(
                    ctx, slot, professional, examTypeCtrl.text, notesCtrl.text),
                child: const Text('Solicitar Exame'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitMedicoRequest(
    BuildContext ctx,
    ProfessionalAvailability slot,
    Professional professional,
    String examType,
    String notes,
  ) async {
    Navigator.pop(ctx);

    final api = ref.read(apiClientProvider);
    await ref.read(examRequestsProvider.notifier).request(
          ExamRequest(
            id: '',
            patientId: api.currentPatientId ?? '',
            professionalId: professional.id,
            availabilitySlotId: slot.id,
            examType: examType,
            notes: notes,
            status: 'solicitado',
          ),
        );
    await ref.read(availabilityProvider.notifier).markBooked(slot.id);
    ref.invalidate(availabilityProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solicitação enviada! Aguarde confirmação.')),
      );
    }
  }

  /// Psicólogo: agendar consulta (sem exame)
  void _showPsicologoRequestDialog(
      Professional professional, ProfessionalAvailability slot) {
    final reasonCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.psychology, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                const Text('Agendar Consulta',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Psicólogo(a) ${professional.name} — ${slot.date.day}/${slot.date.month}/${slot.date.year} às ${slot.startTime}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Motivo da consulta',
                hintText: 'Ex: Ansiedade, orientação profissional...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                hintText: 'Informações que achar relevantes...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _submitPsicologoRequest(
                    ctx, slot, professional, reasonCtrl.text, notesCtrl.text),
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('Agendar Consulta'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPsicologoRequest(
    BuildContext ctx,
    ProfessionalAvailability slot,
    Professional professional,
    String reason,
    String notes,
  ) async {
    Navigator.pop(ctx);

    final api = ref.read(apiClientProvider);
    // Psicólogo: usa o mesmo exam_requests mas sem examType
    // O examType fica como "consulta_psicologia"
    await ref.read(examRequestsProvider.notifier).request(
          ExamRequest(
            id: '',
            patientId: api.currentPatientId ?? '',
            professionalId: professional.id,
            availabilitySlotId: slot.id,
            examType: 'consulta_psicologia',
            notes: 'Motivo: $reason\n$notes',
            status: 'solicitado',
          ),
        );
    await ref.read(availabilityProvider.notifier).markBooked(slot.id);
    ref.invalidate(availabilityProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Consulta agendada! Aguarde confirmação.')),
      );
    }
  }
}

// ============================================================
// Widget: Cartão do Profissional
// ============================================================
class _ProfessionalCard extends StatelessWidget {
  final Professional professional;
  final AgendaMode mode;
  final VoidCallback onTap;

  const _ProfessionalCard({
    required this.professional,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = mode == AgendaMode.medico
        ? const Color(0xFF3B82F6)
        : const Color(0xFF8B5CF6);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar com ícone do tipo
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  mode == AgendaMode.medico
                      ? Icons.medical_services
                      : Icons.psychology,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional.name.isNotEmpty
                          ? professional.name
                          : '${mode == AgendaMode.medico ? "Médico" : "Psicólogo"} ${professional.council}/${professional.councilUf}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (professional.specialty.isNotEmpty)
                      Text(
                        professional.specialty,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '${professional.council} ${professional.councilUf}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Seta
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.chevron_right, color: color, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
