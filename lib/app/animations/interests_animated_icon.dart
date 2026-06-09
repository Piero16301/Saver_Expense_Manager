import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class InterestsAnimatedIcon extends StatefulWidget {
  const InterestsAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<InterestsAnimatedIcon> createState() => _InterestsAnimatedIconState();
}

class _InterestsAnimatedIconState extends State<InterestsAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
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
            painter: _InterestsPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _InterestsPainter extends CustomPainter {
  _InterestsPainter({required this.color, required this.animationValue});

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
      ..strokeWidth = w * 0.015
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Bounce the entire % sign slightly
    final bounce = math.sin(animationValue * math.pi * 4) * h * 0.02;

    canvas
      ..save()
      ..translate(0, bounce);

    // 1. Draw Diagonal Line of the % sign
    final lineW = w * 0.12;
    final p0 = Offset(cx + w * 0.25, cy - h * 0.28);
    final p1 = Offset(cx - w * 0.25, cy + h * 0.28);

    canvas.drawLine(
      p0,
      p1,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineW
        ..strokeCap = StrokeCap.round,
    );

    // 2. Draw the two circles as spinning coins
    void drawCoin(Offset center, double delay) {
      final phase = (animationValue + delay) % 1.0;
      // Coin flipping around Y axis
      final scaleX = math.cos(phase * math.pi * 6); // spins 3 times per cycle

      final coinRadius = w * 0.18;
      final yFloat = math.sin(phase * math.pi * 2) * h * 0.03;

      canvas
        ..save()
        ..translate(center.dx, center.dy + yFloat)
        ..scale(scaleX, 1)
        ..drawCircle(Offset.zero, coinRadius, paintFill)
        // Inner clear circle
        ..drawCircle(Offset.zero, coinRadius * 0.6, clearPaintList)
        // little plus or symbol in the center
        ..drawLine(
          Offset(0, -coinRadius * 0.3),
          Offset(0, coinRadius * 0.3),
          clearPaintList,
        )
        ..drawLine(
          Offset(-coinRadius * 0.3, 0),
          Offset(coinRadius * 0.3, 0),
          clearPaintList,
        )
        ..restore();
    }

    // Top Left Coin
    drawCoin(Offset(cx - w * 0.22, cy - h * 0.22), 0);
    // Bottom Right Coin
    drawCoin(Offset(cx + w * 0.22, cy + h * 0.22), 0.4);

    canvas.restore(); // end bounce

    // 3. Floating Sparkles / Arrows (Growth)
    void drawArrowSparkle(double x, double y, double delay) {
      final phase = (animationValue + delay) % 1.0;
      final scale = math.sin(phase * math.pi); // 0 -> 1 -> 0
      final offsetUp = phase * h * 0.1; // flies upwards

      final sPaint = Paint()
        ..color = color.withValues(alpha: scale.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final p = Path()
        ..moveTo(x, y - offsetUp - h * 0.05)
        ..lineTo(x, y - offsetUp + h * 0.05)
        ..moveTo(x, y - offsetUp - h * 0.05)
        ..lineTo(x - w * 0.04, y - offsetUp - h * 0.01)
        ..moveTo(x, y - offsetUp - h * 0.05)
        ..lineTo(x + w * 0.04, y - offsetUp - h * 0.01);
      canvas.drawPath(p, sPaint);
    }

    drawArrowSparkle(cx - w * 0.4, h * 0.4, 0.2);
    drawArrowSparkle(cx + w * 0.38, h * 0.6, 0.7);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _InterestsPainter oldDelegate) {
    return true;
  }
}
