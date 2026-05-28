# 迁移指南

## 📋 从旧代码迁移到改进的新代码

本指南帮助你逐步迁移现有代码到改进的架构。

## 🔄 迁移步骤

### 第 1 步：更新导入

#### 旧代码
```dart
import 'package:app/pages/home/sdk_manager.dart';
```

#### 新代码
```dart
import 'package:app/pages/home/sdk_manager_improved.dart';
import 'package:app/core/logger.dart';
import 'package:app/config/app_config.dart';
```

---

### 第 2 步：替换 print() 为 Logger

#### 旧代码
```dart
print('SDK 初始化成功');
print('发生错误: $error');
```

#### 新代码
```dart
Logger.info('SDK 初始化成功');
Logger.error('发生错误', error, stackTrace);
```

---

### 第 3 步：使用 Result 类型

#### 旧代码
```dart
final ok = await manager.init(config);
if (ok) {
  print('初始化成功');
} else {
  print('初始化失败');
}
```

#### 新代码
```dart
final result = await manager.init(config);
if (result.isSuccess) {
  Logger.info('初始化成功');
} else {
  final error = result.getExceptionOrNull();
  Logger.error('初始化失败', error);
}
```

---

### 第 4 步：使用配置管理

#### 旧代码
```dart
WebUri('http://192.168.1.188:9018/#/')
```

#### 新代码
```dart
WebUri(AppConfig.getWebViewUrl())
```

---

### 第 5 步：使用改进的对话框

#### 旧代码
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (ctx) => const Center(
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('正在初始化，请稍候...'),
          ],
        ),
      ),
    ),
  ),
);
```

#### 新代码
```dart
await LoadingDialog.show(
  context,
  message: '正在初始化，请稍候...',
);
```

---

### 第 6 步：使用权限管理器

#### 旧代码
```dart
final granted = await RuntimePermissions.accessGranted(
  PermissionType.microphone,
);
if (!granted) {
  final state = await RuntimePermissions.requestAccess(
    PermissionType.microphone,
  );
  if (state == PermissionState.denied) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('需要麦克风权限才能对讲'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
}
```

#### 新代码
```dart
final result = await PermissionHelper.requestPermission(
  Permission.microphone,
);

if (result.isFailure) {
  await ErrorDialog.show(
    context,
    title: '权限错误',
    message: result.getExceptionOrNull()?.message ?? '权限被拒绝',
  );
  return;
}
```

---

### 第 7 步：使用全局状态

#### 旧代码
```dart
// 没有全局状态管理
```

#### 新代码
```dart
final appState = AppState();

// 设置状态
appState.setSdkInitialized(true);
appState.setSdkAuthenticated(true);
appState.setCurrentDevice(deviceId, deviceName);

// 获取状态
bool isReady = appState.sdkReady;
String? deviceId = appState.currentDeviceId;

// 监听状态变化
appState.addListener(() {
  print('状态已变化');
});
```

---

## 📝 完整迁移示例

### 迁移 Home 页面

#### 旧代码
```dart
import 'package:app/pages/home/sdk_manager.dart';

class _WebViewPageState extends State<WebViewPage> {
  SdkManager? manager;

  void _handleInit(Map<String, dynamic> msg) async {
    final appId = msg['appId'] as String? ?? '';
    final accessToken = msg['accessToken'] as String? ?? '';

    if (appId.isEmpty || accessToken.isEmpty) {
      print('初始化参数不完整');
      return;
    }

    print('收到 SDK 配置: appId=$appId');

    final initOk = await manager!.init(
      SdkConfig(appId: appId, packageName: ''),
    );
    if (initOk) {
      print('SDK 初始化成功');
      final authOk = await manager!.auth(accessToken);
      if (authOk) {
        print('SDK 认证成功');
        await _webViewController!.evaluateJavascript(
          source: 'window.receiveFromFlutter({"type": "authSuccess"});',
        );
      } else {
        print('SDK 认证失败');
        await _webViewController!.evaluateJavascript(
          source: 'window.receiveFromFlutter({"type": "authFailed"});',
        );
      }
    } else {
      print('SDK 初始化失败');
    }
  }
}
```

#### 新代码
```dart
import 'package:app/pages/home/sdk_manager_improved.dart';
import 'package:app/core/logger.dart';
import 'package:app/config/app_config.dart';
import 'package:app/store/app_state.dart';
import 'package:app/widgets/error_dialog.dart';

class _WebViewPageState extends State<WebViewPage> {
  late SdkManagerImproved _sdkManager;
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _sdkManager = SdkManagerImproved();
    _appState = AppState();
    _appState.setSdkManager(_sdkManager as dynamic);
  }

  void _handleInit(Map<String, dynamic> msg) async {
    final appId = msg['appId'] as String? ?? '';
    final packageName = msg['packageName'] as String? ?? '';
    final accessToken = msg['accessToken'] as String? ?? '';

    if (appId.isEmpty || accessToken.isEmpty) {
      Logger.error('初始化参数不完整');
      _notifyWebAuthFailed('初始化参数不完整');
      return;
    }

    Logger.info('收到 SDK 配置: appId=$appId');

    // 初始化 SDK
    final initResult = await _sdkManager.init(
      SdkConfig(
        appId: appId,
        packageName: packageName,
        accessToken: accessToken,
      ),
    );

    if (initResult.isFailure) {
      Logger.error('SDK 初始化失败: ${initResult.getExceptionOrNull()}');
      _appState.setSdkError(initResult.getExceptionOrNull().toString());
      _notifyWebAuthFailed('SDK 初始化失败');
      return;
    }

    _appState.setSdkInitialized(true);
    Logger.info('SDK 初始化成功');

    // 认证 SDK
    final authResult = await _sdkManager.auth(accessToken);

    if (authResult.isFailure) {
      Logger.error('SDK 认证失败: ${authResult.getExceptionOrNull()}');
      _appState.setSdkError(authResult.getExceptionOrNull().toString());
      _notifyWebAuthFailed('SDK 认证失败');
      return;
    }

    _appState.setSdkAuthenticated(true);
    Logger.info('SDK 认证成功');
    _notifyWebAuthSuccess();
  }

  void _notifyWebAuthSuccess() async {
    try {
      await _webViewController?.evaluateJavascript(
        source: 'window.receiveFromFlutter({"type": "authSuccess"});',
      );
    } catch (e) {
      Logger.error('通知 Web 认证成功失败', e);
    }
  }

  void _notifyWebAuthFailed(String reason) async {
    try {
      await _webViewController?.evaluateJavascript(
        source: 'window.receiveFromFlutter({"type": "authFailed", "reason": "$reason"});',
      );
    } catch (e) {
      Logger.error('通知 Web 认证失败失败', e);
    }
  }
}
```

---

## 🎯 迁移检查清单

- [ ] 更新所有导入语句
- [ ] 将 `print()` 替换为 `Logger`
- [ ] 将 `bool` 返回值替换为 `Result<T>`
- [ ] 将硬编码 URL 替换为 `AppConfig.getWebViewUrl()`
- [ ] 将自定义对话框替换为 `ErrorDialog`、`LoadingDialog` 等
- [ ] 将权限请求替换为 `PermissionHelper`
- [ ] 添加全局状态管理
- [ ] 运行测试确保功能正常
- [ ] 更新文档

---

## 🧪 测试迁移

### 测试 SDK 初始化

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/home/sdk_manager_improved.dart';
import 'package:app/core/result.dart';

void main() {
  group('SdkManagerImproved', () {
    test('初始化成功', () async {
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

    test('初始化失败 - 参数不完整', () async {
      final manager = SdkManagerImproved();
      
      final result = await manager.init(
        SdkConfig(
          appId: '',
          packageName: 'com.example.test',
          accessToken: 'test-token',
        ),
      );
      
      expect(result.isFailure, true);
    });
  });
}
```

