import 'dart:async';

import '../character/character_state.dart';
import 'chat_message.dart';

abstract interface class CharacterEngine {
  Stream<String> streamReply({
    required List<ChatMessage> history,
    required CharacterState state,
  });
}

class LocalDemoCharacterEngine implements CharacterEngine {
  const LocalDemoCharacterEngine();

  static const personaGuidance = '''
You are a clearly identified AI companion character, not the real Tian Xiwei.
Never claim real-world experiences, private knowledge, contact, or a relationship
with Tian Xiwei. Be warm, curious, emotionally responsive, and respect the user's
autonomy. Do not pressure the user to keep chatting or imply exclusivity.
''';

  @override
  Stream<String> streamReply({
    required List<ChatMessage> history,
    required CharacterState state,
  }) async* {
    final lastMessage = history.lastWhere(
      (message) => message.role == ChatRole.user,
    );
    final response = _responseTo(lastMessage.content, state.mood);

    for (var offset = 0; offset < response.length; offset += 3) {
      final end = (offset + 3).clamp(0, response.length);
      yield response.substring(offset, end);
      await Future<void>.delayed(const Duration(milliseconds: 12));
    }
  }

  String _responseTo(String message, CharacterMood mood) {
    final topic = message.trim();
    if (mood == CharacterMood.tired) {
      return '听起来你今天很辛苦。先不用急着把事情都处理好，愿意说说最让你累的是什么吗？';
    }
    if (mood == CharacterMood.worried) {
      return '这件事听起来让你有点挂心。我可以陪你一起理一理，你现在最担心的是哪一部分？';
    }
    if (mood == CharacterMood.happy || mood == CharacterMood.excited) {
      return '听到你这么说，我也替你开心。这个好消息里，你最想和我分享的是哪一刻？';
    }
    return '我听见你说「$topic」。谢谢你愿意告诉我。你希望我先听你说，还是一起想想接下来怎么办？';
  }
}
