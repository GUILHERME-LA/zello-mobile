import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zello_shared/zello_shared.dart';

/// Dialog de importação de arquivo — o usuário escolhe um arquivo,
/// extraímos o texto, enviamos para IA e mostramos o resultado.
Future<void> showImportProntuarioDialog(
    BuildContext context, WidgetRef ref, String patientId) async {
  // --- 1. Escolher o arquivo ---
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['txt', 'pdf', 'csv', 'json', 'md'],
    withData: true,
  );

  if (result == null || result.files.isEmpty) return;
  final file = result.files.first;

  // --- 2. Ler o conteúdo ---
  String text;
  try {
    if (file.bytes != null) {
      text = String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      text = await File(file.path!).readAsString();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível ler o arquivo.'), behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao ler arquivo: $e'), behavior: SnackBarBehavior.floating),
      );
    }
    return;
  }

  if (text.trim().length < 10) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo muito pequeno ou vazio.'), behavior: SnackBarBehavior.floating),
      );
    }
    return;
  }

  // --- 3. Mostrar loading e chamar a IA ---
  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(
        child: Card(
          margin: EdgeInsets.all(40),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Analisando documento com IA...',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('Aguarde enquanto extraímos os dados.',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  await ref.read(prontuarioImportProvider.notifier).import(text, file.name);
  final state = ref.read(prontuarioImportProvider);

  if (!context.mounted) return;
  Navigator.of(context).pop(); // fecha loading

  if (state.status == ProntuarioImportStatus.error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.error ?? 'Erro na importação'), behavior: SnackBarBehavior.floating),
    );
    return;
  }

  if (state.result == null) return;

  // --- 4. Mostrar resultado e permitir salvar ---
  _showImportResult(context, ref, patientId, state.result!);
}

