import 'dart:math' as math;

import 'package:flutter/material.dart';

class SalesAnimatedIcon extends StatefulWidget {
  const SalesAnimatedIcon({required this.color, super.key, this.size = 60.0});

  final Color color;
  final double size;

  @override
  State<SalesAnimatedIcon> createState() => _SalesAnimatedIconState();
}

class _SalesAnimatedIconState extends State<SalesAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _controller.repeat();
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
            painter: _SalesPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _SalesPainter extends CustomPainter {
  _SalesPainter({required this.color, required this.animationValue});

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

    final paintStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final clearPaintFill = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    final clearPaintLine = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // 1. Draw Shopping Bag
    // Bag bounces
    var bounce = 0.0;
    var squishY = 1.0;
    var squishX = 1.0;

    if (animationValue < 0.3) {
      final t = animationValue / 0.3;
      bounce = -math.sin(t * math.pi) * h * 0.1;
      squishY = 1.0 + math.sin(t * math.pi) * 0.1;
      squishX = 1.0 - math.sin(t * math.pi) * 0.05;
    } else if (animationValue < 0.5) {
      final t = (animationValue - 0.3) / 0.2;
      squishY = 1.0 - math.sin(t * math.pi) * 0.1;
      squishX = 1.0 + math.sin(t * math.pi) * 0.05;
    }

    final bagW = w * 0.6;
    final bagH = h * 0.55;
    final bagY = cy + h * 0.1;

    canvas
      ..save()
      ..translate(cx, bagY + bagH / 2)
      ..scale(squishX, squishY)
      ..translate(-cx, -(bagY + bagH / 2) + bounce);

    // Handles
    final handleW = bagW * 0.4;
    final handleH = bagH * 0.4;
    canvas
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx, bagY - bagH / 2),
          width: handleW,
          height: handleH,
        ),
        math.pi,
        math.pi,
        false,
        paintStroke,
      )
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx, bagY - bagH / 2),
          width: handleW,
          height: handleH,
        ),
        math.pi,
        math.pi,
        false,
        clearPaintLine..strokeWidth = w * 0.015,
      )
      // Bag Body
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, bagY), width: bagW, height: bagH),
          Radius.circular(w * 0.04),
        ),
        paintFill,
      )
      // Separation line for the top fold
      ..drawLine(
        Offset(cx - bagW / 2, bagY - bagH * 0.2),
        Offset(cx + bagW / 2, bagY - bagH * 0.2),
        clearPaintLine,
      );

    // Tag on Bag
    final tagW = bagW * 0.4;
    final tagH = bagH * 0.4;
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, bagY + bagH * 0.15),
            width: tagW,
            height: tagH,
          ),
          Radius.circular(w * 0.02),
        ),
        clearPaintFill,
      )
      // Percentage sign in the tag (using lines and circles)
      ..drawCircle(
        Offset(cx - tagW * 0.2, bagY + bagH * 0.05),
        w * 0.02,
        paintFill,
      )
      ..drawCircle(
        Offset(cx + tagW * 0.2, bagY + bagH * 0.25),
        w * 0.02,
        paintFill,
      )
      ..drawLine(
        Offset(cx - tagW * 0.2, bagY + bagH * 0.25),
        Offset(cx + tagW * 0.2, bagY + bagH * 0.05),
        paintStroke..strokeWidth = w * 0.015,
      )
      ..restore(); // end bag bounce

    // 2. Rising Coin (Sale made)
    if (animationValue > 0.4 && animationValue < 0.9) {
      final t = (animationValue - 0.4) / 0.5;

      final startY = bagY - bagH * 0.1;
      final endY = bagY - bagH * 1.5;

      final coinY = startY + (endY - startY) * t;
      final coinX = cx + math.sin(t * math.pi * 2) * w * 0.05;

      var opacity = 1.0;
      if (t > 0.7) {
        opacity = 1.0 - (t - 0.7) / 0.3;
      }

      final coinScale = math.sin(t * math.pi); // grows and shrinks
      final coinSpin = math.cos(t * math.pi * 6);

      final coinRadius = w * 0.09;

      canvas
        ..save()
        // clip rect so coin seems to come OUT of the bag
        ..clipRect(Rect.fromLTWH(0, 0, w, bagY - bagH * 0.2))
        ..translate(coinX, coinY)
        ..scale(coinSpin, coinScale)
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

    // 3. Floating Sparkles
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

    drawSparkle(cx - w * 0.35, cy - h * 0.2, 0.2);
    drawSparkle(cx + w * 0.35, cy, 0.8);
    drawSparkle(cx - w * 0.2, cy + h * 0.35, 0.5);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _SalesPainter oldDelegate) {
    return true;
  }
}
