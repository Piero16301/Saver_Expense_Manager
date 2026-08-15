import 'dart:math' as math;

import 'package:flutter/material.dart';

class FashionAnimatedIcon extends StatefulWidget {
  const FashionAnimatedIcon({required this.color, super.key, this.size = 60.0});

  final Color color;
  final double size;

  @override
  State<FashionAnimatedIcon> createState() => _FashionAnimatedIconState();
}

class _FashionAnimatedIconState extends State<FashionAnimatedIcon>
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
            painter: _FashionPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _FashionPainter extends CustomPainter {
  _FashionPainter({required this.color, required this.animationValue});

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
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;

    final clearFill = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    // The swing animation mimics a clothing hanger swaying naturally
    final swingPhase = animationValue * math.pi * 2;
    final swingAngle = math.sin(swingPhase) * 0.08; // Gentle sway

    final hangerWy = h * 0.35; // Horizontal rod of hanger
    final pivotX = cx;
    final pivotY = hangerWy - h * 0.15; // Pivot point at the hook tip

    canvas
      ..save()
      ..translate(pivotX, pivotY)
      ..rotate(swingAngle)
      ..translate(-pivotX, -pivotY);

    // 1. Draw Hanger Hook
    final hookPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;

    final hookPath = Path()
      ..moveTo(cx, hangerWy)
      ..lineTo(cx, hangerWy - h * 0.04)
      ..quadraticBezierTo(
        cx + w * 0.08,
        hangerWy - h * 0.08,
        cx + w * 0.05,
        hangerWy - h * 0.14,
      )
      ..quadraticBezierTo(
        cx - w * 0.05,
        hangerWy - h * 0.16,
        cx - w * 0.05,
        hangerWy - h * 0.10,
      );

    canvas.drawPath(hookPath, hookPaint);

    // 2. Draw Hanger Base (Wooden part)
    final hangerWidth = w * 0.45;
    final hangerPath = Path()
      ..moveTo(cx - hangerWidth / 2, hangerWy)
      ..quadraticBezierTo(
        cx,
        hangerWy - h * 0.08,
        cx + hangerWidth / 2,
        hangerWy,
      )
      ..lineTo(cx + hangerWidth / 2, hangerWy + h * 0.03)
      ..lineTo(cx - hangerWidth / 2, hangerWy + h * 0.03)
      ..close();

    canvas.drawPath(hangerPath, paintFill);

    // 3. Draw Dress/Coat
    final dressPath = Path()
      ..moveTo(cx - w * 0.18, hangerWy - h * 0.01) // left collar start
      ..quadraticBezierTo(
        cx,
        hangerWy + h * 0.08,
        cx + w * 0.18,
        hangerWy - h * 0.01,
      ) // neck cutout / right collar
      ..lineTo(cx + w * 0.28, hangerWy + h * 0.05) // right shoulder
      ..lineTo(cx + w * 0.38, hangerWy + h * 0.25) // right sleeve end
      ..lineTo(cx + w * 0.22, hangerWy + h * 0.32) // right armpit
      ..quadraticBezierTo(
        cx + w * 0.25,
        h * 0.65,
        cx + w * 0.32,
        h * 0.85,
      ) // right skirt hem flowing out
      ..quadraticBezierTo(
        cx,
        h * 0.90,
        cx - w * 0.32,
        h * 0.85,
      ) // bottom hem waving
      ..quadraticBezierTo(
        cx - w * 0.25,
        h * 0.65,
        cx - w * 0.22,
        hangerWy + h * 0.32,
      ) // left armpit
      ..lineTo(cx - w * 0.38, hangerWy + h * 0.25) // left sleeve end
      ..lineTo(cx - w * 0.28, hangerWy + h * 0.05) // left shoulder
      ..close();

    canvas.drawPath(dressPath, paintFill);

    // Dress details using clear lines (seams, waist belt, collar)
    // Cutout neck
    final collarCutout = Path()
      ..moveTo(cx - w * 0.12, hangerWy - h * 0.01)
      ..quadraticBezierTo(
        cx,
        hangerWy + h * 0.06,
        cx + w * 0.12,
        hangerWy - h * 0.01,
      )
      ..close();
    canvas.drawPath(collarCutout, clearFill);

    final clearLapel = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..strokeJoin = StrokeJoin.round;

    final lapelLeft = Path()
      ..moveTo(cx - w * 0.15, hangerWy + h * 0.01)
      ..lineTo(cx - w * 0.04, hangerWy + h * 0.2)
      ..lineTo(cx - w * 0.1, hangerWy + h * 0.12);
    canvas.drawPath(lapelLeft, clearLapel);

    final lapelRight = Path()
      ..moveTo(cx + w * 0.15, hangerWy + h * 0.01)
      ..lineTo(cx + w * 0.04, hangerWy + h * 0.2)
      ..lineTo(cx + w * 0.1, hangerWy + h * 0.12);
    canvas.drawPath(lapelRight, clearLapel);

    // Waist belt
    final beltCy = h * 0.55;
    canvas
      ..drawLine(
        Offset(cx - w * 0.22, beltCy - h * 0.02),
        Offset(cx + w * 0.22, beltCy - h * 0.02),
        clearPaint,
      )
      ..drawLine(
        Offset(cx - w * 0.23, beltCy + h * 0.02),
        Offset(cx + w * 0.23, beltCy + h * 0.02),
        clearPaint,
      )
      // Middle zipper or seam
      ..drawLine(
        Offset(cx, hangerWy + h * 0.08),
        Offset(cx, beltCy - h * 0.02),
        clearPaint,
      )
      ..drawLine(
        Offset(cx, beltCy + h * 0.02),
        Offset(cx, h * 0.88),
        clearPaint,
      )
      // Belt buckle
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, beltCy),
            width: w * 0.15,
            height: h * 0.08,
          ),
          Radius.circular(w * 0.02),
        ),
        clearPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, beltCy),
            width: w * 0.08,
            height: h * 0.04,
          ),
          Radius.circular(w * 0.01),
        ),
        clearPaint,
      )
      ..restore(); // end hanger swing

    // 4. Floating sparkles matching stylish theme
    void drawSparkle(double x, double y, double delay) {
      final phase = (animationValue + delay) % 1.0;
      final scale = math.sin(phase * math.pi); // 0 -> 1 -> 0
      final sLength = w * 0.04 * scale;

      final sPaint = Paint()
        ..color = color.withValues(alpha: scale)
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

    drawSparkle(cx - w * 0.35, h * 0.2, 0);
    drawSparkle(cx + w * 0.35, h * 0.3, 0.3);
    drawSparkle(cx - w * 0.3, h * 0.7, 0.6);
    drawSparkle(cx + w * 0.4, h * 0.75, 0.1);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _FashionPainter oldDelegate) {
    return true;
  }
}
