/// 应用配置管理
/// 集中管理所有硬编码的配置参数
class AppConfig {
  // 环境配置
  static const String environment =
      'development'; // development, staging, production

  // WebView 配置
  static const String webViewUrl = 'http://192.168.1.188:9018/#/';
  // 可选的备用 URL
  static const String webViewUrlBackup =
      'https://wc.faceds.cc/phone/index.html#/pages/home/home';

  // 视频通话配置
  static const int videoCallTimeoutSeconds = 60;
  static const int sdkReadyTimeoutSeconds = 10;

  // SDK 配置
  static const bool sdkHttpLogging = true;
  static const bool sdkDebugging = true;

  // 权限配置
  static const List<String> requiredPermissions = [
    'camera',
    'microphone',
    'storage',
  ];

  // 音频配置
  static const int audioAecLevel = 1; // 回声消除等级
  static const int audioSampleRate = 16000; // 采样率

  /// 获取当前环境的 WebView URL
  static String getWebViewUrl() {
    return webViewUrlBackup;
  }

  /// 检查是否为开发环境
  static bool isDevelopment() => environment == 'development';

  /// 检查是否为生产环境
  static bool isProduction() => environment == 'production';

  /// 获取日志级别
  static String getLogLevel() {
    return isDevelopment() ? 'DEBUG' : 'ERROR';
  }
}
