import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MedicationCard(
            name: 'Losartana 50mg',
            dosage: '1 comprimido ao dia',
            time: '08:00',
            status: MedicationStatus.pending,
          ),
          _MedicationCard(
            name: 'Omeprazol 20mg',
            dosage: '1 cápsula em jejum',
            time: '07:00',
            status: MedicationStatus.taken,
          ),
          _MedicationCard(
            name: 'Metformina 850mg',
            dosage: '1 comprimido após almoço',
            time: '13:00',
            status: MedicationStatus.pending,
          ),
        ],
      ),
    );
  }
}

enum MedicationStatus { taken, pending, missed }

class _MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final MedicationStatus status;

  const _MedicationCard({
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      MedicationStatus.taken => ZelloColors.accent,
      MedicationStatus.pending => ZelloColors.warning,
      MedicationStatus.missed => ZelloColors.danger,
    };
    final statusLabel = switch (status) {
      MedicationStatus.taken => 'Tomado',
      MedicationStatus.pending => 'Pendente',
      MedicationStatus.missed => 'Perdido',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.medication, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(dosage, style: const TextStyle(fontSize: 12, color: ZelloColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('$time - $statusLabel',
                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (status == MedicationStatus.pending)
              TextButton(
                onPressed: () {},
                child: const Text('Confirmar', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
