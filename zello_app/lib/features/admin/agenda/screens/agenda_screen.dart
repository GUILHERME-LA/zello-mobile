import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedProfessionalId;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isAdmin = user?.isAdmin == true;
    final canConsultations = ref.watch(canAccessProvider('consultations'));

    if (!canConsultations) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.lock, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Você não tem permissão para gerenciar consultas',
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Solicite acesso ao administrador do sistema.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final professionalId = isAdmin
        ? _selectedProfessionalId
        : user?.professionalId;

    // Altura do calendário responsiva: 40% da tela, entre 220 e 300px
    final calendarHeight =
        (MediaQuery.of(context).size.height * 0.4).clamp(220.0, 300.0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GradientHeader(
              title: 'Agenda',
              subtitle: 'Gerencie os horários dos profissionais',
            ),
            if (isAdmin) _buildProfessionalSelector(),
            SizedBox(
              height: calendarHeight,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                onDateChanged: (d) => setState(() => _selectedDate = d),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: professionalId == null
                  ? EmptyState(
                      icon: LucideIcons.userX,
                      title: 'Profissional não identificado',
                      subtitle: isAdmin
                          ? 'Selecione um profissional acima para ver a agenda.'
                          : 'Associe um perfil profissional para gerenciar sua agenda.',
                    )
                  : _buildSlotsList(professionalId),
            ),
          ],
        ),
      ),
      floatingActionButton: professionalId != null
          ? FloatingActionButton(
              onPressed: () => _showCreateSlotDialog(professionalId),
              child: const Icon(LucideIcons.plus),
            )
          : null,
    );
  }

  Widget _buildProfessionalSelector() {
    final professionalsAsync = ref.watch(professionalsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: professionalsAsync.when(
        data: (professionals) {
          if (professionals.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Nenhum profissional cadastrado.',
                  style: TextStyle(color: Color(0xFF6B7280))),
            );
          }
          return DropdownButtonFormField<String>(
            value: _selectedProfessionalId,
            decoration: const InputDecoration(
              labelText: 'Selecionar profissional',
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            items: professionals.map((p) => DropdownMenuItem(
              value: p.id,
              child: Text(p.name.isNotEmpty ? p.name : '${p.type} - ${p.council}/${p.councilUf}'),
            )).toList(),
            onChanged: (v) {
              setState(() => _selectedProfessionalId = v);
              if (v != null) {
                ref.read(availabilityProvider.notifier).load(v);
              }
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: LinearProgressIndicator(),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSlotsList(String professionalId) {
    final availabilityAsync = ref.watch(availabilityProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(availabilityProvider);
        if (professionalId.isNotEmpty) {
          await ref.read(availabilityProvider.notifier).load(professionalId);
        }
      },
      child: availabilityAsync.when(
        data: (slots) {
          final daySlots = slots
              .where((s) =>
                  s.date.year == _selectedDate.year &&
                  s.date.month == _selectedDate.month &&
                  s.date.day == _selectedDate.day)
              .toList();
          if (daySlots.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                EmptyState(
                  icon: LucideIcons.calendarX,
                  title: 'Nenhum horário para este dia',
                  subtitle: 'Toque + para adicionar um horário disponível.',
                ),
              ],
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: daySlots.length,
            itemBuilder: (context, i) {
              final slot = daySlots[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedCard(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 48,
                        decoration: BoxDecoration(
                          color: slot.isBooked
                              ? ZelloColors.primaryLighter
                              : ZelloColors.primaryLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${slot.startTime} - ${slot.endTime}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              slot.isBooked ? 'Reservado' : 'Disponível',
                              style: TextStyle(
                                fontSize: 12,
                                color: slot.isBooked
                                    ? ZelloColors.primaryLighter
                                    : ZelloColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!slot.isBooked)
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444)),
                          onPressed: () async {
                            try {
                              await ref.read(availabilityProvider.notifier).delete(slot.id);
                              ref.invalidate(availabilityProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Horário removido'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao remover: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          message: 'Não foi possível carregar os horários.',
          technicalDetails: '$e',
          onRetry: () {
            ref.invalidate(availabilityProvider);
            if (professionalId.isNotEmpty) {
              ref.read(availabilityProvider.notifier).load(professionalId);
            }
          },
        ),
      ),
    );
  }

  void _showCreateSlotDialog(String professionalId) {
    final startCtrl = TextEditingController(text: '08:00');
    final endCtrl = TextEditingController(text: '09:00');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
            const Text('Novo Horário',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startCtrl,
                    decoration: const InputDecoration(labelText: 'Início (HH:mm)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: endCtrl,
                    decoration: const InputDecoration(labelText: 'Fim (HH:mm)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final slot = ProfessionalAvailability(
                    id: '',
                    professionalId: professionalId,
                    date: _selectedDate,
                    startTime: startCtrl.text,
                    endTime: endCtrl.text,
                  );
                  try {
                    await ref.read(availabilityProvider.notifier).create(slot);
                    ref.invalidate(availabilityProvider);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Horário criado com sucesso'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    if (!ctx.mounted) return;
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao criar horário: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Criar Horário'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
