import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:zello_shared/zello_shared.dart';
import '../utils/prontuario_pdf.dart';

/// Filtros disponíveis para o prontuário
enum ProntuarioFilter { todos, perfil, cirurgias, internacoes, sintomas, alergias, vacinas }

extension ProntuarioFilterX on ProntuarioFilter {
  String get label {
    switch (this) {
      case ProntuarioFilter.todos: return 'Todos';
      case ProntuarioFilter.perfil: return 'Perfil';
      case ProntuarioFilter.cirurgias: return 'Cirurgias';
      case ProntuarioFilter.internacoes: return 'Internações';
      case ProntuarioFilter.sintomas: return 'Sintomas';
      case ProntuarioFilter.alergias: return 'Alergias';
      case ProntuarioFilter.vacinas: return 'Vacinas';
    }
  }

  IconData get icon {
    switch (this) {
      case ProntuarioFilter.todos: return Icons.dashboard;
      case ProntuarioFilter.perfil: return Icons.person;
      case ProntuarioFilter.cirurgias: return Icons.content_cut;
      case ProntuarioFilter.internacoes: return Icons.local_hospital;
      case ProntuarioFilter.sintomas: return Icons.monitor_heart_outlined;
      case ProntuarioFilter.alergias: return Icons.warning_amber;
      case ProntuarioFilter.vacinas: return Icons.vaccines_outlined;
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
  ProntuarioFilter _selectedFilter = ProntuarioFilter.todos;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final patientId = auth.user?.id ?? '';
    final userName = auth.user?.name ?? 'Paciente';

    // Providers de dados
    final profileAsync = ref.watch(patientHealthProfileProvider(patientId));
    final surgeriesAsync = ref.watch(patientSurgeriesProvider(patientId));
    final hospitalizationsAsync = ref.watch(patientHospitalizationsProvider(patientId));
    final symptomsAsync = ref.watch(patientSymptomsProvider(patientId));
    final allergiesAsync = ref.watch(patientAllergiesProvider(patientId));
    final vaccinesAsync = ref.watch(patientVaccinesProvider(patientId));
    final analysisState = ref.watch(prontuarioAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prontuário'),
        actions: [
          // Botão filtrar
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            tooltip: 'Filtrar',
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          // Botão exportar PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: () => _exportPdf(
              context,
              patientId: patientId,
              userName: userName,
            ),
          ),
          // Botão análise IA
          IconButton(
            icon: analysisState.status == ProntuarioAnalysisStatus.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            tooltip: 'Análise com IA',
            onPressed: analysisState.status == ProntuarioAnalysisStatus.loading
                ? null
                : () => _analyzeProntuario(context, patientId),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(patientHealthProfileProvider(patientId));
          ref.invalidate(patientSurgeriesProvider(patientId));
          ref.invalidate(patientHospitalizationsProvider(patientId));
          ref.invalidate(patientSymptomsProvider(patientId));
          ref.invalidate(patientAllergiesProvider(patientId));
          ref.invalidate(patientVaccinesProvider(patientId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtros (show/hide)
              if (_showFilters) _buildFilterChips(),

              // Conteúdo filtrado
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção Perfil
                    if (_selectedFilter == ProntuarioFilter.todos ||
                        _selectedFilter == ProntuarioFilter.perfil)
                      _PerfilSection(profileAsync: profileAsync, patientId: patientId),

                    if (_selectedFilter == ProntuarioFilter.todos ||
                        _selectedFilter == ProntuarioFilter.cirurgias)
                      _GenericListSection<dynamic>(
                        title: 'Cirurgias',
                        icon: Icons.content_cut,
                        iconColor: const Color(0xFF1565C0),
                        async: surgeriesAsync,
                        emptyText: 'Nenhuma cirurgia cadastrada.',
                        itemBuilder: (item) => _ProntuarioItem(
                          title: item['name'] ?? '',
                          subtitle: item['date'] != null ? Formatters.formatDate(DateTime.parse(item['date'])) : '',
                          trailing: item['hospital'] != null && item['hospital'].toString().isNotEmpty
                              ? item['hospital'].toString()
                              : null,
                          notes: item['notes'] ?? '',
                        ),
                      ),

                    if (_selectedFilter == ProntuarioFilter.todos ||
                        _selectedFilter == ProntuarioFilter.internacoes)
                      _GenericListSection<dynamic>(
                        title: 'Internações',
                        icon: Icons.local_hospital,
                        iconColor: const Color(0xFFEF4444),
                        async: hospitalizationsAsync,
                        emptyText: 'Nenhuma internação registrada.',
                        itemBuilder: (item) => _ProntuarioItem(
                          title: item['reason'] ?? '',
                          subtitle: '${item['start_date'] ?? ""} a ${item['end_date'] ?? "em andamento"}',
                          trailing: item['hospital'] != null && item['hospital'].toString().isNotEmpty
                              ? item['hospital'].toString()
                              : null,
                          notes: item['notes'] ?? '',
                        ),
                      ),

                    if (_selectedFilter == ProntuarioFilter.todos ||
                        _selectedFilter == ProntuarioFilter.sintomas)
                      _GenericListSection<dynamic>(
                        title: 'Sintomas Recorrentes',
                        icon: Icons.monitor_heart_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        async: symptomsAsync,
                        emptyText: 'Nenhum sintoma registrado.',
                        itemBuilder: (item) => _ProntuarioItem(
                          title: item['name'] ?? '',
                          subtitle: [
                            if (item['frequency'] != null && item['frequency'].toString().isNotEmpty)
                              item['frequency'].toString(),
                            if (item['intensity'] != null && item['intensity'].toString().isNotEmpty)
                              'Intensidade: ${item['intensity']}',
                          ].join(' — '),
                          notes: item['notes'] ?? '',
                        ),
                      ),

                    if (_selectedFilter == ProntuarioFilter.todos ||
                        _selectedFilter == ProntuarioFilter.alergias)
                      _GenericListSection<dynamic>(
                        title: 'Alergias',
                        icon: Icons.warning_amber,
                        iconColor: const Color(0xFFEF4444),
                        async: allergiesAsync,
                        emptyText: 'Nenhuma alergia cadastrada.',
                        isUrgent: true,
                        itemBuilder: (item) => _ProntuarioItem(
                          title: item['name'] ?? '',
                          subtitle: 'Tipo: ${item['type'] ?? ""}${item['reaction'] != null && item['reaction'].toString().isNotEmpty ? " — ${item['reaction']}" : ""}',
                          notes: item['notes'] ?? '',
                          isUrgent: true,
                        ),
                      ),

                    if (_selectedFilter == ProntuarioFilter.todos ||
                        _selectedFilter == ProntuarioFilter.vacinas)
                      _GenericListSection<dynamic>(
                        title: 'Vacinas',
                        icon: Icons.vaccines_outlined,
                        iconColor: const Color(0xFF10B981),
                        async: vaccinesAsync,
                        emptyText: 'Nenhuma vacina cadastrada.',
                        itemBuilder: (item) => _ProntuarioItem(
                          title: item['name'] ?? '',
                          subtitle: '${item['date'] ?? ""}${item['dose'] != null && item['dose'].toString().isNotEmpty ? " — ${item['dose']}" : ""}',
                          trailing: item['is_pending'] == true ? 'Pendente' : null,
                          notes: item['notes'] ?? '',
                          isPending: item['is_pending'] == true,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FILTROS ====================

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
              children: ProntuarioFilter.values.map((f) {
                final selected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: selected,
                    showCheckmark: false,
                    avatar: Icon(f.icon, size: 16, color: selected ? Colors.white : Colors.grey.shade600),
                    label: Text(f.label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.grey.shade700)),
                    selectedColor: const Color(0xFF1565C0),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: selected ? const Color(0xFF1565C0) : Colors.grey.shade300),
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

  // ==================== EXPORTAR PDF ====================

  Future<void> _exportPdf(BuildContext context, {required String patientId, required String userName}) async {
    try {
      // Coleta dados atuais
      final profile = await ref.read(patientHealthProfileProvider(patientId).future);
      final surgeries = await ref.read(patientSurgeriesProvider(patientId).future);
      final hospitalizations = await ref.read(patientHospitalizationsProvider(patientId).future);
      final symptoms = await ref.read(patientSymptomsProvider(patientId).future);
      final allergies = await ref.read(patientAllergiesProvider(patientId).future);
      final vaccines = await ref.read(patientVaccinesProvider(patientId).future);

      if (!context.mounted) return;

      // Gera o PDF
      final pdfBytes = await ProntuarioPdf.generate(
        patientName: userName,
        profile: profile,
        surgeries: surgeries,
        hospitalizations: hospitalizations,
        symptoms: symptoms,
        allergies: allergies,
        vaccines: vaccines,
      );

      if (!context.mounted) return;

      // Mostra preview/print
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ==================== ANÁLISE COM IA ====================

  Future<void> _analyzeProntuario(BuildContext context, String patientId) async {
    await ref.read(prontuarioAnalysisProvider.notifier).analyze(patientId);

    final state = ref.read(prontuarioAnalysisProvider);
    if (!context.mounted) return;

    if (state.status == ProntuarioAnalysisStatus.success && state.result != null) {
      _showAnalysisResult(context, state.result!);
    } else if (state.status == ProntuarioAnalysisStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error ?? 'Erro ao analisar prontuário'),
          behavior: SnackBarBehavior.floating,
        ),
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
              // Handle
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Análise do Prontuário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                        SizedBox(height: 2),
                        Text('Gerado por IA • Claude Sonnet 4', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Disclaimer
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
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta análise é gerada por IA e tem caráter informativo. '
                        'Consulte sempre um médico para decisões sobre sua saúde.',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // RISCO GERAL
              _riskBadge(result.overallRisk),
              const SizedBox(height: 20),

              // SUMMARY
              _sectionLabel('Resumo Geral', Icons.summarize_outlined),
              const SizedBox(height: 8),
              Text(result.summary, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6)),
              const SizedBox(height: 24),

              // PONTOS DE ATENÇÃO
              _sectionLabel('Pontos de Atenção', Icons.report_problem_outlined),
              const SizedBox(height: 8),
              ...result.attentionPoints.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3, right: 8),
                          child: Icon(Icons.circle, size: 8, color: Color(0xFFEF4444)),
                        ),
                        Expanded(child: Text(p, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),

              // SUGESTÕES
              _sectionLabel('Sugestões', Icons.lightbulb_outline),
              const SizedBox(height: 8),
              ...result.suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3, right: 8),
                          child: Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF3B82F6)),
                        ),
                        Expanded(child: Text(s, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),

              // CUIDADOS PREVENTIVOS
              _sectionLabel('Cuidados Preventivos', Icons.shield_outlined),
              const SizedBox(height: 8),
              ...result.preventiveCare.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3, right: 8),
                          child: Icon(Icons.favorite_outline, size: 16, color: Color(0xFF10B981)),
                        ),
                        Expanded(child: Text(c, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),

              // ESTILO DE VIDA
              _sectionLabel('Recomendações de Estilo de Vida', Icons.self_improvement),
              const SizedBox(height: 8),
              ...result.lifestyleRecommendations.map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3, right: 8),
                          child: Icon(Icons.eco_outlined, size: 16, color: Color(0xFF8B5CF6)),
                        ),
                        Expanded(child: Text(l, style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),

              // Botão compartilhar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share, size: 18),
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

// ==================== WIDGETS REUTILIZÁVEIS ====================

class _PerfilSection extends ConsumerWidget {
  final AsyncValue<HealthProfile?> profileAsync;
  final String patientId;

  const _PerfilSection({required this.profileAsync, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return profileAsync.when(
      data: (profile) {
        final p = profile ?? const HealthProfile(id: '', patientId: '');
        final imc = p.imc;
        return _SectionCard(
          icon: Icons.person,
          iconColor: const Color(0xFF1565C0),
          title: 'Perfil de Saúde',
          trailing: OutlinedButton(
            onPressed: () => _showEditProfileDialog(context, ref, patientId, p),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: const Text('Editar'),
          ),
          child: Column(
            children: [
              _infoRow('Peso', p.weight > 0 ? '${p.weight.toStringAsFixed(0)} kg' : 'Não informado'),
              _infoRow('Altura', p.height > 0 ? '${p.height.toStringAsFixed(0)} cm' : 'Não informado'),
              if (imc > 0)
                _infoRow('IMC', '${imc.toStringAsFixed(1)} — ${p.imcCategory}'),
              _infoRow('Tipo Sanguíneo', p.bloodType.isNotEmpty ? p.bloodType : 'Não informado'),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _multiLineInfo('Condições Médicas', p.medicalConditions.isNotEmpty ? p.medicalConditions : 'Nenhuma'),
              const SizedBox(height: 8),
              _multiLineInfo('Condições Crônicas', p.chronicConditions.isNotEmpty ? p.chronicConditions : 'Nenhuma'),
              const SizedBox(height: 8),
              _multiLineInfo('Medicações em Uso', p.medications.isNotEmpty ? p.medications : 'Nenhuma'),
              const SizedBox(height: 8),
              _multiLineInfo('Histórico Familiar', p.familyHistory.isNotEmpty ? p.familyHistory : 'Nenhum'),
            ],
          ),
        );
      },
      loading: () => const _SectionCard(
        icon: Icons.person,
        iconColor: Color(0xFF1565C0),
        title: 'Perfil de Saúde',
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => _SectionCard(
        icon: Icons.person,
        iconColor: Color(0xFF1565C0),
        title: 'Perfil de Saúde',
        child: Text('Erro ao carregar: $e', style: TextStyle(fontSize: 12, color: Colors.red.shade600)),
      ),
    );
  }
}

class _GenericListSection<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final AsyncValue<List<T>> async;
  final String emptyText;
  final Widget Function(T) itemBuilder;
  final bool isUrgent;

  const _GenericListSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.async,
    required this.emptyText,
    required this.itemBuilder,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return async.when(
      data: (items) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _SectionCard(
          icon: icon,
          iconColor: iconColor,
          title: title,
          subtitle: '${items.length} ${items.length == 1 ? 'registro' : 'registros'}',
          isUrgent: isUrgent,
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(emptyText, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                )
              : Column(
                  children: items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        if (idx > 0) const Divider(height: 1),
                        itemBuilder(item),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _SectionCard(
          icon: icon,
          iconColor: iconColor,
          title: title,
          child: const LinearProgressIndicator(),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _SectionCard(
          icon: icon,
          iconColor: iconColor,
          title: title,
          child: Text('Erro: $e', style: TextStyle(fontSize: 12, color: Colors.red.shade600)),
        ),
      ),
    );
  }
}

class _ProntuarioItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final String notes;
  final bool isUrgent;
  final bool isPending;

  const _ProntuarioItem({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.notes = '',
    this.isUrgent = false,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador urgência
          if (isUrgent)
            Container(
              width: 4,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailing != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPending
                              ? const Color(0xFFF59E0B).withAlpha(25)
                              : isUrgent
                                  ? const Color(0xFFEF4444).withAlpha(15)
                                  : Colors.grey.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trailing!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isPending
                                ? const Color(0xFFF59E0B)
                                : isUrgent
                                    ? const Color(0xFFEF4444)
                                    : Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    notes,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CARD BASE ====================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final bool isUrgent;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isUrgent ? const Color(0xFFEF4444).withAlpha(60) : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                      if (subtitle != null)
                        Text(subtitle!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ==================== HELPERS ====================

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
      ],
    ),
  );
}

Widget _multiLineInfo(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
    ],
  );
}

Widget _sectionLabel(String label, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 18, color: const Color(0xFF6B7280)),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
    ],
  );
}

Widget _riskBadge(String risk) {
  Color color;
  IconData icon;
  String label;

  switch (risk) {
    case 'alto':
      color = const Color(0xFFEF4444);
      icon = Icons.warning;
      label = 'Risco Alto';
      break;
    case 'moderado':
      color = const Color(0xFFF59E0B);
      icon = Icons.info_outline;
      label = 'Risco Moderado';
      break;
    default:
      color = const Color(0xFF10B981);
      icon = Icons.check_circle_outline;
      label = 'Risco Baixo';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withAlpha(60)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
      ],
    ),
  );
}

