import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class AddReferralDialog extends ConsumerStatefulWidget {
  final String patientId;

  const AddReferralDialog({super.key, required this.patientId});

  @override
  ConsumerState<AddReferralDialog> createState() => _AddReferralDialogState();
}

class _AddReferralDialogState extends ConsumerState<AddReferralDialog> {
  final _formKey = GlobalKey<FormState>();
  final _specialtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _specialtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(LucideIcons.send, color: ZelloColors.primaryLighter),
          SizedBox(width: 8),
          Text('Encaminhamento'),
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
                const Text(
                  'Encaminhe o paciente para outra especialidade ou profissional.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specialtyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Especialidade / Profissional',
                    hintText: 'Ex: Neurologista, Psiquiatra, Fonoaudiólogo...',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Motivo do encaminhamento',
                    hintText:
                        'Descreva o motivo e informações relevantes...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
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
          icon: const Icon(LucideIcons.send, size: 18),
          label: const Text('Encaminhar'),
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authProvider);
    final referral = Referral(
      id: '',
      patientId: widget.patientId,
      fromProfessionalId: auth.user?.professionalId ?? '',
      toSpecialty: _specialtyCtrl.text.trim(),
      reason: _reasonCtrl.text.trim(),
      status: 'ativo',
    );

    try {
      await ref.read(referralsProvider).create(referral);
      ref.invalidate(patientReferralsProvider(widget.patientId));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encaminhamento registrado!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao encaminhar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
