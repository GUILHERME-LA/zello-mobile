import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class PatientAgendaScreen extends ConsumerStatefulWidget {
  const PatientAgendaScreen({super.key});

  @override
  ConsumerState<PatientAgendaScreen> createState() => _PatientAgendaScreenState();
}

class _PatientAgendaScreenState extends ConsumerState<PatientAgendaScreen> {
  @override
  Widget build(BuildContext context) {
    final availabilityAsync = ref.watch(availabilityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda do Profissional')),
      body: availabilityAsync.when(
        data: (slots) {
          if (slots.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 16),
                  Text('Nenhum horário disponível no momento',
                      style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              return AnimatedCard(
                onTap: () => _showRequestDialog(slot),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time,
                          color: Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${slot.date.day}/${slot.date.month}/${slot.date.year}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${slot.startTime} - ${slot.endTime}',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  void _showRequestDialog(ProfessionalAvailability slot) {
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
              '${slot.date.day}/${slot.date.month}/${slot.date.year} - ${slot.startTime} às ${slot.endTime}',
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
              decoration: const InputDecoration(labelText: 'Observações (opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final auth = ref.read(authProvider);
                  await ref.read(examRequestsProvider.notifier).request(
                        ExamRequest(
                          id: '',
                          patientId: auth.user?.id ?? '',
                          professionalId: slot.professionalId,
                          availabilitySlotId: slot.id,
                          examType: examTypeCtrl.text,
                          notes: notesCtrl.text,
                          status: 'solicitado',
                        ),
                      );
                  await ref.read(availabilityProvider.notifier).markBooked(slot.id);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Solicitação enviada! Aguarde confirmação.')),
                    );
                  }
                },
                child: const Text('Enviar Solicitação'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
