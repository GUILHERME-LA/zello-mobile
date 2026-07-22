import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:printing/printing.dart';
import 'package:zello_shared/zello_shared.dart';
import '../utils/prontuario_pdf.dart';
import '../widgets/perfil_section.dart';
import '../widgets/typed_list_section.dart';
import '../widgets/prontuario_item.dart';
import '../widgets/prontuario_helpers.dart';
import '../widgets/delete_confirm_dialog.dart';
import 'add_dialogs.dart';
import 'edit_dialogs.dart';

enum SaudeFilter { todos, anamnese, perfil, medicacoes, cirurgias, internacoes, sintomas, alergias, vacinas, exames, terapias, tratamentos }

extension SaudeFilterX on SaudeFilter {
  String get label {
    switch (this) {
      case SaudeFilter.todos: return 'Todos';
      case SaudeFilter.anamnese: return 'Anamnese';
      case SaudeFilter.perfil: return 'Perfil';
      case SaudeFilter.medicacoes: return 'Medicações';
      case SaudeFilter.cirurgias: return 'Cirurgias';
      case SaudeFilter.internacoes: return 'Internações';
      case SaudeFilter.sintomas: return 'Sintomas';
      case SaudeFilter.alergias: return 'Alergias';
      case SaudeFilter.vacinas: return 'Vacinas';
      case SaudeFilter.exames: return 'Exames';
      case SaudeFilter.terapias: return 'Terapias';
      case SaudeFilter.tratamentos: return 'Tratamentos';
    }
  }

  IconData get icon {
    switch (this) {
      case SaudeFilter.todos: return Icons.dashboard;
      case SaudeFilter.anamnese: return LucideIcons.clipboardList;
      case SaudeFilter.perfil: return Icons.person;
      case SaudeFilter.medicacoes: return LucideIcons.pill;
      case SaudeFilter.cirurgias: return Icons.content_cut;
      case SaudeFilter.internacoes: return Icons.local_hospital;
      case SaudeFilter.sintomas: return Icons.monitor_heart_outlined;
      case SaudeFilter.alergias: return Icons.warning_amber;
      case SaudeFilter.vacinas: return Icons.vaccines_outlined;
      case SaudeFilter.exames: return LucideIcons.flaskConical;
      case SaudeFilter.terapias: return LucideIcons.activity;
      case SaudeFilter.tratamentos: return LucideIcons.heartPulse;
    }
  }
}

class ProntuarioScreen extends ConsumerStatefulWidget {
  const ProntuarioScreen({super.key});

  @override
  ConsumerState<ProntuarioScreen> createState() => _ProntuarioScreenState();
}

class _ProntuarioScreenState extends ConsumerState<ProntuarioScreen> {
  bool _showFilters = false;
  SaudeFilter _selectedFilter = SaudeFilter.todos;

  Future<bool> _confirmDelete(BuildContext context, String type, String name) {
    return showDeleteConfirmDialog(context, type, name);
  }

