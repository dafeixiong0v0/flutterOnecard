import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rapid_kit/rapid_kit.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:app/router/index.dart';
import 'package:app/pages/tangevideo/video_call_manager.dart';
import 'package:app/pages/tangevideo/video_call_ui.dart';

class TangeVideoPage extends StatefulWidget {
  const TangeVideoPage({super.key});

  @override
  State<TangeVideoPage> createState() => _TangeVideoPageState();
}

class _TangeVideoPageState extends State<TangeVideoPage>
    with WidgetsBindingObserver {
  String? _deviceId;
  String? _deviceName;

  VideoCallManager? _manager;
  AudioPlayer? _ringtonePlayer;

  Timer? _timeoutTimer;

  bool _connecting = true;
  bool _hangUpDone = false;
  bool _timedOut = false;
  bool _establishFailed = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _startRingtone();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _deviceId = args?['deviceId'] as String?;
      _deviceName = args?['deviceName'] as String?;
      if (_deviceId != null && _deviceId!.isNotEmpty) {
        _initManager();
        _startTimeout();
      } else {
        setState(() {
          _connecting = false;
          _establishFailed = true;
        });
      }
    });
  }

  Future<void> _initManager() async {
    final manager = VideoCallManager(
      deviceId: _deviceId!,
      deviceName: _deviceName ?? '',
      onStateChanged: (state) {
        if (!mounted || _leaving) return;
        switch (state) {
          case 'established':
            _timeoutTimer?.cancel();
            _stopRingtone();
            setState(() => _connecting = false);
            _manager?.initializePlayer();
          case 'playerReady':
            _manager?.start();
          case 'intercomStarted':
          case 'intercomStopped':
          case 'speakerOn':
          case 'speakerOff':
            setState(() {});
        }
      },
      onError: (error) {
        if (!mounted || _leaving) return;
        setState(() {
          _establishFailed = true;
          _connecting = false;
        });
      },
    );

    setState(() => _manager = manager);

    final initResult = await manager.initialize();
    if (initResult.isSuccess) {
      manager.establish();
    }
  }

  @override
  void dispose() {
    _stopRingtone();
    _timeoutTimer?.cancel();
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    _manager?.cleanup();
    super.dispose();
  }

  void _startRingtone() {
    _ringtonePlayer = AudioPlayer();
    _ringtonePlayer!.setReleaseMode(ReleaseMode.loop);
    _ringtonePlayer!.play(AssetSource('sounds/ringtone.wav'));
  }

  void _stopRingtone() {
    _ringtonePlayer?.stop();
    _ringtonePlayer?.dispose();
    _ringtonePlayer = null;
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (!mounted || _leaving) return;
      _stopRingtone();
      setState(() {
        _timedOut = true;
        _connecting = false;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_leaving || _hangUpDone) return;
    if (state == AppLifecycleState.resumed) {
      _manager?.start();
    } else if (state == AppLifecycleState.paused) {
      _manager?.stop();
    }
  }

  Future<void> _toggleIntercom() async {
    if (_manager == null) return;
    final result = await _manager!.toggleIntercom(
      checkPermission:
          () => RuntimePermissions.accessGranted(PermissionType.microphone),
      requestPermission: () async {
        final state = await RuntimePermissions.requestAccess(
          PermissionType.microphone,
        );
        return state == PermissionState.granted;
      },
    );
    setState(() {});
    if (result.isFailure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.getExceptionOrNull().toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleSpeaker() {
    _manager?.toggleSpeaker();
    setState(() {});
  }

  void _hangUp() {
    if (_leaving) return;
    _leaving = true;
    _timeoutTimer?.cancel();
    _stopRingtone();
    _manager?.stop();
    setState(() => _hangUpDone = true);
  }

  void _returnToPreviousPage() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name != RouteNames.tangevideo);
  }

  void _retry() {
    setState(() {
      _establishFailed = false;
      _connecting = true;
    });
    _manager?.establish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: _buildBody());
  }

  Widget _buildBody() {
    if (_hangUpDone) {
      return HangUpUI(onReturn: _returnToPreviousPage);
    }

    if (_connecting) {
      return CallingUI(deviceName: _deviceName ?? '未知设备', onHangUp: _hangUp);
    }

    if (_timedOut) {
      return OfflineUI(
        deviceName: _deviceName ?? '未知设备',
        onRetry: _retry,
        onReturn: _returnToPreviousPage,
      );
    }

    if (_establishFailed) {
      return FailedUI(
        deviceName: _deviceName ?? '未知设备',
        onRetry: _retry,
        onReturn: _returnToPreviousPage,
      );
    }

    return _buildVideoUI();
  }

  Widget _buildVideoUI() {
    final mgr = _manager;
    final videoTexture = mgr?.texture;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (videoTexture != null)
          Positioned.fill(child: videoTexture)
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),

        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _deviceName ?? '未知设备',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon:
                    (mgr?.isSpeakerMode ?? true)
                        ? Icons.volume_up
                        : Icons.hearing,
                label: (mgr?.isSpeakerMode ?? true) ? '扬声器' : '听筒',
                onTap: _toggleSpeaker,
              ),
              const SizedBox(width: 32),
              _ControlButton(
                icon: Icons.call_end,
                label: '挂断',
                isHangUp: true,
                onTap: _hangUp,
              ),
              const SizedBox(width: 32),
              _ControlButton(
                icon:
                    (mgr?.isIntercomActive ?? false)
                        ? Icons.mic
                        : Icons.mic_none,
                label: (mgr?.isIntercomActive ?? false) ? '挂断对讲' : '对讲',
                isActive: mgr?.isIntercomActive ?? false,
                onTap: _toggleIntercom,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHangUp;
  final bool isActive;
  final VoidCallback onTap;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.isHangUp = false,
    this.isActive = false,
    required this.onTap,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color:
                  isHangUp
                      ? Colors.red
                      : isActive
                      ? Colors.green
                      : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
