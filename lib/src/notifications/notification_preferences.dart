class NotificationPreferences {
  const NotificationPreferences({
    required this.enabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.quietStartHour,
    required this.quietStartMinute,
    required this.quietEndHour,
    required this.quietEndMinute,
  });

  factory NotificationPreferences.defaults() => const NotificationPreferences(
    enabled: false,
    reminderHour: 20,
    reminderMinute: 30,
    quietStartHour: 22,
    quietStartMinute: 0,
    quietEndHour: 8,
    quietEndMinute: 0,
  );

  final bool enabled;
  final int reminderHour;
  final int reminderMinute;
  final int quietStartHour;
  final int quietStartMinute;
  final int quietEndHour;
  final int quietEndMinute;

  bool get reminderFallsInQuietHours {
    final reminder = reminderHour * 60 + reminderMinute;
    final start = quietStartHour * 60 + quietStartMinute;
    final end = quietEndHour * 60 + quietEndMinute;
    if (start == end) return false;
    return start < end
        ? reminder >= start && reminder < end
        : reminder >= start || reminder < end;
  }

  NotificationPreferences copyWith({
    bool? enabled,
    int? reminderHour,
    int? reminderMinute,
    int? quietStartHour,
    int? quietStartMinute,
    int? quietEndHour,
    int? quietEndMinute,
  }) => NotificationPreferences(
    enabled: enabled ?? this.enabled,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    quietStartHour: quietStartHour ?? this.quietStartHour,
    quietStartMinute: quietStartMinute ?? this.quietStartMinute,
    quietEndHour: quietEndHour ?? this.quietEndHour,
    quietEndMinute: quietEndMinute ?? this.quietEndMinute,
  );

  String get reminderTime => _formatTime(reminderHour, reminderMinute);
  String get quietStartTime => _formatTime(quietStartHour, quietStartMinute);
  String get quietEndTime => _formatTime(quietEndHour, quietEndMinute);

  static String _formatTime(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
