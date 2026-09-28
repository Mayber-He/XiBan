import 'package:flutter/material.dart';

import '../chat/model_config_controller.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.modelConfigController,
    required this.onOpenChatModelSettings,
    required this.onOpenNotificationSettings,
  });

  final ModelConfigController modelConfigController;
  final VoidCallback onOpenChatModelSettings;
  final VoidCallback onOpenNotificationSettings;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text('设置', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 5),
            Text(
              '按照自己的节奏，调整陪伴方式。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _IdentityCard(),
            const SizedBox(height: 28),
            _SectionHeading(title: '提醒'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('notification-settings-entry'),
                leading: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.coral,
                ),
                title: const Text('每日问候'),
                subtitle: const Text('问候时间与免打扰时段'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: onOpenNotificationSettings,
              ),
            ),
            const SizedBox(height: 22),
            _SectionHeading(title: '聊天'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: AnimatedBuilder(
                animation: modelConfigController,
                builder: (context, _) => ListTile(
                  key: const Key('chat-model-settings-entry'),
                  leading: const Icon(
                    Icons.tune_rounded,
                    color: AppTheme.coral,
                  ),
                  title: const Text('聊天模型配置'),
                  subtitle: Text(
                    modelConfigController.isLoading
                        ? '正在读取配置…'
                        : modelConfigController.isConfigured
                        ? '当前模型：${modelConfigController.config!.model}'
                        : '尚未配置 · 当前使用本地演示',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onOpenChatModelSettings,
                ),
              ),
            ),
            const SizedBox(height: 22),
            _SectionHeading(title: '关于曦伴'),
            Text(
              '曦伴是一款私人 AI 陪伴体验。对话由 AI 生成，角色并非田曦薇本人。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard();

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.blush,
      borderRadius: BorderRadius.circular(22),
    ),
    clipBehavior: Clip.antiAlias,
    child: Row(
      children: [
        SizedBox(
          width: 104,
          height: 132,
          child: Image.asset(
            'assets/companion_portrait.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('曦伴', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'AI 陪伴角色，并非田曦薇本人',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.ink),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 10),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );
}
