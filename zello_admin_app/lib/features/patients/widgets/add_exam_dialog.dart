import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class AddExamDialog extends ConsumerStatefulWidget {
  final String patientId;
  const AddExamDialog({super.key, required this.patientId});

  @override
  ConsumerState<AddExamDialog> createState() => _AddExamDialogState();
}

class _AddExamDialogState extends ConsumerState<AddExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _physicianCtrl = TextEditingController();
  final _labCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _date;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _physicianCtrl.dispose();
    _labCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Exame'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome do Exame', hintText: 'Ex: Hemograma'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_date != null
                    ? Formatters.formatDate(_date!)
                    : 'Selecionar data'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _physicianCtrl,
                decoration: const InputDecoration(
                    labelText: 'Médico Solicitante',
                    hintText: 'Dr(a). ...'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labCtrl,
                decoration: const InputDecoration(
                    labelText: 'Laboratório',
                    hintText: 'Ex: Lab São Paulo'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                    labelText: 'Observações', hintText: 'Opcional'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(apiClientProvider).createExam({
        'patient_id': widget.patientId,
        'name': _nameCtrl.text.trim(),
        'date': _date?.toIso8601String(),
        'requesting_physician': _physicianCtrl.text.trim(),
        'lab_facility': _labCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      });
      ref.invalidate(patientExamsProvider(widget.patientId)); // Invalidate to refetch
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exame adicionado com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
