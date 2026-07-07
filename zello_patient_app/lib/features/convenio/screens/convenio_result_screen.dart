import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class ConvenioResultScreen extends ConsumerWidget {
  const ConvenioResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = GoRouterState.of(context).extra as Map<String, String>? ?? {};
    final symptoms = extra['symptoms'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado da Análise')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisclaimer(),
            const SizedBox(height: 20),
            const Text('Hospitais Recomendados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _buildHospitalCard(
              'Hospital São Lucas',
              'Rua Augusta, 1500 - Consolação, SP',
              '(11) 3333-1000',
              'Cardiologia, Pediatria, Ortopedia',
            ),
            const SizedBox(height: 8),
            _buildHospitalCard(
              'Hospital Albert Einstein',
              'Av. Albert Einstein, 627 - Morumbi, SP',
              '(11) 2151-1233',
              'Oncologia, Cardiologia, Neurologia',
            ),
            if (symptoms.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Sugestão de Plano',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildPlanSuggestion(symptoms),
            ],
            const SizedBox(height: 24),
            _buildLegalDisclaimer(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withAlpha(76)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              LgpdConstants.aiDisclaimer,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(
      String name, String address, String phone, String specialties) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(address,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(phone,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: specialties
                .split(', ')
                .map((s) => ZelloBadge(label: s, variant: ZelloBadgeVariant.default$))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSuggestion(String symptoms) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Com base na condição relatada, recomendamos verificar planos com cobertura hospitalar ampliada.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          _buildSuggestionRow('Plano recomendado', 'Premium ou Apartamento'),
          _buildSuggestionRow('Upgrade disponível', 'Sim'),
          _buildSuggestionRow('Mudança principal', 'Cobertura cirúrgica e UTI ampliada'),
        ],
      ),
    );
  }

  Widget _buildSuggestionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withAlpha(51)),
      ),
      child: Text(
        'ATENÇÃO: Esta análise é apenas orientativa e NÃO substitui '
        'consulta médica ou contato direto com a operadora. '
        'Confirme sempre a cobertura com a ${LgpdConstants.aiDisclaimer.split('operadora')[0]}operadora/hospital.',
        style: const TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF6B7280)),
      ),
    );
  }
}
