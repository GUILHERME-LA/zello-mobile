import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

// ==================== SURGERY ====================

void showAddSurgeryDialog(BuildContext context, WidgetRef ref, String patientId) {
  final nameCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final hospitalCtrl = TextEditingController();
  final doctorCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime? selectedDate;
  var isLoading = false;

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
              _header(Icons.content_cut, const Color(0xFF1565C0), 'Nova Cirurgia'),
              const SizedBox(height: 20),
              _requiredField(nameCtrl, 'Nome da cirurgia *', 'Ex: Apendicectomia'),
              const SizedBox(height: 12),
              _dateField(dateCtrl, 'Data *', ctx, (d) { selectedDate = d; dateCtrl.text = _fmt(d); }),
              const SizedBox(height: 12),
              _optField(hospitalCtrl, 'Hospital', 'Opcional'),
              const SizedBox(height: 12),
              _optField(doctorCtrl, 'Médico', 'Opcional'),
              const SizedBox(height: 12),
              _notesField(notesCtrl),
              const SizedBox(height: 20),
              _btn(isLoading, 'Adicionar Cirurgia', () async {
                if (nameCtrl.text.trim().isEmpty) return _snack(ctx, 'Informe o nome da cirurgia');
                if (selectedDate == null) return _snack(ctx, 'Selecione a data');
                setLocal(() => isLoading = true);
                try {
                  await ref.read(patientHealthProvider).addSurgery(Surgery(
                    id: '', patientId: patientId, name: nameCtrl.text.trim(),
                    date: selectedDate!, hospital: hospitalCtrl.text.trim(),
                    doctor: doctorCtrl.text.trim(), notes: notesCtrl.text.trim(),
                  ));
                  ref.invalidate(patientSurgeriesProvider(patientId));
                  _sucesso(context);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setLocal(() => isLoading = false);
                  if (ctx.mounted) _snack(ctx, 'Erro ao salvar: $e');
                }
              }),
            ],
          ),
        ),
      ),
    ),
  );
}

// ==================== HOSPITALIZATION ====================

void showAddHospitalizationDialog(BuildContext context, WidgetRef ref, String patientId) {
  final reasonCtrl = TextEditingController();
  final hospitalCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final startCtrl = TextEditingController();
  final endCtrl = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  var isLoading = false;

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
              _header(Icons.local_hospital, const Color(0xFFEF4444), 'Nova Internação'),
              const SizedBox(height: 20),
              _requiredField(reasonCtrl, 'Motivo *', 'Ex: Pneumonia'),
              const SizedBox(height: 12),
              _optField(hospitalCtrl, 'Hospital', 'Opcional'),
              const SizedBox(height: 12),
              _dateField(startCtrl, 'Data de início *', ctx, (d) { startDate = d; startCtrl.text = _fmt(d); }),
              const SizedBox(height: 12),
              _dateField(endCtrl, 'Data de alta', ctx, (d) { endDate = d; endCtrl.text = _fmt(d); }),
              const SizedBox(height: 12),
              _notesField(notesCtrl),
              const SizedBox(height: 20),
              _btn(isLoading, 'Adicionar Internação', () async {
                if (reasonCtrl.text.trim().isEmpty) return _snack(ctx, 'Informe o motivo');
                if (startDate == null) return _snack(ctx, 'Selecione a data de início');
                setLocal(() => isLoading = true);
                try {
                  await ref.read(patientHealthProvider).addHospitalization(Hospitalization(
                    id: '', patientId: patientId, reason: reasonCtrl.text.trim(),
                    hospital: hospitalCtrl.text.trim(), startDate: startDate!,
                    endDate: endDate, notes: notesCtrl.text.trim(),
                  ));
                  ref.invalidate(patientHospitalizationsProvider(patientId));
                  _sucesso(context);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setLocal(() => isLoading = false);
                  if (ctx.mounted) _snack(ctx, 'Erro ao salvar: $e');
                }
              }),
            ],
          ),
        ),
      ),
    ),
  );
}

