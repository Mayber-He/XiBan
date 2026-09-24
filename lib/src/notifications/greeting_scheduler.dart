import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_preferences.dart';

abstract interface class GreetingScheduler {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> scheduleDaily(NotificationPreferences preferences);
  Future<void> cancel();
  Future<void> showNow();
}

class LocalGreetingScheduler implements GreetingScheduler {
  LocalGreetingScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _notificationId = 5210;
  static const _androidChannelId = 'daily_companion_greeting';
  static const _androidChannelName = '每日陪伴问候';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_companion'),
      windows: WindowsInitializationSettings(
        appName: '陪伴时光',
        appUserModelId: 'Com.Xiban.Companion',
        guid: '3d0f37b4-a463-4c4e-b8ab-8a3d8ab7a0fb',
      ),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    return await android.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> scheduleDaily(NotificationPreferences preferences) async {
    if (preferences.reminderFallsInQuietHours) {
      throw ArgumentError('每日提醒时间位于免打扰时段内。');
    }
    await initialize();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      preferences.reminderHour,
      preferences.reminderMinute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _notificationId,
      title: '陪伴时光',
      body: '今天也别忘了照顾自己。想聊聊时，我在这里。',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: '每天一次的陪伴问候',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        windows: WindowsNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel() async {
    await initialize();
    await _plugin.cancel(id: _notificationId);
  }

  @override
  Future<void> showNow() async {
    await initialize();
    await _plugin.show(
      id: _notificationId + 1,
      title: '陪伴时光',
      body: '今天也别忘了照顾自己。想聊聊时，我在这里。',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: '每天一次的陪伴问候',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        windows: WindowsNotificationDetails(),
      ),
    );
  }
}

class InMemoryGreetingScheduler implements GreetingScheduler {
  bool permissionGranted = true;
  NotificationPreferences? scheduledPreferences;
  int scheduleCount = 0;
  int cancelCount = 0;
  int showNowCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> scheduleDaily(NotificationPreferences preferences) async {
    scheduledPreferences = preferences;
    scheduleCount++;
  }

  @override
  Future<void> cancel() async {
    scheduledPreferences = null;
    cancelCount++;
  }

  @override
  Future<void> showNow() async {
    showNowCount++;
  }
}
