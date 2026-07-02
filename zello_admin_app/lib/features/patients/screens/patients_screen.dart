import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: ZelloAvatar(name: 'Paciente ${index + 1}'),
              title: Text('Paciente ${index + 1}'),
              subtitle: Text('(11) 9${index}000-000$index', style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
