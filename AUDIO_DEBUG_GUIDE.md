# 音频对讲调试指南

## 🎤 问题：手机端说话没有声音到设备端

### 🔍 问题分析

根据代码分析，可能的原因：

1. **回声消除（AEC）配置不当** - `aecLevel: 1` 可能过滤掉了你的声音
2. **麦克风权限未授予**
3. **音频采样率不匹配**
4. **MediaChat 未正确启动**
5. **设备端未正确接收音频流**

---

## 🔧 解决方案

### 方案 1：禁用回声消除（推荐先测试）

```dart
mediaChat.configureAudioProcessing(
  const IntercomAudioProcessingConfig(
    aecLevel: 0, // 禁用 AEC
  ),
);
```

**优点**：最简单，适合测试  
**缺点**：可能有回声

---

### 方案 2：使用半双工模式

```dart
mediaChat.configureAudioProcessing(
  const IntercomAudioProcessingConfig(
    aecLevel: 2, // 半双工模式（按下说话）
  ),
);
```

**优点**：避免回声，声音清晰  
**缺点**：需要按住按钮说话

---

### 方案 3：调整全双工模式参数

```dart
mediaChat.configureAudioProcessing(
  const IntercomAudioProcessingConfig(
    aecLevel: 1, // 全双工模式
    // 可能需要其他参数，查看 rapid_kit 文档
  ),
);
```

---

## 📝 测试步骤

### 1. 检查麦克风权限

```dart
// 在 _toggleIntercom() 中添加日志
print('🎤 检查麦克风权限...');
final granted = await RuntimePermissions.accessGranted(
  PermissionType.microphone,
);
print('🎤 麦克风权限: $granted');
```

**验证**：
- 查看控制台日志
- 确认权限已授予

---

### 2. 测试不同的 AEC 级别

#### 测试 aecLevel: 0（禁用 AEC）

```dart
mediaChat.configureAudioProcessing(
  const IntercomAudioProcessingConfig(aecLevel: 0),
);
```

**测试**：
1. 启动对讲
2. 对着手机说话
3. 检查设备端是否有声音

#### 测试 aecLevel: 2（半双工）

```dart
mediaChat.configureAudioProcessing(
  const IntercomAudioProcessingConfig(aecLevel: 2),
);
```

**测试**：
1. 按住对讲按钮
2. 对着手机说话
3. 释放按钮
4. 检查设备端是否有声音

---

### 3. 测试不同的采样率

```dart
// 测试 8kHz
mediaChat.start(sampleRate: MediaChat.sampleRate8k);

// 测试 16kHz（默认）
mediaChat.start(sampleRate: MediaChat.sampleRate16k);

// 测试 32kHz
mediaChat.start(sampleRate: MediaChat.sampleRate32k);
```

---

### 4. 检查 MediaChat 状态

```dart
print('🎤 MediaChat 已启动: ${mediaChat.started()}');
print('🎤 Pipe 已建立: ${_pipe!.isEstablished}');
```

---

## 🐛 调试代码

### 完整的调试版本

