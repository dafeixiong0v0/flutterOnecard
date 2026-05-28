import 'dart:async';
import 'package:rapid_kit/rapid_kit.dart';

class SdkConfig {
  String appId;
  String packageName;
  String accessToken;

  SdkConfig({this.appId = '', this.packageName = '', this.accessToken = ''});

  bool get isReady => appId.isNotEmpty && accessToken.isNotEmpty;
}

class SdkManager {
  static final SdkManager _instance = SdkManager._();
  factory SdkManager() => _instance;
  SdkManager._();

  bool _initialized = false;
  bool _authenticated = false;
  final Completer<void> _readyCompleter = Completer<void>();

  Future<bool> init(SdkConfig config) async {
    if (_initialized) return true;

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
      print('SDK 初始化完成');
    }
    return ok;
  }

  Future<bool> auth(String accessToken) async {
    if (_authenticated) return true;

    final resp = await Authenticate.configure(accessToken);
    if (resp.success) {
      _authenticated = true;
      if (!_readyCompleter.isCompleted) _readyCompleter.complete();
      print('SDK 认证完成');
    }
    return resp.success;
  }

  Future<void> waitUntilReady() => _readyCompleter.future;

  bool get isReady => _initialized && _authenticated;
}
