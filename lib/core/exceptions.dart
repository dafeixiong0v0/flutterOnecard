/// 应用异常基类
abstract class AppException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// SDK 初始化异常
class SdkInitException extends AppException {
  SdkInitException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: 'SDK 初始化失败: $message',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// SDK 认证异常
class SdkAuthException extends AppException {
  SdkAuthException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: 'SDK 认证失败: $message',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// 权限异常
class PermissionException extends AppException {
  PermissionException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: '权限错误: $message',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// 视频通话异常
class VideoCallException extends AppException {
  VideoCallException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: '视频通话错误: $message',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// 网络异常
class NetworkException extends AppException {
  NetworkException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: '网络错误: $message',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}
