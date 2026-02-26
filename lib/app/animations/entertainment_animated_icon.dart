import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class EntertainmentAnimatedIcon extends StatefulWidget {
  const EntertainmentAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<EntertainmentAnimatedIcon> createState() =>
      _EntertainmentAnimatedIconState();
}

class _EntertainmentAnimatedIconState extends State<EntertainmentAnimatedIcon>
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
          return Transform.scale(
            scale: 0.9,
            child: CustomPaint(
              painter: _EntertainmentPainter(
                color: widget.color,
                animationValue: _controller.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EntertainmentPainter extends CustomPainter {
  _EntertainmentPainter({required this.color, required this.animationValue});

  final Color color;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final w = size.width;
    final h = size.height;

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    void drawChevron(double x, double y) {
      final p = Path()
        ..moveTo(x, y)
        ..lineTo(x + w * 0.06, y)
        ..lineTo(x - w * 0.02, y + h * 0.08)
        ..lineTo(x - w * 0.1, y + h * 0.08)
        ..close();
      canvas.drawPath(p, clearPaint);
    }

    // 1. Static base elements
    // The top part of the static base
    final staticBarPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.2, h * 0.35, w * 0.6, h * 0.08),
          Radius.circular(w * 0.02),
        ),
      );

    canvas
      ..drawPath(staticBarPath, paintFill)
      ..save()
      ..clipPath(staticBarPath);
    drawChevron(w * 0.3, h * 0.35);
    drawChevron(w * 0.5, h * 0.35);
    drawChevron(w * 0.7, h * 0.35);
    drawChevron(w * 0.9, h * 0.35);
    canvas.restore();

    // Slate bottom part
    final slate = Path()
      ..moveTo(w * 0.2, h * 0.43)
      ..lineTo(w * 0.8, h * 0.43)
      ..lineTo(w * 0.8, h * 0.80)
      ..arcToPoint(
        Offset(w * 0.75, h * 0.85),
        radius: Radius.circular(w * 0.05),
      )
      ..lineTo(w * 0.25, h * 0.85)
      ..arcToPoint(
        Offset(w * 0.2, h * 0.80),
        radius: Radius.circular(w * 0.05),
      )
      ..close();

    canvas.drawPath(slate, paintFill);

    // Play button cutout
    final playBtn = Path()
      ..moveTo(w * 0.45, h * 0.56)
      ..lineTo(w * 0.60, h * 0.64)
      ..lineTo(w * 0.45, h * 0.72)
      ..close();

    canvas.drawPath(playBtn, clearPaint);

    // 2. Animated top stick
    var stickAngle = 0.0;
    if (animationValue < 0.2) {
      stickAngle = -math.pi / 5 * (animationValue / 0.2); // opens
    } else if (animationValue < 0.4) {
      stickAngle = -math.pi / 5; // holds open
    } else if (animationValue < 0.45) {
      final t = (animationValue - 0.4) / 0.05;
      stickAngle = -math.pi / 5 * (1.0 - t); // snap shut
    } else if (animationValue < 0.55) {
      final t = (animationValue - 0.45) / 0.1;
      stickAngle = -math.sin(t * math.pi) * 0.05; // tiny bounce
    } else {
      stickAngle = 0.0;
    }

    // Pivot point
    final pivotX = w * 0.25;
    final pivotY = h * 0.35;

    canvas
      ..save()
      ..translate(pivotX, pivotY)
      ..rotate(stickAngle)
      ..translate(-pivotX, -pivotY);

    final stickPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.2, h * 0.27, w * 0.6, h * 0.08),
          Radius.circular(w * 0.02),
        ),
      );
    canvas
      ..drawPath(stickPath, paintFill)
      ..save()
      ..clipPath(stickPath);
    drawChevron(w * 0.3, h * 0.27);
    drawChevron(w * 0.5, h * 0.27);
    drawChevron(w * 0.7, h * 0.27);
    drawChevron(w * 0.9, h * 0.27);
    canvas
      ..restore()
      ..restore();

    // 3. Popping stars after the snap
    if (animationValue > 0.45) {
      final phase = (animationValue - 0.45) / 0.55; // 0.0 to 1.0

      void drawBurstStar(
        double cx,
        double cy,
        double angle,
        double distanceScale,
      ) {
        final dist = w * 0.3 * phase * distanceScale;
        final x = cx + math.cos(angle) * dist;
        final y = cy + math.sin(angle) * dist;

        final opacity = 1.0 - phase; // fade out
        final pPaint = Paint()
          ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;

        final starSize = w * 0.06 * (1.0 - phase * 0.5);

        // draw a 4-point star
        final p = Path()
          ..moveTo(x, y - starSize)
          ..quadraticBezierTo(x, y, x + starSize, y)
          ..quadraticBezierTo(x, y, x, y + starSize)
          ..quadraticBezierTo(x, y, x - starSize, y)
          ..quadraticBezierTo(x, y, x, y - starSize)
          ..close();

        canvas.drawPath(p, pPaint);
      }

      final burstCx = w * 0.5;
      final burstCy = h * 0.35;
      drawBurstStar(burstCx, burstCy, -math.pi * 0.5, 1.2);
      drawBurstStar(burstCx, burstCy, -math.pi * 0.75, 1);
      drawBurstStar(burstCx, burstCy, -math.pi * 0.25, 1);
      drawBurstStar(burstCx, burstCy, -math.pi * 0.1, 0.8);
      drawBurstStar(burstCx, burstCy, -math.pi * 0.9, 0.8);
    }

    canvas.restore(); // End saveLayer
  }

  @override
  bool shouldRepaint(covariant _EntertainmentPainter oldDelegate) {
    return true;
  }
}
