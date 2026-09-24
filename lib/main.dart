import 'dart:io';

import 'package:flutter/widgets.dart';

import 'src/companion_app.dart';
import 'src/memory/memory_repository.dart';
import 'src/wardrobe/outfit_repository.dart';
import 'src/notifications/greeting_scheduler.dart';
import 'src/notifications/notification_preferences_repository.dart';
import 'src/desktop/desktop_companion_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final desktopWindow = WindowsCompanionWindowController();
  if (Platform.isWindows) await desktopWindow.initialize();
  runApp(
    CompanionApp(
      memoryRepository: SharedPreferencesMemoryRepository(),
      outfitRepository: SharedPreferencesOutfitRepository(),
      notificationRepository: SharedPreferencesNotificationRepository(),
      greetingScheduler: LocalGreetingScheduler(),
      desktopWindowController: Platform.isWindows ? desktopWindow : null,
    ),
  );
}
