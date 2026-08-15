import 'dart:math' as math;

import 'package:flutter/material.dart';

class TransportAnimatedIcon extends StatefulWidget {
  const TransportAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<TransportAnimatedIcon> createState() => _TransportAnimatedIconState();
}

class _TransportAnimatedIconState extends State<TransportAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
            painter: _TransportPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _TransportPainter extends CustomPainter {
  _TransportPainter({required this.color, required this.animationValue});

  final Color color;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final w = size.width;
    final h = size.height;

    // Bounce effect
    final bounce = math.sin(animationValue * math.pi * 4) * (h * 0.04);

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas
      ..save()
      ..translate(0, bounce);

    // 1. Draw solid car body
    final chassis = Path()
      ..moveTo(w * 0.1, h * 0.65)
      ..lineTo(w * 0.1, h * 0.45)
      ..quadraticBezierTo(w * 0.1, h * 0.35, w * 0.25, h * 0.35)
      ..lineTo(w * 0.45, h * 0.35)
      ..quadraticBezierTo(w * 0.65, h * 0.35, w * 0.70, h * 0.45)
      ..lineTo(w * 0.90, h * 0.45)
      ..quadraticBezierTo(w * 0.95, h * 0.45, w * 0.95, h * 0.55)
      ..lineTo(w * 0.95, h * 0.65)
      ..lineTo(w * 0.1, h * 0.65)
      ..close();

    canvas.drawPath(chassis, paintFill);

    // 2. Erase windows with clear blend mode
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    final windowGroup = Path()
      // Back window
      ..moveTo(w * 0.20, h * 0.45)
      ..lineTo(w * 0.42, h * 0.45)
      ..lineTo(w * 0.42, h * 0.38)
      ..quadraticBezierTo(w * 0.25, h * 0.38, w * 0.20, h * 0.45)
      // Front window
      ..moveTo(w * 0.48, h * 0.45)
      ..lineTo(w * 0.65, h * 0.45)
      ..quadraticBezierTo(w * 0.60, h * 0.38, w * 0.48, h * 0.38)
      ..lineTo(w * 0.48, h * 0.45);

    canvas
      ..drawPath(windowGroup, clearPaint)
      // 3. Draw wheel arches (Erase)
      ..drawCircle(Offset(w * 0.25, h * 0.65), w * 0.16, clearPaint)
      ..drawCircle(Offset(w * 0.80, h * 0.65), w * 0.16, clearPaint)
      ..restore(); // Wheels shouldn't bounce as much

    // 4. Draw wheels!
    void drawWheel(double cx, double cy) {
      canvas
        ..save()
        ..translate(cx, cy)
        // rotate backwards if movement is left, or forwards if movement is
        // right the car is facing right, so speed lines go left, wheels rotate
        // CW.
        ..rotate(animationValue * math.pi * 2)
        // Wheel rim outer circle
        ..drawCircle(Offset.zero, w * 0.12, paintFill)
        // Wheel rim cutout
        ..drawCircle(Offset.zero, w * 0.05, clearPaint)
        // Wheel inner circle
        ..drawCircle(Offset.zero, w * 0.02, paintFill);

      // Spokes cutout
      final spokeClear = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015;

      canvas
        ..drawLine(Offset(-w * 0.1, 0), Offset(w * 0.1, 0), spokeClear)
        ..drawLine(Offset(0, -w * 0.1), Offset(0, w * 0.1), spokeClear)
        ..restore();
    }

    drawWheel(w * 0.25, h * 0.7);
    drawWheel(w * 0.80, h * 0.7);

    // 5. Speed Lines
    final lineSpeed = w;
    final dx = -(animationValue * lineSpeed * 2);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    void drawSpeedLine(double startX, double y, double length) {
      var x = (startX + dx) % (w * 1.5);
      if (x < -w * 0.5) x += w * 1.5;

      final renderX = x;
      // Fade near ends
      final opacity = (renderX + w * 0.5) / (w * 1.5);
      linePaint.color = color.withValues(
        alpha: math.sin(opacity * math.pi).clamp(0.0, 1.0),
      );

      canvas.drawLine(
        Offset(renderX, y),
        Offset(renderX - length, y),
        linePaint,
      );
    }

    drawSpeedLine(w * 1.0, h * 0.85, w * 0.2);
    drawSpeedLine(w * 0.6, h * 0.90, w * 0.15);
    drawSpeedLine(w * 1.3, h * 0.75, w * 0.25);

    canvas.restore(); // End saveLayer
  }

  @override
  bool shouldRepaint(covariant _TransportPainter oldDelegate) {
    return true; // We animate continuously
  }
}
