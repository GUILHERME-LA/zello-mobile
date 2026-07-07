import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _medicationReminders = true;
  bool _shareData = false;

  void _showInfo(String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              const SectionHeader(title: 'Preferências'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedCard(
                  child: Column(
                    children: [
                      _buildSwitchTile(Icons.notifications_outlined, 'Notificações', 'Alertas de medicamentos e consultas',
                          _notifications, (v) => setState(() => _notifications = v)),
                      const Divider(height: 1),
                      _buildSwitchTile(Icons.medication_outlined, 'Lembretes', 'Alertas para horários de medicação',
                          _medicationReminders, (v) => setState(() => _medicationReminders = v)),
                      const Divider(height: 1),
                      _buildSwitchTile(Icons.share_outlined, 'Compartilhar Dados', 'Permitir uso anônimo para melhoria',
                          _shareData, (v) => setState(() => _shareData = v)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SectionHeader(title: 'Informações'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.info_outline, 'Sobre o App', 'Versão 1.0.0',
                        () => _showInfo('Sobre o App', 'Zello Saúde v1.0.0\n\nPlataforma de assistência inteligente.')),
                    const SizedBox(height: 12),
                    _buildInfoTile(Icons.description_outlined, 'Termos de Uso', '',
                        () => _showInfo('Termos de Uso', 'Consulte nossa política de privacidade.')),
                    const SizedBox(height: 12),
                    _buildInfoTile(Icons.privacy_tip_outlined, 'Privacidade', '',
                        () => _showInfo('Privacidade', 'Seus dados estão protegidos conforme a LGPD.')),
                    const SizedBox(height: 12),
                    _buildInfoTile(Icons.lock_outline, 'Alterar Senha', '',
                        () => context.push('/change-password')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, size: 18, color: Color(0xFFEF4444)),
                      SizedBox(width: 8),
                      Text('Sair da Conta',
                          style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withAlpha(38), borderRadius: BorderRadius.circular(14)),
            child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop())),
          const SizedBox(width: 14),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Configurações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
            SizedBox(height: 2),
            Text('Personalize sua experiência', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: SwitchListTile(
        secondary: Icon(icon, size: 22, color: const Color(0xFF1565C0)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        value: value, onChanged: onChanged, activeColor: const Color(0xFF1565C0),
      ),
    );
  }

  static Widget _buildInfoTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1565C0)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ])),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
