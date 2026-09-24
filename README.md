# 陪伴时光（开发中）

面向 Windows 与 Android 的 AI 陪伴应用。当前版本包含响应式应用骨架、首页与导航预览；聊天、记忆、衣橱、通知和云端服务将逐项实现。

首页角色视觉目前为原创抽象占位图。取得授权前，应用不会使用田曦薇的真人照片、声音或经历，也会清楚说明角色是 AI、并非本人。

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
