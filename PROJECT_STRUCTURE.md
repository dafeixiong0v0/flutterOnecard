# 项目结构文档

## 📁 完整的项目结构

```
flutter_application_2/
├── lib/
│   ├── config/                          # 配置管理
│   │   └── app_config.dart              # 应用配置（WebView URL、超时等）
│   │
│   ├── core/                            # 核心模块
│   │   ├── exceptions.dart              # 异常定义
│   │   ├── logger.dart                  # 日志管理
│   │   └── result.dart                  # 结果包装类
│   │
│   ├── utils/                           # 工具函数
│   │   └── permission_helper.dart       # 权限管理助手
│   │
│   ├── store/                           # 状态管理
│   │   └── app_state.dart               # 全局应用状态
│   │
│   ├── widgets/                         # 通用 UI 组件
│   │   └── error_dialog.dart            # 对话框组件
│   │
│   ├── pages/                           # 页面
│   │   ├── SplashPage/
│   │   │   └── index.dart               # 启动屏
│   │   │
│   │   ├── home/
│   │   │   ├── index.dart               # 主页（WebView）
│   │   │   ├── sdk_manager.dart         # 原始 SDK 管理器
│   │   │   └── sdk_manager_improved.dart # 改进的 SDK 管理器
│   │   │
│   │   ├── door/
│   │   │   ├── index.dart               # 门禁页面
│   │   │   └── addDoor/                 # 添加门禁子模块
│   │   │
│   │   ├── people/
│   │   │   └── index.dart               # 人员管理页面
│   │   │
│   │   ├── tangevideo/
│   │   │   ├── index.dart               # 视频通话页面
│   │   │   ├── video_call_manager.dart  # 视频通话管理器
│   │   │   └── video_call_ui.dart       # 视频通话 UI 组件
│   │   │
│   │   └── other/
│   │       └── index.dart               # 其他页面
│   │
│   ├── router/
│   │   └── index.dart                   # 路由定义
│   │
│   ├── components/                      # 可复用组件（预留）
│   │   ├── AppBar/
│   │   │   └── index.dart
│   │   └── nav/
│   │
│   ├── main.dart                        # 应用入口
│   │
│   └── assets/                          # 资源文件
│       └── sounds/
│           └── ringtone.wav             # 来电铃声
│
├── android/                             # Android 原生代码
│   ├── app/
│   │   ├── build.gradle.kts             # 应用构建配置
│   │   └── src/main/
│   │       ├── AndroidManifest.xml      # 权限声明
│   │       └── kotlin/
│   │
│   └── build.gradle.kts                 # 项目构建配置
│
├── ios/                                 # iOS 原生代码
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── Runner.xcodeproj
│   │
│   └── Podfile
│
├── test/                                # 单元测试（预留）
│   └── widget_test.dart
│
├── pubspec.yaml                         # 依赖配置
├── pubspec.lock                         # 依赖锁定文件
├── analysis_options.yaml                # 代码分析配置
├── .gitignore                           # Git 忽略文件
│
├── IMPROVEMENTS.md                      # 改进详情
├── QUICK_START.md                       # 快速开始指南
└── PROJECT_STRUCTURE.md                 # 本文件
```

## 📚 模块说明

### `lib/config/` - 配置管理
**职责**: 集中管理应用配置参数

**文件**:
- `app_config.dart` - 应用配置常量

**关键配置**:
- `webViewUrl` - WebView 加载的 URL
- `videoCallTimeoutSeconds` - 视频通话超时时间
- `sdkReadyTimeoutSeconds` - SDK 就绪超时时间
- `environment` - 运行环境

**使用场景**:
- 修改 WebView URL
- 调整超时时间
- 切换环境配置

---

### `lib/core/` - 核心模块
**职责**: 提供应用的核心功能和类型

**文件**:
- `exceptions.dart` - 异常定义
- `logger.dart` - 日志管理
- `result.dart` - 结果包装类

**关键类**:
- `AppException` - 异常基类
- `Logger` - 日志管理器
- `Result<T>` - 结果类型

**使用场景**:
- 统一异常处理
- 日志输出
- 函数式错误处理

---

### `lib/utils/` - 工具函数
**职责**: 提供通用的工具函数

**文件**:
- `permission_helper.dart` - 权限管理

**关键函数**:
- `requestPermission()` - 请求单个权限
- `requestPermissions()` - 请求多个权限
- `hasPermission()` - 检查权限

**使用场景**:
- 请求摄像头权限
- 请求麦克风权限
- 检查权限状态

---

### `lib/store/` - 状态管理
**职责**: 管理应用全局状态

**文件**:
- `app_state.dart` - 全局应用状态

**关键状态**:
- `sdkManager` - SDK 管理器实例
- `sdkInitialized` - SDK 初始化状态
- `sdkAuthenticated` - SDK 认证状态
- `currentDeviceId` - 当前设备 ID
- `currentDeviceName` - 当前设备名称

**使用场景**:
- 跨页面共享状态
- 监听状态变化
- 重置应用状态

---

### `lib/widgets/` - UI 组件
**职责**: 提供通用的 UI 组件

**文件**:
- `error_dialog.dart` - 对话框组件

**关键组件**:
- `ErrorDialog` - 错误对话框
- `LoadingDialog` - 加载对话框
- `SuccessDialog` - 成功对话框

**使用场景**:
- 显示错误信息
- 显示加载状态
- 显示成功提示

---

