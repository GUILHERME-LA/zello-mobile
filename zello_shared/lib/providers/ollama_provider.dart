import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ollama/ollama_service.dart';

final ollamaConfigProvider = Provider<OllamaConfig>((ref) {
  return const OllamaConfig();
});

final ollamaServiceProvider = Provider<OllamaService>((ref) {
  final config = ref.watch(ollamaConfigProvider);
  return OllamaService(config: config);
});
