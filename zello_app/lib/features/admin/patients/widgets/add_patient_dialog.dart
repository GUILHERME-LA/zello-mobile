import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:zello_shared/zello_shared.dart';

class AddPatientDialog extends ConsumerStatefulWidget {
  final String? professionalId;
  const AddPatientDialog({super.key, this.professionalId});

  @override
  ConsumerState<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends ConsumerState<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  DateTime? _birthDate;
  String? _selectedProfessionalId;
  bool _saving = false;
  bool _autoGeneratePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cpfCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final professionalsAsync = ref.watch(professionalsProvider);

    return AlertDialog(
      title: const Text('Novo Paciente'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome', hintText: 'Nome completo'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                    labelText: 'Email', hintText: 'email@exemplo.com'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                    labelText: 'Telefone', hintText: '(11) 99999-9999'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpfCtrl,
                decoration:
                    const InputDecoration(labelText: 'CPF', hintText: '123.456.789-00'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_birthDate != null
                    ? Formatters.formatDate(_birthDate!)
                    : 'Data de nascimento'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1990),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _birthDate = picked);
                },
              ),
              const SizedBox(height: 12),
              professionalsAsync.when(
                data: (professionals) {
                  if (professionals.isEmpty) return const SizedBox.shrink();
                  return DropdownButtonFormField<String>(
                    value: _selectedProfessionalId,
                    decoration: const InputDecoration(
                        labelText: 'Profissional vinculado'),
                    items: professionals
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                  '${p.type == 'medico' ? 'Dr.' : 'Psi.'} ${p.specialty} - ${p.council}/${p.councilUf}'),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedProfessionalId = v),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Senha temporária',
                      ),
                      enabled: !_autoGeneratePassword,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _autoGeneratePassword = !_autoGeneratePassword;
                        if (_autoGeneratePassword) {
                          _passwordCtrl.clear();
                        }
                      });
                    },
                    child: Text(
                        _autoGeneratePassword ? 'Gerar' : 'Digitar'),
                  ),
                ],
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

    final supabase = Supabase.instance.client;
    final password = _autoGeneratePassword
        ? 'paciente${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 10)}'
        : _passwordCtrl.text;
    final email = _emailCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final cpf = _cpfCtrl.text.trim();

    try {
      final currentSession = supabase.auth.currentSession;

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      final userId = response.user?.id;

      if (userId != null) {
        try {
          await supabase.from('profiles').insert({
            'user_id': userId,
            'role': 'patient',
            'name': name,
            'phone': phone,
          });
        } catch (_) {}

        await supabase.from('patients').insert({
          'user_id': userId,
          'name': name,
          'email': email,
          'phone': phone,
          'cpf': cpf,
            'birth_date': _birthDate == null
                ? null
                : _birthDate is DateTime
                    ? (_birthDate as DateTime).toIso8601String()
                    : (_birthDate as String),
          'professional_id': _selectedProfessionalId ?? widget.professionalId,
        });
      }

      if (currentSession != null) {
        await supabase.auth.setSession(currentSession.accessToken);
      }

      ref.invalidate(patientsProvider);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userId != null
              ? 'Paciente criado! Senha temporária: $password'
              : 'E-mail de confirmação enviado para $email'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      final msg = e.toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro: ${msg.contains('already') ? 'Email já cadastrado' : msg}'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}