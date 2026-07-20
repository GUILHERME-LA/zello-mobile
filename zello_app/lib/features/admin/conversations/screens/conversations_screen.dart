import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              title: 'Conversas',
              subtitle: 'Gerencie conversas com pacientes',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(conversationsProvider);
                  await ref.read(conversationsProvider.future);
                },
                child: conversationsAsync.when(
                  data: (conversations) {
                    if (conversations.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          EmptyState(
                            icon: LucideIcons.messageCircle,
                            title: 'Nenhuma conversa ativa',
                            subtitle:
                                'Quando um paciente iniciar uma conversa, aparecera aqui.',
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ConversationCard(
                          conversation: conversations[index],
                          onTap: () => context
                              .go('/admin/conversations/${conversations[index].id}'),
                        ),
                      ),
                    );
                  },
                  loading: () => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: 5,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: SkeletonCard(),
                    ),
                  ),
                  error: (e, _) => ErrorState(
                    message: 'Nao foi possivel carregar as conversas.',
                    technicalDetails: '$e',
                    onRetry: () => ref.invalidate(conversationsProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;
  const _ConversationCard({required this.conversation, this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeAgo = Formatters.formatRelativeTime(conversation.lastMessageTime);
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Stack(
            children: [
              ZelloAvatar(name: conversation.userName, size: 48),
              if (conversation.unreadCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.alertTriangle,
                          size: 8, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(conversation.userName,
                        style: TextStyle(
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 14,
                            color: const Color(0xFF1A1A2E))),
                    Text(timeAgo,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(conversation.lastMessage,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ),
                    if (conversation.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${conversation.unreadCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
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
