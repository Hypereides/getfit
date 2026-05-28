import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/mock_food_database.dart';
import 'food_detail_screen.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;

  bool _hasScanned = false;
  bool _torchOn   = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final rawValue = capture.barcodes
        .where((b) => b.rawValue != null)
        .map((b) => b.rawValue!)
        .firstOrNull;

    if (rawValue == null) return;

    _hasScanned = true;
    _controller.stop();

    final product = MockFoodDatabase.lookup(rawValue);

    if (!mounted) return;

    if (product == null) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.search_off_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text('Product Not Found'),
            ],
          ),
          content: Text(
            'No product matched barcode "$rawValue".\n'
            'Try scanning again or search manually.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);     // close
                Navigator.pop(context); 
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);     // close
                setState(() => _hasScanned = false);
                _controller.start();
              },
              child: const Text('Scan Again'),
            ),
          ],
        ),
      );
    } else {
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => FoodDetailScreen(product: product),
        ),
      ).then((_) {
        setState(() => _hasScanned = false);
        _controller.start();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _torchOn ? Colors.amber : Colors.white,
            ),
            tooltip: 'Toggle torch',
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded,
                color: Colors.white),
            tooltip: 'Flip camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return _ErrorView(error: error);
            },
          ),

          _ScanOverlay(),

          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Align barcode within the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameSize = size.width * 0.7;
    final top = (size.height - frameSize) / 2.5;

    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.55),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut)),
              Positioned(
                left: (size.width - frameSize) / 2,
                top: top,
                child: Container(
                  width: frameSize,
                  height: frameSize * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: (size.width - frameSize) / 2,
          top: top,
          child: _CornerBrackets(
            width: frameSize,
            height: frameSize * 0.6,
          ),
        ),
      ],
    );
  }
}

class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    const c = Color(0xFF4CAF50);
    const t = 3.0;
    const len = 24.0;
    const r = 12.0;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _BracketPainter(
            color: c, thickness: t, bracketLength: len, radius: r),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter({
    required this.color,
    required this.thickness,
    required this.bracketLength,
    required this.radius,
  });

  final Color color;
  final double thickness;
  final double bracketLength;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final l = bracketLength;

    canvas.drawPath(
        Path()
          ..moveTo(0, l)
          ..lineTo(0, radius)
          ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
          ..lineTo(l, 0),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(w - l, 0)
          ..lineTo(w - radius, 0)
          ..arcToPoint(Offset(w, radius), radius: Radius.circular(radius))
          ..lineTo(w, l),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(0, h - l)
          ..lineTo(0, h - radius)
          ..arcToPoint(Offset(radius, h), radius: Radius.circular(radius))
          ..lineTo(l, h),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(w - l, h)
          ..lineTo(w - radius, h)
          ..arcToPoint(Offset(w, h - radius), radius: Radius.circular(radius))
          ..lineTo(w, h - l),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final isPermission =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPermission
                  ? Icons.no_photography_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white60,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              isPermission
                  ? 'Camera Permission Required'
                  : 'Camera Unavailable',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isPermission
                  ? 'GetFit needs camera access to scan barcodes. Please enable it in your device settings.'
                  : 'Could not open the camera. ${error.errorDetails?.message ?? ''}',
              style: const TextStyle(color: Colors.white60, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isPermission)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
              ),
          ],
        ),
      ),
    );
  }
}