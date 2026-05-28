import 'dart:async';
import 'package:rapid_kit/rapid_kit.dart';
import 'package:app/core/logger.dart';
import 'package:app/core/exceptions.dart';
import 'package:app/core/result.dart';

class SdkConfig {
  final String appId;
  final String packageName;
  final String accessToken;

  SdkConfig({
    required this.appId,
    required this.packageName,
    required this.accessToken,
  });

  bool get isValid => appId.isNotEmpty && accessToken.isNotEmpty;
}

/// 改进的 SDK 管理器
/// 提供更好的错误处理和状态管理
class SdkManagerImproved {
  static final SdkManagerImproved _instance = SdkManagerImproved._();

  factory SdkManagerImproved() => _instance;

  SdkManagerImproved._();

  bool _initialized = false;
  bool _authenticated = false;
  final Completer<void> _readyCompleter = Completer<void>();
  String? _lastError;

  Future<Result<void>> init(SdkConfig config) async {
    if (_initialized) {
      Logger.info('SDK 已初始化，跳过重复初始化');
      return Result.success(null);
    }

    if (!config.isValid) {
      final error = SdkInitException(
        message:
            '配置参数不完整: appId=${config.appId.isEmpty ? "缺失" : "有效"}, accessToken=${config.accessToken.isEmpty ? "缺失" : "有效"}',
      );
      _lastError = error.message;
      Logger.error(error.message);
      return Result.failure(error);
    }

    try {
      Logger.info('开始初始化 SDK...');

      final ok = await RapidKit.initialize(
        Configurations(
          id: config.appId,
          package: config.packageName,
          httpLogging: false,
          debugging: false,
          environment: Environment.values[0],
        ),
      );

      if (ok) {
        _initialized = true;
        Logger.info('SDK 初始化成功');
        return Result.success(null);
      } else {
        final error = SdkInitException(message: 'RapidKit.initialize 返回 false');
        _lastError = error.message;
        Logger.error(error.message);
        return Result.failure(error);
      }
    } catch (e, stackTrace) {
      final error = SdkInitException(
        message: '初始化过程中发生异常',
        originalException: e,
        stackTrace: stackTrace,
      );
      _lastError = error.message;
      Logger.error(error.message, e, stackTrace);
      return Result.failure(error);
    }
  }

  Future<Result<void>> auth(String accessToken) async {
    if (_authenticated) {
      Logger.info('SDK 已认证，跳过重复认证');
      return Result.success(null);
    }

    if (!_initialized) {
      final error = SdkAuthException(message: 'SDK 未初始化，无法进行认证');
      _lastError = error.message;
      Logger.error(error.message);
      return Result.failure(error);
    }

    if (accessToken.isEmpty) {
      final error = SdkAuthException(message: 'accessToken 为空');
      _lastError = error.message;
      Logger.error(error.message);
      return Result.failure(error);
    }

    try {
      Logger.info('开始认证 SDK...');

      final resp = await Authenticate.configure(accessToken);

      if (resp.success) {
        _authenticated = true;
        if (!_readyCompleter.isCompleted) {
          _readyCompleter.complete();
        }
        Logger.info('SDK 认证成功');
        return Result.success(null);
      } else {
        final error = SdkAuthException(message: 'Authenticate.configure 返回失败');
        _lastError = error.message;
        Logger.error(error.message);
        return Result.failure(error);
      }
    } catch (e, stackTrace) {
      final error = SdkAuthException(
        message: '认证过程中发生异常',
        originalException: e,
        stackTrace: stackTrace,
      );
      _lastError = error.message;
      Logger.error(error.message, e, stackTrace);
      return Result.failure(error);
    }
  }

  /// 等待 SDK 就绪
  Future<Result<void>> waitUntilReady({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (isReady) {
      return Result.success(null);
    }

    try {
      await _readyCompleter.future.timeout(timeout);
      return Result.success(null);
    } on TimeoutException catch (e, stackTrace) {
      final error = SdkInitException(
        message: 'SDK 就绪超时 (${timeout.inSeconds}秒)',
        originalException: e,
        stackTrace: stackTrace,
      );
      _lastError = error.message;
      Logger.error(error.message, e, stackTrace);
      return Result.failure(error);
    } catch (e, stackTrace) {
      final error = SdkInitException(
        message: '等待 SDK 就绪时发生异常',
        originalException: e,
        stackTrace: stackTrace,
      );
      _lastError = error.message;
      Logger.error(error.message, e, stackTrace);
      return Result.failure(error);
    }
  }

  bool get isReady => _initialized && _authenticated;
  bool get isInitialized => _initialized;
  bool get isAuthenticated => _authenticated;
  String? get lastError => _lastError;

  /// 重置状态
  void reset() {
    _initialized = false;
    _authenticated = false;
    _lastError = null;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError('SDK 已重置');
    }
  }
}
