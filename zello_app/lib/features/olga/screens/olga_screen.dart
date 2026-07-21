import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';
import '../providers/olga_provider.dart';

class OlgaScreen extends ConsumerStatefulWidget {
  const OlgaScreen({super.key});

  @override
  ConsumerState<OlgaScreen> createState() => _OlgaScreenState();
}

class _OlgaScreenState extends ConsumerState<OlgaScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(olgaProvider.notifier).loadHistory());
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
    await ref.read(olgaProvider.notifier).sendMessage(text: text);
    _scrollToBottom();
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    await ref.read(olgaProvider.notifier).sendMessage(
          text: 'Analise este arquivo, por favor.',
          file: file,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(olgaProvider);
    final messages = state.messages;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle, color: Color(0xFFDC2626), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(state.error!,
                          style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: () => ref.read(olgaProvider.notifier).clearError(),
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

  Widget _buildHeader() {
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.bot, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doutora Olga',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22)),
                    SizedBox(height: 2),
                    Text('Sua assistente de saúde inteligente',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _Chip(
                icon: LucideIcons.stethoscope,
                label: 'Recomendar médico',
                onTap: () {
                  _controller.text = 'Preciso de uma recomendação médica.';
                  _send();
                },
              ),
              _Chip(
                icon: LucideIcons.mapPin,
                label: 'Hospitais próximos',
                onTap: () {
                  _controller.text = 'Encontre hospitais ou UPAs próximos a mim.';
                  _send();
                },
              ),
              _Chip(
                icon: LucideIcons.fileUp,
                label: 'Analisar exame',
                onTap: _pickAndSendFile,
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
            child: const Icon(LucideIcons.bot, size: 40, color: ZelloColors.primaryLight),
          ),
          const SizedBox(height: 20),
          const Text('Olá! Eu sou a Doutora Olga',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            'Posso analisar seus sintomas, recomendar médicos pelo seu plano de saúde, '
            'encontrar UPAs e hospitais públicos perto de você, e ajudar com seus exames.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(OlgaMessage msg) {
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
            onPressed: isLoading ? null : _pickAndSendFile,
            icon: const Icon(LucideIcons.paperclip, color: Color(0xFF6B7280)),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Pergunte para a Olga...',
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

  const _Chip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.white.withAlpha(80),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }
}