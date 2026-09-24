import 'package:xiban_companion/src/character/character_state.dart';
import 'package:xiban_companion/src/chat/character_engine.dart';
import 'package:xiban_companion/src/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xiban_companion/src/companion_app.dart';

void main() {
  test('角色状态可序列化，并保留情绪、数值和当前话题', () {
    final original = CharacterState(
      mood: CharacterMood.happy,
      energy: 88,
      affection: 42,
      currentOutfitId: 'weekend',
      lastInteractionAt: DateTime.utc(2026, 9, 24, 8),
      currentTopic: '周末计划',
    );

    final restored = CharacterState.fromJson(original.toJson());

    expect(restored.mood, CharacterMood.happy);
    expect(restored.energy, 88);
    expect(restored.affection, 42);
    expect(restored.currentOutfitId, 'weekend');
    expect(restored.currentTopic, '周末计划');
    expect(restored.lastInteractionAt, original.lastInteractionAt?.toLocal());
  });

  test('无效状态数据回退到安全默认值并限制数值范围', () {
    final state = CharacterState.fromJson({
      'mood': 'unknown',
      'energy': 300,
      'affection': -10,
      'currentOutfitId': '',
      'lastInteractionAt': 'not-a-date',
      'currentTopic': 42,
    });

    expect(state.mood, CharacterMood.calm);
    expect(state.energy, 100);
    expect(state.affection, 0);
    expect(state.currentOutfitId, 'daily');
    expect(state.lastInteractionAt, isNull);
    expect(state.currentTopic, isNull);
  });

  test('用户表达心情后角色状态随对话更新', () {
    final initial = CharacterState.initial(now: DateTime.utc(2026, 9, 24));
    final updated = initial.afterUserMessage(
      '今天有点累，也有些担心',
      at: DateTime.utc(2026, 9, 24, 10),
    );

    expect(updated.mood, CharacterMood.tired);
    expect(updated.energy, initial.energy - 2);
    expect(updated.affection, initial.affection + 1);
    expect(updated.currentTopic, '今天有点累，也有些担心');
    expect(updated.lastInteractionAt, DateTime.utc(2026, 9, 24, 10));
  });

  test('聊天控制器使用可替换引擎并保留 AI 身份边界', () async {
    final state = ValueNotifier(CharacterState.initial());
    final controller = ChatController(
      engine: const LocalDemoCharacterEngine(),
      characterState: state,
    );
    addTearDown(controller.dispose);
    addTearDown(state.dispose);

    await controller.send('今天有点累');

    expect(controller.messages, hasLength(3));
    expect(controller.messages[1].content, '今天有点累');
    expect(controller.messages[2].content, contains('很辛苦'));
    expect(controller.isReplying, isFalse);
    expect(state.value.mood, CharacterMood.tired);
  });

  testWidgets('首页展示清晰的 AI 身份说明与聊天入口', (tester) async {
    await tester.pumpWidget(const CompanionApp());

    expect(find.text('嗨，欢迎回来'), findsOneWidget);
    expect(find.text('AI 角色 · 非田曦薇本人'), findsOneWidget);
    expect(find.text('她现在平静'), findsOneWidget);
    expect(find.text('精力  76'), findsOneWidget);

    await tester.tap(find.text('开始聊天'));
    await tester.pumpAndSettle();
    expect(find.text('AI 陪伴角色 · 并非田曦薇本人'), findsOneWidget);
    expect(find.text('你好呀，我是你的 AI 陪伴角色。今天过得怎么样？'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('chat-input')), '今天有点累');
    await tester.tap(find.byTooltip('发送消息'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('今天有点累'), findsOneWidget);
    expect(find.textContaining('听起来你今天很辛苦'), findsOneWidget);
  });

  testWidgets('手机端底部导航可打开衣橱和记忆页面', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CompanionApp());
    await tester.tap(find.text('衣橱').last);
    await tester.pumpAndSettle();
    expect(find.text('授权服装素材接入后，就可以在这里换装'), findsOneWidget);

    await tester.tap(find.text('记忆').last);
    await tester.pumpAndSettle();
    expect(find.text('记忆控制与云端同步正在准备中'), findsOneWidget);
  });

  testWidgets('宽屏使用侧边导航', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CompanionApp());

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('陪伴'), findsOneWidget);
  });
}
