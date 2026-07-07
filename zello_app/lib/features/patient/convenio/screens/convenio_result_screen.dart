import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class ConvenioResultScreen extends ConsumerWidget {
  const ConvenioResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analysisState = ref.watch(aiAnalysisProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado da Análise')),
      body: _buildBody(context, theme, analysisState),
    );
  }

  Widget _buildBody(
      BuildContext context, ThemeData theme, AiAnalysisState state) {
    final colorScheme = theme.colorScheme;

    // Loading
    if (state.status == AiAnalysisStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (state.status == AiAnalysisStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Erro na análise',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: colorScheme.error)),
              const SizedBox(height: 8),
              Text(
                state.error ?? 'Tente novamente mais tarde.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    // Idle (nada foi analisado ainda)
    if (state.status == AiAnalysisStatus.idle || state.result == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Nenhuma análise realizada',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Volte e preencha os dados do convênio.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    // Success: exibe o resultado real da IA
    final result = state.result!;
    final plan = result.planAnalysis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Disclaimer LGPD ---
          _DisclaimerCard(colorScheme: colorScheme),
          const SizedBox(height: 16),

          // --- Análise do Plano ---
          _PlanAnalysisCard(plan: plan, colorScheme: colorScheme),
          const SizedBox(height: 16),

          // --- Recomendação ---
          _RecommendationCard(plan: plan, colorScheme: colorScheme),
          const SizedBox(height: 16),

          // --- Hospitais Recomendados ---
          _HospitalListSection(
            hospitals: result.hospitals,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------- Widgets ----------

class _DisclaimerCard extends StatelessWidget {
  final ColorScheme colorScheme;

  const _DisclaimerCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta análise é gerada por IA e tem caráter informativo. '
              'Consulte sempre a operadora do plano para informações oficiais '
              'sobre cobertura e rede credenciada.',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanAnalysisCard extends StatelessWidget {
  final AiPlanAnalysis plan;
  final ColorScheme colorScheme;

  const _PlanAnalysisCard({required this.plan, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.analytics, color: Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 12),
                Text('Análise do Plano',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan.currentPlan.isNotEmpty
                  ? plan.currentPlan
                  : 'Análise não disponível.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final AiPlanAnalysis plan;
  final ColorScheme colorScheme;

  const _RecommendationCard({required this.plan, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // Escolhe cor baseada na recomendação
    Color recommendationColor;
    IconData icon;
    String label;

    switch (plan.recommendation) {
      case 'upgrade':
        recommendationColor = Colors.orange;
        icon = Icons.arrow_upward;
        label = 'Considere fazer upgrade';
        break;
      case 'downgrade':
        recommendationColor = Colors.green;
        icon = Icons.arrow_downward;
        label = 'Plano atual atende bem';
        break;
      default:
        recommendationColor = const Color(0xFF3B82F6);
        icon = Icons.check_circle;
        label = 'Plano adequado';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: recommendationColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: recommendationColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: recommendationColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: recommendationColor.withAlpha(60)),
                  ),
                  child: Text(
                    plan.recommendation.toUpperCase(),
                    style: TextStyle(
                      color: recommendationColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan.justification.isNotEmpty
                  ? plan.justification
                  : 'Justificativa não disponível.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            if (plan.suggestedPlanType.isNotEmpty ||
                plan.estimatedCostImpact.isNotEmpty) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.card_membership,
                      label: plan.suggestedPlanType.isNotEmpty
                          ? plan.suggestedPlanType
                          : 'Mesmo tipo',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.attach_money,
                      label: plan.estimatedCostImpact.isNotEmpty
                          ? plan.estimatedCostImpact
                          : 'Sem estimativa',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}

class _HospitalListSection extends StatelessWidget {
  final List<AiHospital> hospitals;
  final ColorScheme colorScheme;

  const _HospitalListSection({
    required this.hospitals,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_hospital, color: Color(0xFF10B981)),
            ),
            const SizedBox(width: 12),
            Text(
              'Hospitais Recomendados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hospitals.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Nenhum hospital encontrado para sua região/plano.'),
              ),
            ),
          )
        else
          ...hospitals.map((h) => _HospitalCard(hospital: h)),
      ],
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final AiHospital hospital;

  const _HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.local_hospital,
                        color: Color(0xFF10B981), size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < hospital.rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 14,
                              color: Colors.amber.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hospital.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hospital.acceptsPlan
                        ? const Color(0xFF10B981).withAlpha(20)
                        : Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hospital.acceptsPlan ? 'Aceita' : 'Verificar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hospital.acceptsPlan
                          ? const Color(0xFF10B981)
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Endereço
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hospital.address.isNotEmpty
                        ? hospital.address
                        : 'Endereço não informado',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),

            // Telefone
            if (hospital.phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(hospital.phone,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ],

            // Especialidades
            if (hospital.specialties.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: hospital.specialties.map((s) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
