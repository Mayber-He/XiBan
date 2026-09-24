import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xiban_companion/src/companion_app.dart';

void main() {
  testWidgets('首页展示清晰的 AI 身份说明与聊天入口', (tester) async {
    await tester.pumpWidget(const CompanionApp());

    expect(find.text('嗨，欢迎回来'), findsOneWidget);
    expect(find.text('AI 角色 · 非田曦薇本人'), findsOneWidget);

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
