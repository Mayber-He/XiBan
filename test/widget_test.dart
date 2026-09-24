import 'dart:async';

import 'package:xiban_companion/src/character/character_state.dart';
import 'package:xiban_companion/src/chat/character_engine.dart';
import 'package:xiban_companion/src/chat/chat_controller.dart';
import 'package:xiban_companion/src/chat/chat_message.dart';
import 'package:xiban_companion/src/memory/companion_memory.dart';
import 'package:xiban_companion/src/memory/memory_controller.dart';
import 'package:xiban_companion/src/memory/memory_repository.dart';
import 'package:xiban_companion/src/wardrobe/outfit_repository.dart';
import 'package:xiban_companion/src/wardrobe/wardrobe_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xiban_companion/src/companion_app.dart';
import 'package:xiban_companion/src/notifications/greeting_scheduler.dart';
import 'package:xiban_companion/src/notifications/notification_controller.dart';
import 'package:xiban_companion/src/notifications/notification_preferences.dart';
import 'package:xiban_companion/src/notifications/notification_preferences_repository.dart';
import 'package:xiban_companion/src/desktop/desktop_companion_window.dart';

void main() {
  test('聊天单次只允许一个请求，并在引擎失败后给出可重试回退', () async {
    final gate = Completer<void>();
    final state = ValueNotifier(CharacterState.initial());
    final controller = ChatController(
      engine: _FailingCharacterEngine(gate),
      characterState: state,
    );
    addTearDown(controller.dispose);
    addTearDown(state.dispose);

    final sending = controller.send('第一条消息');
    expect(controller.isReplying, isTrue);
    await controller.send('重复点击');
    expect(controller.messages, hasLength(3));
    gate.complete();
    await sending;

    expect(controller.isReplying, isFalse);
    expect(controller.messages.last.content, contains('可以再试一次'));
  });

  test('流式响应在超时后会发出可处理的超时错误', () {
    var timedOut = false;
    fakeAsync((async) {
      StreamController<void>().stream
          .timeout(const Duration(milliseconds: 10))
          .listen(
            (_) {},
            onError: (Object error) {
              timedOut = error is TimeoutException;
            },
          );
      async.elapse(const Duration(milliseconds: 20));
      async.flushMicrotasks();
    });

    expect(timedOut, isTrue);
  });

  test('免打扰区间正确识别跨午夜及边界时间', () {
    final preferences = NotificationPreferences.defaults();
    expect(preferences.reminderFallsInQuietHours, isFalse);
    expect(
      preferences.copyWith(reminderHour: 23).reminderFallsInQuietHours,
      isTrue,
    );
    expect(
      preferences
          .copyWith(reminderHour: 7, reminderMinute: 59)
          .reminderFallsInQuietHours,
      isTrue,
    );
    expect(
      preferences.copyWith(reminderHour: 8).reminderFallsInQuietHours,
      isFalse,
    );
  });

  test('通知默认关闭；主动开启获准后每日调度，关闭后取消', () async {
    final scheduler = InMemoryGreetingScheduler();
    final controller = NotificationController(
      repository: InMemoryNotificationRepository(),
      scheduler: scheduler,
    );
    addTearDown(controller.dispose);
    await controller.load();
    expect(controller.preferences.enabled, isFalse);
    expect(scheduler.scheduleCount, 0);
    expect(await controller.setEnabled(true), isTrue);
    expect(scheduler.scheduleCount, 1);
    expect(controller.preferences.enabled, isTrue);
    expect(await controller.setEnabled(false), isTrue);
    expect(scheduler.cancelCount, 1);
  });

  test('拒绝通知权限或提醒落入免打扰时不会启用', () async {
    final scheduler = InMemoryGreetingScheduler()..permissionGranted = false;
    final controller = NotificationController(
      repository: InMemoryNotificationRepository(),
      scheduler: scheduler,
    );
    addTearDown(controller.dispose);
    await controller.load();
    expect(await controller.setEnabled(true), isFalse);
    expect(controller.preferences.enabled, isFalse);
    expect(controller.permissionDenied, isTrue);
    scheduler.permissionGranted = true;
    await controller.updateTimes(reminderHour: 23);
    expect(await controller.setEnabled(true), isFalse);
    expect(controller.preferences.enabled, isFalse);
    expect(scheduler.scheduleCount, 0);
  });

  test('通知时间配置通过 SharedPreferences 持久化', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesNotificationRepository();
    final changed = NotificationPreferences.defaults().copyWith(
      reminderHour: 19,
      reminderMinute: 15,
      quietStartHour: 21,
    );
    await repository.save(changed);
    final loaded = await repository.load();
    expect(loaded.reminderTime, '19:15');
    expect(loaded.quietStartTime, '21:00');
    expect(loaded.enabled, isFalse);
  });

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

  test('记忆内容可新增、编辑、单条停用、全局关闭和删除', () async {
    final repository = InMemoryMemoryRepository();
    final controller = MemoryController(repository: repository);
    addTearDown(controller.dispose);
    await controller.load();

    await controller.add(
      content: '喜欢周末散步',
      category: MemoryCategory.preference,
      importance: 4,
    );
    final memory = controller.memories.single;
    expect(memory.content, '喜欢周末散步');
    expect(memory.isEnabled, isTrue);

    await controller.update(
      memory.id,
      content: '喜欢清晨散步',
      category: MemoryCategory.routine,
      importance: 5,
    );
    expect(controller.memories.single.content, '喜欢清晨散步');
    expect(controller.memories.single.category, MemoryCategory.routine);
    expect(controller.memories.single.importance, 5);

    await controller.setMemoryEnabled(memory.id, false);
    await controller.setEnabled(true);
    expect(controller.memories.single.isEnabled, isFalse);
    expect(controller.isEnabled, isTrue);

    await controller.setEnabled(false);
    await controller.delete(memory.id);
    expect(controller.memories, isEmpty);
    expect(controller.isEnabled, isFalse);
  });

  test('记忆能通过本机 SharedPreferences 持久化', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesMemoryRepository(
      preferences: preferences,
    );
    final now = DateTime.utc(2026, 9, 24, 9);
    final entry = CompanionMemory(
      id: 'memory-1',
      userId: 'local-user',
      content: '周五有重要安排',
      category: MemoryCategory.importantDate,
      importance: 5,
      sourceMessageId: null,
      createdAt: now,
      updatedAt: now,
      isEnabled: true,
    );

    await repository.saveMemories([entry]);
    await repository.saveEnabled(true);

    expect((await repository.loadMemories()).single.content, '周五有重要安排');
    expect(await repository.loadEnabled(), isTrue);
  });

  test('换装会更新角色状态并持久化当前穿搭', () async {
    final state = ValueNotifier(CharacterState.initial());
    final repository = InMemoryOutfitRepository();
    final controller = WardrobeController(
      repository: repository,
      characterState: state,
    );
    addTearDown(controller.dispose);
    addTearDown(state.dispose);
    await controller.load();

    expect(controller.currentOutfit.id, 'daily');
    await controller.select('home');

    expect(controller.currentOutfit.name, '慵懒时光');
    expect(state.value.currentOutfitId, 'home');
    expect(await repository.loadCurrentOutfitId(), 'home');
  });

  test('当前穿搭使用本机 SharedPreferences 保存', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesOutfitRepository();
    await repository.saveCurrentOutfitId('commute');

    expect(await repository.loadCurrentOutfitId(), 'commute');
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

  testWidgets('首页可打开通知设置，并由用户主动开启每日提醒', (tester) async {
    final scheduler = InMemoryGreetingScheduler();
    await tester.pumpWidget(CompanionApp(greetingScheduler: scheduler));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-notification-settings')));
    await tester.pumpAndSettle();
    expect(find.text('通知与提醒'), findsOneWidget);
    expect(find.byKey(const Key('reminder-time-setting')), findsOneWidget);
    await tester.tap(find.byKey(const Key('notification-enabled-switch')));
    await tester.pumpAndSettle();
    expect(scheduler.scheduleCount, 1);
    expect(find.text('每日主动问候'), findsOneWidget);
  });

  testWidgets('桌面迷你陪伴状态可进入、展示身份並恢复完整窗口', (tester) async {
    final window = InMemoryCompanionWindowController();
    await tester.pumpWidget(CompanionApp(desktopWindowController: window));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('enter-mini-mode')));
    await tester.pumpAndSettle();
    expect(find.text('AI 陪伴角色 · 并非田曦薇本人'), findsOneWidget);
    expect(find.byKey(const Key('mini-start-chat')), findsOneWidget);
    await tester.tap(find.byKey(const Key('restore-main-window')));
    await tester.pumpAndSettle();
    expect(window.isMiniMode, isFalse);
    expect(find.byKey(const Key('enter-mini-mode')), findsOneWidget);
  });

  testWidgets('手机端底部导航可打开衣橱和记忆页面', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CompanionApp());
    await tester.tap(find.text('衣橱').last);
    await tester.pumpAndSettle();
    expect(find.text('今日衣橱'), findsOneWidget);
    expect(find.text('当前穿着：午后漫步'), findsOneWidget);
    await tester.tap(find.byKey(const Key('outfit-select-home')));
    await tester.pumpAndSettle();
    expect(find.text('当前穿着：慵懒时光'), findsOneWidget);

    await tester.tap(find.text('记忆').last);
    await tester.pumpAndSettle();
    expect(find.text('记忆管理'), findsOneWidget);
    await tester.tap(find.byKey(const Key('add-memory-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('memory-content')), '喜欢周末散步');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('喜欢周末散步'), findsOneWidget);

    await tester.tap(find.byTooltip('编辑记忆'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('memory-content')), '喜欢清晨散步');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('喜欢清晨散步'), findsOneWidget);

    await tester.tap(find.byKey(const Key('memory-global-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('删除记忆'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除').last);
    await tester.pumpAndSettle();
    expect(find.text('还没有保存的记忆'), findsOneWidget);
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

class _FailingCharacterEngine implements CharacterEngine {
  const _FailingCharacterEngine(this.gate);

  final Completer<void> gate;

  @override
  Stream<String> streamReply({
    required List<ChatMessage> history,
    required CharacterState state,
  }) async* {
    await gate.future;
    throw StateError('模拟服务超时');
  }
}
