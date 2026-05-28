import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final headless =
        ModalRoute.of(context)!.settings.arguments as HeadlessInAppWebView;
    return WebViewExample(headless: headless);
  }
}

class WebViewExample extends StatefulWidget {
  final HeadlessInAppWebView headless;
  const WebViewExample({super.key, required this.headless});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    // 注意：6.x 的 fromHeadless 会保留所有事件和设置，但需要重新添加 handler
    // 这里采用另一种方式：不使用 fromHeadless，而是直接新建 InAppWebView 并复用缓存？
    // 但官方推荐 fromHeadless 来实现无缝切换，下面使用 fromHeadless
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_webViewController != null &&
            await _webViewController!.canGoBack()) {
          await _webViewController!.goBack();
          return false;
        } else {
          Navigator.of(context).pop();
          return true;
        }
      },
      child: Scaffold(
        // appBar: AppBar(title: const Text('WebView 页面')),
        body: InAppWebView(
          headlessWebView: widget.headless,
          onWebViewCreated: (controller) {
            _webViewController = controller;
            // 注入环境标识（再次确保）
            controller.evaluateJavascript(
              source: 'window.isInFlutterApp = true;',
            );
            // 注册 JavaScript Handler（接收网页消息）
            controller.addJavaScriptHandler(
              handlerName: 'AppNavigator',
              callback: (args) {
                print('收到网页消息: $args');
                if (args.isEmpty) return;
                final data = args[0];
                if (data is String) {
                  try {
                    final json = jsonDecode(data);
                    final pageName = json['page'] ?? data;
                    Navigator.pushNamed(context, '/$pageName', arguments: json);
                  } catch (e) {
                    // 纯字符串作为页面名称
                    Navigator.pushNamed(context, '/$data');
                  }
                } else {
                  // 如果不是字符串，直接传递
                  Navigator.pushNamed(context, '/$data');
                }
              },
            );
          },
          // 可选：添加 shouldOverrideUrlLoading 拦截自定义 scheme
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url?.toString() ?? '';
            if (url.startsWith('myapp://')) {
              final uri = WebUri(url);
              final id = uri.queryParameters['id'];
              final name = uri.queryParameters['name'];
              // 跳转到 Flutter 页面
              Navigator.pushNamed(
                context,
                uri.path,
                arguments: {'id': id, 'name': name},
              );
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
        ),
      ),
    );
  }
}
