import 'package:shared_preferences/shared_preferences.dart';

import 'notification_preferences.dart';

abstract interface class NotificationPreferencesRepository {
  Future<NotificationPreferences> load();
  Future<void> save(NotificationPreferences preferences);
}

class SharedPreferencesNotificationRepository
    implements NotificationPreferencesRepository {
  SharedPreferencesNotificationRepository({this.preferences});

  static const _enabledKey = 'companion_notifications_enabled_v1';
  static const _reminderHourKey = 'companion_reminder_hour_v1';
  static const _reminderMinuteKey = 'companion_reminder_minute_v1';
  static const _quietStartHourKey = 'companion_quiet_start_hour_v1';
  static const _quietStartMinuteKey = 'companion_quiet_start_minute_v1';
  static const _quietEndHourKey = 'companion_quiet_end_hour_v1';
  static const _quietEndMinuteKey = 'companion_quiet_end_minute_v1';

  final SharedPreferences? preferences;

  Future<SharedPreferences> get _store async =>
      preferences ?? SharedPreferences.getInstance();

  @override
  Future<NotificationPreferences> load() async {
    final store = await _store;
    final defaults = NotificationPreferences.defaults();
    return NotificationPreferences(
      enabled: store.getBool(_enabledKey) ?? defaults.enabled,
      reminderHour: _readInt(
        store,
        _reminderHourKey,
        defaults.reminderHour,
        0,
        23,
      ),
      reminderMinute: _readInt(
        store,
        _reminderMinuteKey,
        defaults.reminderMinute,
        0,
        59,
      ),
      quietStartHour: _readInt(
        store,
        _quietStartHourKey,
        defaults.quietStartHour,
        0,
        23,
      ),
      quietStartMinute: _readInt(
        store,
        _quietStartMinuteKey,
        defaults.quietStartMinute,
        0,
        59,
      ),
      quietEndHour: _readInt(
        store,
        _quietEndHourKey,
        defaults.quietEndHour,
        0,
        23,
      ),
      quietEndMinute: _readInt(
        store,
        _quietEndMinuteKey,
        defaults.quietEndMinute,
        0,
        59,
      ),
    );
  }

  @override
  Future<void> save(NotificationPreferences value) async {
    final store = await _store;
    await store.setBool(_enabledKey, value.enabled);
    await store.setInt(_reminderHourKey, value.reminderHour);
    await store.setInt(_reminderMinuteKey, value.reminderMinute);
    await store.setInt(_quietStartHourKey, value.quietStartHour);
    await store.setInt(_quietStartMinuteKey, value.quietStartMinute);
    await store.setInt(_quietEndHourKey, value.quietEndHour);
    await store.setInt(_quietEndMinuteKey, value.quietEndMinute);
  }

  static int _readInt(
    SharedPreferences store,
    String key,
    int fallback,
    int minimum,
    int maximum,
  ) {
    final value = store.getInt(key) ?? fallback;
    return value.clamp(minimum, maximum);
  }
}

class InMemoryNotificationRepository
    implements NotificationPreferencesRepository {
  NotificationPreferences _preferences = NotificationPreferences.defaults();

  @override
  Future<NotificationPreferences> load() async => _preferences;

  @override
  Future<void> save(NotificationPreferences preferences) async {
    _preferences = preferences;
  }
}
