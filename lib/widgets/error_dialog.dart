import 'package:flutter/material.dart';

/// 错误对话框
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool dismissible;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        if (dismissible)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        if (actionLabel != null && onAction != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAction?.call();
            },
            child: Text(actionLabel!),
          ),
      ],
    );
  }

  /// 显示错误对话框
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool dismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        dismissible: dismissible,
      ),
    );
  }
}

/// 加载对话框
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  /// 显示加载对话框
  static Future<void> show(
    BuildContext context, {
    required String message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }
}

/// 成功对话框
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final Duration duration;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.duration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    Future.delayed(duration, () {
      if (context.mounted) {
        Navigator.pop(context);
      }
    });

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
    );
  }

  /// 显示成功对话框
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        duration: duration,
      ),
    );
  }
}
