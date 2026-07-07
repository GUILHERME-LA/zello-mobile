import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _autoReply = true;
  bool _notifications = true;
  bool _analytics = false;

  void _showInfo(String title, String content) {
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
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            Text(content,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
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
              const SectionHeader(title: 'Geral'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedCard(
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        LucideIcons.sparkles,
                        'Resposta Automática',
                        'Agente responde automaticamente',
                        _autoReply,
                        (v) => setState(() => _autoReply = v),
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        LucideIcons.bell,
                        'Notificações',
                        'Alertas de novas conversas',
                        _notifications,
                        (v) => setState(() => _notifications = v),
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        LucideIcons.barChart,
                        'Analytics',
                        'Relatórios de uso e desempenho',
                        _analytics,
                        (v) => setState(() => _analytics = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SectionHeader(title: 'Integrações'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildIntegrationTile(
                      LucideIcons.gitBranch,
                      'Webhook n8n',
                      ApiEndpoints.baseUrl,
                      () => _showInfo('Webhook n8n',
                          'Endpoint configurado para integração\n\n'
                          '${ApiEndpoints.baseUrl}\n\n'
                          'Status: Conectado'),
                    ),
                    const SizedBox(height: 12),
                    _buildIntegrationTile(
                      LucideIcons.code,
                      'API Key',
                      '••••••••••••••••',
                      () => _showInfo('API Key',
                          'Chave de API para integração externa\n\n'
                          'Status: Ativa\nCriada: 01/01/2026'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Sistema'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInfoTile(LucideIcons.database, 'Banco de Dados',
                        'PostgreSQL • Conectado'),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                        LucideIcons.cloud, 'Servidor', 'Online • v2.4.1'),
                    const SizedBox(height: 12),
                    _buildInfoTile(LucideIcons.shield, 'SSL/TLS', 'Ativo'),
                    const SizedBox(height: 12),
                    _buildIntegrationTile(
                      LucideIcons.lock,
                      'Alterar Senha',
                      '',
                      () => context.push('/change-password'),
                    ),
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
                      Icon(LucideIcons.logOut, size: 18, color: Color(0xFFEF4444)),
                      SizedBox(width: 8),
                      Text('Sair da Conta',
                          style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configurações',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20)),
              SizedBox(height: 2),
              Text('Gerenciar sistema',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: SwitchListTile(
        secondary: Icon(icon, size: 22, color: const Color(0xFF1565C0)),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1A1A2E))),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildIntegrationTile(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF1565C0)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return AnimatedCard(
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1565C0)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
