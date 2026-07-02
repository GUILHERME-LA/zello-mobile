import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';

class AgentsScreen extends StatefulWidget {
  const AgentsScreen({super.key});

  @override
  State<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends State<AgentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agentes'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 4,
        itemBuilder: (context, index) {
          final agents = ['Dra. Olga', 'Dr. Carlos', 'Psicóloga Ana', 'Dra. Beatriz'];
          final types = ['Médico', 'Médico', 'Psicólogo', 'Médico'];
          return Card(
            child: ListTile(
              leading: ZelloAvatar(name: agents[index], size: 40),
              title: Text(agents[index]),
              subtitle: Row(
                children: [
                  ZelloBadge(label: types[index], variant: types[index] == 'Médico' ? ZelloBadgeVariant.medical : ZelloBadgeVariant.psychology, fontSize: 10),
                  const SizedBox(width: 8),
                  ZelloBadge(label: 'Online', variant: ZelloBadgeVariant.success, fontSize: 10),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
