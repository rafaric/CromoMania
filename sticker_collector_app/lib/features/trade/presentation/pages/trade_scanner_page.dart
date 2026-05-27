import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../cubit/trade_scanner_cubit.dart';
import '../cubit/trade_scanner_state.dart';
import 'trade_confirmation_page.dart';

/// Page for scanning QR codes
class TradeScannerPage extends StatefulWidget {
  const TradeScannerPage({super.key});

  @override
  State<TradeScannerPage> createState() => _TradeScannerPageState();
}

class _TradeScannerPageState extends State<TradeScannerPage> {
  MobileScannerController? _controller;
  bool _torchEnabled = false;
  bool _scannerVisible = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<TradeScannerCubit>();
    if (cubit.state.status != TradeScannerStatus.idle) {
      cubit.reset();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TradeScannerCubit, TradeScannerState>(
      listener: (context, state) {
        if (state.status == TradeScannerStatus.parsed &&
            state.scannedData != null) {
          final scannerCubit = context.read<TradeScannerCubit>();
          // Navigate to confirmation page
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) =>
                      TradeConfirmationPage(scannedData: state.scannedData!),
                ),
              )
              .then((_) {
                if (mounted) {
                  scannerCubit.reset();
                }
              });
        } else if (state.status == TradeScannerStatus.expired) {
          _showErrorSnackBar(
            'This QR code has expired. Ask your friend to generate a new one.',
          );
          context.read<TradeScannerCubit>().reset();
        } else if (state.status == TradeScannerStatus.invalid) {
          _showErrorSnackBar(state.errorMessage ?? 'Invalid QR code');
          context.read<TradeScannerCubit>().reset();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Scan QR Code'),
            actions: [
              if (_controller != null &&
                  state.status == TradeScannerStatus.scanning)
                IconButton(
                  icon: Icon(_torchEnabled ? Icons.flash_on : Icons.flash_off),
                  onPressed: () {
                    setState(() {
                      _torchEnabled = !_torchEnabled;
                      _controller?.toggleTorch();
                    });
                  },
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TradeScannerState state) {
    switch (state.status) {
      case TradeScannerStatus.idle:
        return _buildIdleState(context);
      case TradeScannerStatus.requestingPermission:
      case TradeScannerStatus.scanning:
      case TradeScannerStatus.parsed:
      case TradeScannerStatus.expired:
      case TradeScannerStatus.invalid:
        return _buildScannerView(context);
      case TradeScannerStatus.permissionDenied:
        return _buildPermissionDeniedState(context);
    }
  }

  Widget _buildIdleState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Ready to scan QR codes', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openCamera(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Open Camera'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Camera access needed to scan QR codes',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _openCamera(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView(BuildContext context) {
    if (!_scannerVisible || _controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Requesting camera permission...'),
          ],
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _controller!,
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                context.read<TradeScannerCubit>().onQRScanned(
                  barcode.rawValue!,
                );
                break;
              }
            }
          },
        ),
        // Scanning frame overlay
        _buildScannerOverlay(context),
        // Instruction text
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Point camera at QR code',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openCamera(BuildContext context) {
    _controller?.dispose();
    _controller = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    context.read<TradeScannerCubit>().requestPermission();

    setState(() {
      _scannerVisible = true;
      _torchEnabled = false;
    });

    _startScanner(context);
  }

  Future<void> _startScanner(BuildContext context) async {
    final controller = _controller;
    if (controller == null) return;

    final scannerCubit = context.read<TradeScannerCubit>();

    try {
      await controller.start();

      if (!mounted) return;

      if (controller.value.error?.errorCode ==
          MobileScannerErrorCode.permissionDenied) {
        scannerCubit.onPermissionDenied();
      } else {
        scannerCubit.onPermissionGranted();
      }
    } on MobileScannerException {
      if (!mounted) return;
      scannerCubit.onPermissionDenied();
    }
  }

  Widget _buildScannerOverlay(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Custom painter for scanner overlay with cutout
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final cutoutSize = 250.0;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );

    // Draw overlay with cutout using path
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerLength = 30.0;
    final cornerRadius = 12.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.top + cornerLength)
        ..lineTo(cutoutRect.left, cutoutRect.top + cornerRadius)
        ..quadraticBezierTo(
          cutoutRect.left,
          cutoutRect.top,
          cutoutRect.left + cornerRadius,
          cutoutRect.top,
        )
        ..lineTo(cutoutRect.left + cornerLength, cutoutRect.top),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right - cornerLength, cutoutRect.top)
        ..lineTo(cutoutRect.right - cornerRadius, cutoutRect.top)
        ..quadraticBezierTo(
          cutoutRect.right,
          cutoutRect.top,
          cutoutRect.right,
          cutoutRect.top + cornerRadius,
        )
        ..lineTo(cutoutRect.right, cutoutRect.top + cornerLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.bottom - cornerLength)
        ..lineTo(cutoutRect.left, cutoutRect.bottom - cornerRadius)
        ..quadraticBezierTo(
          cutoutRect.left,
          cutoutRect.bottom,
          cutoutRect.left + cornerRadius,
          cutoutRect.bottom,
        )
        ..lineTo(cutoutRect.left + cornerLength, cutoutRect.bottom),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right - cornerLength, cutoutRect.bottom)
        ..lineTo(cutoutRect.right - cornerRadius, cutoutRect.bottom)
        ..quadraticBezierTo(
          cutoutRect.right,
          cutoutRect.bottom,
          cutoutRect.right,
          cutoutRect.bottom - cornerRadius,
        )
        ..lineTo(cutoutRect.right, cutoutRect.bottom - cornerLength),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
