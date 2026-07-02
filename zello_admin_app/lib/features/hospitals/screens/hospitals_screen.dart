import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';

class AdminHospitalsScreen extends StatefulWidget {
  const AdminHospitalsScreen({super.key});

  @override
  State<AdminHospitalsScreen> createState() => _AdminHospitalsScreenState();
}

class _AdminHospitalsScreenState extends State<AdminHospitalsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospitais'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 5,
        itemBuilder: (context, index) {
          final hospitals = ['Hospital São Lucas', 'Hospital Albert Einstein', 'Hospital Sírio-Libanês', 'Hospital das Clínicas', 'Hospital Santa Catarina'];
          return Card(
            child: ListTile(
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: ZelloColors.primary.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.local_hospital, color: ZelloColors.primary),
              ),
              title: Text(hospitals[index]),
              subtitle: Text('São Paulo - SP', style: TextStyle(fontSize: 12, color: ZelloColors.textSecondary)),
              trailing: ZelloBadge(label: 'Ativo', variant: ZelloBadgeVariant.success),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
