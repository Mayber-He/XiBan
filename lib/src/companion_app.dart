import 'package:flutter/material.dart';

import 'navigation/app_shell.dart';
import 'memory/memory_repository.dart';
import 'theme/app_theme.dart';
import 'wardrobe/outfit_repository.dart';
import 'notifications/greeting_scheduler.dart';
import 'notifications/notification_preferences_repository.dart';
import 'desktop/desktop_companion_window.dart';

class CompanionApp extends StatelessWidget {
  const CompanionApp({
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '陪伴时光',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppShell(
        memoryRepository: memoryRepository,
        outfitRepository: outfitRepository,
        notificationRepository: notificationRepository,
        greetingScheduler: greetingScheduler,
        desktopWindowController: desktopWindowController,
      ),
    );
  }
}
