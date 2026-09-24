import 'package:flutter/material.dart';

import '../notifications/notification_controller.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key, required this.controller});

  final NotificationController controller;

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    Future<bool> Function(TimeOfDay) onPicked,
  ) async {
    final time = await showTimePicker(context: context, initialTime: initial);
    if (time != null && context.mounted) {
      final saved = await onPicked(time);
      if (!saved && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.errorMessage ?? '设置未能保存。')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('通知与提醒')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final preferences = controller.preferences;
          final enabled = preferences.enabled;
          final reminder = TimeOfDay(
            hour: preferences.reminderHour,
            minute: preferences.reminderMinute,
          );
          final quietStart = TimeOfDay(
            hour: preferences.quietStartHour,
            minute: preferences.quietStartMinute,
          );
          final quietEnd = TimeOfDay(
            hour: preferences.quietEndHour,
            minute: preferences.quietEndMinute,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Card(
                child: SwitchListTile.adaptive(
                  key: const Key('notification-enabled-switch'),
                  title: const Text('每日主动问候'),
                  subtitle: const Text('每天最多一条；关闭后不会安排提醒'),
                  value: enabled,
                  onChanged: controller.isBusy
                      ? null
                      : (value) => controller.setEnabled(value),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      key: const Key('reminder-time-setting'),
                      title: const Text('问候时间'),
                      subtitle: const Text('使用设备本地时间'),
                      trailing: TextButton(
                        onPressed: controller.isBusy
                            ? null
                            : () => _pickTime(
                                context,
                                reminder,
                                (time) => controller.updateTimes(
                                  reminderHour: time.hour,
                                  reminderMinute: time.minute,
                                ),
                              ),
                        child: Text(reminder.format(context)),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text('免打扰开始'),
                      trailing: TextButton(
                        onPressed: controller.isBusy
                            ? null
                            : () => _pickTime(
                                context,
                                quietStart,
                                (time) => controller.updateTimes(
                                  quietStartHour: time.hour,
                                  quietStartMinute: time.minute,
                                ),
                              ),
                        child: Text(quietStart.format(context)),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text('免打扰结束'),
                      trailing: TextButton(
                        onPressed: controller.isBusy
                            ? null
                            : () => _pickTime(
                                context,
                                quietEnd,
                                (time) => controller.updateTimes(
                                  quietEndHour: time.hour,
                                  quietEndMinute: time.minute,
                                ),
                              ),
                        child: Text(quietEnd.format(context)),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.errorMessage case final message?) ...[
                const SizedBox(height: 12),
                Text(message, key: const Key('notification-settings-error')),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('test-notification-button'),
                onPressed: controller.isBusy
                    ? null
                    : () async {
                        final sent = await controller.sendTestNotification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                sent ? '测试通知已发送。' : controller.errorMessage!,
                              ),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('发送测试通知'),
              ),
              const SizedBox(height: 12),
              const Text(
                '提醒只会在你主动开启后安排。免打扰时段跨午夜生效，提醒时间不能落在该时段内。通知内容为固定的温和问候，不代表真人实时发送。',
              ),
            ],
          );
        },
      ),
    );
  }
}
