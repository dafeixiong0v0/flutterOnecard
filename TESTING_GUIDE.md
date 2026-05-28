# 测试和验证指南

## 🧪 应用测试计划

本指南帮助你验证改进的模块是否正常工作。

---

## 📱 手动测试

### 1. 应用启动测试

**预期结果**:
- ✅ 应用成功启动
- ✅ Splash 屏显示 3 秒
- ✅ 跳转到 Home 页面
- ✅ WebView 加载成功

**测试步骤**:
```bash
flutter run
```

**验证**:
- 查看控制台日志，应该看到 `[App] INFO: ...` 格式的日志
- 应用应该显示启动屏，然后跳转到主页

---

### 2. 日志系统测试

**预期结果**:
- ✅ 日志正确输出到控制台
- ✅ 不同级别的日志显示不同的前缀

**测试步骤**:

在 `lib/main.dart` 中添加测试代码：

```dart
import 'package:app/core/logger.dart';

void main() {
  // 测试日志
  Logger.info('应用启动');
  Logger.warning('这是一条警告');
  Logger.debug('这是调试信息');
  
  runApp(const MyApp());
}
```

**验证**:
- 查看控制台输出，应该看到：
  ```
  [App] INFO: 应用启动
  [App] WARNING: 这是一条警告
  [App] DEBUG: 这是调试信息
  ```

---

### 3. 配置管理测试

**预期结果**:
- ✅ 配置值正确返回
- ✅ 环境检查正确

**测试步骤**:

在 `lib/main.dart` 中添加测试代码：

```dart
import 'package:app/config/app_config.dart';
import 'package:app/core/logger.dart';

void main() {
  // 测试配置
  Logger.info('WebView URL: ${AppConfig.getWebViewUrl()}');
  Logger.info('是否开发环境: ${AppConfig.isDevelopment()}');
  Logger.info('视频通话超时: ${AppConfig.videoCallTimeoutSeconds}秒');
  
  runApp(const MyApp());
}
```

**验证**:
- 查看控制台输出，应该看到配置值

---

### 4. 权限管理测试

**预期结果**:
- ✅ 权限请求对话框显示
- ✅ 权限授予/拒绝正确处理

**测试步骤**:

在 Home 页面添加测试按钮：

```dart
import 'package:app/utils/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';

// 在 _WebViewPageState 中添加
void _testPermission() async {
  final result = await PermissionHelper.requestPermission(Permission.camera);
  
  if (result.isSuccess) {
    Logger.info('摄像头权限已授予');
  } else {
    Logger.error('摄像头权限被拒绝', result.getExceptionOrNull());
  }
}
```

**验证**:
- 点击测试按钮
- 系统权限对话框应该显示
- 授予或拒绝权限后，应该看到相应的日志

---

### 5. 对话框组件测试

**预期结果**:
- ✅ 对话框正确显示
- ✅ 按钮点击正确处理

**测试步骤**:

在 Home 页面添加测试按钮：

```dart
import 'package:app/widgets/error_dialog.dart';

// 在 _WebViewPageState 中添加
void _testErrorDialog() async {
  await ErrorDialog.show(
    context,
    title: '测试错误',
    message: '这是一条测试错误消息',
    actionLabel: '重试',
    onAction: () => Logger.info('用户点击了重试'),
  );
}

void _testLoadingDialog() async {
  await LoadingDialog.show(context, message: '加载中...');
  await Future.delayed(Duration(seconds: 2));
  if (mounted) Navigator.pop(context);
}

void _testSuccessDialog() async {
  await SuccessDialog.show(
    context,
    title: '成功',
    message: '操作成功完成',
  );
}
```

**验证**:
- 点击测试按钮
- 对话框应该正确显示
- 按钮点击应该正确处理

---

### 6. 全局状态测试

**预期结果**:
- ✅ 状态正确设置
- ✅ 状态变化正确通知

**测试步骤**:

在 Home 页面添加测试代码：

```dart
import 'package:app/store/app_state.dart';

// 在 _WebViewPageState 中添加
void _testAppState() {
  final appState = AppState();
  
  // 监听状态变化
  appState.addListener(() {
    Logger.info('应用状态已变化');
  });
  
  // 设置状态
  appState.setSdkInitialized(true);
  appState.setSdkAuthenticated(true);
  appState.setCurrentDevice('device123', '前门摄像头');
  
  // 获取状态
  Logger.info('SDK 就绪: ${appState.sdkReady}');
  Logger.info('当前设备: ${appState.currentDeviceName}');
}
```

**验证**:
- 查看控制台日志
- 应该看到状态变化的通知

---

### 7. SDK 管理器测试

**预期结果**:
- ✅ SDK 初始化成功
- ✅ SDK 认证成功
- ✅ 错误处理正确

**测试步骤**:

在 Home 页面的 `_handleInit` 方法中已经使用了改进的 SDK 管理器。

**验证**:
- 从 Web 端发送初始化消息
- 查看控制台日志，应该看到：
  ```
  [App] INFO: 收到 SDK 配置: appId=...
  [App] INFO: SDK 初始化成功
  [App] INFO: SDK 认证成功
  ```

---

## 🧬 单元测试

### 创建测试文件

