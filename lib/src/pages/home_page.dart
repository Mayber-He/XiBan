import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../character/character_state.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.characterState,
    required this.onStartChat,
    required this.onOpenSettings,
  });

  final ValueListenable<CharacterState> characterState;
  final VoidCallback onStartChat;
  final VoidCallback onOpenSettings;

  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel =
        '${now.month}月${now.day}日 · 星期${_weekdays[now.weekday - 1]}';

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: CustomScrollView(
            key: const PageStorageKey('companion-home'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
                sliver: SliverList.list(
                  children: [
                    _TopBar(
                      dateLabel: dateLabel,
                      onOpenSettings: onOpenSettings,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      '嗨，欢迎回来',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '忙了一天，也给自己留一点温柔的时间。',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.mutedInk),
                    ),
                    const SizedBox(height: 24),
                    _CompanionCard(onStartChat: onStartChat),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<CharacterState>(
                      valueListenable: characterState,
                      builder: (context, state, _) =>
                          _CharacterStatusCard(state: state),
                    ),
                    const SizedBox(height: 20),
                    _TodayCard(onStartChat: onStartChat),
                    const SizedBox(height: 28),
                    Text(
                      '慢慢来就好',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const _GentlePromptCard(),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'AI 陪伴体验 · 角色并非田曦薇本人',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterStatusCard extends StatelessWidget {
  const _CharacterStatusCard({required this.state});

  final CharacterState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.blush,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(state.mood.icon, color: AppTheme.coral),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '她现在${state.mood.label}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        state.currentTopic == null
                            ? '角色状态会随着相处慢慢变化'
                            : '最近聊到：${state.currentTopic}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatusMeter(
                    label: '精力',
                    value: state.energy,
                    icon: Icons.bolt_rounded,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _StatusMeter(
                    label: '默契',
                    value: state.affection,
                    icon: Icons.favorite_border_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMeter extends StatelessWidget {
  const _StatusMeter({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.mutedInk),
            const SizedBox(width: 5),
            Text(
              '$label  $value',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Semantics(
          label: '$label：$value%',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: AppTheme.blush,
              color: AppTheme.coral,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.dateLabel, required this.onOpenSettings});

  final String dateLabel;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mutedInk,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          key: const Key('open-notification-settings'),
          tooltip: '通知设置',
          onPressed: onOpenSettings,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _CompanionCard extends StatelessWidget {
  const _CompanionCard({required this.onStartChat});

  final VoidCallback onStartChat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 260),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7DFD8), Color(0xFFFCEEE7), Color(0xFFF3E9DF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: -32,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x99FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.66),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'AI 角色 · 非田曦薇本人',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppTheme.coral,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '今天的心情，\n想和我说说吗？',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: compact ? 25 : 30,
                        height: 1.32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: onStartChat,
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text('开始聊天'),
                    ),
                  ],
                );

                if (compact) return copy;
                return Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 16),
                    const _PortraitPlaceholder(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitPlaceholder extends StatelessWidget {
  const _PortraitPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '角色形象占位区域，等待授权素材接入',
      child: Container(
        width: 196,
        height: 204,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        ),
        child: const Center(
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 58,
            color: AppTheme.coral,
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.onStartChat});

  final VoidCallback onStartChat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.blush,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.wb_sunny_outlined, color: AppTheme.coral),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今天还没有聊过',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '从一句近况开始也可以。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onStartChat,
              tooltip: '去聊天',
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _GentlePromptCard extends StatelessWidget {
  const _GentlePromptCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF2ED),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.spa_outlined, color: AppTheme.coral),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '不用整理好心情再开口。开心的、疲惫的、说不清的，都可以慢慢讲。',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