---

## 🚀 逐步迁移策略

### 方案 1：一次性迁移（推荐用于小项目）
1. 创建新的改进模块
2. 一次性更新所有代码
3. 运行完整测试
4. 部署

### 方案 2：渐进式迁移（推荐用于大项目）
1. 创建新的改进模块
2. 在新功能中使用改进的模块
3. 逐步迁移现有功能
4. 保留旧模块作为备份
5. 最后删除旧模块

### 方案 3：并行运行（最安全）
1. 创建新的改进模块
2. 在新分支中进行迁移
3. 充分测试
4. 合并到主分支

---

## 📊 迁移前后对比

| 方面 | 迁移前 | 迁移后 |
|------|--------|--------|
| 错误处理 | 异常抛出 | Result 类型 |
| 日志输出 | print() | Logger |
| 配置管理 | 硬编码 | AppConfig |
| 权限请求 | 自定义 | PermissionHelper |
| 对话框 | 自定义 | 统一组件 |
| 状态管理 | 无 | AppState |
| 代码复用 | 低 | 高 |
| 可维护性 | 低 | 高 |
| 可测试性 | 低 | 高 |

---

## 💡 迁移建议

1. **备份代码** - 迁移前备份现有代码
2. **逐步迁移** - 不要一次性迁移所有代码
3. **充分测试** - 每个模块迁移后都要测试
4. **更新文档** - 迁移后更新相关文档
5. **代码审查** - 让团队成员审查迁移代码
6. **性能测试** - 确保迁移后性能没有下降

---

## 🆘 常见问题

### Q: 迁移会影响性能吗？

A: 不会。改进的代码使用相同的底层 API，性能不会有明显变化。

### Q: 可以同时使用旧代码和新代码吗？

A: 可以。在迁移期间，可以同时使用旧的 `SdkManager` 和新的 `SdkManagerImproved`。

### Q: 如何处理现有的异常处理代码？

A: 将 `try-catch` 块替换为 `Result` 类型的检查。

### Q: 迁移需要多长时间？

A: 取决于项目大小。小项目可能需要几小时，大项目可能需要几天。

### Q: 迁移后如何回滚？

A: 保留旧代码作为备份，如果出现问题可以快速回滚。

---

## 📚 相关文档

- [改进详情](IMPROVEMENTS.md) - 详细的改进说明
- [快速开始](QUICK_START.md) - 快速开始指南
- [项目结构](PROJECT_STRUCTURE.md) - 项目结构文档

---

**最后更新**: 2026-05-22
