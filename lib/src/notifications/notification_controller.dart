import 'package:flutter/foundation.dart';

import 'greeting_scheduler.dart';
import 'notification_preferences.dart';
import 'notification_preferences_repository.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({required this.repository, required this.scheduler});

  final NotificationPreferencesRepository repository;
  final GreetingScheduler scheduler;
  NotificationPreferences _preferences = NotificationPreferences.defaults();
  bool _isLoading = true;
  bool _isBusy = false;
  bool _permissionDenied = false;
  String? _errorMessage;

  NotificationPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  bool get permissionDenied => _permissionDenied;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      await scheduler.initialize();
      _preferences = await repository.load();
      if (_preferences.enabled) {
        if (_preferences.reminderFallsInQuietHours) {
          _preferences = _preferences.copyWith(enabled: false);
          await repository.save(_preferences);
          _errorMessage = '提醒时间与免打扰时段冲突，提醒已暂停。';
        } else {
          await scheduler.scheduleDaily(_preferences);
        }
      }
    } catch (_) {
      _errorMessage = '通知设置暂时无法加载。';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setEnabled(bool enabled) async {
    if (_isBusy) return false;
    _isBusy = true;
    _permissionDenied = false;
    _errorMessage = null;
    notifyListeners();
    try {
      if (enabled && _preferences.reminderFallsInQuietHours) {
        _errorMessage = '每日提醒时间须避开免打扰时段。';
        return false;
      }
      final next = _preferences.copyWith(enabled: enabled);
      if (enabled) {
        final granted = await scheduler.requestPermission();
        if (!granted) {
          _permissionDenied = true;
          _errorMessage = '系统通知权限未开启，可前往系统设置允许通知。';
          return false;
        }
        await scheduler.scheduleDaily(next);
      } else {
        await scheduler.cancel();
      }
      await repository.save(next);
      _preferences = next;
      return true;
    } catch (_) {
      _errorMessage = '通知设置保存失败，请稍后重试。';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> updateTimes({
    int? reminderHour,
    int? reminderMinute,
    int? quietStartHour,
    int? quietStartMinute,
    int? quietEndHour,
    int? quietEndMinute,
  }) async {
    if (_isBusy) return false;
    final next = _preferences.copyWith(
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      quietStartHour: quietStartHour,
      quietStartMinute: quietStartMinute,
      quietEndHour: quietEndHour,
      quietEndMinute: quietEndMinute,
    );
    if (next.enabled && next.reminderFallsInQuietHours) {
      _errorMessage = '提醒时间须避开免打扰时段，请调整其中一项。';
      notifyListeners();
      return false;
    }

    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (next.enabled) await scheduler.scheduleDaily(next);
      await repository.save(next);
      _preferences = next;
      return true;
    } catch (_) {
      _errorMessage = '通知设置保存失败，请稍后重试。';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> sendTestNotification() async {
    _errorMessage = null;
    try {
      await scheduler.showNow();
      return true;
    } catch (_) {
      _errorMessage = '暂时无法发送测试通知。';
      notifyListeners();
      return false;
    }
  }
}
