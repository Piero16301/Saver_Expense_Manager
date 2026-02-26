import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class PensionsAnimatedIcon extends StatefulWidget {
  const PensionsAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<PensionsAnimatedIcon> createState() => _PensionsAnimatedIconState();
}

class _PensionsAnimatedIconState extends State<PensionsAnimatedIcon>
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
            painter: _PensionsPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _PensionsPainter extends CustomPainter {
  _PensionsPainter({required this.color, required this.animationValue});

  final Color color;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final w = size.width;
    final h = size.height;
    final cx = w / 2.0;

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final clearPaintList = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final baseCy = h * 0.7;

    // Phase 1: Coin drops (0.0 -> 0.4)
    // Phase 2: Squish (impact around 0.4)
    var squishY = 1.0;
    var squishX = 1.0;
    var pigYOffset = 0.0;

    if (animationValue >= 0.35 && animationValue <= 0.6) {
      final t = (animationValue - 0.35) / 0.25; // 0 -> 1
      final phase = math.sin(t * math.pi); // 0 -> 1 -> 0
      squishY = 1.0 - phase * 0.15; // compress Y
      squishX = 1.0 + phase * 0.1; // expand X
      pigYOffset = h * 0.04 * phase; // move down slightly
    }

    // 1. Draw Piggy Bank
    canvas
      ..save()
      ..translate(cx, baseCy + pigYOffset)
      ..scale(squishX, squishY)
      ..translate(-cx, -baseCy);

    final pigRadius = w * 0.3;
    final pigCenter = Offset(cx, baseCy - pigRadius * 0.7);

    // Legs
    final legW = w * 0.1;
    final legH = h * 0.15;
    // Back leg
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx - pigRadius * 0.5, baseCy),
            width: legW,
            height: legH,
          ),
          Radius.circular(w * 0.04),
        ),
        paintFill,
      )
      // Front leg
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + pigRadius * 0.5, baseCy),
            width: legW,
            height: legH,
          ),
          Radius.circular(w * 0.04),
        ),
        paintFill,
      );

    // Ears
    final earPath = Path()
      ..moveTo(cx - pigRadius * 0.5, pigCenter.dy - pigRadius * 0.6)
      ..lineTo(cx - pigRadius * 0.8, pigCenter.dy - pigRadius * 1.0)
      ..lineTo(cx - pigRadius * 0.1, pigCenter.dy - pigRadius * 0.9)
      ..close();
    canvas.drawPath(earPath, paintFill);

    // Tail (curly)
    final tailPath = Path()
      ..moveTo(cx + pigRadius * 0.85, pigCenter.dy)
      ..quadraticBezierTo(
        cx + pigRadius * 1.3,
        pigCenter.dy - h * 0.1,
        cx + pigRadius * 1.1,
        pigCenter.dy + h * 0.05,
      )
      ..quadraticBezierTo(
        cx + pigRadius * 0.9,
        pigCenter.dy + h * 0.1,
        cx + pigRadius * 1.15,
        pigCenter.dy + h * 0.15,
      );
    canvas
      ..drawPath(
        tailPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.025
          ..strokeCap = StrokeCap.round,
      )

      // Main Body
      ..drawCircle(pigCenter, pigRadius, paintFill);

    // Snout
    final snoutRect = Rect.fromCenter(
      center: Offset(cx - pigRadius * 0.85, pigCenter.dy + h * 0.05),
      width: w * 0.12,
      height: h * 0.15,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(snoutRect, Radius.circular(w * 0.04)),
        paintFill,
      )
      // Separation line for snout
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx - pigRadius * 0.7, pigCenter.dy + h * 0.05),
          width: w * 0.2,
          height: h * 0.25,
        ),
        math.pi / 2.5,
        math.pi - math.pi / 2.5 * 2,
        false,
        clearPaintList..strokeWidth = w * 0.02,
      )
      // Nostrils (clear)
      ..drawCircle(
        Offset(cx - pigRadius * 0.85 - w * 0.02, pigCenter.dy + h * 0.05),
        w * 0.012,
        Paint()..blendMode = BlendMode.clear,
      )
      ..drawCircle(
        Offset(cx - pigRadius * 0.85 + w * 0.02, pigCenter.dy + h * 0.05),
        w * 0.012,
        Paint()..blendMode = BlendMode.clear,
      )

      // Eye (clear)
      ..drawCircle(
        Offset(cx - pigRadius * 0.35, pigCenter.dy - h * 0.08),
        w * 0.02,
        Paint()..blendMode = BlendMode.clear,
      )
      // Coin slot (clear)
      ..drawLine(
        Offset(cx - w * 0.08, pigCenter.dy - pigRadius * 0.8),
        Offset(cx + w * 0.12, pigCenter.dy - pigRadius * 0.8),
        clearPaintList..strokeWidth = w * 0.02,
      )
      ..restore(); // end pig squish

    // 2. Draw Coin dropping
    if (animationValue < 0.45) {
      final t = animationValue / 0.45; // 0 -> 1
      // Start high, drop to slot
      final startY = -h * 0.1;
      final endY = pigCenter.dy - pigRadius * 0.8 + pigYOffset;
      // Parabola or ease in effect (gravity)
      final coinY = startY + (endY - startY) * (t * t);

      // Spin coin
      final scaleX = math.cos(t * math.pi * 8);

      final coinRadius = w * 0.08;

      canvas
        ..save()
        // If it crosses the slot, clip it so it looks like it goes inside
        ..clipRect(
          Rect.fromLTWH(0, 0, w, pigCenter.dy - pigRadius * 0.8 + pigYOffset),
        )
        ..translate(cx + w * 0.02, coinY)
        ..scale(scaleX, 1)
        ..drawCircle(Offset.zero, coinRadius, paintFill)
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

    // 3. Spitting out heart/star when squished
    if (animationValue > 0.4 && animationValue < 0.9) {
      final t = (animationValue - 0.4) / 0.5; // 0 -> 1
      // Fly out of the snout leftwards and upwards
      final startX = cx - pigRadius * 0.9;
      final startY = pigCenter.dy;

      final endX = cx - pigRadius * 1.5;
      final endY = pigCenter.dy - h * 0.25;

      // Parabolic arc for the heart
      final heartX = startX + (endX - startX) * t;
      // Arc up and then down
      final arcY = math.sin(t * math.pi) * h * 0.1;
      final heartY = startY + (endY - startY) * t - arcY;

      var opacity = 1.0;
      if (t > 0.7) {
        opacity = 1.0 - (t - 0.7) / 0.3;
      }

      // Draw a small heart
      final hw = w * 0.06;
      final hh = h * 0.06;
      final heartPath = Path()
        ..moveTo(heartX, heartY + hh * 0.3)
        ..cubicTo(
          heartX - hw,
          heartY - hh * 0.5,
          heartX,
          heartY - hh * 1.2,
          heartX,
          heartY - hh * 0.2,
        )
        ..cubicTo(
          heartX,
          heartY - hh * 1.2,
          heartX + hw,
          heartY - hh * 0.5,
          heartX,
          heartY + hh * 0.3,
        );

      canvas
        ..save()
        ..translate(heartX, heartY)
        ..rotate(-math.pi / 6 * t) // rotate slightly while flying
        ..translate(-heartX, -heartY)
        ..drawPath(
          heartPath,
          Paint()
            ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
            ..style = PaintingStyle.fill,
        )
        ..restore();
    }

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

    drawSparkle(cx + w * 0.3, h * 0.2, 0.1);
    drawSparkle(cx - w * 0.35, h * 0.25, 0.8);
    drawSparkle(cx + w * 0.35, h * 0.8, 0.5);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _PensionsPainter oldDelegate) {
    return true;
  }
}
