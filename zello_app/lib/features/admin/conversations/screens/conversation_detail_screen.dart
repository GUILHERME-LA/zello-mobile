import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

import 'package:zello_shared/providers/conversation_messages_provider.dart';

class ConversationDetailScreen extends ConsumerStatefulWidget {
  final String convKey;
  final String? userName;
  final String? userPhone;

  const ConversationDetailScreen({
    super.key,
    required this.convKey,
    this.userName,
    this.userPhone,
  });

  @override
  ConsumerState<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState
    extends ConsumerState<ConversationDetailScreen> {
  final _scrollController = ScrollController();
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _generate() async {
    final reply =
        await ref.read(conversationMessagesProvider(widget.convKey).notifier).generateAgentReply();
    if (reply != null && reply.isNotEmpty) {
      _replyController.text = reply;
      _scrollToBottom();
    } else {
      final err = ref.read(conversationMessagesProvider(widget.convKey)).error;
      if (err != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar resposta: $err')),
        );
      }
    }
  }

  Future<void> _send() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    _replyController.clear();
    await ref
        .read(conversationMessagesProvider(widget.convKey).notifier)
        .sendAgentMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationMessagesProvider(widget.convKey));
    final messages = state.messages;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName?.isNotEmpty == true ? widget.userName! : 'Conversa'),
            if (widget.userPhone != null && widget.userPhone!.isNotEmpty)
              Text(
                widget.userPhone!,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(
                        child: Text('Nenhuma mensagem nesta conversa ainda.'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) => _bubble(messages[i]),
                      ),
          ),
          if (state.error != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFFEE2E2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                state.error!,
                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
              ),
            ),
          _composer(state.isGenerating, state.isSending),
        ],
      ),
    );
  }

  Widget _bubble(Message msg) {
    final isAgent = msg.sender == MessageSender.agent;
    return Align(
      alignment: isAgent ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isAgent ? const Color(0xFFE3F2FD) : const Color(0xFF1565C0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg.content,
          style: TextStyle(
            color: isAgent ? const Color(0xFF1A1A2E) : Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _composer(bool isGenerating, bool isSending) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isGenerating ? null : _generate,
                  icon: isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.sparkles, size: 16),
                  label: const Text('Gerar resposta com IA'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Escreva ou gere uma resposta...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF1565C0),
                child: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : IconButton(
                        onPressed: _send,
                        icon: const Icon(LucideIcons.send, color: Colors.white),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
