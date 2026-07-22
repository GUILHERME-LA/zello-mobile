import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';
import 'add_dialogs.dart';

// ==================== EDIT SURGERY ====================

void showEditSurgeryDialog(
    BuildContext context, WidgetRef ref, String patientId, Surgery surgery) {
  final nameCtrl = TextEditingController(text: surgery.name);
  final dateCtrl = TextEditingController(text: _fmt(surgery.date));
  final hospitalCtrl = TextEditingController(text: surgery.hospital);
  final doctorCtrl = TextEditingController(text: surgery.doctor);
  final notesCtrl = TextEditingController(text: surgery.notes);
  DateTime? selectedDate = surgery.date;
  var isLoading = false;

  _showEditSheet(
    context, ref, patientId,
    Icons.content_cut, const Color(0xFF1565C0), 'Editar Cirurgia',
    Column(children: [
      _requiredField(nameCtrl, 'Nome da cirurgia *', 'Ex: Apendicectomia'),
      const SizedBox(height: 12),
      _dateField(dateCtrl, 'Data *', context, (d) { selectedDate = d; dateCtrl.text = _fmt(d); }),
      const SizedBox(height: 12),
      _optField(hospitalCtrl, 'Hospital', 'Opcional'),
      const SizedBox(height: 12),
      _optField(doctorCtrl, 'Médico', 'Opcional'),
      const SizedBox(height: 12),
      _notesField(notesCtrl),
    ]),
    isLoading, 'Salvar',
    () async {
      if (nameCtrl.text.trim().isEmpty) return _snack(context, 'Informe o nome da cirurgia');
      if (selectedDate == null) return _snack(context, 'Selecione a data');
      await ref.read(patientHealthProvider).deleteSurgery(surgery.id);
      await ref.read(patientHealthProvider).addSurgery(Surgery(
        id: '', patientId: patientId, name: nameCtrl.text.trim(),
        date: selectedDate!, hospital: hospitalCtrl.text.trim(),
        doctor: doctorCtrl.text.trim(), notes: notesCtrl.text.trim(),
      ));
      ref.invalidate(patientSurgeriesProvider(patientId));
      _sucesso(context);
    },
  );
}

// ==================== EDIT HOSPITALIZATION ====================

void showEditHospitalizationDialog(
    BuildContext context, WidgetRef ref, String patientId, Hospitalization h) {
  final reasonCtrl = TextEditingController(text: h.reason);
  final hospitalCtrl = TextEditingController(text: h.hospital);
  final notesCtrl = TextEditingController(text: h.notes);
  final startCtrl = TextEditingController(text: _fmt(h.startDate));
  final endCtrl = TextEditingController(text: h.endDate != null ? _fmt(h.endDate!) : '');
  DateTime? startDate = h.startDate;
  DateTime? endDate = h.endDate;
  var isLoading = false;

  _showEditSheet(
    context, ref, patientId,
    Icons.local_hospital, const Color(0xFFEF4444), 'Editar Internação',
    Column(children: [
      _requiredField(reasonCtrl, 'Motivo *', 'Ex: Pneumonia'),
      const SizedBox(height: 12),
      _optField(hospitalCtrl, 'Hospital', 'Opcional'),
      const SizedBox(height: 12),
      _dateField(startCtrl, 'Data de início *', context, (d) { startDate = d; startCtrl.text = _fmt(d); }),
      const SizedBox(height: 12),
      _dateField(endCtrl, 'Data de alta', context, (d) { endDate = d; endCtrl.text = _fmt(d); }),
      const SizedBox(height: 12),
      _notesField(notesCtrl),
    ]),
    isLoading, 'Salvar',
    () async {
      if (reasonCtrl.text.trim().isEmpty) return _snack(context, 'Informe o motivo');
      if (startDate == null) return _snack(context, 'Selecione a data de início');
      await ref.read(patientHealthProvider).deleteHospitalization(h.id);
      await ref.read(patientHealthProvider).addHospitalization(Hospitalization(
        id: '', patientId: patientId, reason: reasonCtrl.text.trim(),
        hospital: hospitalCtrl.text.trim(), startDate: startDate!,
        endDate: endDate, notes: notesCtrl.text.trim(),
      ));
      ref.invalidate(patientHospitalizationsProvider(patientId));
      _sucesso(context);
    },
  );
}

