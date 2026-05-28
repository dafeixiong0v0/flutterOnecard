import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:app/core/logger.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  // 控制器，用于管理扫描器状态、手电筒等
  final MobileScannerController _scannerController = MobileScannerController(
    formats: const [BarcodeFormat.all], // 支持所有常见格式
    detectionSpeed: DetectionSpeed.normal, // 检测速度
    facing: CameraFacing.back, // 默认后置摄像头
    torchEnabled: false, // 默认关闭手电筒
    returnImage: false, // 禁用返回图片，节省大量内存
    // 强制限制摄像头的分辨率预设，防止高像素手机直接 OOM 崩溃
    cameraResolution: const Size(1280, 720),
  );

  bool _hasHandledResult = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // mobile_scanner 会在内部自动处理权限请求，不需要我们手动调 permission_handler
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 处理应用切后台/前台时的相机状态
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_hasHandledResult) {
          _scannerController.start();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _scannerController.stop();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_hasHandledResult) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _hasHandledResult = true;
    Logger.info('扫码成功: $code');

    // 扫到后立刻停止扫描
    _scannerController.stop();

    if (mounted) {
      Navigator.of(context).pop(code);
    }
  }

  void _closeWithoutResult() {
    if (!mounted) return;
    _scannerController.stop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _closeWithoutResult();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('扫一扫'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closeWithoutResult,
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await _scannerController.toggleTorch();
                if (mounted) {
                  setState(() {
                    _isTorchOn = !_isTorchOn;
                  });
                }
              },
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: _handleDetect,
              errorBuilder: (context, error, child) {
                Logger.error('扫码器初始化错误: \${error.errorCode}');
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '相机加载失败: \${error.errorCode}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
            // 简单的半透明遮罩和扫描框 UI
            Positioned.fill(child: _buildOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;

        return Stack(
          children: [
            // 使用 CustomPaint 绘制带镂空区域的半透明遮罩和边框
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ScannerOverlayPainter(
                scanAreaSize: scanAreaSize,
                overlayColor: Colors.black54,
                borderColor: Colors.greenAccent,
              ),
            ),
            // 提示文字
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '请将二维码或条形码放入框内\n识别成功后会自动返回',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final Color overlayColor;
  final Color borderColor;

  _ScannerOverlayPainter({
    required this.scanAreaSize,
    required this.overlayColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 计算扫描框的矩形区域（居中）
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // 1. 绘制半透明背景遮罩（镂空中间区域）
    final backgroundPaint =
        Paint()
          ..color = overlayColor
          ..style = PaintingStyle.fill;

    // 使用 Path.combine 的 difference 操作挖空中间
    final backgroundPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // 稍微带点圆角的镂空框
    final holePath =
        Path()
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)));

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );
    canvas.drawPath(overlayPath, backgroundPaint);

    // 2. 绘制扫描框的四个角
    final borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

    final double cornerLength = scanAreaSize * 0.1; // 角落线段长度

    // 左上角
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + cornerLength)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.left + cornerLength, rect.top),
      borderPaint,
    );
    // 右上角
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.top + cornerLength),
      borderPaint,
    );
    // 左下角
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - cornerLength)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.left + cornerLength, rect.bottom),
      borderPaint,
    );
    // 右下角
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.bottom)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right, rect.bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanAreaSize != scanAreaSize ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderColor != borderColor;
  }
}
