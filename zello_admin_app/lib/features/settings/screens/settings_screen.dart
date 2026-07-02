import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _autoReply = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Geral', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Resposta Automática'),
                  subtitle: const Text('Agente responde automaticamente'),
                  value: _autoReply,
                  onChanged: (v) => setState(() => _autoReply = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notificações'),
                  subtitle: const Text('Alertas de novas conversas'),
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Integrações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.webhook, color: ZelloColors.primary),
              title: const Text('Webhook n8n'),
              subtitle: const Text(ApiEndpoints.baseUrl, style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
