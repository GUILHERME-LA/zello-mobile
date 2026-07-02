import 'package:flutter/material.dart';

class HospitalsScreen extends StatelessWidget {
  const HospitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospitais Próximos')),
      body: const Center(child: Text('Hospitais - Em construção')),
    );
  }
}
