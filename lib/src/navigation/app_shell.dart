import 'package:flutter/material.dart';

import '../character/character_state.dart';
import '../chat/character_engine.dart';
import '../chat/chat_controller.dart';
import '../memory/memory_controller.dart';
import '../memory/memory_repository.dart';
import '../pages/home_page.dart';
import '../pages/chat_page.dart';
import '../pages/memory_page.dart';
import '../pages/placeholder_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.memoryRepository});

  final MemoryRepository? memoryRepository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final _characterState = ValueNotifier(CharacterState.initial());
  late final MemoryController _memoryController;
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
  }

  late final _pages = <Widget>[
    HomePage(characterState: _characterState, onStartChat: () => _select(1)),
    ChatPage(controller: _chatController),
    const FeaturePlaceholder(
      title: '衣橱',
      subtitle: '为她挑一套今天喜欢的穿搭。',
      icon: Icons.checkroom_outlined,
      detail: '授权服装素材接入后，就可以在这里换装',
    ),
    MemoryPage(controller: _memoryController),
  ];

  void _select(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _chatController.dispose();
    _memoryController.dispose();
    _characterState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        final content = IndexedStack(index: _selectedIndex, children: _pages);

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
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
