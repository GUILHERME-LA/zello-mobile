import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class AddSessionNoteDialog extends ConsumerStatefulWidget {
  final String patientId;

  const AddSessionNoteDialog({super.key, required this.patientId});

  @override
  ConsumerState<AddSessionNoteDialog> createState() =>
      _AddSessionNoteDialogState();
}

class _AddSessionNoteDialogState extends ConsumerState<AddSessionNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'neutro';

  final List<String> _moods = [
    'neutro',
    'calmo',
    'ansioso',
    'triste',
    'feliz',
    'irritado',
  ];

  final Map<String, String> _moodEmojis = {
    'neutro': '😐',
    'calmo': '😌',
    'ansioso': '😰',
    'triste': '😢',
    'feliz': '😊',
    'irritado': '😠',
  };

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.psychology, color: Color(0xFF8B5CF6)),
          SizedBox(width: 8),
          Text('Registrar Sessão'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Data
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 8),

                // Humor/Estado
                const Text('Estado do paciente:',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _moods.map((mood) {
                    final selected = _selectedMood == mood;
                    return ChoiceChip(
                      label: Text('${_moodEmojis[mood]} $mood'),
                      selected: selected,
                      selectedColor: const Color(0xFF8B5CF6).withAlpha(30),
                      onSelected: (_) =>
                          setState(() => _selectedMood = mood),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Conteúdo da sessão
                TextFormField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Anotações da sessão / evolução',
                    hintText:
                        'Descreva o progresso, observações e encaminhamentos...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo obrigatório' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save, size: 18),
          label: const Text('Salvar'),
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authProvider);
    final note = SessionNote(
      id: '',
      patientId: widget.patientId,
      professionalId: auth.user?.professionalId ?? '',
      date: _selectedDate,
      content: _contentCtrl.text.trim(),
      mood: _selectedMood,
      status: 'realizada',
    );

    try {
      await ref.read(sessionNotesProvider).create(note);
      ref.invalidate(patientSessionNotesProvider(widget.patientId));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão registrada com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
