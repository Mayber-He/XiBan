import 'package:xiban_companion/src/character/character_state.dart';
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

  testWidgets('首页展示清晰的 AI 身份说明与聊天入口', (tester) async {
    await tester.pumpWidget(const CompanionApp());

    expect(find.text('嗨，欢迎回来'), findsOneWidget);
    expect(find.text('AI 角色 · 非田曦薇本人'), findsOneWidget);
    expect(find.text('她现在平静'), findsOneWidget);
    expect(find.text('精力  76'), findsOneWidget);

    await tester.tap(find.text('开始聊天'));
    await tester.pumpAndSettle();
    expect(find.text('文字聊天与角色记忆正在准备中'), findsOneWidget);
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
