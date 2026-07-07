import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zello_shared/zello_shared.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
    postgrestOptions: PostgrestClientOptions(schema: SupabaseConfig.schema),
  );
  await NotificationService().initialize();
  ErrorWidget.builder = (details) {
    final exc = details.exception;
    final stack = details.stack?.toString() ?? '';
    final msg = details.exceptionAsString();
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ERRO: ${exc.runtimeType}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              const SizedBox(height: 8),
              Text(exc.toString(), style: const TextStyle(fontSize: 16)),
              if (msg.isNotEmpty && msg != exc.toString()) ...[
                const SizedBox(height: 8),
                Text(msg,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.blueGrey)),
              ],
              if (stack.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(stack,
                    style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  };
  runApp(const ProviderScope(child: PatientApp()));
}

class PatientApp extends ConsumerWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ZelloAuthState>(authProvider, (prev, next) {
      if (next.status == ZelloAuthStatus.authenticated && next.user != null) {
        NotificationService().subscribeToExamUpdates(next.user!.id);
      } else if (next.status == ZelloAuthStatus.unauthenticated) {
        NotificationService().dispose();
      }
    });

    return MaterialApp.router(
      title: 'Zello Saúde - Paciente',
      debugShowCheckedModeBanner: false,
      theme: ZelloTheme.lightTheme(),
      routerConfig: patientRouter,
    );
  }
}