// ==================== EDIT SYMPTOM ====================

void showEditSymptomDialog(
    BuildContext context, WidgetRef ref, String patientId, Symptom symptom) {
  final nameCtrl = TextEditingController(text: symptom.name);
  final freqCtrl = TextEditingController(text: symptom.frequency);
  final intensCtrl = TextEditingController(text: symptom.intensity);
  final notesCtrl = TextEditingController(text: symptom.notes);
  var isLoading = false;

  _showEditSheet(
    context, ref, patientId,
    Icons.monitor_heart_outlined, const Color(0xFFF59E0B), 'Editar Sintoma',
    Column(children: [
      _requiredField(nameCtrl, 'Sintoma *', 'Ex: Dor de cabeça'),
      const SizedBox(height: 12),
      _optField(freqCtrl, 'Frequência', 'Ex: Diário, Semanal'),
      const SizedBox(height: 12),
      _optField(intensCtrl, 'Intensidade', 'Ex: Leve, Forte'),
      const SizedBox(height: 12),
      _notesField(notesCtrl),
    ]),
    isLoading, 'Salvar',
    () async {
      if (nameCtrl.text.trim().isEmpty) return _snack(context, 'Informe o sintoma');
      await ref.read(patientHealthProvider).deleteSymptom(symptom.id);
      await ref.read(patientHealthProvider).addSymptom(Symptom(
        id: '', patientId: patientId, name: nameCtrl.text.trim(),
        frequency: freqCtrl.text.trim(), intensity: intensCtrl.text.trim(),
        notes: notesCtrl.text.trim(),
      ));
      ref.invalidate(patientSymptomsProvider(patientId));
      _sucesso(context);
    },
  );
}

// ==================== EDIT ALLERGY ====================

void showEditAllergyDialog(
    BuildContext context, WidgetRef ref, String patientId, Allergy allergy) {
  final nameCtrl = TextEditingController(text: allergy.name);
  final reactionCtrl = TextEditingController(text: allergy.reaction);
  final notesCtrl = TextEditingController(text: allergy.notes);
  var selectedType = allergy.type;
  var isLoading = false;

  _showEditSheet(
    context, ref, patientId,
    Icons.warning_amber, const Color(0xFFEF4444), 'Editar Alergia',
    Column(children: [
      _requiredField(nameCtrl, 'Alergia *', 'Ex: Dipirona'),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: selectedType,
        decoration: const InputDecoration(labelText: 'Tipo'),
        items: const [
          DropdownMenuItem(value: 'medicamento', child: Text('Medicamento')),
          DropdownMenuItem(value: 'alimento', child: Text('Alimento')),
          DropdownMenuItem(value: 'substancia', child: Text('Substância')),
          DropdownMenuItem(value: 'outro', child: Text('Outro')),
        ],
        onChanged: (v) => selectedType = v ?? 'medicamento',
      ),
      const SizedBox(height: 12),
      _optField(reactionCtrl, 'Reação', 'Ex: Urticária'),
      const SizedBox(height: 12),
      _notesField(notesCtrl),
    ]),
    isLoading, 'Salvar',
    () async {
      if (nameCtrl.text.trim().isEmpty) return _snack(context, 'Informe a alergia');
      await ref.read(patientHealthProvider).deleteAllergy(allergy.id);
      await ref.read(patientHealthProvider).addAllergy(Allergy(
        id: '', patientId: patientId, name: nameCtrl.text.trim(),
        type: selectedType, reaction: reactionCtrl.text.trim(),
        notes: notesCtrl.text.trim(),
      ));
      ref.invalidate(patientAllergiesProvider(patientId));
      _sucesso(context);
    },
  );
}

// ==================== EDIT VACCINE ====================

