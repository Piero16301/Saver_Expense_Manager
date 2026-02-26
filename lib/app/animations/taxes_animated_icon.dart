import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class TaxesAnimatedIcon extends StatefulWidget {
  const TaxesAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<TaxesAnimatedIcon> createState() => _TaxesAnimatedIconState();
}

class _TaxesAnimatedIconState extends State<TaxesAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _TaxesPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _TaxesPainter extends CustomPainter {
  _TaxesPainter({required this.color, required this.animationValue});

  final Color color;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final w = size.width;
    final h = size.height;
    final cx = w / 2.0;
    final cy = h / 2.0;

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    final clearStrokeInfo = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;

    // We will draw the receipt first
    // (so it's behind the calculator if they overlap)
    final recW = w * 0.35;
    final recH = h * 0.55;
    final recHover =
        math.sin(animationValue * math.pi * 2 + math.pi) * h * 0.04;

    canvas
      ..save()
      ..translate(cx + w * 0.15, cy + recHover)
      ..rotate(math.pi / 12);

    final rPath = Path()
      ..moveTo(-recW / 2, -recH / 2)
      ..lineTo(recW / 2, -recH / 2)
      ..lineTo(recW / 2, recH / 2);

    const steps = 5;
    final stepW = recW / steps;
    for (var i = 0; i < steps; i++) {
      rPath
        ..lineTo(recW / 2 - stepW * i - stepW / 2, recH / 2 + h * 0.04)
        ..lineTo(recW / 2 - stepW * (i + 1), recH / 2);
    }
    rPath
      ..lineTo(-recW / 2, recH / 2)
      ..close();

    canvas
      ..drawPath(rPath, paintFill)
      // clear percent inside receipt and lines
      ..drawCircle(Offset(-recW * 0.1, 0), w * 0.03, clearPaint)
      ..drawCircle(Offset(recW * 0.1, recW * 0.2), w * 0.03, clearPaint)
      ..drawLine(
        Offset(-recW * 0.15, recW * 0.25),
        Offset(recW * 0.15, -w * 0.05),
        Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.02
          ..strokeCap = StrokeCap.round,
      )
      ..drawLine(
        Offset(-recW * 0.3, -recH * 0.3),
        Offset(recW * 0.3, -recH * 0.3),
        clearStrokeInfo,
      )
      ..drawLine(
        Offset(-recW * 0.3, -recH * 0.18),
        Offset(recW * 0.3, -recH * 0.18),
        clearStrokeInfo,
      )
      ..restore();

    // Now draw the calculator
    final calcW = w * 0.38;
    final calcH = h * 0.55;
    final calcHover = math.sin(animationValue * math.pi * 2) * h * 0.04;

    canvas
      ..save()
      ..translate(cx - w * 0.15, cy + calcHover)
      ..rotate(-math.pi / 15);

    final calcRect = Rect.fromCenter(
      center: Offset.zero,
      width: calcW,
      height: calcH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(calcRect, Radius.circular(w * 0.04)),
      paintFill,
    );

    // Screen cutout
    final screenRect = Rect.fromCenter(
      center: Offset(0, -calcH * 0.3),
      width: calcW * 0.8,
      height: calcH * 0.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, Radius.circular(w * 0.02)),
      clearPaint,
    );

    // Buttons cutout grid (3 cols, 4 rows)
    final btnW = calcW * 0.2;
    final btnH = calcH * 0.08;
    final startX = -calcW * 0.25;
    final startY = -calcH * 0.05;

    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 3; col++) {
        final btnRect = Rect.fromCenter(
          center:
              Offset(startX + col * calcW * 0.25, startY + row * calcH * 0.14),
          width: btnW,
          height: btnH,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(btnRect, Radius.circular(w * 0.01)),
          clearPaint,
        );
      }
    }

    canvas.restore();

    // Floating sparkles/coins
    void drawSparkle(double x, double y, double delay) {
      final phase = (animationValue + delay) % 1.0;
      final scale = math.sin(phase * math.pi); // 0 -> 1 -> 0
      final sLength = w * 0.04 * scale;

      final sPaint = Paint()
        ..color = color.withValues(alpha: scale.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final p = Path()
        ..moveTo(x, y - sLength)
        ..quadraticBezierTo(x, y, x + sLength, y)
        ..quadraticBezierTo(x, y, x, y + sLength)
        ..quadraticBezierTo(x, y, x - sLength, y)
        ..quadraticBezierTo(x, y, x, y - sLength)
        ..close();
      canvas.drawPath(p, sPaint);
    }

    drawSparkle(cx - w * 0.35, h * 0.2, 0);
    drawSparkle(cx + w * 0.35, h * 0.25, 0.3);
    drawSparkle(cx, h * 0.15, 0.6);
    drawSparkle(cx - w * 0.2, h * 0.85, 0.2);
    drawSparkle(cx + w * 0.25, h * 0.8, 0.8);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _TaxesPainter oldDelegate) {
    return true;
  }
}
