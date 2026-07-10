import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zello_shared/zello_shared.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  bool _isMedical = true;
  RealtimeChannel? _realtimeChannel;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(messagesProvider.notifier).loadMessages('c1'));
    _subscribeRealTime();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _subscribeRealTime() {
    _realtimeChannel = Supabase.instance.client
        .channel('chat-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final data = payload.newRecord;
            if (data['conversation_id'] != 'c1') return;
            final message = Message(
              id: data['id'].toString(),
              conversationId: data['conversation_id'] as String,
              content: data['content'] as String,
              sender: data['sender'] == 'agent'
                  ? MessageSender.agent
                  : MessageSender.user,
              timestamp: DateTime.parse(data['created_at'] as String),
            );
            ref.read(messagesProvider.notifier).addMessage(message);
            _scrollToBottom();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String content) {
    ref.read(messagesProvider.notifier).sendMessage(content);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final messages = state.messages;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: ZelloColors.warningLight,
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: ZelloColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Assistente de IA. Não substitui consulta médica.',
                        style: TextStyle(fontSize: 11, color: ZelloColors.textSecondary)),
                  ),
                ],
              ),
            ),
            if (state.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: messages.length + (state.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const _TypingIndicator();
                    }
                    return MessageBubble(message: messages[index]);
                  },
                ),
              ),
            ChatInput(onSend: _sendMessage),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        gradient: ZelloGradients.header,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybeOf(context)?.pop(),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withAlpha(38), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Agente de Saúde',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _PulseDot(color: ZelloColors.online),
                    const SizedBox(width: 6),
                    Text('Online',
                        style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 12)),
                    const SizedBox(width: 12),
                    ZelloBadge(
                      label: _isMedical ? 'Médico' : 'Psicólogo',
                      variant: _isMedical ? ZelloBadgeVariant.medical : ZelloBadgeVariant.psychology,
                      fontSize: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<bool>(
            icon: Icon(Icons.more_vert, color: Colors.white.withAlpha(179)),
            onSelected: (value) => setState(() => _isMedical = value),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: true, child: Row(
                children: [Icon(Icons.medical_services, size: 18, color: ZelloColors.medical), SizedBox(width: 10), Text('Módulo Médico')],
              )),
              const PopupMenuItem(value: false, child: Row(
                children: [Icon(Icons.psychology, size: 18, color: ZelloColors.psychology), SizedBox(width: 10), Text('Módulo Psicológico')],
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha((_pulse.value * 80).round()),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final tween = Tween<double>(begin: 0.3, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  i * 0.2,
                  i * 0.2 + 0.5,
                  curve: Curves.easeInOut,
                ),
              ),
            );
            return AnimatedBuilder(
              animation: tween,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(
                        (255 * tween.value).round(),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
