import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class ExamStatusScreen extends ConsumerWidget {
  const ExamStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examReqAsync = ref.watch(examRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Status dos Exames')),
      body: examReqAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science_outlined, size: 64, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 16),
                  Text('Nenhuma solicitação de exame',
                      style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return AnimatedCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _statusColor(req.status).withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_statusIcon(req.status),
                          color: _statusColor(req.status), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req.examType,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(_statusLabel(req.status),
                              style: TextStyle(
                                  fontSize: 12, color: _statusColor(req.status))),
                        ],
                      ),
                    ),
                    if (req.createdAt != null)
                      Text(
                        '${req.createdAt!.day}/${req.createdAt!.month}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmado':
        return const Color(0xFF10B981);
      case 'recusado':
        return const Color(0xFFEF4444);
      case 'concluido':
        return const Color(0xFF3B82F6);
      case 'cancelado':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'confirmado':
        return Icons.check_circle_outline;
      case 'recusado':
        return Icons.cancel_outlined;
      case 'concluido':
        return Icons.task_alt;
      case 'cancelado':
        return Icons.remove_circle_outline;
      default:
        return Icons.schedule;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'solicitado':
        return 'Aguardando confirmação';
      case 'confirmado':
        return 'Confirmado';
      case 'recusado':
        return 'Recusado';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }
}
