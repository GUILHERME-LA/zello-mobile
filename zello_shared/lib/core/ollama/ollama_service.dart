import 'package:dio/dio.dart';
import '../../models/message.dart';

class OllamaConfig {
  final String baseUrl;
  final String model;

  const OllamaConfig({
    this.baseUrl = 'http://localhost:11434/v1',
    this.model = 'llama3.2',
  });
}

class OllamaService {
  final Dio _dio;
  final OllamaConfig _config;

  OllamaService({
    Dio? dio,
    OllamaConfig? config,
  })  : _dio = dio ?? Dio(),
        _config = config ?? const OllamaConfig();

  Future<String> chatCompletion({
    required String userMessage,
    required List<Message> history,
    String? systemPrompt,
  }) async {
    final messages = <Map<String, String>>[
      if (systemPrompt != null)
        {'role': 'system', 'content': systemPrompt},
      ...history
          .where((m) => m.content.isNotEmpty)
          .map((m) => {
                'role': m.sender == MessageSender.user ? 'user' : 'assistant',
                'content': m.content,
              }),
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await _dio.post(
        '${_config.baseUrl}/chat/completions',
        data: {
          'model': _config.model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        },
      );

      final choices = response.data['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final content = choices[0]['message']['content'] as String?;
        return content ?? 'Desculpe, não consegui processar sua mensagem.';
      }
      return 'Desculpe, não consegui processar sua mensagem.';
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?['message'] as String? ??
          e.message ??
          'Erro de conexão com o servidor local';
      throw Exception(msg);
    }
  }
}
