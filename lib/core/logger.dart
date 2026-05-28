import 'package:app/config/app_config.dart';

/// 日志管理器
class Logger {
  static const String _tag = 'App';

  /// 调试日志
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.isDevelopment()) {
      print('[$_tag] DEBUG: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  /// 信息日志
  static void info(String message) {
    print('[$_tag] INFO: $message');
  }

  /// 警告日志
  static void warning(String message, [dynamic error]) {
    print('[$_tag] WARNING: $message');
    if (error != null) print('Error: $error');
  }

  /// 错误日志
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[$_tag] ERROR: $message');
    if (error != null) print('Error: $error');
    if (stackTrace != null) print('StackTrace: $stackTrace');
  }
}
