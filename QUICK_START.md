# 快速开始指南

## 🚀 项目改进概览

这个项目已经进行了全面的架构改进，提供了更好的代码组织、错误处理和可维护性。

## 📦 新增模块

### 1. 配置管理 (`lib/config/app_config.dart`)
集中管理所有应用配置参数。

**修改 WebView URL**:
```dart
// lib/config/app_config.dart
static const String webViewUrl = 'http://your-server:port/#/';
```

### 2. 日志系统 (`lib/core/logger.dart`)
统一的日志接口，替代 `print()`。

```dart
Logger.info('信息');
Logger.warning('警告');
Logger.error('错误', exception, stackTrace);
```

### 3. 异常处理 (`lib/core/exceptions.dart`)
定义了 5 种应用异常类型，便于统一处理。

### 4. 结果类型 (`lib/core/result.dart`)
使用 `Result<T>` 替代异常抛出，更安全的错误处理。

```dart
final result = await someOperation();
if (result.isSuccess) {
  print('成功');
} else {
  print('失败: ${result.getExceptionOrNull()}');
}
```

### 5. 权限管理 (`lib/utils/permission_helper.dart`)
统一的权限请求接口。

```dart
final result = await PermissionHelper.requestPermission(Permission.camera);
```

### 6. 全局状态 (`lib/store/app_state.dart`)
使用 `ChangeNotifier` 管理全局状态。

```dart
final appState = AppState();
appState.setSdkInitialized(true);
```

### 7. UI 组件 (`lib/widgets/error_dialog.dart`)
统一的对话框组件。

```dart
await ErrorDialog.show(context, title: '错误', message: '...');
await LoadingDialog.show(context, message: '加载中...');
```

### 8. 改进的 SDK 管理器 (`lib/pages/home/sdk_manager_improved.dart`)
返回 `Result<T>` 的 SDK 管理器。

### 9. 视频通话管理器 (`lib/pages/tangevideo/video_call_manager.dart`)
封装视频通话核心逻辑。

### 10. 视频通话 UI (`lib/pages/tangevideo/video_call_ui.dart`)
分离的 UI 组件。

## 🔧 使用示例

### 初始化 SDK

```dart
import 'package:app/pages/home/sdk_manager_improved.dart';
import 'package:app/core/logger.dart';

final manager = SdkManagerImproved();

// 初始化
final initResult = await manager.init(
  SdkConfig(
    appId: 'your-app-id',
    packageName: 'com.example.app',
    accessToken: 'your-token',
  ),
);

if (initResult.isFailure) {
  Logger.error('初始化失败: ${initResult.getExceptionOrNull()}');
  return;
}

// 认证
final authResult = await manager.auth('your-token');

if (authResult.isSuccess) {
  Logger.info('认证成功');
}
```

### 请求权限

```dart
import 'package:app/utils/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';

final result = await PermissionHelper.requestPermission(Permission.camera);

if (result.isSuccess) {
  print('权限已授予');
} else {
  print('权限被拒绝: ${result.getExceptionOrNull()}');
}
```

### 显示对话框

```dart
import 'package:app/widgets/error_dialog.dart';

// 错误对话框
await ErrorDialog.show(
  context,
  title: '错误',
  message: '发生了一个错误',
  actionLabel: '重试',
  onAction: () => retry(),
);

// 加载对话框
await LoadingDialog.show(context, message: '加载中...');

// 成功对话框
await SuccessDialog.show(
  context,
  title: '成功',
  message: '操作成功',
);
```

### 使用全局状态

```dart
import 'package:app/store/app_state.dart';

final appState = AppState();

// 设置状态
appState.setSdkInitialized(true);
appState.setSdkAuthenticated(true);
appState.setCurrentDevice('device123', '前门摄像头');

// 获取状态
bool isReady = appState.sdkReady;
String? deviceId = appState.currentDeviceId;

// 监听状态变化
appState.addListener(() {
  print('状态已变化');
});
```

## 📝 常见任务

### 修改 WebView URL

编辑 `lib/config/app_config.dart`:
```dart
static const String webViewUrl = 'http://new-server:port/#/';
```

### 修改视频通话超时时间

编辑 `lib/config/app_config.dart`:
```dart
static const int videoCallTimeoutSeconds = 120; // 改为 120 秒
```

### 添加新的日志

```dart
import 'package:app/core/logger.dart';

Logger.info('这是一条信息日志');
Logger.warning('这是一条警告日志');
Logger.error('这是一条错误日志', exception, stackTrace);
```

### 添加新的异常类型

编辑 `lib/core/exceptions.dart`:
```dart
class MyCustomException extends AppException {
  MyCustomException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: '自定义错误: $message',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}
```

### 添加新的权限

编辑 `lib/config/app_config.dart`:
```dart
static const List<String> requiredPermissions = [
  'camera',
  'microphone',
  'storage',
  'location', // 新增
];
```

## 🧪 测试

### 测试 SDK 初始化

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/home/sdk_manager_improved.dart';

void main() {
  test('SDK 初始化成功', () async {
    final manager = SdkManagerImproved();
    
    final result = await manager.init(
      SdkConfig(
        appId: 'test-app-id',
        packageName: 'com.example.test',
        accessToken: 'test-token',
      ),
    );
    
    expect(result.isSuccess, true);
  });
}
```

## 🐛 调试

### 启用详细日志

所有日志都会在开发环境自动输出。在生产环境中，只有 INFO、WARNING 和 ERROR 级别的日志会输出。

### 查看 SDK 错误

```dart
final result = await manager.init(config);

if (result.isFailure) {
  final exception = result.getExceptionOrNull();
  print('错误信息: ${exception?.message}');
  print('原始异常: ${exception?.originalException}');
  print('堆栈跟踪: ${exception?.stackTrace}');
}
```

## 📚 文档

- [改进详情](IMPROVEMENTS.md) - 详细的改进说明
- [Flutter 官方文档](https://flutter.dev)
- [Dart 官方文档](https://dart.dev)

## 💬 常见问题

### Q: 如何从旧的 SDK 管理器迁移到新的？

A: 新的 SDK 管理器返回 `Result<T>` 而不是 `bool`。只需将 `if (ok)` 改为 `if (result.isSuccess)`。

### Q: 如何添加新的配置参数？

A: 编辑 `lib/config/app_config.dart`，添加新的常量即可。

### Q: 如何自定义错误对话框？

A: 编辑 `lib/widgets/error_dialog.dart`，或创建新的对话框组件。

### Q: 如何在生产环境中禁用日志？

A: 修改 `lib/config/app_config.dart` 中的 `environment` 常量为 `'production'`。

## 🚀 下一步

1. 阅读 [改进详情](IMPROVEMENTS.md) 了解所有改进
2. 根据需要修改配置参数
3. 开始使用新的 API
4. 添加单元测试
5. 部署到生产环境

---

**最后更新**: 2026-05-22