// ==================== DIALOG EDITAR PERFIL ====================

void _showEditProfileDialog(
    BuildContext context, WidgetRef ref, String patientId, HealthProfile current) {
  final weightCtrl = TextEditingController(
    text: current.weight > 0 ? current.weight.toStringAsFixed(0) : '');
  final heightCtrl = TextEditingController(
    text: current.height > 0 ? current.height.toStringAsFixed(0) : '');
  final bloodCtrl = TextEditingController(text: current.bloodType);
  final conditionsCtrl = TextEditingController(text: current.medicalConditions);
  final chronicCtrl = TextEditingController(text: current.chronicConditions);
  final medsCtrl = TextEditingController(text: current.medications);
  final familyCtrl = TextEditingController(text: current.familyHistory);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Editar Perfil de Saúde', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: 'Altura (cm)'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 12),
            TextField(controller: bloodCtrl, decoration: const InputDecoration(labelText: 'Tipo Sanguíneo', hintText: 'Ex: A+, O-')),
            const SizedBox(height: 12),
            TextField(controller: conditionsCtrl, decoration: const InputDecoration(labelText: 'Condições Médicas'), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: chronicCtrl, decoration: const InputDecoration(labelText: 'Condições Crônicas'), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: medsCtrl, decoration: const InputDecoration(labelText: 'Medicações em Uso'), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: familyCtrl, decoration: const InputDecoration(labelText: 'Histórico Familiar'), maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final profile = HealthProfile(
                    id: current.id,
                    patientId: patientId,
                    weight: double.tryParse(weightCtrl.text) ?? 0,
                    height: double.tryParse(heightCtrl.text) ?? 0,
                    bloodType: bloodCtrl.text.trim(),
                    medicalConditions: conditionsCtrl.text.trim(),
                    chronicConditions: chronicCtrl.text.trim(),
                    medications: medsCtrl.text.trim(),
                    familyHistory: familyCtrl.text.trim(),
                  );
                  await ref.read(patientHealthProvider).saveHealthProfile(profile);
                  ref.invalidate(patientHealthProfileProvider(patientId));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
