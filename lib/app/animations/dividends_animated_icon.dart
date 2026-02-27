import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class DividendsAnimatedIcon extends StatefulWidget {
  const DividendsAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<DividendsAnimatedIcon> createState() => _DividendsAnimatedIconState();
}

class _DividendsAnimatedIconState extends State<DividendsAnimatedIcon>
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
            painter: _DividendsPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _DividendsPainter extends CustomPainter {
  _DividendsPainter({required this.color, required this.animationValue});

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

    // Slight bounce
    final bounce = math.sin(animationValue * math.pi * 2) * h * 0.02;

    canvas
      ..save()
      ..translate(0, bounce);

    final pieCenter = Offset(cx - w * 0.05, cy + h * 0.05);
    final outerR = w * 0.28;
    final innerR = w * 0.12;

    // 1. Draw Coin Behind Pie
    if (animationValue > 0.1 && animationValue < 0.9) {
      final coinPhase = (animationValue - 0.1) / 0.8;
      // coin flies up and right from center
      final coinX =
          pieCenter.dx + math.cos(-math.pi / 4) * (coinPhase * w * 0.8);
      // add a parabolic arc to the y motion
      final arcMod = math.sin(coinPhase * math.pi) * h * 0.25;
      final coinY = pieCenter.dy +
          math.sin(-math.pi / 4) * (coinPhase * w * 0.8) -
          arcMod;

      final scaleX = math.cos(coinPhase * math.pi * 6);

      var opacity = 1.0;
      if (coinPhase > 0.8) {
        opacity = 1.0 - (coinPhase - 0.8) / 0.2;
      }

      final coinRadius = w * 0.09;

      canvas
        ..save()
        ..translate(coinX, coinY)
        ..scale(scaleX, 1)
        ..drawCircle(
          Offset.zero,
          coinRadius,
          Paint()..color = color.withValues(alpha: opacity.clamp(0.0, 1.0)),
        )
        ..drawCircle(
          Offset.zero,
          coinRadius * 0.5,
          Paint()
            ..blendMode = BlendMode.clear
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.015,
        )
        ..restore();
    }

    // 2. Pie Layer

    // Slice animation
    var sliceOffsetDist = 0.0;
    if (animationValue < 0.2) {
      sliceOffsetDist = math.sin(animationValue / 0.2 * math.pi / 2) * w * 0.08;
    } else if (animationValue < 0.8) {
      sliceOffsetDist = w * 0.08;
      // floating
      sliceOffsetDist +=
          math.sin((animationValue - 0.2) / 0.6 * math.pi * 2) * w * 0.015;
    } else {
      sliceOffsetDist =
          math.cos((animationValue - 0.8) / 0.2 * math.pi / 2) * w * 0.08;
    }

    const sliceAngleCenter = -math.pi / 4;
    final sliceDx = math.cos(sliceAngleCenter) * sliceOffsetDist;
    final sliceDy = math.sin(sliceAngleCenter) * sliceOffsetDist;

    final sliceCenter = Offset(pieCenter.dx + sliceDx, pieCenter.dy + sliceDy);

    final clearLinePaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;

    void drawSlice(Offset center, double startAngle) {
      canvas
        ..saveLayer(Rect.fromLTWH(-w, -h, w * 3, h * 3), Paint())
        ..drawArc(
          Rect.fromCircle(center: center, radius: outerR),
          startAngle,
          math.pi / 2,
          true,
          paintFill,
        )
        ..drawCircle(center, innerR, clearPaint)
        ..drawLine(
          center,
          Offset(
            center.dx + math.cos(startAngle) * outerR,
            center.dy + math.sin(startAngle) * outerR,
          ),
          clearLinePaint,
        )
        ..drawLine(
          center,
          Offset(
            center.dx + math.cos(startAngle + math.pi / 2) * outerR,
            center.dy + math.sin(startAngle + math.pi / 2) * outerR,
          ),
          clearLinePaint,
        )
        ..restore();
    }

    // 1. Draw main pie (4 quadrants total initially)
    drawSlice(pieCenter, 0); // Bottom-Right
    drawSlice(pieCenter, math.pi / 2); // Bottom-Left
    drawSlice(pieCenter, math.pi); // Top-Left

    // 2. Draw animated slice (-90 to 0 deg)
    drawSlice(sliceCenter, -math.pi / 2); // Top-Right

    // 4. Floating Sparkles
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

    drawSparkle(cx - w * 0.35, h * 0.3, 0.2);
    drawSparkle(cx + w * 0.4, h * 0.2, 0.7);
    drawSparkle(cx - w * 0.1, h * 0.8, 0.4);

    canvas
      ..restore() // end global bounce
      ..restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _DividendsPainter oldDelegate) {
    return true;
  }
}
