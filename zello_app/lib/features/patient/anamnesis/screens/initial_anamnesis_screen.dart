import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class InitialAnamnesisScreen extends ConsumerStatefulWidget {
  const InitialAnamnesisScreen({super.key});

  @override
  ConsumerState<InitialAnamnesisScreen> createState() =>
      _InitialAnamnesisScreenState();
}

class _InitialAnamnesisScreenState
    extends ConsumerState<InitialAnamnesisScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _rgController = TextEditingController();
  final _cpfController = TextEditingController();
  final _alturaController = TextEditingController();
  final _surgeriesController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _mentalNotesController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insurancePlanController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  bool _hasAllergies = false;
  bool _hasSurgeries = false;
  bool _hasDepression = false;
  bool _hasSuicideAttempts = false;
  bool _hasSelfHarm = false;
  bool _hasInsurance = false;
  bool _isSaving = false;
  bool _isEditing = false;

  Anamnesis? _existingAnamnesis;

  final _steps = [
    'Dados Pessoais',
    'Cirurgias',
    'Alergias',
    'Saúde Mental',
    'Plano de Saúde',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final anamneses = await ref.read(anamnesesProvider.future);
    if (anamneses.isNotEmpty) {
      final anamnesis = anamneses.first;
      if (anamnesis.completed) {
        setState(() {
          _existingAnamnesis = anamnesis;
          _isEditing = false;
        });
        _prefillFromAnamnesis(anamnesis);
      }
    }
  }

  void _prefillFromAnamnesis(Anamnesis a) {
    _nameController.text = a.professional.isNotEmpty ? a.professional : (ref.read(authProvider).user?.name ?? '');
    _rgController.text = a.rg;
    _cpfController.text = a.cpf;
    _alturaController.text = a.altura != null ? a.altura!.toStringAsFixed(2).replaceAll('.', ',') : '';
    _hasSurgeries = a.surgeriesDescription.isNotEmpty;
    _surgeriesController.text = a.surgeriesDescription;
    _hasAllergies = a.allergiesDetails.isNotEmpty;
    _allergiesController.text = a.allergiesDetails;
    _hasDepression = a.hasDepression;
    _hasSuicideAttempts = a.hasSuicideAttempts;
    _hasSelfHarm = a.hasSelfHarm;
    _mentalNotesController.text = a.mentalHealthNotes;
    _hasInsurance = a.hasInsurance;
    _insuranceProviderController.text = a.insuranceProvider;
    _insurancePlanController.text = a.insurancePlan;
    _streetController.text = a.addressStreet;
    _numberController.text = a.addressNumber;
    _neighborhoodController.text = a.addressNeighborhood;
    _cityController.text = a.addressCity;
    _stateController.text = a.addressState;
    _zipController.text = a.addressZip;
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in [
      _nameController,
      _rgController,
      _cpfController,
      _alturaController,
      _surgeriesController,
      _allergiesController,
      _mentalNotesController,
      _insuranceProviderController,
      _insurancePlanController,
      _streetController,
      _numberController,
      _neighborhoodController,
      _cityController,
      _stateController,
      _zipController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) return false;
        if (_cpfController.text.trim().isEmpty) return false;
        if (_rgController.text.trim().isEmpty) return false;
        return true;
      case 4:
        if (_hasInsurance) {
          if (_insuranceProviderController.text.trim().isEmpty) return false;
          if (_insurancePlanController.text.trim().isEmpty) return false;
        } else {
          if (_streetController.text.trim().isEmpty) return false;
          if (_cityController.text.trim().isEmpty) return false;
          if (_zipController.text.trim().isEmpty) return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _next() async {
    if (!_validateStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_currentStep == _steps.length - 1) {
      await _save();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final altura = double.tryParse(
          _alturaController.text.trim().replaceAll(',', '.'));
      await ref.read(anamnesisSaveProvider(
        {
          'rg': _rgController.text.trim(),
          'cpf': _cpfController.text.trim(),
          'altura': altura,
          'surgeries_description':
              _hasSurgeries ? _surgeriesController.text.trim() : '',
          'allergies_details':
              _hasAllergies ? _allergiesController.text.trim() : '',
          'has_depression': _hasDepression,
          'has_suicide_attempts': _hasSuicideAttempts,
          'has_self_harm': _hasSelfHarm,
          'mental_health_notes': _mentalNotesController.text.trim(),
          'has_insurance': _hasInsurance,
          'insurance_provider':
              _hasInsurance ? _insuranceProviderController.text.trim() : '',
          'insurance_plan':
              _hasInsurance ? _insurancePlanController.text.trim() : '',
          'address_street':
              !_hasInsurance ? _streetController.text.trim() : '',
          'address_number':
              !_hasInsurance ? _numberController.text.trim() : '',
          'address_neighborhood':
              !_hasInsurance ? _neighborhoodController.text.trim() : '',
          'address_city': !_hasInsurance ? _cityController.text.trim() : '',
          'address_state': !_hasInsurance ? _stateController.text.trim() : '',
          'address_zip': !_hasInsurance ? _zipController.text.trim() : '',
          'completed': true,
        },
      ).future);
      if (mounted) context.go('/home');
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
    if (_existingAnamnesis != null && !_isEditing) {
      return _buildSummaryView();
    }
    return _buildFormView();
  }

  Widget _buildSummaryView() {
    final a = _existingAnamnesis!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _SummarySection(
                      icon: LucideIcons.user,
                      title: 'Dados Pessoais',
                      children: [
                        _SummaryRow(label: 'Nome', value: _nameController.text.isNotEmpty ? _nameController.text : a.professional),
                        _SummaryRow(label: 'RG', value: a.rg.isNotEmpty ? a.rg : '—'),
                        _SummaryRow(label: 'CPF', value: a.cpf.isNotEmpty ? a.cpf : '—'),
                        _SummaryRow(label: 'Altura', value: a.altura != null ? '${a.altura!.toStringAsFixed(2)} m' : '—'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SummarySection(
                      icon: LucideIcons.scissors,
                      title: 'Cirurgias',
                      children: [
                        _SummaryRow(
                          label: 'Já realizou cirurgias?',
                          value: a.surgeriesDescription.isNotEmpty ? 'Sim' : 'Não',
                        ),
                        if (a.surgeriesDescription.isNotEmpty)
                          _SummaryRow(label: 'Detalhes', value: a.surgeriesDescription),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SummarySection(
                      icon: LucideIcons.shieldAlert,
                      title: 'Alergias',
                      children: [
                        _SummaryRow(
                          label: 'Possui alergias?',
                          value: a.allergiesDetails.isNotEmpty ? 'Sim' : 'Não',
                        ),
                        if (a.allergiesDetails.isNotEmpty)
                          _SummaryRow(label: 'Detalhes', value: a.allergiesDetails),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SummarySection(
                      icon: LucideIcons.brain,
                      title: 'Saúde Mental',
                      children: [
                        _SummaryRow(label: 'Depressão', value: a.hasDepression ? 'Sim' : 'Não'),
                        _SummaryRow(label: 'Tentativa de suicídio', value: a.hasSuicideAttempts ? 'Sim' : 'Não'),
                        _SummaryRow(label: 'Automutilação', value: a.hasSelfHarm ? 'Sim' : 'Não'),
                        if (a.mentalHealthNotes.isNotEmpty)
                          _SummaryRow(label: 'Observações', value: a.mentalHealthNotes),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SummarySection(
                      icon: LucideIcons.heart,
                      title: 'Plano de Saúde',
                      children: [
                        _SummaryRow(
                          label: 'Tipo',
                          value: a.hasInsurance ? 'Plano de saúde' : 'Sem plano',
                        ),
                        if (a.hasInsurance) ...[
                          _SummaryRow(label: 'Operadora', value: a.insuranceProvider.isNotEmpty ? a.insuranceProvider : '—'),
                          _SummaryRow(label: 'Plano', value: a.insurancePlan.isNotEmpty ? a.insurancePlan : '—'),
                        ] else ...[
                          if (a.addressStreet.isNotEmpty)
                            _SummaryRow(label: 'Endereço', value: '${a.addressStreet}${a.addressNumber.isNotEmpty ? ', ${a.addressNumber}' : ''}'),
                          if (a.addressNeighborhood.isNotEmpty)
                            _SummaryRow(label: 'Bairro', value: a.addressNeighborhood),
                          if (a.addressCity.isNotEmpty)
                            _SummaryRow(label: 'Cidade', value: '${a.addressCity}${a.addressState.isNotEmpty ? ' - ${a.addressState}' : ''}'),
                          if (a.addressZip.isNotEmpty)
                            _SummaryRow(label: 'CEP', value: a.addressZip),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
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
                child: const Icon(LucideIcons.clipboardList,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Minha Anamnese',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20)),
                    Text('Dados preenchidos com sucesso',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.checkCircle,
                    color: Colors.greenAccent, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(LucideIcons.arrowLeft, size: 18),
                  label: const Text('Voltar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _isEditing = true);
                    _pageController.jumpToPage(0);
                  },
                  icon: const Icon(LucideIcons.pencil, size: 18),
                  label: const Text('Editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1565C0),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildPersonalData(),
                  _buildSurgeries(),
                  _buildAllergies(),
                  _buildMentalHealth(),
                  _buildInsurance(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              IconButton(
                onPressed: () {
                  if (_existingAnamnesis != null) {
                    setState(() => _isEditing = false);
                  } else {
                    context.pop();
                  }
                },
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.clipboardList,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _existingAnamnesis != null ? 'Editar Anamnese' : 'Bem-vindo ao Zello',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                    const Text('Preencha seus dados para começar',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              _steps.length,
              (i) => Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= _currentStep
                        ? Colors.white
                        : Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentStep + 1} de ${_steps.length} — ${_steps[_currentStep]}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Voltar'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: ZelloColors.primary,
                foregroundColor: ZelloColors.textOnPrimary,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_currentStep == _steps.length - 1
                      ? 'Finalizar'
                      : 'Continuar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalData() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nome completo *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Seu nome'),
          ),
          const SizedBox(height: 20),
          const Text('RG *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _rgController,
            decoration: const InputDecoration(hintText: 'Ex: 12.345.678-9'),
          ),
          const SizedBox(height: 20),
          const Text('CPF *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _cpfController,
            decoration: const InputDecoration(hintText: 'Ex: 123.456.789-00'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          const Text('Altura (metros)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _alturaController,
            decoration: const InputDecoration(hintText: 'Ex: 1.75'),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSurgeries() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Já passou por alguma cirurgia?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Sim'),
                selected: _hasSurgeries,
                onSelected: (v) => setState(() => _hasSurgeries = v),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Não'),
                selected: !_hasSurgeries,
                onSelected: (v) => setState(() => _hasSurgeries = !v),
              ),
            ],
          ),
          if (_hasSurgeries) ...[
            const SizedBox(height: 20),
            const Text('Quais cirurgias?',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _surgeriesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Descreva as cirurgias que realizou e quando...',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllergies() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tem alguma alergia?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Sim'),
                selected: _hasAllergies,
                onSelected: (v) => setState(() => _hasAllergies = v),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Não'),
                selected: !_hasAllergies,
                onSelected: (v) => setState(() => _hasAllergies = !v),
              ),
            ],
          ),
          if (_hasAllergies) ...[
            const SizedBox(height: 20),
            const Text('A quê?',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _allergiesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ex: penicilina, dipirona, camarão, pólen...',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMentalHealth() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saúde Mental',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Suas respostas são confidenciais e ajudam a Olga a '
              'oferecer o melhor cuidado para você.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          const SizedBox(height: 20),
          _buildYesNo('Tem diagnóstico de depressão?', _hasDepression,
              (v) => setState(() => _hasDepression = v)),
          const SizedBox(height: 16),
          _buildYesNo('Já tentou suicídio?', _hasSuicideAttempts,
              (v) => setState(() => _hasSuicideAttempts = v)),
          const SizedBox(height: 16),
          _buildYesNo('Já se automutilou (se cortou)?', _hasSelfHarm,
              (v) => setState(() => _hasSelfHarm = v)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _mentalNotesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'Quer compartilhar mais algo sobre sua saúde mental? (opcional)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNo(String label, bool value, ValueChanged<bool> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Sim'),
              selected: value,
              onSelected: (v) => onChanged(v),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('Não'),
              selected: !value,
              onSelected: (v) => onChanged(!v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsurance() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plano de Saúde',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Tenho plano'),
                selected: _hasInsurance,
                onSelected: (v) => setState(() => _hasInsurance = v),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Não tenho'),
                selected: !_hasInsurance,
                onSelected: (v) => setState(() => _hasInsurance = !v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_hasInsurance) ...[
            const Text('Operadora *',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _insuranceProviderController,
              decoration:
                  const InputDecoration(hintText: 'Ex: Unimed, Bradesco, Amil'),
            ),
            const SizedBox(height: 20),
            const Text('Plano *',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _insurancePlanController,
              decoration: const InputDecoration(hintText: 'Nome do seu plano'),
            ),
          ] else ...[
            const Text('Endereço para encontrar hospitais próximos *',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _zipController,
              decoration:
                  const InputDecoration(hintText: 'CEP', prefixText: ''),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _streetController,
                    decoration:
                        const InputDecoration(hintText: 'Rua / Avenida'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(hintText: 'Nº'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _neighborhoodController,
              decoration: const InputDecoration(hintText: 'Bairro'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(hintText: 'Cidade'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(hintText: 'UF'),
                    maxLength: 2,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SummarySection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Icon(icon, color: const Color(0xFF1565C0), size: 18),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
