import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class SolicitacoesScreen extends ConsumerStatefulWidget {
  const SolicitacoesScreen({super.key});

  @override
  ConsumerState<SolicitacoesScreen> createState() => _SolicitacoesScreenState();
}

class _SolicitacoesScreenState extends ConsumerState<SolicitacoesScreen> {
  @override
  Widget build(BuildContext context) {
    final examReqAsync = ref.watch(examRequestsProvider);
    final canExams = ref.watch(canAccessProvider('exams'));

    if (!canExams) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.lock, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Você não tem permissão para gerenciar exames',
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Solicite acesso ao administrador do sistema.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GradientHeader(
              title: 'Solicitações de Exame',
              subtitle: 'Confirme ou recuse solicitações',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(examRequestsProvider);
                  await ref.read(examRequestsProvider.notifier).load();
                },
                child: examReqAsync.when(
                  data: (requests) {
                    if (requests.isEmpty) {
                      return ListView(
                        children: const [
                          EmptyState(
                            icon: LucideIcons.inbox,
                            title: 'Nenhuma solicitação pendente',
                            subtitle: 'Quando um paciente solicitar um exame, aparecerá aqui.',
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        return _ExamRequestCard(
                          request: req,
                          onConfirm: () async {
                            try {
                              await ref.read(examRequestsProvider.notifier).confirm(req.id);
                              ref.invalidate(examRequestsProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Solicitação confirmada com sucesso'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao confirmar: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          onRefuse: () => _showRefuseDialog(context, ref, req.id),
                        );
                      },
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (e, _) => ErrorState(
                    message: 'Não foi possível carregar as solicitações.',
                    technicalDetails: '$e',
                    onRetry: () {
                      ref.invalidate(examRequestsProvider);
                      ref.read(examRequestsProvider.notifier).load();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRefuseDialog(BuildContext context, WidgetRef ref, String requestId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recusar Solicitação'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Motivo da recusa'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(examRequestsProvider.notifier).refuse(requestId, reasonCtrl.text);
                ref.invalidate(examRequestsProvider);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Solicitação recusada'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao recusar: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Recusar', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}

class _ExamRequestCard extends StatelessWidget {
  final ExamRequest request;
  final VoidCallback onConfirm;
  final VoidCallback onRefuse;

  const _ExamRequestCard({
    required this.request,
    required this.onConfirm,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_statusIcon, color: _statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.examType,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        _statusLabel,
                        style: TextStyle(fontSize: 12, color: _statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(request.notes,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            ],
            if (request.status == 'solicitado') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRefuse,
                      icon: const Icon(LucideIcons.x, size: 16),
                      label: const Text('Recusar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        minimumSize: const Size(0, 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ],
            if (request.refusedReason != null) ...[
              const SizedBox(height: 8),
              Text('Motivo: ${request.refusedReason}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFEF4444), fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (request.status) {
      case 'confirmado':
        return ZelloColors.primaryLight;
      case 'recusado':
        return const Color(0xFFEF4444);
      case 'concluido':
        return ZelloColors.primaryLighter;
      default:
        return ZelloColors.primaryLighter;
    }
  }

  IconData get _statusIcon {
    switch (request.status) {
      case 'confirmado':
        return LucideIcons.checkCircle2;
      case 'recusado':
        return LucideIcons.xCircle;
      case 'concluido':
        return LucideIcons.checkCircle2;
      default:
        return LucideIcons.clock;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case 'solicitado':
        return 'Pendente';
      case 'confirmado':
        return 'Confirmado';
      case 'recusado':
        return 'Recusado';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
      default:
        return request.status;
    }
  }
}
