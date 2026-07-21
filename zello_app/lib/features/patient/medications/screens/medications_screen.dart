import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';
import 'package:zello_shared/providers/dose_history_provider.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  bool _showActive = true;

  void _showMedicationDetail(Medication med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
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
                  Container(
                    width: 48, height: 48,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: const Icon(LucideIcons.pill, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                        Text(med.dosage, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _detailRow('Frequência', med.frequency),
              const SizedBox(height: 12),
              _detailRow('Médico', med.prescribingDoctor),
              const SizedBox(height: 12),
              _detailRow('Início', med.startDate != null ? Formatters.formatDate(med.startDate!) : 'Data não informada'),
              if (med.endDate != null) ...[
                const SizedBox(height: 12),
                _detailRow('Término', Formatters.formatDate(med.endDate!)),
              ],
              const SizedBox(height: 12),
              _detailRow('Status', med.isActive ? 'Ativo' : 'Inativo'),
              if (med.isActive) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _DoseSection(medication: med),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(medicationsProvider);
    return async.when(
      data: (meds) {
        final activeMeds = meds.where((m) => m.isActive).toList();
        final inactiveMeds = meds.where((m) => !m.isActive).toList();
        final displayedMeds = _showActive ? activeMeds : inactiveMeds;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(medicationsProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Ativas',
                            count: activeMeds.length,
                            isSelected: _showActive,
                            onTap: () => setState(() => _showActive = true),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Histórico',
                            count: inactiveMeds.length,
                            isSelected: !_showActive,
                            onTap: () => setState(() => _showActive = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SectionHeader(
                      title: _showActive ? 'Medicações Ativas' : 'Histórico',
                      subtitle: '${displayedMeds.length} ${displayedMeds.length == 1 ? 'item' : 'itens'}',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: displayedMeds.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  _showActive
                                      ? 'Nenhuma medicação ativa'
                                      : 'Nenhuma medicação encerrada',
                                  style: const TextStyle(color: Color(0xFF6B7280)),
                                ),
                              ),
                            )
                          : Column(
                              children: displayedMeds.map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MedicationCard(
                                  medication: m,
                                  onTap: () => _showMedicationDetail(m),
                                ),
                              )).toList(),
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
      loading: () => _buildLoading(),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              ...List.generate(4, (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: SkeletonCard(),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medicações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
              SizedBox(height: 2),
              Text('Acompanhe seus medicamentos', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTap;

  const _MedicationCard({
    required this.medication,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = medication.isActive;
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: (isActive ? const Color(0xFF1565C0) : const Color(0xFF6B7280)).withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(LucideIcons.pill,
                color: isActive ? const Color(0xFF1565C0) : const Color(0xFF6B7280),
                size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(medication.dosage,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                if (medication.prescribingDoctor.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Dr(a). ${medication.prescribingDoctor}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(isActive ? LucideIcons.clock : LucideIcons.checkCircle,
                        size: 14,
                        color: isActive ? const Color(0xFFF59E0B) : const Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(isActive ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                            fontSize: 11,
                            color: isActive ? const Color(0xFFF59E0B) : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
}

class _DoseSection extends ConsumerStatefulWidget {
  final Medication medication;

  const _DoseSection({required this.medication});

  @override
  ConsumerState<_DoseSection> createState() => _DoseSectionState();
}

class _DoseSectionState extends ConsumerState<_DoseSection> {
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveDose() async {
    setState(() => _isSaving = true);
    try {
      final api = ref.read(apiClientProvider);
      final patientId = ref.read(currentPatientIdProvider).valueOrNull;
      if (patientId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: paciente não identificado'),
                behavior: SnackBarBehavior.floating),
          );
        }
        return;
      }

      await api.saveDose({
        'medication_id': widget.medication.id,
        'patient_id': patientId,
        'taken_at': DateTime.now().toUtc().toIso8601String(),
        'dosage': _dosageController.text.trim(),
        'notes': _notesController.text.trim(),
      });

      // Invalidate providers
      ref.invalidate(doseHistoryProvider(widget.medication.id));

      if (mounted) {
        _dosageController.clear();
        _notesController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dose registrada com sucesso!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dosesAsync = ref.watch(doseHistoryProvider(widget.medication.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Registrar Dose',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _dosageController,
          decoration: InputDecoration(
            labelText: 'Dosagem tomada (opcional)',
            hintText: 'Ex: 1 comprimido, 5ml',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Observações (opcional)',
            hintText: 'Ex: Tomado com almoço',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveDose,
            icon: _isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(LucideIcons.check, size: 18),
            label: Text(_isSaving ? 'Salvando...' : 'Registrar Tomada'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        dosesAsync.when(
          data: (doses) {
            if (doses.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nenhuma dose registrada ainda.',
                    style: TextStyle(color: Color(0xFF6B7280), fontStyle: FontStyle.italic)),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Histórico de Doses (${doses.length})',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...doses.take(10).map((dose) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDateTime(dose.takenAt),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            if (dose.dosage.isNotEmpty)
                              Text(dose.dosage,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                            if (dose.notes.isNotEmpty)
                              Text(dose.notes,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Text('Erro ao carregar histórico: $e',
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      ],
    );
  }

  static String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year às $hour:$minute';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFF5F9FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
