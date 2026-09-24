# 陪伴时光（开发中）

面向 Windows 与 Android 的 AI 陪伴应用。当前版本包含响应式首页、角色情绪展示、本地演示聊天、本机记忆管理、原创穿搭示意、每日本地通知设置，以及 Windows 系统托盘和置顶迷你窗口。

首页角色视觉目前为原创抽象占位图。取得授权前，应用不会使用田曦薇的真人照片、声音或经历，也会清楚说明角色是 AI、并非本人。聊天引擎当前为离线演示版本；记忆和当前穿搭保存在本机，尚未配置账号服务或云端同步。通知默认关闭，只在用户主动开启后安排；通知文案为预设内容，并非真人实时发送。

## 本地运行

需要 Flutter stable 与 Dart SDK：

```powershell
flutter pub get
flutter run -d windows
flutter run -d <Android设备ID>
```

运行检查：

```powershell
flutter analyze
flutter test
```

Android 真机调试还需要 Android SDK、ADB 和已启用 USB 调试的设备。

Windows 桌面版首次启动后可从首页进入桌面迷你窗口，点击关闭会隐藏到系统托盘。托盘菜单可恢复完整窗口、打开迷你窗口或退出应用。