创建 `test/unit/config/app_config_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('getWebViewUrl() 返回非空字符串', () {
      final url = AppConfig.getWebViewUrl();
      expect(url, isNotEmpty);
      expect(url, startsWith('http'));
    });

    test('isDevelopment() 返回布尔值', () {
      final isDev = AppConfig.isDevelopment();
      expect(isDev, isA<bool>());
    });

    test('videoCallTimeoutSeconds 大于 0', () {
      expect(AppConfig.videoCallTimeoutSeconds, greaterThan(0));
    });
  });
}
```

### 创建测试文件

创建 `test/unit/core/logger_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/logger.dart';

void main() {
  group('Logger', () {
    test('info() 不抛出异常', () {
      expect(() => Logger.info('测试'), returnsNormally);
    });

    test('warning() 不抛出异常', () {
      expect(() => Logger.warning('测试'), returnsNormally);
    });

    test('error() 不抛出异常', () {
      expect(
        () => Logger.error('测试', Exception('测试异常')),
        returnsNormally,
      );
    });
  });
}
```

### 创建测试文件

创建 `test/unit/core/result_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/result.dart';

void main() {
  group('Result', () {
    test('success() 创建成功结果', () {
      final result = Result.success('data');
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.getOrNull(), 'data');
    });

    test('failure() 创建失败结果', () {
      final exception = Exception('测试异常');
      final result = Result<String>.failure(exception);
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.getExceptionOrNull(), exception);
    });

    test('map() 正确转换数据', () {
      final result = Result.success(5);
      final mapped = result.map((value) => value * 2);
      expect(mapped.getOrNull(), 10);
    });
  });
}
```

### 运行单元测试

```bash
flutter test
```

---

## 🔗 集成测试

### 创建集成测试文件

创建 `integration_test/app_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  group('应用集成测试', () {
    testWidgets('应用启动成功', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // 等待应用加载
      await tester.pumpAndSettle();
      
      // 验证 Scaffold 存在
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('WebView 页面加载', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // 等待应用加载
      await tester.pumpAndSettle();
      
      // 验证页面加载
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
```

### 运行集成测试

```bash
flutter test integration_test/app_test.dart
```

---

## 📊 测试覆盖率

### 生成覆盖率报告

```bash
flutter test --coverage
```

### 查看覆盖率报告

```bash
# 使用 lcov 查看覆盖率
lcov --list coverage/lcov.info
```

---

## 🐛 调试技巧

### 1. 使用 DevTools

```bash
flutter pub global activate devtools
devtools
```

然后在浏览器中打开 DevTools，连接到运行中的应用。

### 2. 查看日志

```bash
flutter logs
```

### 3. 使用断点调试

在 VS Code 中：
1. 打开 `lib/main.dart`
2. 在代码行号旁点击设置断点
3. 按 F5 启动调试
4. 应用会在断点处暂停

### 4. 热重载

在运行中的应用中按 `r` 进行热重载，`R` 进行热重启。

---

## ✅ 测试检查清单

### 基础功能
- [ ] 应用成功启动
- [ ] Splash 屏显示正确
- [ ] WebView 加载成功
- [ ] 日志输出正确

### 配置管理
- [ ] 配置值正确返回
- [ ] 环境检查正确
- [ ] 超时时间正确

### 权限管理
- [ ] 权限请求对话框显示
- [ ] 权限授予正确处理
- [ ] 权限拒绝正确处理

### UI 组件
- [ ] 错误对话框显示正确
- [ ] 加载对话框显示正确
- [ ] 成功对话框显示正确
- [ ] 按钮点击正确处理

### 状态管理
- [ ] 状态正确设置
- [ ] 状态变化正确通知
- [ ] 跨页面通信正确

### SDK 管理
- [ ] SDK 初始化成功
- [ ] SDK 认证成功
- [ ] 错误处理正确
- [ ] 超时处理正确

### 视频通话
- [ ] 视频通话管理器初始化成功
- [ ] 连接建立成功
- [ ] 视频流启动成功
- [ ] 对讲功能正常
- [ ] 挂断功能正常

---

## 📝 测试报告模板

```markdown
# 测试报告

## 测试日期
2026-05-22

## 测试环境
- 设备: 2407FRK8EC
- Flutter 版本: 3.7.2+
- Dart 版本: 3.7.2+

## 测试结果

### 基础功能
- [x] 应用启动: 通过
- [x] 日志输出: 通过
- [x] 配置管理: 通过

### 高级功能
- [x] 权限管理: 通过
- [x] UI 组件: 通过
- [x] 状态管理: 通过

### 总体结果
✅ 所有测试通过

## 问题和建议
无

## 签名
测试人员: [你的名字]
日期: 2026-05-22
```

---

## 🚀 持续集成

### GitHub Actions 配置

创建 `.github/workflows/test.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.2'
      - run: flutter pub get
      - run: flutter test
      - run: flutter test --coverage
```

---

## 📚 参考资源

- [Flutter 测试指南](https://flutter.dev/docs/testing)
- [单元测试](https://flutter.dev/docs/testing/unit-testing)
- [集成测试](https://flutter.dev/docs/testing/integration-testing)
- [DevTools](https://flutter.dev/docs/development/tools/devtools)

---

**最后更新**: 2026-05-22
