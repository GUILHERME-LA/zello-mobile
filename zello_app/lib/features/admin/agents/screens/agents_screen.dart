import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class AgentsScreen extends ConsumerWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(agentsProvider);
                  await ref.read(agentsProvider.future);
                },
                child: agentsAsync.when(
                  data: (agents) => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: agents.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AgentCard(
                        agent: agents[index],
                        onTap: () =>
                            _showAgentDetail(context, agents[index]),
                      ),
                    ),
                  ),
                  loading: () => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: 3,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: SkeletonCard(),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Erro ao carregar agentes: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAgent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Novo Agente',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nome do agente',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agente adicionado com sucesso!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(12))),
                    ),
                  );
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgentDetail(BuildContext context, Agent agent) {
    final statusColor = switch (agent.status) {
      AgentStatus.online => const Color(0xFF10B981),
      AgentStatus.busy => const Color(0xFFF59E0B),
      AgentStatus.offline => const Color(0xFF9CA3AF),
    };
    final statusLabel = switch (agent.status) {
      AgentStatus.online => 'Online',
      AgentStatus.busy => 'Ocupado',
      AgentStatus.offline => 'Offline',
    };
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ZelloAvatar(name: agent.name, size: 52),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agent.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ZelloBadge(
                            label: agent.type == AgentType.medico
                                ? 'Médico'
                                : 'Psicólogo',
                            variant: agent.type == AgentType.medico
                                ? ZelloBadgeVariant.medical
                                : ZelloBadgeVariant.psychology,
                            fontSize: 10,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(statusLabel,
                              style: TextStyle(
                                  fontSize: 12, color: statusLabel == 'Online' ? const Color(0xFF10B981) : const Color(0xFF6B7280))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _detailRow('Conversas Ativas', '${agent.activeConversations}'),
            const SizedBox(height: 12),
            _detailRow('Total Atendidas', '${agent.totalHandled}'),
            const SizedBox(height: 12),
            _detailRow('Tempo Médio', '${agent.avgResponseTime.toStringAsFixed(1)}min'),
          ],
        ),
      ),
    );
  }

  static Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Agentes',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22)),
                SizedBox(height: 2),
                Text('Gerenciar agentes',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showAddAgent(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final Agent agent;
  final VoidCallback? onTap;
  const _AgentCard({required this.agent, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (agent.status) {
      AgentStatus.online => const Color(0xFF10B981),
      AgentStatus.busy => const Color(0xFFF59E0B),
      AgentStatus.offline => const Color(0xFF9CA3AF),
    };
    final statusLabel = switch (agent.status) {
      AgentStatus.online => 'Online',
      AgentStatus.busy => 'Ocupado',
      AgentStatus.offline => 'Offline',
    };

    return AnimatedCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              ZelloAvatar(name: agent.name, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ZelloBadge(
                          label: agent.type == AgentType.medico
                              ? 'Médico'
                              : 'Psicólogo',
                          variant: agent.type == AgentType.medico
                              ? ZelloBadgeVariant.medical
                              : ZelloBadgeVariant.psychology,
                          fontSize: 10,
                        ),
                        const SizedBox(width: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(statusLabel,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildStat('Conversas', '${agent.activeConversations}'),
                Container(
                  width: 1,
                  height: 24,
                  color: const Color(0xFFE5E7EB),
                ),
                _buildStat('Atendidas', '${agent.totalHandled}'),
                Container(
                  width: 1,
                  height: 24,
                  color: const Color(0xFFE5E7EB),
                ),
                _buildStat('Tempo Médio', '${agent.avgResponseTime.toStringAsFixed(1)}min'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
