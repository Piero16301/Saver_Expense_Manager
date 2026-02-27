import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class GiftsAnimatedIcon extends StatefulWidget {
  const GiftsAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<GiftsAnimatedIcon> createState() => _GiftsAnimatedIconState();
}

class _GiftsAnimatedIconState extends State<GiftsAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
            painter: _GiftsPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _GiftsPainter extends CustomPainter {
  _GiftsPainter({required this.color, required this.animationValue});

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

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    final clearStroke = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // 1. Calculate jump animation for the box
    // Jump happens between 0.0 and 0.5 phase
    var jumpY = 0.0;
    var lidAngle = 0.0;
    var lidOffsetY = 0.0;
    var scaleX = 1.0;
    var scaleY = 1.0;

    if (animationValue < 0.1) {
      // Anticipation squish
      final t = animationValue / 0.1;
      scaleX = 1.0 + 0.1 * t;
      scaleY = 1.0 - 0.1 * t;
      jumpY = h * 0.02 * t; // slightly down
    } else if (animationValue < 0.3) {
      // Jump up
      final t = (animationValue - 0.1) / 0.2;
      scaleX = 0.9 + 0.1 * t;
      scaleY = 1.1 - 0.1 * t;
      jumpY = -h * 0.2 * math.sin(t * math.pi / 2); // goes up to -20%
      lidAngle = -math.pi / 10 * t; // lid starts to fly open a bit
      lidOffsetY = -h * 0.05 * t;
    } else if (animationValue < 0.5) {
      // Fall down
      final t = (animationValue - 0.3) / 0.2;
      scaleX = 1.0;
      scaleY = 1.0;
      jumpY = -h * 0.2 * math.cos(t * math.pi / 2);
      lidAngle = -math.pi / 10 * (1.0 - t); // lid comes back
      lidOffsetY = -h * 0.05 * (1.0 - t);
    } else if (animationValue < 0.6) {
      // Landing squish
      final t = (animationValue - 0.5) / 0.1;
      scaleX = 1.0 + 0.15 * math.sin(t * math.pi);
      scaleY = 1.0 - 0.15 * math.sin(t * math.pi);
      jumpY = h * 0.02 * math.sin(t * math.pi);
    }

    final boxBaseCy = h * 0.8 + jumpY;

    // Dimensions
    final boxW = w * 0.45;
    final boxH = h * 0.35;
    final lidW = w * 0.55;
    final lidH = h * 0.12;
    final ribbonW = w * 0.06;

    // Draw Box
    canvas
      ..save()
      ..translate(cx, boxBaseCy)
      ..scale(scaleX, scaleY)
      ..translate(-cx, -boxBaseCy);

    // Box body
    final boxRect = Rect.fromCenter(
      center: Offset(cx, boxBaseCy - boxH / 2),
      width: boxW,
      height: boxH,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(boxRect, Radius.circular(w * 0.03)),
        paintFill,
      )

      // Vertical ribbon cutout
      ..drawRect(
        Rect.fromCenter(
          center: Offset(cx, boxBaseCy - boxH / 2),
          width: ribbonW,
          height: boxH,
        ),
        clearPaint,
      )

      // Horizontal ribbon cutout
      ..drawRect(
        Rect.fromCenter(
          center: Offset(cx, boxBaseCy - boxH / 2),
          width: boxW,
          height: ribbonW,
        ),
        clearPaint,
      )
      ..restore(); // end box scale

    // Draw Lid
    final lidCy = boxBaseCy - boxH + lidOffsetY;
    canvas
      ..save()
      // Translate to lid hinge (let's say left side)
      ..translate(cx - lidW / 2, lidCy)
      ..rotate(lidAngle)
      ..translate(-(cx - lidW / 2), -lidCy)
      // also apply jump scale (but only translation mostly)
      ..translate(cx, lidCy)
      ..scale(scaleX, scaleY)
      ..translate(-cx, -lidCy);

    final lidRect = Rect.fromCenter(
      center: Offset(cx, lidCy - lidH / 2),
      width: lidW,
      height: lidH,
    );
    final lidRRect =
        RRect.fromRectAndRadius(lidRect, Radius.circular(w * 0.03));
    canvas
      ..drawRRect(lidRRect, paintFill)

      // Lid vertical ribbon cutout
      ..drawRect(
        Rect.fromCenter(
          center: Offset(cx, lidCy - lidH / 2),
          width: ribbonW,
          height: lidH,
        ),
        clearPaint,
      )

      // Separation line between lid and box
      ..drawLine(
        Offset(cx - lidW / 2, lidCy),
        Offset(cx + lidW / 2, lidCy),
        clearStroke,
      );

    // Draw Bow (on top of lid)
    // Left loop
    final leftLoop = Path()
      ..moveTo(cx - w * 0.02, lidCy - lidH)
      ..cubicTo(
        cx - w * 0.25,
        lidCy - lidH - h * 0.1,
        cx - w * 0.15,
        lidCy - lidH - h * 0.2,
        cx,
        lidCy - lidH - h * 0.02,
      );

    // Right loop
    final rightLoop = Path()
      ..moveTo(cx + w * 0.02, lidCy - lidH)
      ..cubicTo(
        cx + w * 0.25,
        lidCy - lidH - h * 0.1,
        cx + w * 0.15,
        lidCy - lidH - h * 0.2,
        cx,
        lidCy - lidH - h * 0.02,
      );

    canvas
      ..drawPath(
        leftLoop,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.03
          ..strokeCap = StrokeCap.round,
      )
      ..drawPath(
        rightLoop,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.03
          ..strokeCap = StrokeCap.round,
      );

    // Inside bow loops (clear)
    final insideBow = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.01
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawPath(leftLoop, insideBow)
      ..drawPath(rightLoop, insideBow)

      // Center knot of the bow
      ..drawCircle(Offset(cx, lidCy - lidH - h * 0.02), w * 0.03, paintFill)
      ..restore(); // end lid transform

    // Confetti/Sparkles
    void drawConfetti(double x, double y, double delay, {bool isStar = false}) {
      final phase = (animationValue + delay) % 1.0;
      // Confetti shoots up during the jump
      final upY = y - phase * h * 0.3;
      final scaleX = math.cos(phase * math.pi * 4); // spinning effect

      var opacity = 1.0;
      if (phase < 0.1) {
        opacity = phase / 0.1;
      } else if (phase > 0.6) {
        opacity = 1.0 - (phase - 0.6) / 0.4;
      }

      canvas
        ..save()
        ..translate(x, upY)
        ..scale(scaleX, 1)
        ..translate(-x, -upY);

      final pPaint = Paint()
        ..color = color.withValues(alpha: (opacity * 0.8).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      if (isStar) {
        final r = w * 0.03;
        final p = Path()
          ..moveTo(x, upY - r)
          ..quadraticBezierTo(x, upY, x + r, upY)
          ..quadraticBezierTo(x, upY, x, upY + r)
          ..quadraticBezierTo(x, upY, x - r, upY)
          ..quadraticBezierTo(x, upY, x, upY - r)
          ..close();
        canvas.drawPath(p, pPaint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, upY),
            width: w * 0.03,
            height: h * 0.03,
          ),
          pPaint,
        );
      }

      canvas.restore();
    }

    if (animationValue >= 0.2 && animationValue <= 0.8) {
      // Confetti starts slightly after jump
      drawConfetti(cx - w * 0.3, boxBaseCy - h * 0.3, 0.8, isStar: true);
      drawConfetti(cx + w * 0.3, boxBaseCy - h * 0.25, 0.7);
      drawConfetti(cx - w * 0.2, boxBaseCy - h * 0.4, 0.6);
      drawConfetti(cx + w * 0.25, boxBaseCy - h * 0.45, 0.85, isStar: true);
      drawConfetti(cx, boxBaseCy - h * 0.5, 0.75, isStar: true);
    }

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _GiftsPainter oldDelegate) {
    return true;
  }
}
