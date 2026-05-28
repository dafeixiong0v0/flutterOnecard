# 项目改进 - README 更新建议

## 📝 建议更新现有 README.md

如果你的项目中有 README.md 文件，建议添加以下内容：

---

## 🏗️ 项目架构

本项目采用了现代化的 Flutter 架构，包含以下核心模块：

### 核心模块

- **配置管理** (`lib/config/`) - 集中管理应用配置
- **日志系统** (`lib/core/logger.dart`) - 统一的日志接口
- **异常处理** (`lib/core/exceptions.dart`) - 定义应用异常
- **结果类型** (`lib/core/result.dart`) - 安全的错误处理
- **权限管理** (`lib/utils/permission_helper.dart`) - 统一的权限请求
- **状态管理** (`lib/store/app_state.dart`) - 全局应用状态
- **UI 组件** (`lib/widgets/`) - 可复用的 UI 组件

### 页面模块

- **Home** - WebView 主页面，SDK 初始化和认证
- **TangeVideo** - 实时视频对讲功能
- **Door** - 门禁管理
- **People** - 人员管理
- **Splash** - 启动屏

## 🚀 快速开始

### 1. 环境要求

- Flutter 3.7.2+
- Dart 3.7.2+
- Android SDK 21+
- iOS 11+

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 运行应用

```bash
flutter run
```

### 4. 构建应用

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## 📚 文档

- [改进详情](IMPROVEMENTS.md) - 详细的改进说明
- [快速开始](QUICK_START.md) - 快速开始指南
- [项目结构](PROJECT_STRUCTURE.md) - 项目结构文档
- [迁移指南](MIGRATION_GUIDE.md) - 从旧代码迁移到新代码
- [改进总结](IMPROVEMENT_SUMMARY.md) - 改进总结
- [实施清单](IMPLEMENTATION_CHECKLIST.md) - 实施清单

## 🔧 配置

### 修改 WebView URL

编辑 `lib/config/app_config.dart`:

```dart
static const String webViewUrl = 'http://your-server:port/#/';
```

### 修改超时时间

编辑 `lib/config/app_config.dart`:

```dart
static const int videoCallTimeoutSeconds = 120;
```

## 🧪 测试

### 运行单元测试

```bash
flutter test
```

### 运行集成测试

```bash
flutter test integration_test
```

## 📦 依赖

主要依赖包括：

- `flutter_inappwebview` - WebView 支持
- `rapid_kit` - Tange AI SDK
- `wakelock_plus` - 屏幕常亮
- `audioplayers` - 音频播放
- `permission_handler` - 权限管理

详见 `pubspec.yaml`

## 🔐 权限

应用需要以下权限：

- 摄像头 (CAMERA)
- 录音 (RECORD_AUDIO)
- 存储 (READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE)
- 网络 (INTERNET)

## 🐛 调试

### 启用详细日志

所有日志都会在开发环境自动输出。在生产环境中，只有 INFO、WARNING 和 ERROR 级别的日志会输出。

### 查看 SDK 错误

```dart
final result = await manager.init(config);
if (result.isFailure) {
  final error = result.getExceptionOrNull();
  print('错误: ${error?.message}');
}
```

## 📱 支持的平台

- ✅ Android 5.0+ (API 21+)
- ✅ iOS 11+
- ⚠️ Web (部分支持)
- ⚠️ Windows (部分支持)
- ⚠️ macOS (部分支持)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

[添加你的许可证信息]

## 📞 联系方式

[添加你的联系方式]

---

## 🎯 项目特性

### ✨ 代码质量
- 统一的日志系统
- 安全的错误处理
- 集中的配置管理
- 统一的 UI 组件

### 🛡️ 安全性
- 类型安全
- 空值安全
- 异常安全
- 资源安全

### 🚀 性能
- 无额外开销
- 内存高效
- 响应迅速
- 可扩展

### 😊 用户体验
- 清晰的错误提示
- 统一的 UI 风格
- 流畅的交互
- 快速的响应

## 📊 项目统计

- 代码行数: ~2000+
- 模块数: 13+
- 文档页数: 5+
- 测试覆盖率: 待完成

## 🔄 更新日志

### v1.1.0 (2026-05-22)
- ✨ 添加配置管理模块
- ✨ 添加日志系统
- ✨ 添加异常处理
- ✨ 添加结果类型
- ✨ 添加权限管理
- ✨ 添加全局状态管理
- ✨ 添加 UI 组件库
- ✨ 改进 SDK 管理器
- ✨ 添加视频通话管理器
- ✨ 添加详细文档

### v1.0.0 (初始版本)
- 基础 Flutter 应用
- WebView 集成
- 视频通话功能
- 门禁管理
- 人员管理

---

**最后更新**: 2026-05-22
