import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';
import 'home_screen.dart';

class HomeGateway extends ConsumerWidget {
  const HomeGateway({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anamnesisAsync = ref.watch(currentAnamnesisProvider);

    return anamnesisAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erro: $e')),
      ),
      data: (anamnesis) {
        if (anamnesis == null || !anamnesis.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/anamnesis');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const HomeScreen();
      },
    );
  }
}
