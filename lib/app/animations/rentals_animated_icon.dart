import 'dart:math' as math;

import 'package:flutter/material.dart';

class RentalsAnimatedIcon extends StatefulWidget {
  const RentalsAnimatedIcon({required this.color, super.key, this.size = 60.0});

  final Color color;
  final double size;

  @override
  State<RentalsAnimatedIcon> createState() => _RentalsAnimatedIconState();
}

class _RentalsAnimatedIconState extends State<RentalsAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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
            painter: _RentalsPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _RentalsPainter extends CustomPainter {
  _RentalsPainter({required this.color, required this.animationValue});

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

    final clearFill = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    // Bounce the entire keyring assembly
    final bounce = math.sin(animationValue * math.pi * 2) * h * 0.03;

    canvas
      ..save()
      ..translate(0, bounce);

    // Key ring
    final ringCy = cy - h * 0.15;
    final ringR = w * 0.15;

    // Draw ring
    canvas
      ..drawCircle(
        Offset(cx, ringCy),
        ringR,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.04,
      )
      // Inner clear
      ..drawCircle(
        Offset(cx, ringCy),
        ringR,
        Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.015,
      );

    // 1. Tag (House shaped) swinging
    final tagSwing = math.sin(animationValue * math.pi * 2) * math.pi / 12;
    canvas
      ..save()
      ..translate(cx, ringCy + ringR)
      ..rotate(tagSwing)
      ..translate(-cx, -(ringCy + ringR));

    final tagW = w * 0.35;
    final tagH = h * 0.4;
    final tagStartCy = ringCy + ringR;

    final tagPath = Path()
      ..moveTo(cx, tagStartCy) // top hole
      ..lineTo(cx + tagW / 2, tagStartCy + tagH * 0.3)
      ..lineTo(cx + tagW * 0.4, tagStartCy + tagH)
      ..lineTo(cx - tagW * 0.4, tagStartCy + tagH)
      ..lineTo(cx - tagW / 2, tagStartCy + tagH * 0.3)
      ..close();

    canvas
      ..drawPath(tagPath, paintFill)
      // clear hole
      ..drawCircle(Offset(cx, tagStartCy + h * 0.05), w * 0.03, clearFill)
      // inner house cutout
      ..drawPath(
        Path()
          ..moveTo(cx, tagStartCy + h * 0.15)
          ..lineTo(cx + tagW * 0.2, tagStartCy + tagH * 0.4)
          ..lineTo(cx + tagW * 0.2, tagStartCy + tagH * 0.8)
          ..lineTo(cx - tagW * 0.2, tagStartCy + tagH * 0.8)
          ..lineTo(cx - tagW * 0.2, tagStartCy + tagH * 0.4)
          ..close(),
        clearFill,
      )
      // little door in house cutout
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, tagStartCy + tagH * 0.65),
            width: tagW * 0.1,
            height: tagH * 0.2,
          ),
          Radius.circular(w * 0.01),
        ),
        paintFill,
      )
      ..restore(); // end tag swing

    // 2. Key swinging (over the tag)
    final keySwing = math.cos(animationValue * math.pi * 2) * math.pi / 8;
    canvas
      ..save()
      ..translate(
        cx + ringR * 0.7,
        ringCy + ringR * 0.7,
      ) // key hangs from bottom right of ring
      ..rotate(-math.pi / 6 + keySwing);

    // Key body
    final keyW = w * 0.15;
    final keyH = h * 0.45;
    final keyPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, keyH * 0.2),
            width: keyW,
            height: keyW * 1.5,
          ),
          Radius.circular(w * 0.03),
        ),
      ) // key head
      ..addRect(
        Rect.fromLTWH(-keyW * 0.2, keyH * 0.2, keyW * 0.4, keyH * 0.8),
      ) // key shaft
      // Teeth
      ..addRect(Rect.fromLTWH(keyW * 0.1, keyH * 0.7, keyW * 0.3, keyH * 0.1))
      ..addRect(Rect.fromLTWH(keyW * 0.1, keyH * 0.85, keyW * 0.3, keyH * 0.1));

    canvas
      ..drawPath(
        keyPath,
        clearPaintList..strokeWidth = w * 0.04,
      ) // outline to separate from tag
      ..drawPath(keyPath, paintFill)
      // key head hole
      ..drawCircle(Offset(0, keyH * 0.15), keyW * 0.2, clearFill)
      // key center groove
      // key center groove
      ..drawLine(
        Offset(0, keyH * 0.4),
        Offset(0, keyH * 0.9),
        clearPaintList..strokeWidth = w * 0.015,
      )
      // end key swing
      ..restore()
      ..restore(); // end bounce

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

    drawSparkle(cx - w * 0.35, h * 0.3, 0.2);
    drawSparkle(cx + w * 0.35, h * 0.2, 0.7);
    drawSparkle(cx - w * 0.2, h * 0.8, 0.4);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _RentalsPainter oldDelegate) {
    return true;
  }
}