// ==================== SYMPTOM ====================

void showAddSymptomDialog(BuildContext context, WidgetRef ref, String patientId) {
  final nameCtrl = TextEditingController();
  final freqCtrl = TextEditingController();
  final intensCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  var isLoading = false;

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
              _header(Icons.monitor_heart_outlined, const Color(0xFFF59E0B), 'Novo Sintoma'),
              const SizedBox(height: 20),
              _requiredField(nameCtrl, 'Sintoma *', 'Ex: Dor de cabeça'),
              const SizedBox(height: 12),
              _optField(freqCtrl, 'Frequência', 'Ex: Diário, Semanal'),
              const SizedBox(height: 12),
              _optField(intensCtrl, 'Intensidade', 'Ex: Leve, Forte'),
              const SizedBox(height: 12),
              _notesField(notesCtrl),
              const SizedBox(height: 20),
              _btn(isLoading, 'Adicionar Sintoma', () async {
                if (nameCtrl.text.trim().isEmpty) return _snack(ctx, 'Informe o sintoma');
                setLocal(() => isLoading = true);
                try {
                  await ref.read(patientHealthProvider).addSymptom(Symptom(
                    id: '', patientId: patientId, name: nameCtrl.text.trim(),
                    frequency: freqCtrl.text.trim(), intensity: intensCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                  ));
                  ref.invalidate(patientSymptomsProvider(patientId));
                  _sucesso(context);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setLocal(() => isLoading = false);
                  if (ctx.mounted) _snack(ctx, 'Erro ao salvar: $e');
                }
              }),
            ],
          ),
        ),
      ),
    ),
  );
}

// ==================== ALLERGY ====================

void showAddAllergyDialog(BuildContext context, WidgetRef ref, String patientId) {
  final nameCtrl = TextEditingController();
  final reactionCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  var selectedType = 'medicamento';
  var isLoading = false;

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
              _header(Icons.warning_amber, const Color(0xFFEF4444), 'Nova Alergia'),
              const SizedBox(height: 20),
              _requiredField(nameCtrl, 'Alergia *', 'Ex: Dipirona'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'medicamento', child: Text('💊 Medicamento')),
                  DropdownMenuItem(value: 'alimento', child: Text('🍽️ Alimento')),
                  DropdownMenuItem(value: 'substancia', child: Text('🧪 Substância')),
                  DropdownMenuItem(value: 'outro', child: Text('📌 Outro')),
                ],
                onChanged: (v) => setLocal(() => selectedType = v ?? 'medicamento'),
              ),
              const SizedBox(height: 12),
              _optField(reactionCtrl, 'Reação', 'Ex: Urticária'),
              const SizedBox(height: 12),
              _notesField(notesCtrl),
              const SizedBox(height: 20),
              _btn(isLoading, 'Adicionar Alergia', () async {
                if (nameCtrl.text.trim().isEmpty) return _snack(ctx, 'Informe a alergia');
                setLocal(() => isLoading = true);
                try {
                  await ref.read(patientHealthProvider).addAllergy(Allergy(
                    id: '', patientId: patientId, name: nameCtrl.text.trim(),
                    type: selectedType, reaction: reactionCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                  ));
                  ref.invalidate(patientAllergiesProvider(patientId));
                  _sucesso(context);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setLocal(() => isLoading = false);
                  if (ctx.mounted) _snack(ctx, 'Erro ao salvar: $e');
                }
              }),
            ],
          ),
        ),
      ),
    ),
  );
}

// ==================== VACCINE ====================