void _showImportResult(BuildContext context, WidgetRef ref, String patientId, ProntuarioImportResult result) {
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
                    color: const Color(0xFF8B5CF6).withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.file_upload_outlined, color: Color(0xFF8B5CF6), size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dados Extraídos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Revise os dados encontrados no documento', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary
            if (result.summary.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.summarize_outlined, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(child: Text(result.summary, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Condições
            if (result.conditions.isNotEmpty) ...[
              _importSection('Condições/Diagnósticos', Icons.health_and_safety, result.conditions, const Color(0xFF1565C0)),
              const SizedBox(height: 12),
            ],

            // Medicações
            if (result.medications.isNotEmpty) ...[
              _importSection('Medicações', Icons.medication, result.medications, const Color(0xFF10B981)),
              const SizedBox(height: 12),
            ],

            // Cirurgias
            if (result.surgeries.isNotEmpty) ...[
              _importListSection('Cirurgias', Icons.content_cut, result.surgeries, const Color(0xFF1565C0)),
              const SizedBox(height: 12),
            ],

            // Internações
            if (result.hospitalizations.isNotEmpty) ...[
              _importListSection('Internações', Icons.local_hospital, result.hospitalizations, const Color(0xFFEF4444)),
              const SizedBox(height: 12),
            ],

            // Sintomas
            if (result.symptoms.isNotEmpty) ...[
              _importListSection('Sintomas', Icons.monitor_heart_outlined, result.symptoms, const Color(0xFFF59E0B)),
              const SizedBox(height: 12),
            ],

            // Alergias
            if (result.allergies.isNotEmpty) ...[
              _importListSection('Alergias', Icons.warning_amber, result.allergies, const Color(0xFFEF4444)),
              const SizedBox(height: 12),
            ],

            // Vacinas
            if (result.vaccines.isNotEmpty) ...[
              _importListSection('Vacinas', Icons.vaccines_outlined, result.vaccines, const Color(0xFF10B981)),
              const SizedBox(height: 12),
            ],

            if (result.surgeries.isEmpty && result.hospitalizations.isEmpty &&
                result.symptoms.isEmpty && result.allergies.isEmpty &&
                result.vaccines.isEmpty && result.conditions.isEmpty &&
                result.medications.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
                child: const Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.orange),
                    SizedBox(height: 12),
                    Text('Nenhum dado de saúde identificado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange)),
                    SizedBox(height: 4),
                    Text('O documento pode estar em um formato que não conseguimos processar. Tente um arquivo de texto simples.', style: TextStyle(fontSize: 13, color: Colors.orange), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Descartar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Salvar dados extraídos
                      await _saveImportResult(context, ref, patientId, result);
                      ref.invalidate(patientHealthProfileProvider(patientId));
                      ref.invalidate(patientSurgeriesProvider(patientId));
                      ref.invalidate(patientHospitalizationsProvider(patientId));
                      ref.invalidate(patientSymptomsProvider(patientId));
                      ref.invalidate(patientAllergiesProvider(patientId));
                      ref.invalidate(patientVaccinesProvider(patientId));
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Salvar Dados'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

Future<void> _saveImportResult(BuildContext context, WidgetRef ref, String patientId, ProntuarioImportResult result) async {
  final health = ref.read(patientHealthProvider);

  // Salva condições e medicações no perfil
  if (result.conditions.isNotEmpty || result.medications.isNotEmpty) {
    try {
      final supabase = Supabase.instance.client;
      final existing = await supabase
          .from('health_profiles')
          .select()
          .eq('patient_id', patientId)
          .maybeSingle();

      if (existing != null) {
        final currentConditions = (existing['medical_conditions'] as String? ?? '');
        final merged = currentConditions.isNotEmpty
            ? '$currentConditions\n\n--- Dados importados ---\n${result.conditions}'
            : result.conditions;
        await supabase.from('health_profiles').update({
          if (result.conditions.isNotEmpty) 'medical_conditions': merged,
          if (result.medications.isNotEmpty) 'medications': result.medications,
        }).eq('patient_id', patientId);
      } else {
        await supabase.from('health_profiles').insert({
          'patient_id': patientId,
          if (result.conditions.isNotEmpty) 'medical_conditions': result.conditions,
          if (result.medications.isNotEmpty) 'medications': result.medications,
        });
      }
    } catch (_) {
      // fallback: salva só medicações
    }
  }

  // Cirurgias
  for (final s in result.surgeries) {
    try {
      final date = DateTime.tryParse(s['date'] ?? '');
      if (s['name']!.isNotEmpty && date != null) {
        await health.addSurgery(Surgery(
          id: '',
          patientId: patientId,
          name: s['name']!,
          date: date,
          hospital: s['hospital'] ?? '',
          notes: s['notes'] ?? '',
        ));
      }
    } catch (_) {}
  }

  // Internações
  for (final h in result.hospitalizations) {
    try {
      final startDate = DateTime.tryParse(h['startDate'] ?? '');
      if (h['reason']!.isNotEmpty && startDate != null) {
        await health.addHospitalization(Hospitalization(
          id: '',
          patientId: patientId,
          reason: h['reason']!,
          hospital: h['hospital'] ?? '',
          startDate: startDate,
          endDate: h['endDate'] != null ? DateTime.tryParse(h['endDate']!) : null,
          notes: h['notes'] ?? '',
        ));
      }
    } catch (_) {}
  }

  // Sintomas
  for (final s in result.symptoms) {
    try {
      if (s['name']!.isNotEmpty) {
        await health.addSymptom(Symptom(
          id: '',
          patientId: patientId,
          name: s['name']!,
          frequency: s['frequency'] ?? '',
          intensity: s['intensity'] ?? '',
          notes: s['notes'] ?? '',
        ));
      }
    } catch (_) {}
  }

  // Alergias
  for (final a in result.allergies) {
    try {
      if (a['name']!.isNotEmpty) {
        final type = ['medicamento', 'alimento', 'substancia'].contains(a['type']) ? a['type']! : 'outro';
        await health.addAllergy(Allergy(
          id: '',
          patientId: patientId,
          name: a['name']!,
          type: type,
          reaction: a['reaction'] ?? '',
          notes: a['notes'] ?? '',
        ));
      }
    } catch (_) {}
  }

  // Vacinas
  for (final v in result.vaccines) {
    try {
      final date = DateTime.tryParse(v['date'] ?? '');
      if (v['name']!.isNotEmpty && date != null) {
        await health.addVaccine(Vaccine(
          id: '',
          patientId: patientId,
          name: v['name']!,
          date: date,
          dose: v['dose'] ?? '',
          notes: v['notes'] ?? '',
          isPending: false,
        ));
      }
    } catch (_) {}
  }
}

// ==================== WIDGETS ====================

Widget _importSection(String label, IconData icon, String content, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        ],
      ),
      const SizedBox(height: 4),
      Text(content, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
    ],
  );
}

Widget _importListSection(String label, IconData icon, List<Map<String, String>> items, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        ],
      ),
      const SizedBox(height: 6),
      ...items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.entries
                  .where((e) => e.value.isNotEmpty && e.key != 'type')
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key}: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                            Expanded(child: Text(e.value, style: TextStyle(fontSize: 11, color: Colors.grey.shade800))),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          )),
    ],
  );
}
