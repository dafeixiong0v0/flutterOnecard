import 'package:flutter/material.dart';

/// 应用全局状态管理
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._();

  factory AppState() => _instance;

  AppState._();

  // SDK 状态
  dynamic _sdkManager; // 使用 dynamic 以支持任何 SDK 管理器
  bool _sdkInitialized = false;
  bool _sdkAuthenticated = false;
  String? _sdkError;

  // 用户状态
  String? _currentDeviceId;
  String? _currentDeviceName;

  // Getters
  dynamic get sdkManager => _sdkManager;
  bool get sdkInitialized => _sdkInitialized;
  bool get sdkAuthenticated => _sdkAuthenticated;
  bool get sdkReady => _sdkInitialized && _sdkAuthenticated;
  String? get sdkError => _sdkError;

  String? get currentDeviceId => _currentDeviceId;
  String? get currentDeviceName => _currentDeviceName;

  // Setters
  void setSdkManager(dynamic manager) {
    _sdkManager = manager;
    notifyListeners();
  }

  void setSdkInitialized(bool value) {
    _sdkInitialized = value;
    notifyListeners();
  }

  void setSdkAuthenticated(bool value) {
    _sdkAuthenticated = value;
    notifyListeners();
  }

  void setSdkError(String? error) {
    _sdkError = error;
    notifyListeners();
  }

  void setCurrentDevice(String? deviceId, String? deviceName) {
    _currentDeviceId = deviceId;
    _currentDeviceName = deviceName;
    notifyListeners();
  }

  /// 重置 SDK 状态
  void resetSdkState() {
    _sdkInitialized = false;
    _sdkAuthenticated = false;
    _sdkError = null;
    notifyListeners();
  }

  /// 重置所有状态
  void resetAll() {
    _sdkManager = null;
    _sdkInitialized = false;
    _sdkAuthenticated = false;
    _sdkError = null;
    _currentDeviceId = null;
    _currentDeviceName = null;
    notifyListeners();
  }
}
