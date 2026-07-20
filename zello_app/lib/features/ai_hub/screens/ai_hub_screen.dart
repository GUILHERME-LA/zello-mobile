import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

import '../providers/ai_hub_provider.dart';

class AiHubScreen extends ConsumerStatefulWidget {
  const AiHubScreen({super.key});

  @override
  ConsumerState<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends ConsumerState<AiHubScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(aiHubProvider.notifier).loadHistory());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(aiHubProvider.notifier).sendMessage(
          text: text,
          kind: 'qa',
        );
    _scrollToBottom();
  }

  Future<void> _pickAndSendExam() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    await ref.read(aiHubProvider.notifier).sendMessage(
          text: 'Analise este exame, por favor.',
          file: file,
          kind: 'exam',
        );
    _scrollToBottom();
  }

  Future<void> _analyzePlan() async {
    await ref.read(aiHubProvider.notifier).analyzePlan();
    _scrollToBottom();
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final history = ref.watch(aiHubProvider).history;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scroll) => Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Histórico de análises',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              Expanded(
                child: history.isEmpty
                    ? const Center(
                        child: Text('Nenhuma análise salva ainda.',
                            style: TextStyle(color: Color(0xFF6B7280))))
                    : ListView.separated(
                        controller: scroll,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final rec = history[i];
                          return ListTile(
                            onTap: () => _showRecord(ctx, rec),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            leading: Icon(
                              rec.kind == 'exam'
                                  ? LucideIcons.fileText
                                  : rec.kind == 'plan'
                                      ? LucideIcons.heartPulse
                                      : LucideIcons.messageCircle,
                              color: ZelloColors.primaryLight,
                            ),
                            title: Text(rec.kindLabel),
                            subtitle: Text(
                              rec.inputText.isEmpty
                                  ? '(sem texto)'
                                  : (rec.inputText.length > 50
                                      ? '${rec.inputText.substring(0, 50)}…'
                                      : rec.inputText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '${rec.createdAt.day}/${rec.createdAt.month}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF9CA3AF)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecord(BuildContext ctx, AiHubRecord rec) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scroll) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: ListView(
            controller: scroll,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Chip(
                label: Text(rec.kindLabel),
                backgroundColor: ZelloColors.primaryLight.withAlpha(25),
                labelStyle:
                    TextStyle(color: ZelloColors.primaryLight, fontSize: 12),
              ),
              const SizedBox(height: 12),
              const Text('Pergunta / envio',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(rec.inputText.isEmpty ? '(sem texto)' : rec.inputText),
              const SizedBox(height: 16),
              const Text('Resposta da IA',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(rec.aiReply),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiHubProvider);
    final messages = state.messages;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state),
            Expanded(
              child: messages.isEmpty
                  ? _buildWelcome()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => _buildBubble(messages[i]),
                    ),
            ),
            if (state.error != null)
              Container(
                width: double.infinity,
                color: const Color(0xFFFEE2E2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle,
                        color: Color(0xFFDC2626), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(state.error!,
                          style:
                              const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(aiHubProvider.notifier).clearError(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            _buildComposer(state.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AiHubState state) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Colors.white, size: 28),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Central de IA',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22)),
                    SizedBox(height: 2),
                    Text('Perguntas, exames e seu plano',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                onPressed: state.isLoading ? null : _showHistory,
                icon: const Icon(LucideIcons.history, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _Chip(
                icon: LucideIcons.heartPulse,
                label: 'Analisar meu plano',
                onTap: state.isLoading ? null : _analyzePlan,
              ),
              _Chip(
                icon: LucideIcons.fileUp,
                label: 'Enviar exame',
                onTap: state.isLoading ? null : _pickAndSendExam,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZelloColors.primaryLight.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.sparkles,
                size: 40, color: ZelloColors.primaryLight),
          ),
          const SizedBox(height: 20),
          const Text('Como posso ajudar?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            'Tire dúvidas sobre os recursos do app, envie um exame '
            'para análise ou peça para analisarmos o seu plano de saúde.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(AiMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: msg.isUser
              ? ZelloColors.primaryLight
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg.content,
          style: TextStyle(
            color: msg.isUser ? Colors.white : const Color(0xFF1A1A2E),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(bool isLoading) {
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
      child: Row(
        children: [
          IconButton(
            onPressed: isLoading ? null : _pickAndSendExam,
            icon: const Icon(LucideIcons.paperclip,
                color: Color(0xFF6B7280)),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Pergunte algo...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: ZelloColors.primaryLight,
            child: isLoading
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
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _Chip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.white.withAlpha(30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }
}
