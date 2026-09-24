import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import '../character/character_state.dart';
import '../chat/character_engine.dart';
import '../chat/chat_controller.dart';
import '../memory/memory_controller.dart';
import '../memory/memory_repository.dart';
import '../wardrobe/outfit_repository.dart';
import '../wardrobe/wardrobe_controller.dart';
import '../notifications/greeting_scheduler.dart';
import '../notifications/notification_controller.dart';
import '../notifications/notification_preferences_repository.dart';
import '../desktop/desktop_companion_window.dart';
import '../pages/home_page.dart';
import '../pages/chat_page.dart';
import '../pages/memory_page.dart';
import '../pages/wardrobe_page.dart';
import '../pages/notification_settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.memoryRepository,
    this.outfitRepository,
    this.notificationRepository,
    this.greetingScheduler,
    this.desktopWindowController,
  });

  final MemoryRepository? memoryRepository;
  final OutfitRepository? outfitRepository;
  final NotificationPreferencesRepository? notificationRepository;
  final GreetingScheduler? greetingScheduler;
  final CompanionWindowController? desktopWindowController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final _characterState = ValueNotifier(CharacterState.initial());
  late final MemoryController _memoryController;
  late final WardrobeController _wardrobeController;
  late final NotificationController _notificationController;
  late final CompanionWindowController _desktopWindowController;
  late final _chatController = ChatController(
    engine: const LocalDemoCharacterEngine(),
    characterState: _characterState,
  );

  static const _items = [
    _NavItem('陪伴', Icons.home_outlined, Icons.home_rounded),
    _NavItem('聊天', Icons.chat_bubble_outline_rounded, Icons.chat_rounded),
    _NavItem('衣橱', Icons.checkroom_outlined, Icons.checkroom_rounded),
    _NavItem('记忆', Icons.bookmark_border_rounded, Icons.bookmark_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _memoryController = MemoryController(
      repository: widget.memoryRepository ?? InMemoryMemoryRepository(),
    )..load();
    _wardrobeController = WardrobeController(
      repository: widget.outfitRepository ?? InMemoryOutfitRepository(),
      characterState: _characterState,
    )..load();
    _notificationController = NotificationController(
      repository:
          widget.notificationRepository ?? InMemoryNotificationRepository(),
      scheduler: widget.greetingScheduler ?? InMemoryGreetingScheduler(),
    )..load();
    _desktopWindowController =
        widget.desktopWindowController ?? InMemoryCompanionWindowController();
  }

  late final _pages = <Widget>[
    HomePage(
      characterState: _characterState,
      onStartChat: () => _select(1),
      onOpenSettings: _openNotificationSettings,
      onEnterMiniMode: () => _desktopWindowController.enterMiniMode(),
    ),
    ChatPage(controller: _chatController),
    WardrobePage(controller: _wardrobeController),
    MemoryPage(controller: _memoryController),
  ];

  void _select(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            NotificationSettingsPage(controller: _notificationController),
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _memoryController.dispose();
    _wardrobeController.dispose();
    _notificationController.dispose();
    _desktopWindowController.disposeController();
    _characterState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _desktopWindowController,
      builder: (context, _) => _desktopWindowController.isMiniMode
          ? _MiniCompanionPage(
              state: _characterState,
              onRestore: _desktopWindowController.restoreMainWindow,
              onStartChat: () async {
                await _desktopWindowController.restoreMainWindow();
                _select(1);
              },
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 840;
                final content = IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                );

                if (isWide) {
                  return Scaffold(
                    body: Row(
                      children: [
                        const SizedBox(width: 16),
                        NavigationRail(
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: _select,
                          labelType: NavigationRailLabelType.all,
                          groupAlignment: -0.65,
                          leading: Padding(
                            padding: const EdgeInsets.only(bottom: 28, top: 12),
                            child: Semantics(
                              label: '陪伴时光',
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          destinations: [
                            for (final item in _items)
                              NavigationRailDestination(
                                icon: Icon(item.icon),
                                selectedIcon: Icon(item.selectedIcon),
                                label: Text(item.label),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const VerticalDivider(width: 1, thickness: 1),
                        Expanded(child: content),
                      ],
                    ),
                  );
                }

                return Scaffold(
                  body: content,
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _select,
                    destinations: [
                      for (final item in _items)
                        NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _MiniCompanionPage extends StatelessWidget {
  const _MiniCompanionPage({
    required this.state,
    required this.onRestore,
    required this.onStartChat,
  });

  final ValueListenable<CharacterState> state;
  final VoidCallback onRestore;
  final VoidCallback onStartChat;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DragToMoveArea(
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '陪伴时光',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('restore-main-window'),
                  tooltip: '恢复完整窗口',
                  onPressed: onRestore,
                  icon: const Icon(Icons.open_in_full_rounded),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF7DFD8),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 42,
                color: Color(0xFFC76F61),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<CharacterState>(
              valueListenable: state,
              builder: (context, character, _) => Text(
                '她现在${character.mood.label}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            const Text('AI 陪伴角色 · 并非田曦薇本人', textAlign: TextAlign.center),
            const Spacer(),
            FilledButton.icon(
              key: const Key('mini-start-chat'),
              onPressed: onStartChat,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('和我聊聊'),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRestore, child: const Text('打开完整应用')),
          ],
        ),
      ),
    ),
  );
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
