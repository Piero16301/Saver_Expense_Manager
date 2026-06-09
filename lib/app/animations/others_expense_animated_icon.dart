import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class OthersExpenseAnimatedIcon extends StatefulWidget {
  const OthersExpenseAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<OthersExpenseAnimatedIcon> createState() =>
      _OthersExpenseAnimatedIconState();
}

class _OthersExpenseAnimatedIconState extends State<OthersExpenseAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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
            painter: _OthersExpensePainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _OthersExpensePainter extends CustomPainter {
  _OthersExpensePainter({required this.color, required this.animationValue});

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
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Bounce animation for the bag
    final bouncePhase = math.sin(animationValue * math.pi * 2);
    final bagCy = h * 0.6 + bouncePhase * h * 0.03;
    final bagW = w * 0.55;
    final bagH = h * 0.45;

    // Items popping out
    void drawPoppingItem(double delay, int type, double localXOffset) {
      final phase = (animationValue + delay) % 1.0;
      // Fly up and fall down (parabola)
      // t goes 0 -> 1
      // y = v0*t - 0.5*g*t^2 (we can fake it)
      // Let's use a sin curve for Y
      final itemY = bagCy - bagH / 2 - h * 0.3 * math.sin(phase * math.pi);
      // X drift
      final itemX = cx + localXOffset * phase;

      var opacity = 1.0;
      if (phase < 0.1) {
        opacity = phase / 0.1;
      } else if (phase > 0.7) {
        opacity = 1.0 - (phase - 0.7) / 0.3;
      }

      if (opacity <= 0) return;

      final pPaint = Paint()
        ..color = color.withValues(alpha: (opacity * 0.8).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas
        ..save()
        // Spin
        ..translate(itemX, itemY)
        ..rotate(phase * math.pi * 4 * (localXOffset > 0 ? 1 : -1));

      if (type == 0) {
        // Circle (Coin)
        canvas
          ..drawCircle(Offset.zero, w * 0.04, pPaint)
          ..drawCircle(
            Offset.zero,
            w * 0.02,
            Paint()..blendMode = BlendMode.clear,
          );
      } else if (type == 1) {
        // Square (Bill/Ticket)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: w * 0.08,
              height: w * 0.06,
            ),
            Radius.circular(w * 0.01),
          ),
          pPaint,
        );
      } else {
        // Triangle
        final tPath = Path()
          ..moveTo(0, -w * 0.05)
          ..lineTo(w * 0.05, w * 0.04)
          ..lineTo(-w * 0.05, w * 0.04)
          ..close();
        canvas.drawPath(tPath, pPaint);
      }
      canvas.restore();
    }

    // Draw popping items BEFORE bag (so they come from behind/inside)
    drawPoppingItem(0, 0, -w * 0.3);
    drawPoppingItem(0.3, 1, w * 0.4);
    drawPoppingItem(0.6, 2, -w * 0.2);
    drawPoppingItem(0.8, 0, w * 0.2);

    canvas
      ..save()
      ..translate(0, bagCy - h * 0.6); // Adjust everything based on bagCy

    // Handles
    final handlePath = Path()
      ..moveTo(cx - bagW * 0.25, h * 0.6 - bagH * 0.45)
      ..cubicTo(
        cx - bagW * 0.25,
        h * 0.6 - bagH * 0.45 - h * 0.2,
        cx + bagW * 0.25,
        h * 0.6 - bagH * 0.45 - h * 0.2,
        cx + bagW * 0.25,
        h * 0.6 - bagH * 0.45,
      );

    canvas
      ..drawPath(
        handlePath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.04
          ..strokeCap = StrokeCap.round,
      )
      // Inner clear handle so it looks like a ring
      ..drawPath(handlePath, clearStroke);

    // Bag Body
    final bagBodyStyle = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(
            center: Offset(cx, h * 0.6),
            width: bagW,
            height: bagH,
          ),
          bottomLeft: Radius.circular(w * 0.06),
          bottomRight: Radius.circular(w * 0.06),
          topLeft: Radius.circular(w * 0.02),
          topRight: Radius.circular(w * 0.02),
        ),
      );

    canvas.drawPath(bagBodyStyle, paintFill);

    // Top opening fold (curve)
    final foldPath = Path()
      ..moveTo(cx - bagW * 0.5, h * 0.6 - bagH * 0.45)
      ..quadraticBezierTo(
        cx,
        h * 0.6 - bagH * 0.35,
        cx + bagW * 0.5,
        h * 0.6 - bagH * 0.45,
      );
    canvas.drawPath(foldPath, clearStroke);

    // Add 3 bouncing dots "..." on the bag
    void drawDot(int index, double x) {
      // Offset dots phase
      final dotPhase = (animationValue * 2.0 + index * 0.2) % 1.0;
      final dotYOffset = math.sin(dotPhase * math.pi * 2) * h * 0.03;
      canvas.drawCircle(Offset(x, h * 0.65 + dotYOffset), w * 0.04, clearPaint);
    }

    drawDot(0, cx - w * 0.15);
    drawDot(1, cx);
    drawDot(2, cx + w * 0.15);

    canvas.restore(); // restore bag translation

    // Floating sparkles around
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

    drawSparkle(cx - w * 0.4, h * 0.3, 0.1);
    drawSparkle(cx + w * 0.4, h * 0.4, 0.5);
    drawSparkle(cx - w * 0.35, h * 0.8, 0.8);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _OthersExpensePainter oldDelegate) {
    return true;
  }
}