  Color _examStatusColor(String status) {
    switch (status) {
      case 'concluido': return ZelloColors.success;
      case 'confirmado': return ZelloColors.primary;
      case 'recusado': case 'cancelado': return ZelloColors.danger;
      default: return ZelloColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final api = ref.watch(apiClientProvider);
    final patientIdAsync = ref.watch(currentPatientIdProvider);
    final isDemo = api.useDemoData;

    final noPatientId = patientIdAsync is AsyncLoading ||
        (patientIdAsync is AsyncData && patientIdAsync.valueOrNull == null);

    String? patientId;
    String userName;
    if (isDemo || noPatientId) {
      patientId = null;
      userName = 'Paciente';
    } else {
      patientId = patientIdAsync.valueOrNull;
      userName = auth.user?.name ?? 'Paciente';
    }

    final anamnesisAsync = ref.watch(currentAnamnesisProvider);
    final profileAsync = patientId != null
        ? ref.watch(patientHealthProfileProvider(patientId))
        : const AsyncLoading<HealthProfile?>();
    final medsAsync = patientId != null
        ? ref.watch(patientMedicationsProvider(patientId))
        : const AsyncLoading<List<Medication>>();
    final surgeriesAsync = patientId != null
        ? ref.watch(patientSurgeriesProvider(patientId))
        : const AsyncLoading<List<Surgery>>();
    final hospitalizationsAsync = patientId != null
        ? ref.watch(patientHospitalizationsProvider(patientId))
        : const AsyncLoading<List<Hospitalization>>();
    final symptomsAsync = patientId != null
        ? ref.watch(patientSymptomsProvider(patientId))
        : const AsyncLoading<List<Symptom>>();
    final allergiesAsync = patientId != null
        ? ref.watch(patientAllergiesProvider(patientId))
        : const AsyncLoading<List<Allergy>>();
    final vaccinesAsync = patientId != null
        ? ref.watch(patientVaccinesProvider(patientId))
        : const AsyncLoading<List<Vaccine>>();
    final examsAsync = patientId != null
        ? ref.watch(patientExamsProvider(patientId))
        : const AsyncLoading<List<Exam>>();
    final therapiesAsync = patientId != null
        ? ref.watch(patientTherapiesProvider(patientId))
        : const AsyncLoading<List<Therapy>>();
    final analysisState = ref.watch(prontuarioAnalysisProvider);

    final isAnalyzing = analysisState.status == ProntuarioAnalysisStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildBody(context, patientId, isDemo, userName,
                  anamnesisAsync, profileAsync, medsAsync,
                  surgeriesAsync, hospitalizationsAsync,
                  symptomsAsync, allergiesAsync, vaccinesAsync,
                  examsAsync, therapiesAsync,
                  analysisState, isAnalyzing),
            ),
            if (patientId != null)
              _buildBottomBar(isAnalyzing, patientId, userName),
          ],
        ),
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
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.folderOpen,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meu Histórico de Saúde',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20)),
                    Text('Todas as suas informações de saúde',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_showFilters ? LucideIcons.filterX : LucideIcons.filter,
                    color: Colors.white.withAlpha(180)),
                onPressed: () => setState(() => _showFilters = !_showFilters),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    String? patientId,
    bool isDemo,
    String userName,
    AsyncValue<Anamnesis?> anamnesisAsync,
    AsyncValue<HealthProfile?> profileAsync,
    AsyncValue<List<Medication>> medsAsync,
    AsyncValue<List<Surgery>> surgeriesAsync,
    AsyncValue<List<Hospitalization>> hospitalizationsAsync,
    AsyncValue<List<Symptom>> symptomsAsync,
    AsyncValue<List<Allergy>> allergiesAsync,
    AsyncValue<List<Vaccine>> vaccinesAsync,
    AsyncValue<List<Exam>> examsAsync,
    AsyncValue<List<Therapy>> therapiesAsync,
    ProntuarioAnalysisState analysisState,
    bool isAnalyzing,
  ) {
    if (patientId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline, size: 48, color: Colors.orange.shade300),
            ),
            const SizedBox(height: 20),
            Text(
              isDemo ? 'Modo Demonstração' : 'Histórico não disponível',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                isDemo
                    ? 'Faça login com uma conta real para acessar seu histórico.'
                    : 'Não foi possível identificar seu perfil de paciente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(anamnesesProvider);
        ref.invalidate(currentAnamnesisProvider);
        ref.invalidate(patientHealthProfileProvider(patientId));
        ref.invalidate(patientMedicationsProvider(patientId));
        ref.invalidate(patientSurgeriesProvider(patientId));
        ref.invalidate(patientHospitalizationsProvider(patientId));
        ref.invalidate(patientSymptomsProvider(patientId));
        ref.invalidate(patientAllergiesProvider(patientId));
        ref.invalidate(patientVaccinesProvider(patientId));
        ref.invalidate(patientExamsProvider(patientId));
        ref.invalidate(patientTherapiesProvider(patientId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showFilters) _buildFilterChips(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Anamnese
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.anamnese)
                    _AnamnesisSection(anamnesisAsync: anamnesisAsync),

                  // Perfil
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.perfil)
                    Padding(
                      padding: EdgeInsets.only(top: _selectedFilter != SaudeFilter.todos ? 0 : 16),
                      child: PerfilSection(profileAsync: profileAsync, patientId: patientId),
                    ),

                  // Medications
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.medicacoes)
                    TypedListSection<Medication>(
                      title: 'Medicações', icon: LucideIcons.pill, iconColor: const Color(0xFF1565C0),
                      async: medsAsync, emptyText: 'Nenhuma medicação cadastrada.',
                      onAdd: null,
                      itemBuilder: (m) => ProntuarioItem(
                        title: m.name,
                        subtitle: '${m.dosage}${m.frequency.isNotEmpty ? ' — ${m.frequency}' : ''}',
                        trailing: m.isActive ? 'Ativo' : 'Inativo',
                        notes: m.prescribingDoctor.isNotEmpty ? 'Dr(a). ${m.prescribingDoctor}' : '',
                        onEdit: null,
                        onDelete: () async {
                          final confirmed = await _confirmDelete(context, 'medicação', m.name);
                          if (confirmed) {
                            await ref.read(patientHealthProvider).deleteMedication(m.id);
                            ref.invalidate(patientMedicationsProvider(patientId));
                            if (context.mounted) _sucesso(context);
                          }
                        },
                      ),
                    ),

                  // Cirurgias
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.cirurgias)
                    TypedListSection<Surgery>(
                      title: 'Cirurgias', icon: LucideIcons.scissors, iconColor: ZelloColors.primary,
                      async: surgeriesAsync, emptyText: 'Nenhuma cirurgia cadastrada.',
                      onAdd: () => showAddSurgeryDialog(context, ref, patientId),
                      onItemEdit: (s) => showEditSurgeryDialog(context, ref, patientId, s),
                      onItemDelete: (s) async {
                        final confirmed = await _confirmDelete(context, 'cirurgia', s.name);
                        if (confirmed) {
                          await ref.read(patientHealthProvider).deleteSurgery(s.id);
                          ref.invalidate(patientSurgeriesProvider(patientId));
                          if (context.mounted) _sucesso(context);
                        }
                      },
                      itemBuilder: (s) => ProntuarioItem(
                        title: s.name,
                        subtitle: Formatters.formatDate(s.date),
                        trailing: s.hospital.isNotEmpty ? s.hospital : null,
                        notes: s.notes,
                      ),
                    ),

                  // Internações
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.internacoes)
                    TypedListSection<Hospitalization>(
                      title: 'Internações', icon: LucideIcons.building2, iconColor: ZelloColors.danger,
                      async: hospitalizationsAsync, emptyText: 'Nenhuma internação registrada.',
                      onAdd: () => showAddHospitalizationDialog(context, ref, patientId),
                      onItemEdit: (h) => showEditHospitalizationDialog(context, ref, patientId, h),
                      onItemDelete: (h) async {
                        final confirmed = await _confirmDelete(context, 'internação', h.reason);
                        if (confirmed) {
                          await ref.read(patientHealthProvider).deleteHospitalization(h.id);
                          ref.invalidate(patientHospitalizationsProvider(patientId));
                          if (context.mounted) _sucesso(context);
                        }
                      },
                      itemBuilder: (h) => ProntuarioItem(
                        title: h.reason,
                        subtitle: '${Formatters.formatDate(h.startDate)} a ${h.endDate != null ? Formatters.formatDate(h.endDate!) : "em andamento"}',
                        trailing: h.hospital.isNotEmpty ? h.hospital : null,
                        notes: h.notes,
                      ),
                    ),

                  // Sintomas
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.sintomas)
                    TypedListSection<Symptom>(
                      title: 'Sintomas Recorrentes', icon: LucideIcons.activity, iconColor: ZelloColors.warning,
                      async: symptomsAsync, emptyText: 'Nenhum sintoma registrado.',
                      onAdd: () => showAddSymptomDialog(context, ref, patientId),
                      onItemEdit: (s) => showEditSymptomDialog(context, ref, patientId, s),
                      onItemDelete: (s) async {
                        final confirmed = await _confirmDelete(context, 'sintoma', s.name);
                        if (confirmed) {
                          await ref.read(patientHealthProvider).deleteSymptom(s.id);
                          ref.invalidate(patientSymptomsProvider(patientId));
                          if (context.mounted) _sucesso(context);
                        }
                      },
                      itemBuilder: (s) => ProntuarioItem(
                        title: s.name,
                        subtitle: [
                          if (s.frequency.isNotEmpty) s.frequency,
                          if (s.intensity.isNotEmpty) 'Intensidade: ${s.intensity}',
                        ].join(' — '),
                        notes: s.notes,
                      ),
                    ),

                  // Alergias
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.alergias)
                    TypedListSection<Allergy>(
                      title: 'Alergias', icon: LucideIcons.shieldAlert, iconColor: ZelloColors.danger,
                      async: allergiesAsync, emptyText: 'Nenhuma alergia cadastrada.',
                      isUrgent: true,
                      onAdd: () => showAddAllergyDialog(context, ref, patientId),
                      onItemEdit: (a) => showEditAllergyDialog(context, ref, patientId, a),
                      onItemDelete: (a) async {
                        final confirmed = await _confirmDelete(context, 'alergia', a.name);
                        if (confirmed) {
                          await ref.read(patientHealthProvider).deleteAllergy(a.id);
                          ref.invalidate(patientAllergiesProvider(patientId));
                          if (context.mounted) _sucesso(context);
                        }
                      },
                      itemBuilder: (a) => ProntuarioItem(
                        title: a.name,
                        subtitle: 'Tipo: ${a.type}${a.reaction.isNotEmpty ? " — ${a.reaction}" : ""}',
                        notes: a.notes,
                        isUrgent: true,
                      ),
                    ),

                  // Vacinas
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.vacinas)
                    TypedListSection<Vaccine>(
                      title: 'Vacinas', icon: LucideIcons.syringe, iconColor: ZelloColors.success,
                      async: vaccinesAsync, emptyText: 'Nenhuma vacina cadastrada.',
                      onAdd: () => showAddVaccineDialog(context, ref, patientId),
                      onItemEdit: (v) => showEditVaccineDialog(context, ref, patientId, v),
                      onItemDelete: (v) async {
                        final confirmed = await _confirmDelete(context, 'vacina', v.name);
                        if (confirmed) {
                          await ref.read(patientHealthProvider).deleteVaccine(v.id);
                          ref.invalidate(patientVaccinesProvider(patientId));
                          if (context.mounted) _sucesso(context);
                        }
                      },
                      itemBuilder: (v) => ProntuarioItem(
                        title: v.name,
                        subtitle: '${Formatters.formatDate(v.date)}${v.dose.isNotEmpty ? " — ${v.dose}" : ""}',
                        trailing: v.isPending ? 'Pendente' : null,
                        notes: v.notes,
                        isPending: v.isPending,
                      ),
                    ),

                  // Exames
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.exames)
                    TypedListSection<Exam>(
                      title: 'Exames', icon: LucideIcons.flaskConical, iconColor: const Color(0xFF7C3AED),
                      async: examsAsync, emptyText: 'Nenhum exame cadastrado.',
                      onAdd: () => showAddExamDialog(context, ref, patientId),
                      onItemEdit: (e) => showEditExamDialog(context, ref, patientId, e),
                      onItemDelete: (e) async {
                        final confirmed = await _confirmDelete(context, 'exame', e.title);
                        if (confirmed) {
                          await ref.read(patientHealthProvider).deleteExam(e.id);
                          ref.invalidate(patientExamsProvider(patientId));
                          if (context.mounted) _sucesso(context);
                        }
                      },
                      itemBuilder: (e) {
                        final color = _examStatusColor(e.status);
                        return ProntuarioItem(
                          title: e.title,
                          subtitle: e.examType.isNotEmpty ? e.examType : null,
                          trailing: e.statusLabel,
                          notes: e.notes,
                          trailingColor: color,
                        );
                      },
                    ),

                  // Terapias
                  if (_selectedFilter == SaudeFilter.todos || _selectedFilter == SaudeFilter.terapias)
                    TypedListSection<Therapy>(
                      title: 'Terapias', icon: LucideIcons.activity, iconColor: const Color(0xFF8B5CF6),
                      async: therapiesAsync, emptyText: 'Nenhuma terapia cadastrada.',
                      onAdd: () => showAddTherapyDialog(context, ref, patientId),
                      onItemEdit: (t) => showEditTherapyDialog(context, ref, patientId, t),
                      onItemDelete: (t) async {
                        final confirmed = await _confirmDelete(context, 'terapia', t.name);
                        if (confirmed) {
                          await ref.read(patientHealthProvider).deleteTherapy(t.id);
                          ref.invalidate(patientTherapiesProvider(patientId));
                          if (context.mounted) _sucesso(context);
                        }
                      },
                      itemBuilder: (t) => ProntuarioItem(
                        title: t.name,
                        subtitle: '${t.frequency.isNotEmpty ? "${t.frequency} — " : ""}${t.professional.isNotEmpty ? t.professional : ""}',
                        trailing: t.status == TherapyStatus.ativa ? 'Ativa' : t.status == TherapyStatus.concluida ? 'Concluída' : 'Pausada',
                        notes: t.notes,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isAnalyzing, String patientId, String userName) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _bottomAction(
                  icon: LucideIcons.fileDown,
                  label: 'Exportar PDF',
                  color: ZelloColors.primary,
                  onTap: () => _exportPdf(context, patientId: patientId, userName: userName),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bottomAction(
                  icon: isAnalyzing ? LucideIcons.hourglass : LucideIcons.sparkles,
                  label: isAnalyzing ? 'Analisando...' : 'Análise IA',
                  color: ZelloColors.psychology,
                  isLoading: isAnalyzing,
                  onTap: isAnalyzing ? null : () => _analyzeProntuario(context, patientId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomAction({
    required IconData icon,
    required String label,
    required Color color,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: color),
                    )
                  : Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtrar por:', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SaudeFilter.values.map((f) {
                final selected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: selected,
                    showCheckmark: false,
                    avatar: Icon(f.icon, size: 16, color: selected ? Colors.white : Colors.grey.shade600),
                    label: Text(f.label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.grey.shade700)),
                    selectedColor: ZelloColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: selected ? ZelloColors.primary : Colors.grey.shade300),
                    onSelected: (_) => setState(() => _selectedFilter = f),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, {required String patientId, required String userName}) async {
    try {
      final profile = await ref.read(patientHealthProfileProvider(patientId).future);
      final surgeries = await ref.read(patientSurgeriesProvider(patientId).future);
      final hospitalizations = await ref.read(patientHospitalizationsProvider(patientId).future);
      final symptoms = await ref.read(patientSymptomsProvider(patientId).future);
      final allergies = await ref.read(patientAllergiesProvider(patientId).future);
      final vaccines = await ref.read(patientVaccinesProvider(patientId).future);

      if (!context.mounted) return;

      final pdfBytes = await ProntuarioPdf.generate(
        patientName: userName,
        profile: profile,
        surgeries: surgeries.map((s) => s.toJson()).toList(),
        hospitalizations: hospitalizations.map((h) => h.toJson()).toList(),
        symptoms: symptoms.map((s) => s.toJson()).toList(),
        allergies: allergies.map((a) => a.toJson()).toList(),
        vaccines: vaccines.map((v) => v.toJson()).toList(),
      );

      if (!context.mounted) return;

      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _analyzeProntuario(BuildContext context, String patientId) async {
    await ref.read(prontuarioAnalysisProvider.notifier).analyze(patientId);

    final state = ref.read(prontuarioAnalysisProvider);
    if (!context.mounted) return;

    if (state.status == ProntuarioAnalysisStatus.success && state.result != null) {
      _showAnalysisResult(context, state.result!);
    } else if (state.status == ProntuarioAnalysisStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error ?? 'Erro ao analisar histórico'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showAnalysisResult(BuildContext context, ProntuarioAnalysisResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Análise do Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                        SizedBox(height: 2),
                        Text('Gerado por IA', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.alertTriangle, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta análise é gerada por IA e tem caráter informativo. Consulte sempre um médico para decisões sobre sua saúde.',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              riskBadge(result.overallRisk),
              const SizedBox(height: 20),
              sectionLabel('Resumo Geral', Icons.summarize_outlined),
              const SizedBox(height: 8),
              Text(result.summary, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6)),
              const SizedBox(height: 24),
              sectionLabel('Pontos de Atenção', Icons.report_problem_outlined),
              const SizedBox(height: 8),
              ...result.attentionPoints.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 3, right: 8), child: Icon(Icons.circle, size: 8, color: Color(0xFFEF4444))),
                        Expanded(child: Text(p, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              sectionLabel('Sugestões', Icons.lightbulb_outline),
              const SizedBox(height: 8),
              ...result.suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 3, right: 8), child: Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF3B82F6))),
                        Expanded(child: Text(s, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              sectionLabel('Cuidados Preventivos', Icons.shield_outlined),
              const SizedBox(height: 8),
              ...result.preventiveCare.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 3, right: 8), child: Icon(Icons.favorite_outline, size: 16, color: Color(0xFF10B981))),
                        Expanded(child: Text(c, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              sectionLabel('Recomendações de Estilo de Vida', Icons.self_improvement),
              const SizedBox(height: 8),
              ...result.lifestyleRecommendations.map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 3, right: 8), child: Icon(Icons.eco_outlined, size: 16, color: Color(0xFF8B5CF6))),
                        Expanded(child: Text(l, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.share2, size: 18),
                  label: const Text('Compartilhar Análise'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnamnesisSection extends StatelessWidget {
  final AsyncValue<Anamnesis?> anamnesisAsync;

  const _AnamnesisSection({required this.anamnesisAsync});

  @override
  Widget build(BuildContext context) {
    return anamnesisAsync.when(
      data: (anamnesis) {
        if (anamnesis == null || !anamnesis.completed) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.clipboardList,
                        color: Color(0xFF1565C0), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Anamnese',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Preenchido',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _AnamnesisRow(label: 'CPF', value: anamnesis.cpf.isNotEmpty ? anamnesis.cpf : '—'),
              _AnamnesisRow(label: 'RG', value: anamnesis.rg.isNotEmpty ? anamnesis.rg : '—'),
              _AnamnesisRow(label: 'Altura', value: anamnesis.altura != null ? '${anamnesis.altura!.toStringAsFixed(2)} m' : '—'),
              _AnamnesisRow(label: 'Cirurgias', value: anamnesis.surgeriesDescription.isNotEmpty ? 'Sim' : 'Não'),
              _AnamnesisRow(label: 'Alergias', value: anamnesis.allergiesDetails.isNotEmpty ? 'Sim' : 'Não'),
              _AnamnesisRow(label: 'Depressão', value: anamnesis.hasDepression ? 'Sim' : 'Não'),
              _AnamnesisRow(label: 'Plano de saúde', value: anamnesis.hasInsurance ? anamnesis.insuranceProvider : 'Sem plano'),
              if (anamnesis.hasInsurance)
                _AnamnesisRow(label: 'Plano', value: anamnesis.insurancePlan.isNotEmpty ? anamnesis.insurancePlan : '—'),
              if (!anamnesis.hasInsurance && anamnesis.addressCity.isNotEmpty)
                _AnamnesisRow(label: 'Cidade', value: '${anamnesis.addressCity}${anamnesis.addressState.isNotEmpty ? ' - ${anamnesis.addressState}' : ''}'),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AnamnesisRow extends StatelessWidget {
  final String label;
  final String value;

  const _AnamnesisRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

void _snack(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}

void _sucesso(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Operação concluída!')]),
    backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating,
  ));
}
