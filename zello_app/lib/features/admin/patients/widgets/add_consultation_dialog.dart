import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class AddConsultationDialog extends ConsumerStatefulWidget {
  final String patientId;
  const AddConsultationDialog({super.key, required this.patientId});

  @override
  ConsumerState<AddConsultationDialog> createState() =>
      _AddConsultationDialogState();
}

class _AddConsultationDialogState extends ConsumerState<AddConsultationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _doctorCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _prescriptionsCtrl = TextEditingController();
  DateTime? _date;
  String _type = 'in_person';
  bool _saving = false;

  @override
  void dispose() {
    _doctorCtrl.dispose();
    _specialtyCtrl.dispose();
    _notesCtrl.dispose();
    _prescriptionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Consulta'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _doctorCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome do Médico', hintText: 'Dr(a). ...'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specialtyCtrl,
                decoration: const InputDecoration(
                    labelText: 'Especialidade',
                    hintText: 'Ex: Cardiologia'),
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
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'in_person', child: Text('Presencial')),
                  DropdownMenuItem(value: 'tele', child: Text('Teleconsulta')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'in_person'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                    labelText: 'Observações', hintText: 'Opcional'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prescriptionsCtrl,
                decoration: const InputDecoration(
                    labelText: 'Prescrições',
                    hintText: 'Separadas por vírgula'),
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
      final prescriptions = _prescriptionsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      await ref.read(apiClientProvider).createConsultation({
        'patient_id': widget.patientId,
        'doctor_name': _doctorCtrl.text.trim(),
        'specialty': _specialtyCtrl.text.trim(),
        'date': _date?.toIso8601String(),
        'type': _type,
        'notes': _notesCtrl.text.trim(),
        'prescriptions': prescriptions,
      });
      ref.invalidate(patientConsultationsProvider(widget.patientId));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
