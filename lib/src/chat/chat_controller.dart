import 'package:flutter/foundation.dart';

import '../character/character_state.dart';
import 'character_engine.dart';
import 'chat_message.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required this.engine,
    required this.characterState,
    this.replyTimeout = const Duration(seconds: 30),
  }) {
    _messages.add(
      ChatMessage(
        id: 'welcome',
        role: ChatRole.character,
        content: '你好呀，我是你的 AI 陪伴角色。今天过得怎么样？',
        createdAt: DateTime.now(),
      ),
    );
  }

  final CharacterEngine engine;
  final ValueNotifier<CharacterState> characterState;
  final Duration replyTimeout;
  final List<ChatMessage> _messages = [];
  int _nextId = 0;
  bool _isReplying = false;
  bool _isDisposed = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isReplying => _isReplying;

  Future<void> send(String rawText) async {
    if (_isDisposed) return;
    final text = rawText.trim();
    if (text.isEmpty || _isReplying) return;

    final now = DateTime.now();
    _messages.add(_newMessage(ChatRole.user, text, now));
    characterState.value = characterState.value.afterUserMessage(text, at: now);
    _isReplying = true;
    final reply = _newMessage(ChatRole.character, '', now);
    _messages.add(reply);
    notifyListeners();

    try {
      final history = List<ChatMessage>.unmodifiable(
        _messages.where((message) => message.content.isNotEmpty).toList(),
      );
      await for (final chunk
          in engine
              .streamReply(history: history, state: characterState.value)
              .timeout(replyTimeout)) {
        if (_isDisposed) return;
        final index = _messages.indexWhere((message) => message.id == reply.id);
        if (index == -1) break;
        _messages[index] = _messages[index].copyWith(
          content: _messages[index].content + chunk,
        );
        notifyListeners();
      }
      final index = _messages.indexWhere((message) => message.id == reply.id);
      if (index != -1 && _messages[index].content.isEmpty) {
        _messages[index] = reply.copyWith(content: '我在听。可以再说一点吗？');
      }
    } catch (_) {
      final index = _messages.indexWhere((message) => message.id == reply.id);
      if (index != -1) {
        _messages[index] = reply.copyWith(
          content: '刚才没能接住这句话。你可以再试一次，或者晚一点再聊。',
        );
      }
    } finally {
      _isReplying = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  ChatMessage _newMessage(ChatRole role, String content, DateTime createdAt) {
    _nextId++;
    return ChatMessage(
      id: '${createdAt.microsecondsSinceEpoch}-$_nextId',
      role: role,
      content: content,
      createdAt: createdAt,
    );
  }
}