void showEditVaccineDialog(
    BuildContext context, WidgetRef ref, String patientId, Vaccine vaccine) {
  final nameCtrl = TextEditingController(text: vaccine.name);
  final dateCtrl = TextEditingController(text: _fmt(vaccine.date));
  final doseCtrl = TextEditingController(text: vaccine.dose);
  final locationCtrl = TextEditingController(text: vaccine.location);
  final notesCtrl = TextEditingController(text: vaccine.notes);
  DateTime? selectedDate = vaccine.date;
  var isPending = vaccine.isPending;
  var isLoading = false;

  _showEditSheet(
    context, ref, patientId,
    Icons.vaccines_outlined, const Color(0xFF10B981), 'Editar Vacina',
    Column(children: [
      _requiredField(nameCtrl, 'Nome da vacina *', 'Ex: Influenza'),
      const SizedBox(height: 12),
      _dateField(dateCtrl, 'Data *', context, (d) { selectedDate = d; dateCtrl.text = _fmt(d); }),
      const SizedBox(height: 12),
      _optField(doseCtrl, 'Dose', 'Ex: 1ª dose'),
      const SizedBox(height: 12),
      _optField(locationCtrl, 'Local', 'Ex: UBS'),
      const SizedBox(height: 12),
      _notesField(notesCtrl),
      const SizedBox(height: 8),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Pendente', style: TextStyle(fontSize: 14)),
        subtitle: const Text('Ainda não foi aplicada', style: TextStyle(fontSize: 11)),
        value: isPending,
        onChanged: (v) => isPending = v,
        activeColor: const Color(0xFFF59E0B),
      ),
    ]),
    isLoading, 'Salvar',
    () async {
      if (nameCtrl.text.trim().isEmpty) return _snack(context, 'Informe o nome da vacina');
      if (selectedDate == null) return _snack(context, 'Selecione a data');
      await ref.read(patientHealthProvider).deleteVaccine(vaccine.id);
      await ref.read(patientHealthProvider).addVaccine(Vaccine(
        id: '', patientId: patientId, name: nameCtrl.text.trim(),
        date: selectedDate!, dose: doseCtrl.text.trim(),
        location: locationCtrl.text.trim(), notes: notesCtrl.text.trim(),
        isPending: isPending,
      ));
      ref.invalidate(patientVaccinesProvider(patientId));
      _sucesso(context);
    },
  );
}

// ==================== HELPERS ====================

String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

void _snack(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}

void _sucesso(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Row(children: [Icon(Icons.check_circle, color: Colors.white, size: 18), SizedBox(width: 8), Text('Salvo com sucesso!')]),
    backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating,
  ));
}

Widget _handle(BuildContext ctx) => Center(
  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
);

Widget _header(IconData icon, Color color, String title) {
  return Row(children: [
    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 20)),
    const SizedBox(width: 12),
    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
  ]);
}

Widget _requiredField(TextEditingController c, String label, String hint) {
  return TextField(controller: c, decoration: InputDecoration(labelText: label, hintText: hint));
}

Widget _optField(TextEditingController c, String label, String hint) {
  return TextField(controller: c, decoration: InputDecoration(labelText: label, hintText: hint));
}

Widget _notesField(TextEditingController c) {
  return TextField(controller: c, decoration: const InputDecoration(labelText: 'Observações', alignLabelWithHint: true), maxLines: 3);
}

Widget _dateField(TextEditingController c, String label, BuildContext ctx, void Function(DateTime) onPicked) {
  return TextField(
    controller: c, readOnly: true,
    decoration: InputDecoration(labelText: label, hintText: 'Toque para selecionar', suffixIcon: const Icon(Icons.calendar_today)),
    onTap: () async {
      final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime.now());
      if (d != null) onPicked(d);
    },
  );
}

Widget _btn(bool isLoading, String label, Future<void> Function() onSave) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isLoading ? null : () async => onSave(),
      child: isLoading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(label),
    ),
  );
}

void _showEditSheet(
  BuildContext context,
  WidgetRef ref,
  String patientId,
  IconData icon,
  Color color,
  String title,
  Widget body,
  bool isLoading,
  String btnLabel,
  Future<void> Function() onSave,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _handle(ctx),
              _header(icon, color, title),
              const SizedBox(height: 20),
              body,
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setLocal(() => isLoading = true);
                          try {
                            await onSave();
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            setLocal(() => isLoading = false);
                            if (ctx.mounted) _snack(ctx, 'Erro ao salvar: $e');
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(btnLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
