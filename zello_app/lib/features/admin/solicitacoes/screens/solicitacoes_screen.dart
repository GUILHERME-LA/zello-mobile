import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class SolicitacoesScreen extends StatelessWidget {
  const SolicitacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicita\u00e7\u00f5es'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: EmptyState(
          icon: LucideIcons.inbox,
          title: 'Nenhuma solicita\u00e7\u00e7\u00e3o',
          subtitle: 'As solicita\u00e7\u00f5es dos pacientes aparecer\u00e3o aqui.',
        ),
      ),
    );
  }
}