```dart
Future<void> _toggleIntercom() async {
  print('═══════════════════════════════════════');
  print('🎤 开始对讲调试');
  print('═══════════════════════════════════════');
  
  _mediaChat ??= MediaChat.create(_pipe!);
  final mediaChat = _mediaChat;
  
  if (mediaChat == null || _pipe == null || !_pipe!.isEstablished) {
    print('❌ 对讲条件不满足');
    print('   MediaChat: ${mediaChat != null}');
    print('   Pipe: ${_pipe != null}');
    print('   Pipe 已建立: ${_pipe?.isEstablished}');
    return;
  }

  if (mediaChat.started()) {
    print('🎤 停止对讲');
    mediaChat.stop();
    setState(() => _intercomActive = false);
    print('✅ 对讲已停止');
    return;
  }

  // 检查权限
  print('🎤 检查麦克风权限...');
  final granted = await RuntimePermissions.accessGranted(
    PermissionType.microphone,
  );
  print('🎤 麦克风权限: $granted');
  
  if (!granted) {
    print('🎤 请求麦克风权限...');
    final state = await RuntimePermissions.requestAccess(
      PermissionType.microphone,
    );
    print('🎤 权限请求结果: $state');
    
    if (state == PermissionState.denied) {
      print('❌ 麦克风权限被拒绝');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需要麦克风权限才能对讲'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
  }

  try {
    // 配置音频处理
    print('🎤 配置音频处理...');
    print('   AEC Level: 0 (禁用回声消除)');
    mediaChat.configureAudioProcessing(
      const IntercomAudioProcessingConfig(aecLevel: 0),
    );
    print('✅ 音频处理配置完成');
    
    // 准备对讲
    print('🎤 准备对讲...');
    await mediaChat.prepare();
    print('✅ 对讲准备完成');
    
    // 启动对讲
    print('🎤 启动对讲...');
    print('   采样率: 16kHz');
    mediaChat.start(sampleRate: MediaChat.sampleRate16k);
    print('✅ 对讲已启动');
    
    // 检查状态
    print('🎤 检查对讲状态...');
    print('   MediaChat.started(): ${mediaChat.started()}');
    print('   Pipe.isEstablished: ${_pipe!.isEstablished}');
    
    setState(() => _intercomActive = true);
    
    print('═══════════════════════════════════════');
    print('✅ 对讲启动成功');
    print('═══════════════════════════════════════');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('对讲已开启，请说话测试'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e, stackTrace) {
    print('═══════════════════════════════════════');
    print('❌ 对讲启动失败');
    print('═══════════════════════════════════════');
    print('错误: $e');
    print('堆栈: $stackTrace');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('对讲启动失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

## 📊 测试矩阵

| AEC Level | 采样率 | 结果 | 备注 |
|-----------|--------|------|------|
| 0 | 8kHz | ⬜ 待测试 | 禁用 AEC，低采样率 |
| 0 | 16kHz | ⬜ 待测试 | 禁用 AEC，标准采样率 |
| 0 | 32kHz | ⬜ 待测试 | 禁用 AEC，高采样率 |
| 1 | 8kHz | ⬜ 待测试 | 全双工，低采样率 |
| 1 | 16kHz | ⬜ 待测试 | 全双工，标准采样率 |
| 1 | 32kHz | ⬜ 待测试 | 全双工，高采样率 |
| 2 | 8kHz | ⬜ 待测试 | 半双工，低采样率 |
| 2 | 16kHz | ⬜ 待测试 | 半双工，标准采样率 |
| 2 | 32kHz | ⬜ 待测试 | 半双工，高采样率 |

---

## 🔍 常见问题

### Q1: 对讲按钮点击后没有反应

**检查**：
1. 查看控制台日志
2. 确认 Pipe 已建立
3. 确认麦克风权限已授予

**解决**：
```dart
print('Pipe 已建立: ${_pipe!.isEstablished}');
print('麦克风权限: ${await RuntimePermissions.accessGranted(PermissionType.microphone)}');
```

---

### Q2: 对讲启动成功但设备端听不到声音

**可能原因**：
1. AEC 级别设置不当
2. 采样率不匹配
3. 设备端未正确接收

**解决**：
1. 尝试 `aecLevel: 0`
2. 尝试不同的采样率
3. 检查设备端日志

---

### Q3: 有回声

**原因**：禁用了 AEC

**解决**：
1. 使用 `aecLevel: 1` 或 `aecLevel: 2`
2. 降低扬声器音量
3. 使用耳机

---

### Q4: 声音断断续续

**可能原因**：
1. 网络不稳定
2. 采样率过高
3. CPU 负载过高

**解决**：
1. 检查网络连接
2. 降低采样率到 8kHz
3. 关闭其他应用

---

## 📱 设备端检查

### 检查设备端是否正确接收

1. **查看设备端日志**
   - 确认设备端收到音频流
   - 确认音频解码正常

2. **检查设备端音频输出**
   - 确认扬声器正常工作
   - 确认音量设置正确

3. **测试设备端麦克风**
   - 确认设备端可以发送音频到手机端
   - 如果设备端到手机端正常，说明通道是通的

---

## 🎯 推荐测试顺序

1. **第一步：禁用 AEC**
   ```dart
   aecLevel: 0
   sampleRate: MediaChat.sampleRate16k
   ```
   - 如果能听到声音 → AEC 配置问题
   - 如果听不到 → 继续下一步

2. **第二步：测试不同采样率**
   ```dart
   aecLevel: 0
   sampleRate: MediaChat.sampleRate8k  // 尝试 8kHz
   ```
   - 如果能听到声音 → 采样率问题
   - 如果听不到 → 继续下一步

3. **第三步：检查权限和状态**
   - 确认麦克风权限已授予
   - 确认 MediaChat.started() 返回 true
   - 确认 Pipe.isEstablished 为 true

4. **第四步：检查设备端**
   - 查看设备端日志
   - 确认设备端正常接收音频流

---

## 📞 联系技术支持

如果以上方法都无法解决问题，请联系 Tange AI 技术支持：

- 文档：https://tange-ai.feishu.cn/wiki/DHQ2wyUXKiVwmDkk7FYcv1n7n7e
- SDK：https://pub.dev/packages/rapid_kit

提供以下信息：
1. 完整的控制台日志
2. 测试矩阵结果
3. 设备型号和系统版本
4. 网络环境

---

**最后更新**: 2026-05-22
