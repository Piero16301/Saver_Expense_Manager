import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class AwardsAnimatedIcon extends StatefulWidget {
  const AwardsAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<AwardsAnimatedIcon> createState() => _AwardsAnimatedIconState();
}

class _AwardsAnimatedIconState extends State<AwardsAnimatedIcon>
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
            painter: _AwardsPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _AwardsPainter extends CustomPainter {
  _AwardsPainter({required this.color, required this.animationValue});

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

    // Wobble animation
    final wobble = math.sin(animationValue * math.pi * 4) * math.pi / 24;
    final bounce = math.sin(animationValue * math.pi * 4) * h * 0.02;

    canvas
      ..save()
      ..translate(cx, h * 0.8)
      ..rotate(wobble)
      ..translate(-cx, -h * 0.8 + bounce);

    // 1. Trophy Base
    final baseW = w * 0.4;
    final baseH = h * 0.12;
    final baseY = h * 0.75;

    // Bottom step
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, baseY),
            width: baseW,
            height: baseH,
          ),
          Radius.circular(w * 0.02),
        ),
        paintFill,
      )
      // Top step
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, baseY - baseH * 0.8),
            width: baseW * 0.6,
            height: baseH * 0.8,
          ),
          Radius.circular(w * 0.02),
        ),
        paintFill,
      );

    // Stem
    final stemW = w * 0.1;
    final stemH = h * 0.15;
    final stemY = baseY - baseH * 1.5;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, stemY), width: stemW, height: stemH),
      paintFill,
    );

    // 2. Trophy Bowl
    final bowlW = w * 0.55;
    final bowlH = h * 0.45;
    final bowlY = stemY - stemH / 2 - bowlH / 2;

    final bowlPath = Path()
      ..moveTo(cx - bowlW / 2, bowlY - bowlH / 2) // top left
      ..lineTo(cx + bowlW / 2, bowlY - bowlH / 2) // top right
      ..quadraticBezierTo(
        cx + bowlW / 2, bowlY + bowlH / 2, // control point right
        cx, bowlY + bowlH / 2, // end point bottom center
      )
      ..quadraticBezierTo(
        cx - bowlW / 2, bowlY + bowlH / 2, // control point left
        cx - bowlW / 2, bowlY - bowlH / 2, // end point top left
      )
      ..close();

    canvas
      ..drawPath(bowlPath, paintFill)

      // Clear line to define rim
      ..drawLine(
        Offset(cx - bowlW / 2 + w * 0.02, bowlY - bowlH / 2 + h * 0.06),
        Offset(cx + bowlW / 2 - w * 0.02, bowlY - bowlH / 2 + h * 0.06),
        clearPaintList,
      )

      // Shine line on the bowl
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx, bowlY - bowlH * 0.1),
          width: bowlW * 0.6,
          height: bowlH * 0.6,
        ),
        math.pi / 2.5,
        math.pi / 4,
        false,
        clearPaintList..strokeWidth = w * 0.015,
      );

    // 3. Handles
    final handleW = w * 0.2;
    final handleH = h * 0.25;

    // Left Handle
    canvas
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx - bowlW / 2 + w * 0.05, bowlY - h * 0.05),
          width: handleW,
          height: handleH,
        ),
        math.pi / 2,
        math.pi,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.04
          ..strokeCap = StrokeCap.round,
      )
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx - bowlW / 2 + w * 0.05, bowlY - h * 0.05),
          width: handleW,
          height: handleH,
        ),
        math.pi / 2,
        math.pi,
        false,
        Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.015
          ..strokeCap = StrokeCap.round,
      )

      // Right Handle
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx + bowlW / 2 - w * 0.05, bowlY - h * 0.05),
          width: handleW,
          height: handleH,
        ),
        -math.pi / 2,
        math.pi,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.04
          ..strokeCap = StrokeCap.round,
      )
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx + bowlW / 2 - w * 0.05, bowlY - h * 0.05),
          width: handleW,
          height: handleH,
        ),
        -math.pi / 2,
        math.pi,
        false,
        Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.015
          ..strokeCap = StrokeCap.round,
      )
      ..restore(); // end wobble

    // 4. Popping Star from inside the cup
    if (animationValue > 0.1 && animationValue < 0.9) {
      final t = (animationValue - 0.1) / 0.8;

      final starStartX = cx;
      final starStartY = bowlY - bowlH / 2 + h * 0.05; // inside cup
      final starEndY = bowlY - bowlH - h * 0.15;

      // parabolic arc
      final starY = starStartY + (starEndY - starStartY) * t;
      // move in a slight sine wave horizontally
      final starX = starStartX + math.sin(t * math.pi * 2) * w * 0.1;

      // spin
      final starAngle = t * math.pi * 4;

      var opacity = 1.0;
      if (t > 0.7) {
        opacity = 1.0 - (t - 0.7) / 0.3;
      }

      final starScale = math.sin(t * math.pi); // grows then shrinks

      canvas
        ..save()
        // clip so it doesn't show over the front edge of the bowl
        ..clipRect(Rect.fromLTWH(0, 0, w, starStartY))
        ..translate(starX, starY)
        ..rotate(starAngle)
        ..scale(starScale);

      // Draw Star
      final starPath = Path();
      const points = 5;
      final outerRadius = w * 0.15;
      final innerRadius = w * 0.06;

      for (var i = 0; i < points * 2; i++) {
        final radius = i.isEven ? outerRadius : innerRadius;
        final angle = i * math.pi / points - math.pi / 2;
        final point =
            Offset(math.cos(angle) * radius, math.sin(angle) * radius);
        if (i == 0) {
          starPath.moveTo(point.dx, point.dy);
        } else {
          starPath.lineTo(point.dx, point.dy);
        }
      }
      starPath.close();

      canvas
        ..drawPath(
          starPath,
          Paint()
            ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
            ..style = PaintingStyle.fill,
        )

        // Inner clear circle to make star pop
        ..drawCircle(
          Offset.zero,
          innerRadius * 0.5,
          Paint()..blendMode = BlendMode.clear,
        )
        ..restore();
    }

    // 5. Floating Sparkles
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

    drawSparkle(cx - w * 0.35, cy, 0.2);
    drawSparkle(cx + w * 0.4, cy - h * 0.1, 0.7);
    drawSparkle(cx - w * 0.1, cy - h * 0.35, 0.4);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _AwardsPainter oldDelegate) {
    return true;
  }
}