void showAddVaccineDialog(BuildContext context, WidgetRef ref, String patientId) {
  final nameCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime? selectedDate;
  var isPending = false;
  var isLoading = false;

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
              _header(Icons.vaccines_outlined, const Color(0xFF10B981), 'Nova Vacina'),
              const SizedBox(height: 20),
              _requiredField(nameCtrl, 'Nome da vacina *', 'Ex: Influenza'),
              const SizedBox(height: 12),
              _dateField(dateCtrl, 'Data *', ctx, (d) { selectedDate = d; dateCtrl.text = _fmt(d); }),
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
                onChanged: (v) => setLocal(() => isPending = v),
                activeColor: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 8),
              _btn(isLoading, 'Adicionar Vacina', () async {
                if (nameCtrl.text.trim().isEmpty) return _snack(ctx, 'Informe o nome da vacina');
                if (selectedDate == null) return _snack(ctx, 'Selecione a data');
                setLocal(() => isLoading = true);
                try {
                  await ref.read(patientHealthProvider).addVaccine(Vaccine(
                    id: '', patientId: patientId, name: nameCtrl.text.trim(),
                    date: selectedDate!, dose: doseCtrl.text.trim(),
                    location: locationCtrl.text.trim(), notes: notesCtrl.text.trim(),
                    isPending: isPending,
                  ));
                  ref.invalidate(patientVaccinesProvider(patientId));
                  _sucesso(context);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setLocal(() => isLoading = false);
                  if (ctx.mounted) _snack(ctx, 'Erro ao salvar: $e');
                }
              }),
            ],
          ),
        ),
      ),
    ),
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

// ==================== EDIT PROFILE ====================

void showEditProfileDialog(BuildContext context, WidgetRef ref, String patientId, HealthProfile current) {
  final weightCtrl = TextEditingController(text: current.weight > 0 ? current.weight.toStringAsFixed(0) : '');
  final heightCtrl = TextEditingController(text: current.height > 0 ? current.height.toStringAsFixed(0) : '');
  final bloodCtrl = TextEditingController(text: current.bloodType);
  final conditionsCtrl = TextEditingController(text: current.medicalConditions);
  final chronicCtrl = TextEditingController(text: current.chronicConditions);
  final medsCtrl = TextEditingController(text: current.medications);
  final familyCtrl = TextEditingController(text: current.familyHistory);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Editar Perfil de Saúde', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: 'Altura (cm)'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 12),
            TextField(controller: bloodCtrl, decoration: const InputDecoration(labelText: 'Tipo Sanguíneo', hintText: 'Ex: A+, O-')),
            const SizedBox(height: 12),
            TextField(controller: conditionsCtrl, decoration: const InputDecoration(labelText: 'Condições Médicas'), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: chronicCtrl, decoration: const InputDecoration(labelText: 'Condições Crônicas'), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: medsCtrl, decoration: const InputDecoration(labelText: 'Medicações em Uso'), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: familyCtrl, decoration: const InputDecoration(labelText: 'Histórico Familiar'), maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final profile = HealthProfile(
                    id: current.id,
                    patientId: patientId,
                    weight: double.tryParse(weightCtrl.text) ?? 0,
                    height: double.tryParse(heightCtrl.text) ?? 0,
                    bloodType: bloodCtrl.text.trim(),
                    medicalConditions: conditionsCtrl.text.trim(),
                    chronicConditions: chronicCtrl.text.trim(),
                    medications: medsCtrl.text.trim(),
                    familyHistory: familyCtrl.text.trim(),
                  );
                  await ref.read(patientHealthProvider).saveHealthProfile(profile);
                  ref.invalidate(patientHealthProfileProvider(patientId));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ==================== EXAM ====================

void showAddExamDialog(BuildContext context, WidgetRef ref, String patientId) {
  final titleCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  var selectedStatus = 'solicitado';
  var isLoading = false;

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
              _header(Icons.science_outlined, const Color(0xFF7C3AED), 'Novo Exame'),
              const SizedBox(height: 20),
              _requiredField(titleCtrl, 'Nome do exame *', 'Ex: Hemograma'),
              const SizedBox(height: 12),
              _optField(typeCtrl, 'Tipo', 'Ex: Sangue, Imagem'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: Exam.statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(Exam.statusLabels[s] ?? s)))
                    .toList(),
                onChanged: (v) => setLocal(() => selectedStatus = v ?? 'solicitado'),
              ),
              const SizedBox(height: 12),
              _notesField(notesCtrl),
              const SizedBox(height: 20),
              _btn(isLoading, 'Adicionar Exame', () async {
                if (titleCtrl.text.trim().isEmpty) return _snack(ctx, 'Informe o nome do exame');
                setLocal(() => isLoading = true);
                try {
                  await ref.read(patientHealthProvider).addExam(Exam(
                    id: '', patientId: patientId, title: titleCtrl.text.trim(),
                    examType: typeCtrl.text.trim(), status: selectedStatus,
                    notes: notesCtrl.text.trim(),
                  ));
                  ref.invalidate(patientExamsProvider(patientId));
                  _sucesso(context);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setLocal(() => isLoading = false);
                  if (ctx.mounted) _snack(ctx, 'Erro ao salvar: $e');
                }
              }),
            ],
          ),
        ),
      ),
    ),
  );
}

