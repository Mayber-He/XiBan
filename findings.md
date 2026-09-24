# 调研发现

- 仓库位于 `D:\GitFiles\XiBan`，当前没有项目文件，也没有历史提交；当前分支为 `main`。
- Git 已配置提交身份：`xuebo.he <xuebo.he@yechtech.com>`。
- Flutter/Dart 原先未安装；已在仓库 `.tooling/flutter` 获取 Flutter stable 3.47.5（该目录被 Git 忽略）。
- Visual Studio 2026 与 MSVC 编译器可用；Android SDK、ADB、Android Studio 未安装/未配置。
- 用户要求每个功能完成且测试通过后立即用中文提交。
- 产品素材须来自授权渠道；目前没有提供授权资产、模型 API 凭据或云后端配置。
- UI/UX 技能支持 Flutter 的通用设计约束，但其自动设计系统搜索说明以 React Native 为工作栈；本项目将采用技能中的通用移动端可访问性、布局、触达区域与反馈原则，不照搬 React Native 栈建议。
- Flutter 初始化曾在沙盒下访问 Android 工具探测失败；获批的工作区工具权限下可运行 Flutter 分析、测试和 Windows 构建。
- 记忆功能通过 `MemoryRepository` 隔离存储；当前生产入口使用 SharedPreferences 本机持久化，全局开关默认关闭，暂无云后端配置。
- 衣橱提供四套原创矢量示意，通过独立的 `OutfitRepository` 在本机保存当前选择；暂无正式授权服装素材。
