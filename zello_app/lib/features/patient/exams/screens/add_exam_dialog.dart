import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class AddExamDialog extends ConsumerStatefulWidget {
  const AddExamDialog({super.key});

  @override
  ConsumerState<AddExamDialog> createState() => _AddExamDialogState();
}

class _AddExamDialogState extends ConsumerState<AddExamDialog> {
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'solicitado';
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do exame.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      final patientId = api.currentPatientId ??
          (await _resolvePatientId(api));
      if (patientId == null || patientId.isEmpty) {
        throw Exception('Paciente nao identificado. Faca login novamente.');
      }
      await api.createExam({
        'patient_id': patientId,
        'title': title,
        'exam_type': _typeController.text.trim(),
        'status': _status,
        'notes': _notesController.text.trim(),
      });
      if (mounted) {
        ref.invalidate(examsProvider);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<String?> _resolvePatientId(dynamic api) async {
    try {
      final user = ref.read(authProvider).user;
      if (user?.id != null) {
        await api.loadCurrentPatient(user!.id);
        return api.currentPatientId;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Novo exame',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nome do exame',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Tipo (ex.: Sangue, Imagem)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: Exam.statuses
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(Exam.statusLabels[s] ?? s),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? 'solicitado'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observacoes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
