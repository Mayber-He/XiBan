import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../character/character_state.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.characterState,
    required this.onStartChat,
    required this.onOpenSettings,
    required this.onEnterMiniMode,
    this.showMiniMode = true,
  });

  final ValueListenable<CharacterState> characterState;
  final VoidCallback onStartChat;
  final VoidCallback onOpenSettings;
  final VoidCallback onEnterMiniMode;
  final bool showMiniMode;

  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel =
        '${now.month}月${now.day}日 · 星期${_weekdays[now.weekday - 1]}';
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              return CustomScrollView(
                key: const PageStorageKey('companion-home'),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 40 : 22,
                      18,
                      wide ? 40 : 22,
                      28,
                    ),
                    sliver: SliverList.list(
                      children: [
                        _TopBar(
                          dateLabel: dateLabel,
                          onOpenSettings: onOpenSettings,
                          onEnterMiniMode: onEnterMiniMode,
                          showMiniMode: showMiniMode,
                        ),
                        const SizedBox(height: 24),
                        if (wide)
                          _WideHome(
                            onStartChat: onStartChat,
                            characterState: characterState,
                          )
                        else
                          _CompactHome(
                            onStartChat: onStartChat,
                            characterState: characterState,
                          ),
                        const SizedBox(height: 18),
                        const _IdentityNote(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.dateLabel,
    required this.onOpenSettings,
    required this.onEnterMiniMode,
    required this.showMiniMode,
  });

  final String dateLabel;
  final VoidCallback onOpenSettings;
  final VoidCallback onEnterMiniMode;
  final bool showMiniMode;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '曦伴',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 2),
            Text(dateLabel, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
      IconButton(
        key: const Key('open-notification-settings'),
        tooltip: '通知设置',
        onPressed: onOpenSettings,
        icon: const Icon(Icons.notifications_none_rounded),
      ),
      if (showMiniMode)
        IconButton(
          key: const Key('enter-mini-mode'),
          tooltip: '桌面迷你陪伴窗口',
          onPressed: onEnterMiniMode,
          icon: const Icon(Icons.picture_in_picture_alt_rounded),
        ),
    ],
  );
}

class _WideHome extends StatelessWidget {
  const _WideHome({required this.onStartChat, required this.characterState});
  final VoidCallback onStartChat;
  final ValueListenable<CharacterState> characterState;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 30),
          child: _Welcome(
            onStartChat: onStartChat,
            characterState: characterState,
          ),
        ),
      ),
      SizedBox(
        width: 400,
        height: 500,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/companion_portrait.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    ],
  );
}

class _CompactHome extends StatelessWidget {
  const _CompactHome({required this.onStartChat, required this.characterState});
  final VoidCallback onStartChat;
  final ValueListenable<CharacterState> characterState;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('嗨，欢迎回来', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 5),
      Text(
        '平凡的日子，也值得被温柔以待。',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppTheme.mutedInk),
      ),
      const SizedBox(height: 17),
      SizedBox(
        height: 290,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Image.asset(
            'assets/companion_portrait.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text(
        '今天的心情，\n想和我说说吗？',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(height: 1.35),
      ),
      const SizedBox(height: 4),
      Text('无论开心或疲惫，都可以慢慢说给我听。', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 17),
      _ChatAction(onPressed: onStartChat),
      const SizedBox(height: 18),
      _MoodLine(characterState: characterState),
    ],
  );
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onStartChat, required this.characterState});
  final VoidCallback onStartChat;
  final ValueListenable<CharacterState> characterState;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('嗨，欢迎回来', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 12),
      Text(
        '平凡的日子，\n也值得被温柔以待。',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(height: 1.4),
      ),
      const SizedBox(height: 15),
      Text('今天的心情，想和我说说吗？', style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 5),
      Text('无论开心或疲惫，都可以慢慢说给我听。', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 22),
      SizedBox(width: 280, child: _ChatAction(onPressed: onStartChat)),
      const SizedBox(height: 32),
      _MoodLine(characterState: characterState),
    ],
  );
}

class _ChatAction extends StatelessWidget {
  const _ChatAction({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.chat_bubble_outline_rounded),
    label: const Text('和我聊聊'),
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(54),
      backgroundColor: AppTheme.coral,
      foregroundColor: Colors.white,
    ),
  );
}

class _MoodLine extends StatelessWidget {
  const _MoodLine({required this.characterState});
  final ValueListenable<CharacterState> characterState;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<CharacterState>(
    valueListenable: characterState,
    builder: (context, state, _) => Row(
      children: [
        Icon(state.mood.icon, size: 18, color: AppTheme.coral),
        const SizedBox(width: 8),
        Text(
          '她现在${state.mood.label}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 14),
        Text(
          '精力  ${state.energy}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

class _IdentityNote extends StatelessWidget {
  const _IdentityNote();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFF4ECE3),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            size: 18,
            color: AppTheme.coral,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI 陪伴角色，并非田曦薇本人',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.ink),
            ),
          ),
        ],
      ),
    ),
  );
}
