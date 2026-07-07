import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

/// Lista de todas as permissões disponíveis no sistema
const List<PermissionDefinition> allPermissions = [
  PermissionDefinition(
    key: 'patients',
    label: 'Ver Pacientes',
    description: 'Acesso à lista de pacientes',
    icon: Icons.people,
  ),
  PermissionDefinition(
    key: 'exams',
    label: 'Gerenciar Exames',
    description: 'Adicionar e editar exames',
    icon: Icons.science,
  ),
  PermissionDefinition(
    key: 'consultations',
    label: 'Gerenciar Consultas',
    description: 'Agendar e editar consultas',
    icon: Icons.event,
  ),
  PermissionDefinition(
    key: 'medications',
    label: 'Gerenciar Medicações',
    description: 'Prescrever e editar medicações',
    icon: Icons.medication,
  ),
  PermissionDefinition(
    key: 'reports',
    label: 'Ver Relatórios',
    description: 'Acesso a estatísticas e relatórios',
    icon: Icons.bar_chart,
  ),
];

class PermissionDefinition {
  final String key;
  final String label;
  final String description;
  final IconData icon;

  const PermissionDefinition({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });
}

class ProfessionalPermissionsScreen extends ConsumerStatefulWidget {
  final String professionalId;
  const ProfessionalPermissionsScreen({super.key, required this.professionalId});

  @override
  ConsumerState<ProfessionalPermissionsScreen> createState() => _ProfessionalPermissionsScreenState();
}

class _ProfessionalPermissionsScreenState extends ConsumerState<ProfessionalPermissionsScreen> {
  final Set<String> _selectedPermissions = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final permissionsAsync = ref.watch(professionalPermissionsProvider(widget.professionalId));
    final professionalsAsync = ref.watch(professionalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissões'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _savePermissions,
            ),
        ],
      ),
      body: permissionsAsync.when(
        data: (permissions) {
          // Inicializa as permissões selecionadas com as já concessas
          if (_selectedPermissions.isEmpty) {
            for (final perm in permissions) {
              _selectedPermissions.add(perm.permission);
            }
          }

          final prof = professionalsAsync.valueOrNull
              ?.where((p) => p.id == widget.professionalId)
              .firstOrNull;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prof != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (prof.type == 'medico'
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFF8B5CF6))
                                .withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            prof.type == 'medico'
                                ? Icons.local_hospital
                                : Icons.psychology,
                            color: prof.type == 'medico'
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prof.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                prof.type == 'medico' ? 'Médico' : 'Psicólogo',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Permissões do Profissional',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecione as permissões que este profissional poderá exercer.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                ...allPermissions.map((perm) => _buildPermissionTile(perm)),
              ],
            ),
          );
        },
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(professionalPermissionsProvider(widget.professionalId))),
      ),
    );
  }

  Widget _buildPermissionTile(PermissionDefinition permDef) {
    final isSelected = _selectedPermissions.contains(permDef.key);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedPermissions.remove(permDef.key);
              } else {
                _selectedPermissions.add(permDef.key);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    permDef.icon,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        permDef.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF1A1A2E)
                              : const Color(0xFF374151),
                        ),
                      ),
                      Text(
                        permDef.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedPermissions.add(permDef.key);
                      } else {
                        _selectedPermissions.remove(permDef.key);
                      }
                    });
                  },
                  activeColor: const Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _savePermissions() async {
    setState(() => _isLoading = true);

    try {
      final api = ref.read(apiClientProvider);
      final auth = ref.read(authProvider);
      final adminProfileId = auth.user?.profileId;
      final currentPermissions = ref.read(professionalPermissionsProvider(widget.professionalId)).valueOrNull ?? [];
      final currentKeys = currentPermissions.map((p) => p.permission).toSet();

      // Remover permissões que foram desmarcadas
      for (final permKey in currentKeys) {
        if (!_selectedPermissions.contains(permKey)) {
          await api.revokePermission(widget.professionalId, permKey);
        }
      }

      // Adicionar permissões que foram marcadas
      for (final permKey in _selectedPermissions) {
        if (!currentKeys.contains(permKey)) {
          await api.grantPermission(widget.professionalId, permKey, grantedBy: adminProfileId);
        }
      }

      // Invalidar o cache para recarregar
      ref.invalidate(professionalPermissionsProvider(widget.professionalId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissões salvas com sucesso!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar permissões: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}