import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';
import 'package:app/pages/home/sdk_manager_improved.dart';
import 'package:app/router/index.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/config/app_config.dart';
import 'package:app/core/logger.dart';
import 'package:app/widgets/error_dialog.dart';
import 'package:app/store/app_state.dart';

const String _bridgeScript = '''
(function() {
  window.isInFlutterApp = true;
  window.AppNavigator = {
    postMessage: function(data) {
      window.flutter_inappwebview.callHandler('AppNavigator', data);
    }
  };
  // ⭐ 新增：接收来自 Flutter 的消息
 window.receiveFromFlutter = function(data) {
  console.log('收到 Flutter 消息:', JSON.stringify(data));
  // 直接调用 Vue 暴露的全局方法
  if (window.__handleFlutterMessage) {
    window.__handleFlutterMessage(data);
  } else {
    // 降级为 CustomEvent
    window.dispatchEvent(new CustomEvent('flutter-message', { detail: data }));
  }
};
})();
''';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebViewPage();
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _webViewController;
  bool _isOpeningVideoPage = false;
  late SdkManagerImproved _sdkManager;
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _sdkManager = SdkManagerImproved();
    _appState = AppState();
    _appState.setSdkManager(_sdkManager);
    _ensurePermissions();
  }

  Future<void> _ensurePermissions() async {
    try {
      Logger.info('请求必要权限...');
      await [
        Permission.camera,
        Permission.photos,
        Permission.storage,
      ].request();
      Logger.info('权限请求完成');
    } catch (e) {
      Logger.error('权限请求失败', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_webViewController != null &&
            await _webViewController!.canGoBack()) {
          await _webViewController!.goBack();
        } else {
          if (context.mounted) {
            await SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(AppConfig.getWebViewUrl()),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                ),
                onWebViewCreated: _onWebViewCreated,
                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(source: _bridgeScript);
                  Logger.info('页面加载完成: $url');
                },
                onPermissionRequest: (controller, permissionRequest) async {
                  return PermissionResponse(
                    resources: permissionRequest.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },
                shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
              ),
            );
          },
        ),
      ),
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;

    controller.addJavaScriptHandler(
      handlerName: 'AppNavigator',
      callback: (args) {
        Logger.info('收到网页消息: $args');
        if (args.isEmpty) return;
        final data = args[0];
        if (data is! String) return;

        try {
          final msg = jsonDecode(data);
          final type = msg['type'] as String?;

          if (type == 'init') {
            _handleInit(msg);
          } else if (type == 'call') {
            _handleCall(msg);
          } else if (type == 'scan') {
            _handleScan(msg);
          }
        } catch (e) {
          if (data == 'tangevideo') {
            Logger.warning('忽略旧协议消息: $data，请改用 type=call 并传 deviceId');
            return;
          }
          if (data == 'scan') {
            Logger.warning('收到旧版扫码协议，建议改用 type=scan');
            _handleScan(const {});
            return;
          }
          Navigator.pushNamed(context, '/$data');
        }
      },
    );

    controller.evaluateJavascript(source: _bridgeScript);
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
      await _notifyWebMessage({'type': 'authSuccess'});
    } catch (e) {
      Logger.error('通知 Web 认证成功失败', e);
    }
  }

  void _notifyWebAuthFailed(String reason) async {
    try {
      await _notifyWebMessage({'type': 'authFailed', 'reason': reason});
    } catch (e) {
      Logger.error('通知 Web 认证失败失败', e);
    }
  }

  Future<void> _notifyWebMessage(Map<String, dynamic> message) async {
    final payload = jsonEncode(message);
    await _webViewController?.evaluateJavascript(
      source: 'window.receiveFromFlutter($payload);',
    );
  }

  void _handleCall(Map<String, dynamic> msg) async {
    final deviceId = msg['deviceId'] as String? ?? '';
    final deviceName = msg['deviceName'] as String? ?? '';

    if (deviceId.isEmpty || _isOpeningVideoPage) return;

    Logger.info('收到呼叫请求，设备ID: $deviceId，设备名称: $deviceName');
    _isOpeningVideoPage = true;

    try {
      // 等待 SDK 初始化 + 认证完成后再跳转
      if (!_sdkManager.isReady) {
        Logger.info('SDK 还未就绪，等待中...');

        if (!mounted) {
          _isOpeningVideoPage = false;
          return;
        }

        await LoadingDialog.show(context, message: '正在初始化，请稍候...');

        final waitResult = await _sdkManager.waitUntilReady(
          timeout: Duration(seconds: AppConfig.sdkReadyTimeoutSeconds),
        );

        if (mounted) Navigator.pop(context);

        if (waitResult.isFailure) {
          Logger.warning('SDK 就绪超时，仍然尝试连接');
          if (mounted) {
            await ErrorDialog.show(
              context,
              title: '初始化超时',
              message: 'SDK 初始化超时，但仍将尝试连接。如果连接失败，请重试。',
            );
          }
        } else {
          Logger.info('SDK 已就绪，准备跳转');
        }
      }

      if (!mounted) {
        _isOpeningVideoPage = false;
        return;
      }

      _appState.setCurrentDevice(deviceId, deviceName);

      await Navigator.pushNamed(
        context,
        RouteNames.tangevideo,
        arguments: {'deviceId': deviceId, 'deviceName': deviceName},
      );
    } catch (e, stackTrace) {
      Logger.error('处理呼叫请求时发生异常', e, stackTrace);
      if (mounted) {
        await ErrorDialog.show(
          context,
          title: '错误',
          message: '处理呼叫请求时发生异常: $e',
        );
      }
    } finally {
      _isOpeningVideoPage = false;
    }
  }

  void _handleScan(Map<String, dynamic> msg) async {
    final callbackId = msg['callbackId'];
    // debugger();
    try {
      final dynamic result = await Navigator.pushNamed(
        context,
        RouteNames.scan,
      );

      final String code = result is String ? result : '';

      await _notifyWebMessage({
        'type': 'scanResult',
        'code': code,
        'cancelled': code.isEmpty,
        'callbackId': callbackId,
      });
    } catch (e, stackTrace) {
      Logger.error('处理扫码请求时发生异常', e, stackTrace);
      await _notifyWebMessage({
        'type': 'scanResult',
        'code': '',
        'cancelled': true,
        'callbackId': callbackId,
        'error': e.toString(),
      });
    }
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final url = navigationAction.request.url?.toString() ?? '';
    final uri = navigationAction.request.url;

    if (url.startsWith('myapp://')) {
      final appUri = WebUri(url);
      final id = appUri.queryParameters['id'];
      final name = appUri.queryParameters['name'];
      Navigator.pushNamed(
        context,
        appUri.path,
        arguments: {'id': id, 'name': name},
      );
      return NavigationActionPolicy.CANCEL;
    }

    if (uri != null &&
        uri.host == 'wc.faceds.cc' &&
        uri.path.startsWith('/pages/')) {
      final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
      final rewrittenUrl =
          'https://wc.faceds.cc/phone/index.html#${uri.path}$query';
      Logger.info('修正 H5 路由: $url -> $rewrittenUrl');
      await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(rewrittenUrl)),
      );
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }
}
