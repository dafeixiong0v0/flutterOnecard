import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rapid_kit/rapid_kit.dart';
import 'package:app/core/logger.dart';
import 'package:app/core/exceptions.dart';
import 'package:app/core/result.dart';

/// 视频通话管理器
/// 封装视频通话的核心逻辑
class VideoCallManager {
  final String deviceId;
  final String deviceName;

  Pipe? _pipe;
  LiveStream? _liveStream;
  Player? _player;
  MediaChat? _mediaChat;

  bool _established = false;
  bool _playerReady = false;
  bool _intercomActive = false;
  bool _speakerMode = true;

  // 回调
  final Function(String)? onStateChanged;
  final Function(String)? onError;

  VideoCallManager({
    required this.deviceId,
    required this.deviceName,
    this.onStateChanged,
    this.onError,
  });

  bool get isEstablished => _established;
  bool get isPlayerReady => _playerReady;
  bool get isIntercomActive => _intercomActive;
  bool get isSpeakerMode => _speakerMode;

  Widget? get texture => _player?.texture();

  /// 初始化视频通话
  Future<Result<void>> initialize() async {
    try {
      Logger.info('初始化视频通话: $deviceName ($deviceId)');

      _pipe = Pipe.create(deviceId);
      _pipe!.listen((state) {
        _handlePipeStateChange(state);
      });

      _liveStream = LiveStream.createPrimary(_pipe!);
      _liveStream!.highQuality();

      _player = Player.create();

      Logger.info('视频通话组件初始化完成');
      return Result.success(null);
    } catch (e, stackTrace) {
      final error = VideoCallException(
        message: '初始化视频通话失败',
        originalException: e,
        stackTrace: stackTrace,
      );
      Logger.error(error.message, e, stackTrace);
      onError?.call(error.message);
      return Result.failure(error);
    }
  }

  /// 建立连接
  Future<Result<void>> establish() async {
    try {
      if (_pipe == null) {
        throw VideoCallException(message: '管道未初始化');
      }

      Logger.info('建立连接...');
      _pipe!.establish();
      return Result.success(null);
    } catch (e, stackTrace) {
      final error = VideoCallException(
        message: '建立连接失败',
        originalException: e,
        stackTrace: stackTrace,
      );
      Logger.error(error.message, e, stackTrace);
      onError?.call(error.message);
      return Result.failure(error);
    }
  }

  /// 初始化播放器
  Future<Result<void>> initializePlayer() async {
    try {
      if (_liveStream == null || _player == null) {
        throw VideoCallException(message: '直播流或播放器未初始化');
      }

      final provider = _liveStream!.provider();
      if (provider == null) {
        throw VideoCallException(message: '无法获取直播流提供者');
      }

      await _player!.prepare(provider);
      _playerReady = true;

      Logger.info('播放器初始化完成');
      onStateChanged?.call('playerReady');
      return Result.success(null);
    } catch (e, stackTrace) {
      final error = VideoCallException(
        message: '初始化播放器失败',
        originalException: e,
        stackTrace: stackTrace,
      );
      Logger.error(error.message, e, stackTrace);
      onError?.call(error.message);
      return Result.failure(error);
    }
  }

  /// 启动视频流
  Future<Result<void>> start() async {
    try {
      if (_pipe == null || !_established) {
        throw VideoCallException(message: '管道未建立');
      }

      _liveStream?.start();
      _player?.start();

      Logger.info('视频流已启动');
      onStateChanged?.call('started');
      return Result.success(null);
    } catch (e, stackTrace) {
      final error = VideoCallException(
        message: '启动视频流失败',
        originalException: e,
        stackTrace: stackTrace,
      );
      Logger.error(error.message, e, stackTrace);
      onError?.call(error.message);
      return Result.failure(error);
    }
  }

  /// 停止视频流
  Future<Result<void>> stop() async {
    try {
      if (_mediaChat != null && _mediaChat!.started()) {
        _mediaChat!.stop();
      }
      _liveStream?.stop();
      _player?.stop();

      Logger.info('视频流已停止');
      onStateChanged?.call('stopped');
      return Result.success(null);
    } catch (e, stackTrace) {
      final error = VideoCallException(
        message: '停止视频流失败',
        originalException: e,
        stackTrace: stackTrace,
      );
      Logger.error(error.message, e, stackTrace);
      return Result.failure(error);
    }
  }

  /// 切换对讲
  Future<Result<void>> toggleIntercom({
    required Future<bool> Function() checkPermission,
    required Future<bool> Function() requestPermission,
  }) async {
    try {
      _mediaChat ??= MediaChat.create(_pipe!);
      final mediaChat = _mediaChat;

      if (mediaChat == null || _pipe == null || !_established) {
        throw VideoCallException(message: '无法切换对讲：连接未建立');
      }

      if (mediaChat.started()) {
        mediaChat.stop();
        _intercomActive = false;
        Logger.info('对讲已关闭');
        onStateChanged?.call('intercomStopped');
        return Result.success(null);
      }

      // 检查权限
      final granted = await checkPermission();
      if (!granted) {
        final requested = await requestPermission();
        if (!requested) {
          throw VideoCallException(message: '需要麦克风权限才能对讲');
        }
      }

      // 配置音频处理
      mediaChat.configureAudioProcessing(
        const IntercomAudioProcessingConfig(aecLevel: 0),
      );
      await mediaChat.prepare();
      mediaChat.start(sampleRate: MediaChat.sampleRate16k);

      _intercomActive = true;
      Logger.info('对讲已启动');
      onStateChanged?.call('intercomStarted');
      return Result.success(null);
    } catch (e, stackTrace) {
      final error = VideoCallException(
        message: '切换对讲失败',
        originalException: e,
        stackTrace: stackTrace,
      );
      Logger.error(error.message, e, stackTrace);
      onError?.call(error.message);
      return Result.failure(error);
    }
  }

  /// 切换扬声器/听筒
  void toggleSpeaker() {
    try {
      if (_player == null) return;

      _speakerMode = !_speakerMode;
      _player!.setAudioOutputMode(
        _speakerMode ? AudioOutputMode.media : AudioOutputMode.voice,
      );

      Logger.info('音频输出模式已切换: ${_speakerMode ? "扬声器" : "听筒"}');
      onStateChanged?.call(_speakerMode ? 'speakerOn' : 'speakerOff');
    } catch (e, stackTrace) {
      Logger.error('切换扬声器失败', e, stackTrace);
    }
  }

  /// 清理资源
  Future<Result<void>> cleanup() async {
    try {
      Logger.info('清理视频通话资源...');

      if (_mediaChat != null && _mediaChat!.started()) {
        _mediaChat!.stop();
      }
      _mediaChat?.destroy();

      _player?.stop();
      _player?.destroy();

      _liveStream?.stop();
      _liveStream?.destroy();

      _pipe?.abolish();
      _pipe?.destroy();

      _established = false;
      _playerReady = false;
      _intercomActive = false;

      Logger.info('资源清理完成');
      return Result.success(null);
    } catch (e, stackTrace) {
      final error = VideoCallException(
        message: '清理资源失败',
        originalException: e,
        stackTrace: stackTrace,
      );
      Logger.error(error.message, e, stackTrace);
      return Result.failure(error);
    }
  }

  /// 处理管道状态变化
  void _handlePipeStateChange(PipeState state) {
    Logger.info('管道状态变化: $state');

    switch (state) {
      case PipeState.established:
        _established = true;
        onStateChanged?.call('established');
        break;
      case PipeState.failed:
        _established = false;
        onError?.call('连接失败');
        break;
      default:
        break;
    }
  }
}
