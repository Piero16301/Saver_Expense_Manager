import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class FeedingAnimatedIcon extends StatefulWidget {
  const FeedingAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<FeedingAnimatedIcon> createState() => _FeedingAnimatedIconState();
}

class _FeedingAnimatedIconState extends State<FeedingAnimatedIcon>
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
            painter: _FeedingPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _FeedingPainter extends CustomPainter {
  _FeedingPainter({required this.color, required this.animationValue});

  final Color color;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final w = size.width;
    final h = size.height;

    final baseWidth = w * 0.7;
    final baseHeight = h * 0.06;
    final baseY = h * 0.8;

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Steam
    final steamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    void drawSteam(double cx, double phaseOffset) {
      final phase = (animationValue + phaseOffset) % 1.0;
      final startY = baseY - h * 0.15;
      final distance = h * 0.55;
      final currentY = startY - phase * distance;

      var opacity = 1.0;
      if (phase < 0.2) opacity = phase / 0.2;
      if (phase > 0.8) opacity = (1.0 - phase) / 0.2;

      steamPaint.color = color.withValues(alpha: opacity.clamp(0.0, 1.0));

      final steamPath = Path();
      final length = h * 0.15;
      final freq = baseWidth * 0.1;
      final amp = w * 0.03;

      for (var i = 0; i <= 10; i++) {
        final dy = length * (i / 10);
        final py = currentY + dy;
        final px =
            cx + math.sin((py / freq) + animationValue * math.pi * 4) * amp;
        if (i == 0) {
          steamPath.moveTo(px, py);
        } else {
          steamPath.lineTo(px, py);
        }
      }

      canvas.drawPath(steamPath, steamPaint);
    }

    drawSteam(w * 0.35, 0);
    drawSteam(w * 0.5, 0.33);
    drawSteam(w * 0.65, 0.66);

    // Plate Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w / 2, baseY),
          width: baseWidth,
          height: baseHeight,
        ),
        Radius.circular(w * 0.03),
      ),
      paintFill,
    );

    // Lift Animation
    final phase = math.sin(animationValue * math.pi * 2);
    final isResting = phase < 0;

    // Shake slightly when resting
    final shake =
        isResting ? math.sin(animationValue * math.pi * 16) * (h * 0.005) : 0.0;
    final lift = math.max(0, phase) * (h * 0.12) + math.max(0.0, shake);
    final tilt = math.max(0, phase) * 0.12;

    canvas
      ..save()
      ..translate(w / 2, baseY - baseHeight / 2)
      ..rotate(tilt)
      ..translate(-w / 2, -(baseY - baseHeight / 2) - lift);

    // Cloche Dome
    final domePath = Path()
      ..moveTo(w * 0.15, baseY - baseHeight / 2)
      ..arcTo(
        Rect.fromLTWH(
          w * 0.15,
          baseY - baseHeight / 2 - w * 0.35,
          w * 0.7,
          w * 0.7,
        ),
        math.pi,
        math.pi,
        false,
      )
      ..close();

    canvas
      ..drawPath(domePath, paintFill)
      // Top handle
      ..drawCircle(
        Offset(w / 2, baseY - baseHeight / 2 - w * 0.35),
        w * 0.05,
        paintFill,
      );

    // Highlight (clear)
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;

    final highlightPath = Path()
      ..addArc(
        Rect.fromLTWH(
          w * 0.22,
          baseY - baseHeight / 2 - w * 0.28,
          w * 0.56,
          w * 0.56,
        ),
        math.pi * 1.15,
        math.pi * 0.3,
      );

    canvas
      ..drawPath(highlightPath, clearPaint)
      ..drawCircle(
        Offset(w * 0.28, baseY - baseHeight / 2 - w * 0.25),
        w * 0.015,
        clearPaint,
      );

    // Clear gap between base and dome to prevent merging visually when resting
    final gapPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.01;

    canvas
      ..drawLine(
        Offset(w * 0.15, baseY - baseHeight / 2),
        Offset(w * 0.85, baseY - baseHeight / 2),
        gapPaint,
      )
      ..restore()
      ..restore(); // End saveLayer
  }

  @override
  bool shouldRepaint(covariant _FeedingPainter oldDelegate) {
    return true; // Continuously animate
  }
}
