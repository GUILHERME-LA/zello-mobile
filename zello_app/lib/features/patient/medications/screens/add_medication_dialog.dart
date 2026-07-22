import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class AddMedicationDialog extends ConsumerStatefulWidget {
  const AddMedicationDialog({super.key});

  @override
  ConsumerState<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends ConsumerState<AddMedicationDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();
  final _scheduleHourController = TextEditingController();
  final _scheduleMinuteController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  var _isActive = true;
  var _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    _scheduleHourController.dispose();
    _scheduleMinuteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do medicamento.')),
      );
      return;
    }
    if (_scheduleHourController.text.isNotEmpty) {
      final h = int.tryParse(_scheduleHourController.text);
      if (h == null || h < 0 || h > 23) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hora inválida (0-23).')),
        );
        return;
      }
    }
    if (_scheduleMinuteController.text.isNotEmpty) {
      final m = int.tryParse(_scheduleMinuteController.text);
      if (m == null || m < 0 || m > 59) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Minuto inválido (0-59).')),
        );
        return;
      }
    }
    setState(() => _isSaving = true);
    try {
      final api = ref.read(apiClientProvider);
      final patientId = api.currentPatientId ??
          (await _resolvePatientId(api));
      if (patientId == null || patientId.isEmpty) {
        throw Exception('Paciente não identificado. Faça login novamente.');
      }
      String? scheduleTime;
      if (_scheduleHourController.text.isNotEmpty && _scheduleMinuteController.text.isNotEmpty) {
        final h = int.parse(_scheduleHourController.text);
        final m = int.parse(_scheduleMinuteController.text);
        scheduleTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      }
      await api.createMedication({
        'patient_id': patientId,
        'name': name,
        'dosage': _dosageController.text.trim(),
        'frequency': _frequencyController.text.trim(),
        'prescribing_doctor': _doctorController.text.trim(),
        'start_date': _startDate?.toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0],
        'is_active': _isActive,
        'observations': _notesController.text.trim(),
        'schedule_time': scheduleTime,
      });
      if (mounted) {
        ref.invalidate(medicationsProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Medicação adicionada!')]),
            backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nova Medicação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do medicamento *', hintText: 'Ex: Losartana', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosagem', hintText: 'Ex: 50mg', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _frequencyController,
              decoration: const InputDecoration(labelText: 'Frequência', hintText: 'Ex: 1x ao dia', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _doctorController,
              decoration: const InputDecoration(labelText: 'Médico que prescreveu', hintText: 'Ex: Dr. Silva', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _scheduleHourController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    decoration: const InputDecoration(labelText: 'Hora (0-23)', hintText: '08', border: OutlineInputBorder(), counterText: ''),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _scheduleMinuteController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    decoration: const InputDecoration(labelText: 'Minuto (0-59)', hintText: '00', border: OutlineInputBorder(), counterText: ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: _startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : ''),
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Data início', hintText: 'Toque para selecionar', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) setState(() => _startDate = d);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: _endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : ''),
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Data fim (opcional)', hintText: 'Toque para selecionar', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) setState(() => _endDate = d);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ativo', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Medicação em uso', style: TextStyle(fontSize: 11)),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
              activeColor: const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Observações', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Adicionar Medicação'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}