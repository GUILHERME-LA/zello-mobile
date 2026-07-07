import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class AddMedicationDialog extends ConsumerStatefulWidget {
  final String patientId;
  final String? prescribedBy;
  const AddMedicationDialog({super.key, required this.patientId, this.prescribedBy});

  @override
  ConsumerState<AddMedicationDialog> createState() =>
      _AddMedicationDialogState();
}

class _AddMedicationDialogState extends ConsumerState<AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _frequencyCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _observationsCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _frequencyCtrl.dispose();
    _doctorCtrl.dispose();
    _observationsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Medicação'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome do Medicamento',
                    hintText: 'Ex: Amoxicilina'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(
                    labelText: 'Dosagem', hintText: 'Ex: 500mg'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _frequencyCtrl,
                decoration: const InputDecoration(
                    labelText: 'Frequência', hintText: 'Ex: 8/8h'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doctorCtrl,
                decoration: const InputDecoration(
                    labelText: 'Médico Prescritor',
                    hintText: 'Dr(a). ...'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observationsCtrl,
                decoration: const InputDecoration(
                    labelText: 'Observações',
                    hintText: 'Ex: Tomar com comida'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_startDate != null
                    ? 'Início: ${Formatters.formatDate(_startDate!)}'
                    : 'Data de início'),
                trailing: const Icon(LucideIcons.calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_endDate != null
                    ? 'Fim: ${Formatters.formatDate(_endDate!)}'
                    : 'Data de fim (opcional)'),
                trailing: const Icon(LucideIcons.calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ativo'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
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
      await ref.read(apiClientProvider).createMedication({
        'patient_id': widget.patientId,
        'name': _nameCtrl.text.trim(),
        'dosage': _dosageCtrl.text.trim(),
        'frequency': _frequencyCtrl.text.trim(),
        'prescribing_doctor': _doctorCtrl.text.trim(),
        'prescribed_by': widget.prescribedBy,
        'start_date': _startDate?.toIso8601String(),
        'end_date': _endDate?.toIso8601String(),
        'is_active': _isActive,
        'observations': _observationsCtrl.text.trim(),
      });
      ref.invalidate(patientMedicationsProvider(widget.patientId));
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
