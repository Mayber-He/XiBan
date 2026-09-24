import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Alignment;
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

abstract interface class CompanionWindowController implements Listenable {
  bool get isMiniMode;
  Future<void> enterMiniMode();
  Future<void> restoreMainWindow();
  Future<void> disposeController();
}

class InMemoryCompanionWindowController extends ChangeNotifier
    implements CompanionWindowController {
  bool _isMiniMode = false;

  @override
  bool get isMiniMode => _isMiniMode;

  @override
  Future<void> enterMiniMode() async {
    _isMiniMode = true;
    notifyListeners();
  }

  @override
  Future<void> restoreMainWindow() async {
    _isMiniMode = false;
    notifyListeners();
  }

  @override
  Future<void> disposeController() async {}
}

class WindowsCompanionWindowController extends ChangeNotifier
    with WindowListener, TrayListener
    implements CompanionWindowController {
  bool _isMiniMode = false;
  bool _started = false;

  @override
  bool get isMiniMode => _isMiniMode;

  Future<void> initialize() async {
    if (!Platform.isWindows || _started) return;
    await windowManager.ensureInitialized();
    windowManager.addListener(this);
    trayManager.addListener(this);
    final options = WindowOptions(
      size: const Size(1120, 780),
      minimumSize: const Size(760, 560),
      center: true,
      title: '陪伴时光',
      skipTaskbar: false,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    await _initializeTray();
    await windowManager.setPreventClose(true);
    _started = true;
  }

  Future<void> _initializeTray() async {
    final icon = await rootBundle.load('windows/runner/resources/app_icon.ico');
    final iconFile = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'xiban-companion-tray-icon.ico',
    );
    await iconFile.writeAsBytes(
      icon.buffer.asUint8List(icon.offsetInBytes, icon.lengthInBytes),
      flush: true,
    );
    await trayManager.setIcon(iconFile.path);
    await trayManager.setToolTip('陪伴时光');
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'show', label: '打开主窗口'),
          MenuItem(key: 'mini', label: '迷你陪伴窗口'),
          MenuItem.separator(),
          MenuItem(key: 'exit', label: '退出陪伴时光'),
        ],
      ),
    );
  }

  @override
  Future<void> enterMiniMode() async {
    if (!Platform.isWindows) return;
    _isMiniMode = true;
    notifyListeners();
    await windowManager.setPreventClose(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setSize(const Size(360, 500));
    await windowManager.setMinimumSize(const Size(320, 420));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setAlignment(Alignment.bottomRight);
    await windowManager.setPreventClose(true);
    await windowManager.show();
  }

  @override
  Future<void> restoreMainWindow() async {
    if (!Platform.isWindows) return;
    _isMiniMode = false;
    notifyListeners();
    await windowManager.setPreventClose(false);
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setSize(const Size(1120, 780));
    await windowManager.setMinimumSize(const Size(760, 560));
    await windowManager.setAlignment(Alignment.center);
    await windowManager.setPreventClose(true);
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onWindowClose() {
    windowManager.hide();
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        restoreMainWindow();
      case 'mini':
        enterMiniMode();
      case 'exit':
        windowManager.setPreventClose(false).then((_) => windowManager.close());
    }
  }

  @override
  Future<void> disposeController() async {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    await trayManager.destroy();
    dispose();
  }
}
