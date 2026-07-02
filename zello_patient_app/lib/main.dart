import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';
import 'core/router.dart';

void main() {
  runApp(const PatientApp());
}

class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zello Saúde - Paciente',
      debugShowCheckedModeBanner: false,
      theme: ZelloTheme.lightTheme(),
      routerConfig: patientRouter,
    );
  }
}