// ==================== THERAPY ====================

void showAddTherapyDialog(BuildContext context, WidgetRef ref, String patientId) {
  final nameCtrl = TextEditingController();
  final profCtrl = TextEditingController();
  final freqCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  var selectedType = TherapyType.psicologica;
  var selectedStatus = TherapyStatus.ativa;
  var isLoading = false;

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
              _header(Icons.psychology_outlined, const Color(0xFF8B5CF6), 'Nova Terapia'),
              const SizedBox(height: 20),
              _requiredField(nameCtrl, 'Nome da terapia *', 'Ex: Terapia Cognitivo-Comportamental'),
              const SizedBox(height: 12),
              _optField(profCtrl, 'Profissional', 'Ex: Dr. Silva'),
              const SizedBox(height: 12),
              _optField(freqCtrl, 'Frequência', 'Ex: Semanal, Quinzenal'),
              const SizedBox(height: 12),
              DropdownButtonFormField<TherapyType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: TherapyType.values.map((t) {
                  final label = {
                    TherapyType.fisica: 'Física',
                    TherapyType.ocupacional: 'Ocupacional',
                    TherapyType.fonoaudiologica: 'Fonoaudiológica',
                    TherapyType.psicologica: 'Psicológica',
                    TherapyType.outro: 'Outro',
                  }[t]!;
                  return DropdownMenuItem(value: t, child: Text(label));
                }).toList(),
                onChanged: (v) => setLocal(() => selectedType = v ?? TherapyType.psicologica),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TherapyStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TherapyStatus.values.map((s) {
                  final label = {
                    TherapyStatus.ativa: 'Ativa',
                    TherapyStatus.concluida: 'Concluída',
                    TherapyStatus.pausada: 'Pausada',
                  }[s]!;
                  return DropdownMenuItem(value: s, child: Text(label));
                }).toList(),
                onChanged: (v) => setLocal(() => selectedStatus = v ?? TherapyStatus.ativa),
              ),
              const SizedBox(height: 12),
              _notesField(notesCtrl),
              const SizedBox(height: 20),
              _btn(isLoading, 'Adicionar Terapia', () async {
                if (nameCtrl.text.trim().isEmpty) return _snack(ctx, 'Informe o nome da terapia');
                setLocal(() => isLoading = true);
                try {
                  await ref.read(patientHealthProvider).addTherapy(Therapy(
                    id: '', name: nameCtrl.text.trim(),
                    professional: profCtrl.text.trim(), type: selectedType,
                    frequency: freqCtrl.text.trim(), status: selectedStatus,
                    notes: notesCtrl.text.trim(),
                  ));
                  ref.invalidate(patientTherapiesProvider(patientId));
                  _sucesso(context);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setLocal(() => isLoading = false);
                  if (ctx.mounted) _snack(ctx, 'Erro ao salvar: $e');
                }
              }),
            ],
          ),
        ),
      ),
    ),
  );
}
