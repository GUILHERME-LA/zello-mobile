import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

/// Lista de todas as permissões disponíveis no sistema
const List<PermissionDefinition> allPermissions = [
  PermissionDefinition(
    key: 'patients',
    label: 'Ver Pacientes',
    description: 'Acesso a lista de pacientes',
    icon: LucideIcons.users,
  ),
  PermissionDefinition(
    key: 'consultations',
    label: 'Gerenciar Consultas',
    description: 'Agendar e editar consultas',
    icon: LucideIcons.calendar,
  ),
  PermissionDefinition(
    key: 'medications',
    label: 'Gerenciar Medicacoes',
    description: 'Prescrever e editar medicacoes',
    icon: LucideIcons.pill,
  ),
  PermissionDefinition(
    key: 'reports',
    label: 'Ver Relatorios',
    description: 'Acesso a estatisticas e relatorios',
    icon: LucideIcons.barChart,
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

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                                          ? ZelloColors.primaryLighter
                                          : ZelloColors.primary)
                                      .withAlpha(25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  prof.type == 'medico'
                                      ? LucideIcons.building2
                                      : LucideIcons.brain,
                                  color: prof.type == 'medico'
                                      ? ZelloColors.primaryLighter
                                      : ZelloColors.primary,
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: const Color(0xFFE5E7EB)),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.check),
                    label: Text(_isLoading ? 'Salvando...' : 'Salvar Permissões'),
                    onPressed: _isLoading ? null : _savePermissions,
                  ),
                ),
              ),
            ],
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
                    ? ZelloColors.primaryLighter
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
                        ? ZelloColors.primaryLighter
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
                  activeColor: ZelloColors.primaryLighter,
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
            backgroundColor: ZelloColors.primaryLight,
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