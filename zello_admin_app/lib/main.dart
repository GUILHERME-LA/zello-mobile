import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';
import 'core/router.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zello Saúde - Admin',
      debugShowCheckedModeBanner: false,
      theme: ZelloTheme.lightTheme(),
      routerConfig: adminRouter,
    );
  }
}
