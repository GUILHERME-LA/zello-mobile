import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: ZelloAvatar(name: 'Paciente ${index + 1}'),
              title: Text('Paciente ${index + 1}'),
              subtitle: Text('Última mensagem recebida...', style: const TextStyle(fontSize: 12)),
              trailing: ZelloBadge(label: index % 3 == 0 ? 'Urgente' : 'Normal', variant: index % 3 == 0 ? ZelloBadgeVariant.warning : ZelloBadgeVariant.default$),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
