import 'package:permission_handler/permission_handler.dart';
import 'package:app/core/logger.dart';
import 'package:app/core/exceptions.dart';
import 'package:app/core/result.dart';

/// 权限管理助手
class PermissionHelper {
  /// 请求单个权限
  static Future<Result<bool>> requestPermission(Permission permission) async {
    try {
      Logger.info('请求权限: ${permission.toString()}');

      final status = await permission.request();

      if (status.isGranted) {
        Logger.info('权限已授予: ${permission.toString()}');
        return Result.success(true);
      } else if (status.isDenied) {
        final error = PermissionException(
          message: '用户拒绝了权限: ${permission.toString()}',
        );
        Logger.warning(error.message);
        return Result.failure(error);
      } else if (status.isPermanentlyDenied) {
        final error = PermissionException(
          message: '权限被永久拒绝，请在设置中手动启用: ${permission.toString()}',
        );
        Logger.warning(error.message);
        return Result.failure(error);
      } else {
        final error = PermissionException(
          message: '权限状态未知: ${permission.toString()} - $status',
        );
        Logger.warning(error.message);
        return Result.failure(error);
      }
    } catch (e, stackTrace) {
      final error = PermissionException(
        message: '请求权限时发生异常',
        originalException: e,
        stackTrace: stackTrace,
      );
      Logger.error(error.message, e, stackTrace);
      return Result.failure(error);
    }
  }

  /// 请求多个权限
  static Future<Result<Map<Permission, PermissionStatus>>> requestPermissions(
    List<Permission> permissions,
  ) async {
    try {
      Logger.info('请求多个权限: ${permissions.map((p) => p.toString()).join(", ")}');

      final statuses = await permissions.request();

      final allGranted = statuses.values.every((status) => status.isGranted);

      if (allGranted) {
        Logger.info('所有权限已授予');
        return Result.success(statuses);
      } else {
        final deniedPermissions = statuses.entries
            .where((e) => !e.value.isGranted)
            .map((e) => e.key.toString())
            .join(", ");

        final error = PermissionException(
          message: '部分权限被拒绝: $deniedPermissions',
        );
        Logger.warning(error.message);
        return Result.failure(error);
      }
    } catch (e, stackTrace) {
      final error = PermissionException(
        message: '请求权限时发生异常',
        originalException: e,
        stackTrace: stackTrace,
      );
      Logger.error(error.message, e, stackTrace);
      return Result.failure(error);
    }
  }

  /// 检查权限状态
  static Future<bool> hasPermission(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      Logger.error('检查权限时发生异常', e);
      return false;
    }
  }

  /// 检查多个权限
  static Future<bool> hasPermissions(List<Permission> permissions) async {
    try {
      final statuses = await Future.wait(
        permissions.map((p) => p.status),
      );
      return statuses.every((status) => status.isGranted);
    } catch (e) {
      Logger.error('检查权限时发生异常', e);
      return false;
    }
  }

  /// 打开应用设置
  static Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      Logger.error('打开应用设置时发生异常', e);
      return false;
    }
  }
}
