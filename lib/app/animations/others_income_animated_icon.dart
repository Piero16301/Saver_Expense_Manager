import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class OthersIncomeAnimatedIcon extends StatefulWidget {
  const OthersIncomeAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<OthersIncomeAnimatedIcon> createState() =>
      _OthersIncomeAnimatedIconState();
}

class _OthersIncomeAnimatedIconState extends State<OthersIncomeAnimatedIcon>
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
            painter: _OthersIncomePainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _OthersIncomePainter extends CustomPainter {
  _OthersIncomePainter({required this.color, required this.animationValue});

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

    final clearPaintList = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final baseCy = h * 0.7;
    final boxW = w * 0.55;
    final boxH = h * 0.5;

    // Wobble and jump
    var bounceY = 0.0;
    var squishY = 1.0;
    var squishX = 1.0;

    if (animationValue < 0.4) {
      final t = animationValue / 0.4;
      // jump up and down
      bounceY = -math.sin(t * math.pi) * h * 0.2;

      // squish when hitting bottom, stretch at top
      if (t < 0.5) {
        // going up
        squishY = 1.0 + math.sin(t * math.pi * 2) * 0.1;
        squishX = 1.0 - math.sin(t * math.pi * 2) * 0.05;
      } else {
        // going down & hit
        squishY = 1.0 - math.sin((t - 0.5) * math.pi * 2) * 0.15;
        squishX = 1.0 + math.sin((t - 0.5) * math.pi * 2) * 0.1;
      }
    }

    // items popping out when landing
    if (animationValue > 0.3 && animationValue < 0.9) {
      final t = (animationValue - 0.3) / 0.6;

      void drawFlyingItem(
        double startX,
        double arcHeight,
        double endXOffset,
        double sizeFactor, {
        bool isCoin = false,
      }) {
        final itemX = startX + t * endXOffset;
        final itemY = baseCy -
            boxH * 0.4 -
            math.sin(t * math.pi) * arcHeight -
            (t * h * 0.2); // parabolic + drifting up

        var opacity = 1.0;
        if (t > 0.7) opacity = 1.0 - (t - 0.7) / 0.3;

        canvas
          ..save()
          ..translate(itemX, itemY)
          ..scale(1.0 - t * 0.5) // shrink as they fly away
          ..rotate(t * math.pi * (isCoin ? 4 : -3)); // spin

        if (isCoin) {
          final r = w * 0.08 * sizeFactor;
          canvas
            ..drawCircle(
              Offset.zero,
              r,
              Paint()..color = color.withValues(alpha: opacity.clamp(0.0, 1.0)),
            )
            ..drawCircle(
              Offset.zero,
              r * 0.5,
              Paint()
                ..blendMode = BlendMode.clear
                ..style = PaintingStyle.stroke
                ..strokeWidth = w * 0.015,
            );
        } else {
          // Draw a small bill
          final bw = w * 0.15 * sizeFactor;
          final bh = h * 0.1 * sizeFactor;
          canvas
            ..drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(center: Offset.zero, width: bw, height: bh),
                Radius.circular(w * 0.01),
              ),
              Paint()..color = color.withValues(alpha: opacity.clamp(0.0, 1.0)),
            )
            ..drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(
                  center: Offset.zero,
                  width: bw * 0.7,
                  height: bh * 0.6,
                ),
                Radius.circular(w * 0.005),
              ),
              Paint()
                ..blendMode = BlendMode.clear
                ..style = PaintingStyle.stroke
                ..strokeWidth = w * 0.01,
            );
        }
        canvas.restore();
      }

      // 3 items popping out
      drawFlyingItem(cx, h * 0.2, -w * 0.4, 1, isCoin: true);
      drawFlyingItem(cx + w * 0.1, h * 0.3, w * 0.3, 0.8);
      drawFlyingItem(cx - w * 0.1, h * 0.15, -w * 0.2, 0.9, isCoin: true);
      drawFlyingItem(cx, h * 0.35, w * 0.1, 1.1);
    }

    canvas
      ..save()
      ..translate(cx, baseCy + boxH / 2)
      ..scale(squishX, squishY)
      ..translate(-cx, -(baseCy + boxH / 2) + bounceY);

    // 1. Draw Open Box
    // Back flap
    final flapPathBack = Path()
      ..moveTo(cx - boxW / 2, baseCy - boxH / 2)
      ..lineTo(cx - boxW * 0.2, baseCy - boxH * 0.8)
      ..lineTo(cx + boxW * 0.2, baseCy - boxH * 0.8)
      ..lineTo(cx + boxW / 2, baseCy - boxH / 2)
      ..close();
    canvas
      ..drawPath(flapPathBack, paintFill)
      // Clear line between back flap and contents? Box is open, so back flap is
      // behind contents.
      // Instead of drawing contents here, the contents fly out.
      // Main Box Body
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, baseCy),
            width: boxW,
            height: boxH,
          ),
          Radius.circular(w * 0.04),
        ),
        paintFill,
      )
      // Box lines (cross)
      ..drawLine(
        Offset(cx, baseCy - boxH / 2 + h * 0.05), // start a bit lower
        Offset(cx, baseCy + boxH / 2 - h * 0.02),
        clearPaintList,
      )
      ..drawLine(
        Offset(cx - boxW / 2 + w * 0.02, baseCy),
        Offset(cx + boxW / 2 - w * 0.02, baseCy),
        clearPaintList,
      );

    // Front flaps
    final flapPathFrontLeft = Path()
      ..moveTo(cx - boxW / 2, baseCy - boxH / 2)
      ..lineTo(cx - boxW / 2 - w * 0.1, baseCy - boxH / 2 + h * 0.15)
      ..lineTo(cx - w * 0.1, baseCy - boxH / 2 + h * 0.15)
      ..lineTo(cx, baseCy - boxH / 2)
      ..close();

    final flapPathFrontRight = Path()
      ..moveTo(cx, baseCy - boxH / 2)
      ..lineTo(cx + w * 0.1, baseCy - boxH / 2 + h * 0.15)
      ..lineTo(cx + boxW / 2 + w * 0.1, baseCy - boxH / 2 + h * 0.15)
      ..lineTo(cx + boxW / 2, baseCy - boxH / 2)
      ..close();

    canvas
      ..drawPath(flapPathFrontLeft, paintFill)
      ..drawPath(flapPathFrontRight, paintFill)
      // Separation lines for flaps
      ..drawLine(
        Offset(cx - boxW / 2, baseCy - boxH / 2),
        Offset(cx, baseCy - boxH / 2),
        clearPaintList..strokeWidth = w * 0.015,
      )
      ..drawLine(
        Offset(cx, baseCy - boxH / 2),
        Offset(cx + boxW / 2, baseCy - boxH / 2),
        clearPaintList..strokeWidth = w * 0.015,
      )
      ..restore(); // end bounce and squish

    // 2. Floating Sparkles
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

    drawSparkle(cx - w * 0.4, cy - h * 0.1, 0.2);
    drawSparkle(cx + w * 0.4, cy - h * 0.2, 0.7);
    drawSparkle(cx - w * 0.35, cy + h * 0.3, 0.4);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _OthersIncomePainter oldDelegate) {
    return true;
  }
}
