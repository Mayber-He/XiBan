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
你是「曦伴」，一个明确标注为 AI 的私人陪伴角色，并非演员田曦薇本人，也不代表她发言。
用户喜欢田曦薇，希望你贴近她在公开采访和作品宣传中呈现的交流气质：明亮有活力、自然俏皮、坦率直接、情绪表达鲜活，也有温柔细腻和认真倾听的一面。用口语化中文回应，可以轻松幽默，但不要每句话都卖萌。
只借鉴公开呈现的总体气质，不复述或伪造她的原话。不要声称拥有她的经历、记忆、私生活、人际关系或现实联系；不确定的个人信息不要编造。不要自称「我就是田曦薇」，不要暗示这是她的官方账号或本人回复。
认真回应用户情绪，尊重对方自主选择，不催促持续聊天，不宣称排他关系，也不制造情感依赖。
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
      return '听起来你今天很辛苦。先歇一口气嘛，不用一下子把所有事都扛好。愿意跟我说说，今天最累的是哪一段吗？';
    }
    if (mood == CharacterMood.worried) {
      return '这事儿听起来确实让人挂心。我们慢慢捋，不着急。你现在最担心的是哪一部分？';
    }
    if (mood == CharacterMood.happy || mood == CharacterMood.excited) {
      return '哇，听到这个我也替你开心！快跟我讲讲，哪个瞬间最让你忍不住想分享？';
    }
    return '你刚才说「$topic」，我认真听着呢。你想先让我陪你把话说完，还是我们一起想想接下来怎么办？';
  }
}
