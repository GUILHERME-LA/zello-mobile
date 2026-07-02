import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <Message>[
    Message(
      id: '1',
      conversationId: 'c1',
      content: 'Olá! Sou a Dra. Olga, sua assistente de saúde. Como posso te ajudar hoje?',
      sender: MessageSender.agent,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: MessageType.text,
    ),
  ];

  bool _isMedical = true;

  void _sendMessage(String content) {
    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: 'c1',
        content: content,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ));
    });

    // Simulate agent response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            conversationId: 'c1',
            content: 'Obrigada pela sua mensagem. Estou analisando suas informações...',
            sender: MessageSender.agent,
            agentType: _isMedical ? 'medico' : 'psicologo',
            timestamp: DateTime.now(),
            type: MessageType.text,
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Dra. Olga', style: TextStyle(fontSize: 16)),
            ZelloBadge(
              label: _isMedical ? 'Médico' : 'Psicólogo',
              variant: _isMedical
                  ? ZelloBadgeVariant.medical
                  : ZelloBadgeVariant.psychology,
              fontSize: 10,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<bool>(
            onSelected: (value) {
              setState(() => _isMedical = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: true,
                child: Text('Módulo Médico'),
              ),
              const PopupMenuItem(
                value: false,
                child: Text('Módulo Psicológico'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: ZelloColors.warning.withAlpha(30),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: ZelloColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta é uma assistente de IA. Não substitui consulta médica.',
                    style: TextStyle(fontSize: 11, color: ZelloColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          ChatInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}
