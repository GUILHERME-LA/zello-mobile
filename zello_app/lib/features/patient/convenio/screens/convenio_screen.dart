import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

// Lista de estados brasileiros
const List<String> _estados = [
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
  'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
  'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
];

class ConvenioScreen extends ConsumerStatefulWidget {
  const ConvenioScreen({super.key});

  @override
  ConsumerState<ConvenioScreen> createState() => _ConvenioScreenState();
}

class _ConvenioScreenState extends ConsumerState<ConvenioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _providerCtrl = TextEditingController();
  final _planNameCtrl = TextEditingController();
  final _planTypeCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  String? _selectedEstado;

  @override
  void dispose() {
    _providerCtrl.dispose();
    _planNameCtrl.dispose();
    _planTypeCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(aiAnalysisProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Análise de Convênio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFF3B82F6), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Informe os dados do seu convênio para análise de cobertura com IA.',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _providerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Operadora (ex: Unimed, Bradesco Saúde)',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _planNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome do plano',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _planTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tipo (enfermaria, apartamento, premium)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedEstado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                ),
                items: _estados
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedEstado = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _symptomsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Condição de saúde atual (opcional)',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: analysisState.status == AiAnalysisStatus.loading
                      ? null
                      : _analyze,
                  icon: analysisState.status == AiAnalysisStatus.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    analysisState.status == AiAnalysisStatus.loading
                        ? 'Analisando...'
                        : 'Analisar Convênio',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;

    // Chama a Edge Function via provider
    await ref.read(aiAnalysisProvider.notifier).analyze(
          provider: _providerCtrl.text.trim(),
          planName: _planNameCtrl.text.trim(),
          planType: _planTypeCtrl.text.trim(),
          symptoms: _symptomsCtrl.text.trim(),
          uf: _selectedEstado ?? '',
        );

    // Navega para a tela de resultado (seja sucesso ou erro)
    if (mounted) {
      context.push('/convenio/resultado');
    }
  }
}
