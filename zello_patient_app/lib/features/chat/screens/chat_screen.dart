import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(messagesProvider.notifier).loadMessages('c1'));
  }

  void _sendMessage(String content) {
    ref.read(messagesProvider.notifier).sendMessage(content);
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
              color: const Color(0xFFFEF3C7),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Assistente de IA. Não substitui consulta médica.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ),
                ],
              ),
            ),
            if (state.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      MessageBubble(message: messages[index]),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
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
                    Container(width: 6, height: 6,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
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
                children: [Icon(Icons.medical_services, size: 18, color: Color(0xFF1565C0)), SizedBox(width: 10), Text('Módulo Médico')],
              )),
              const PopupMenuItem(value: false, child: Row(
                children: [Icon(Icons.psychology, size: 18, color: Color(0xFF8B5CF6)), SizedBox(width: 10), Text('Módulo Psicológico')],
              )),
            ],
          ),
        ],
      ),
    );
  }
}
