import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class RefundsAnimatedIcon extends StatefulWidget {
  const RefundsAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<RefundsAnimatedIcon> createState() => _RefundsAnimatedIconState();
}

class _RefundsAnimatedIconState extends State<RefundsAnimatedIcon>
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
            painter: _RefundsPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _RefundsPainter extends CustomPainter {
  _RefundsPainter({required this.color, required this.animationValue});

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
    final bagW = w * 0.6;
    final bagH = h * 0.55;

    // 1. Draw Banknote returning to bag
    if (animationValue > 0.1 && animationValue < 0.8) {
      final t = (animationValue - 0.1) / 0.7;
      // Start outside (right top) and drop into the slot
      final startX = w * 0.9;
      final startY = -h * 0.1;

      final endX = cx;
      final endY = baseCy - bagH / 2;

      final billX = startX + (endX - startX) * t;
      // Parabolic drop
      final billY =
          startY + (endY - startY) * t - math.sin(t * math.pi) * h * 0.2;

      // Rotate while dropping
      final billAngle = t * math.pi * 2;

      // Scale to simulate it going "in"
      var billScale = 1.0;
      if (t > 0.8) {
        billScale = 1.0 - (t - 0.8) / 0.2; // shrink as it enters
      }

      canvas
        ..save()
        // Clip to only draw above the slot to simulate entering
        ..clipRect(Rect.fromLTWH(0, 0, w, baseCy - bagH * 0.4))
        ..translate(billX, billY)
        ..rotate(billAngle)
        ..scale(billScale);

      final billW = w * 0.35;
      final billH = h * 0.2;

      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: billW, height: billH),
            Radius.circular(w * 0.02),
          ),
          paintFill,
        )
        // Inner dashed line
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: billW * 0.8,
              height: billH * 0.7,
            ),
            Radius.circular(w * 0.01),
          ),
          clearPaintList..strokeWidth = w * 0.015,
        )
        // Center circle inside bill
        ..drawCircle(Offset.zero, w * 0.03, clearPaintList)
        ..restore();
    }

    // Bag wobble when hit
    var wobble = 0.0;
    var squishY = 1.0;
    var squishX = 1.0;

    if (animationValue > 0.7 && animationValue < 0.95) {
      final t = (animationValue - 0.7) / 0.25;
      final phase = math.sin(t * math.pi);
      wobble =
          math.sin(t * math.pi * 4) * math.pi / 24 * phase; // shake right/left
      squishY = 1.0 - phase * 0.1; // compress
      squishX = 1.0 + phase * 0.05;
    }

    canvas
      ..save()
      ..translate(cx, baseCy + bagH / 2)
      ..rotate(wobble)
      ..scale(squishX, squishY)
      ..translate(-cx, -(baseCy + bagH / 2));

    // 2. Draw Bag
    final bagPath = Path()
      ..moveTo(cx - bagW * 0.25, baseCy - bagH / 2) // top left neck
      ..lineTo(cx + bagW * 0.25, baseCy - bagH / 2) // top right neck
      ..quadraticBezierTo(
        cx + bagW / 2, baseCy, // control right
        cx + bagW * 0.4, baseCy + bagH / 2, // bottom right
      )
      ..lineTo(cx - bagW * 0.4, baseCy + bagH / 2) // bottom left
      ..quadraticBezierTo(
        cx - bagW / 2, baseCy, // control left
        cx - bagW * 0.25, baseCy - bagH / 2, // top left neck
      )
      ..close();

    canvas
      ..drawPath(bagPath, paintFill)
      // Top fold (opening of bag)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, baseCy - bagH / 2 - h * 0.02),
            width: bagW * 0.6,
            height: h * 0.1,
          ),
          Radius.circular(w * 0.02),
        ),
        paintFill,
      )
      // Neck tie
      ..drawLine(
        Offset(cx - bagW * 0.3, baseCy - bagH / 2 + h * 0.05),
        Offset(cx + bagW * 0.3, baseCy - bagH / 2 + h * 0.05),
        clearPaintList..strokeWidth = w * 0.025,
      );

    // 3. Arrow looping back (Refund symbol)
    // Draw an arrow making a U-turn on the front of the bag
    final arrowY = baseCy + h * 0.05;
    final r = w * 0.15;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, arrowY), radius: r),
      math.pi / 2, // start bottom
      math.pi * 1.5, // go around 3/4
      false,
      clearPaintList..strokeWidth = w * 0.03,
    );

    // Arrow head on left side pointing correctly (clockwise)
    final arrowHeadPath = Path()
      ..moveTo(cx, arrowY + r + w * 0.06) // right tip
      ..lineTo(cx + w * 0.06, arrowY + r) // center (changed from - to +)
      ..lineTo(cx, arrowY + r - w * 0.06) // left tip
      ..close();

    canvas
      ..drawPath(
        arrowHeadPath,
        Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.fill,
      )
      ..restore(); // end bag wobble/squish

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

    drawSparkle(cx - w * 0.4, h * 0.3, 0.2);
    drawSparkle(cx + w * 0.4, h * 0.4, 0.7);
    drawSparkle(cx - w * 0.3, h * 0.7, 0.4);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _RefundsPainter oldDelegate) {
    return true;
  }
}
