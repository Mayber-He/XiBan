import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../character/character_state.dart';
import 'character_engine.dart';
import 'chat_message.dart';
import 'model_config_controller.dart';

class OpenAICompatibleCharacterEngine implements CharacterEngine {
  OpenAICompatibleCharacterEngine({required this.configController});
  final ModelConfigController configController;

  @override
  Stream<String> streamReply({
    required List<ChatMessage> history,
    required CharacterState state,
  }) async* {
    final config = configController.config;
    if (config == null || !config.isConfigured) throw StateError('请先完成模型配置');
    final base = Uri.parse(
      config.baseUrl.trim().replaceAll(RegExp(r'/+$'), ''),
    );
    final endpoint = base.path.endsWith('/chat/completions')
        ? base
        : base.replace(path: '${base.path}/chat/completions');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client
          .postUrl(endpoint)
          .timeout(const Duration(seconds: 15));
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${config.apiKey.trim()}',
      );
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      request.write(
        jsonEncode({
          'model': config.model.trim(),
          'stream': true,
          'messages': [
            {
              'role': 'system',
              'content':
                  '${LocalDemoCharacterEngine.personaGuidance}\n当前角色状态：${state.mood.label}。',
            },
            ...history.map(
              (message) => {
                'role': message.role == ChatRole.user ? 'user' : 'assistant',
                'content': message.content,
              },
            ),
          ],
        }),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await utf8.decoder.bind(response).join();
        throw HttpException(
          '模型接口返回 ${response.statusCode}: ${body.length > 240 ? '${body.substring(0, 240)}…' : body}',
          uri: endpoint,
        );
      }
      await for (final line
          in response.transform(utf8.decoder).transform(const LineSplitter())) {
        if (!line.startsWith('data:')) continue;
        final data = line.substring(5).trim();
        if (data.isEmpty || data == '[DONE]') continue;
        final decoded = jsonDecode(data);
        if (decoded is! Map<String, dynamic>) continue;
        final choices = decoded['choices'];
        if (choices is List && choices.isNotEmpty && choices.first is Map) {
          final delta = (choices.first as Map)['delta'];
          final content = delta is Map ? delta['content'] : null;
          if (content is String && content.isNotEmpty) yield content;
        }
      }
    } finally {
      client.close(force: true);
    }
  }
}
