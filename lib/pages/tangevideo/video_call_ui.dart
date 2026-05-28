import 'package:flutter/material.dart';

/// 视频通话 UI 组件

/// 响铃状态 UI
class CallingUI extends StatelessWidget {
  final String deviceName;
  final VoidCallback onHangUp;

  const CallingUI({
    super.key,
    required this.deviceName,
    required this.onHangUp,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_in_talk, color: Colors.white54, size: 72),
              const SizedBox(height: 20),
              Text(
                deviceName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '正在连接...',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              FloatingActionButton(
                onPressed: onHangUp,
                backgroundColor: Colors.red,
                child: const Icon(Icons.call_end, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 视频通话 UI
class VideoUI extends StatelessWidget {
  final String deviceName;
  final bool intercomActive;
  final bool speakerMode;
  final VoidCallback onToggleIntercom;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onHangUp;

  const VideoUI({
    super.key,
    required this.deviceName,
    required this.intercomActive,
    required this.speakerMode,
    required this.onToggleIntercom,
    required this.onToggleSpeaker,
    required this.onHangUp,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        // 设备名称
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Text(
            deviceName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // 控制按钮
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 对讲按钮
              FloatingActionButton(
                onPressed: onToggleIntercom,
                backgroundColor: intercomActive ? Colors.green : Colors.grey,
                child: Icon(
                  intercomActive ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                ),
              ),
              // 扬声器按钮
              FloatingActionButton(
                onPressed: onToggleSpeaker,
                backgroundColor: speakerMode ? Colors.blue : Colors.grey,
                child: Icon(
                  speakerMode ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
              ),
              // 挂断按钮
              FloatingActionButton(
                onPressed: onHangUp,
                backgroundColor: Colors.red,
                child: const Icon(Icons.call_end, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 离线状态 UI
class OfflineUI extends StatelessWidget {
  final String deviceName;
  final VoidCallback onRetry;
  final VoidCallback onReturn;

  const OfflineUI({
    super.key,
    required this.deviceName,
    required this.onRetry,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: Colors.orange, size: 72),
              const SizedBox(height: 20),
              const Text(
                '设备离线',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                deviceName,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: onReturn,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('返回'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 连接失败 UI
class FailedUI extends StatelessWidget {
  final String deviceName;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onReturn;

  const FailedUI({
    super.key,
    required this.deviceName,
    this.errorMessage,
    required this.onRetry,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 72),
              const SizedBox(height: 20),
              const Text(
                '连接失败',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                deviceName,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: onReturn,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('返回'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 已挂断 UI
class HangUpUI extends StatelessWidget {
  final VoidCallback onReturn;

  const HangUpUI({
    super.key,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.call_end, color: Colors.white54, size: 72),
              const SizedBox(height: 20),
              const Text(
                '已挂断',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onReturn,
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