### `lib/pages/` - 页面
**职责**: 应用的各个页面

**子目录**:

#### `SplashPage/`
- 启动屏页面
- 显示 3 秒后跳转到主页

#### `home/`
- 主页（WebView）
- SDK 初始化和认证
- 处理 Web 端的消息

**文件**:
- `index.dart` - 主页面
- `sdk_manager.dart` - 原始 SDK 管理器
- `sdk_manager_improved.dart` - 改进的 SDK 管理器

#### `door/`
- 门禁管理页面
- 添加门禁功能

#### `people/`
- 人员管理页面

#### `tangevideo/`
- 视频通话页面
- 实时视频对讲

**文件**:
- `index.dart` - 视频通话页面
- `video_call_manager.dart` - 视频通话管理器
- `video_call_ui.dart` - 视频通话 UI 组件

#### `other/`
- 其他页面

---

### `lib/router/` - 路由
**职责**: 管理应用路由

**文件**:
- `index.dart` - 路由表定义

**路由**:
- `/` - 主页
- `/door` - 门禁页面
- `/people` - 人员管理页面
- `/tangevideo` - 视频通话页面
- `/SplashPage` - 启动屏

---

### `lib/components/` - 可复用组件
**职责**: 提供可复用的 UI 组件（预留）

**子目录**:
- `AppBar/` - 应用栏组件
- `nav/` - 导航组件

---

## 🔄 数据流

### 应用启动流程
```
main.dart
  ↓
MyApp (配置主题和路由)
  ↓
SplashPage (3秒启动屏)
  ↓
HomePage (WebView)
  ↓
SDK 初始化和认证
```

### 视频通话流程
```
Web 端发送 call 消息
  ↓
HomePage._handleCall()
  ↓
等待 SDK 就绪
  ↓
跳转到 TangeVideoPage
  ↓
VideoCallManager 初始化
  ↓
建立连接
  ↓
显示视频
  ↓
用户挂断
  ↓
清理资源
  ↓
返回 HomePage
```

### 权限请求流程
```
需要权限
  ↓
PermissionHelper.requestPermission()
  ↓
检查权限状态
  ↓
如果未授予，显示系统对话框
  ↓
返回结果
```

## 🎯 设计原则

### 1. 单一职责原则
- 每个模块只负责一个功能
- 例如：`Logger` 只负责日志，`PermissionHelper` 只负责权限

### 2. 开闭原则
- 对扩展开放，对修改关闭
- 例如：添加新异常类型不需要修改现有代码

### 3. 依赖倒置原则
- 依赖抽象而不是具体实现
- 例如：使用 `Result<T>` 而不是异常

### 4. 接口隔离原则
- 提供清晰的 API 接口
- 例如：`VideoCallManager` 提供清晰的方法

### 5. 关注点分离
- UI 和业务逻辑分离
- 例如：`VideoCallManager` 和 `VideoUI`

## 📊 依赖关系

```
main.dart
  ├── MyApp
  │   ├── router/index.dart
  │   └── pages/
  │
  ├── pages/home/index.dart
  │   ├── config/app_config.dart
  │   ├── core/logger.dart
  │   ├── pages/home/sdk_manager_improved.dart
  │   ├── store/app_state.dart
  │   └── widgets/error_dialog.dart
  │
  ├── pages/tangevideo/index.dart
  │   ├── pages/tangevideo/video_call_manager.dart
  │   ├── pages/tangevideo/video_call_ui.dart
  │   ├── core/logger.dart
  │   └── utils/permission_helper.dart
  │
  └── pages/SplashPage/index.dart
```

## 🔧 扩展指南

### 添加新页面
1. 在 `lib/pages/` 下创建新目录
2. 创建 `index.dart` 文件
3. 在 `lib/router/index.dart` 中添加路由

### 添加新工具函数
1. 在 `lib/utils/` 下创建新文件
2. 实现工具函数
3. 在需要的地方导入使用

### 添加新异常类型
1. 在 `lib/core/exceptions.dart` 中定义新异常
2. 继承 `AppException`
3. 在相应模块中使用

### 添加新 UI 组件
1. 在 `lib/widgets/` 下创建新文件
2. 实现组件
3. 在需要的地方导入使用

## 📝 命名规范

### 文件命名
- 使用小写字母和下划线
- 例如：`app_config.dart`、`permission_helper.dart`

### 类命名
- 使用 PascalCase
- 例如：`AppConfig`、`PermissionHelper`

### 函数命名
- 使用 camelCase
- 例如：`requestPermission()`、`hasPermission()`

### 常量命名
- 使用 UPPER_SNAKE_CASE
- 例如：`VIDEO_CALL_TIMEOUT_SECONDS`

### 私有成员
- 使用下划线前缀
- 例如：`_sdkManager`、`_initialized`

## 🧪 测试结构

```
test/
├── unit/                                # 单元测试
│   ├── config/
│   │   └── app_config_test.dart
│   ├── core/
│   │   ├── logger_test.dart
│   │   └── result_test.dart
│   └── utils/
│       └── permission_helper_test.dart
│
├── widget/                              # Widget 测试
│   └── pages/
│       └── home_test.dart
│
└── integration/                         # 集成测试
    └── app_test.dart
```

## 📚 相关文档

- [改进详情](IMPROVEMENTS.md) - 详细的改进说明
- [快速开始](QUICK_START.md) - 快速开始指南

---

**最后更新**: 2026-05-22
