import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class BusinessAnimatedIcon extends StatefulWidget {
  const BusinessAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<BusinessAnimatedIcon> createState() => _BusinessAnimatedIconState();
}

class _BusinessAnimatedIconState extends State<BusinessAnimatedIcon>
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
            painter: _BusinessPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _BusinessPainter extends CustomPainter {
  _BusinessPainter({required this.color, required this.animationValue});

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

    final caseW = w * 0.65;
    final caseH = h * 0.45;

    // Bounce phase for briefcase
    final bounce = math.sin(animationValue * math.pi * 2);
    final caseCy = h * 0.65 + bounce * h * 0.02;

    // 1. Draw document sliding out from behind the front half
    // We'll draw document first, so it's behind the briefcase body.
    final docPhase = (animationValue + 0.5) % 1.0;
    // document goes up and comes down slightly
    final docSlide = math.sin(docPhase * math.pi * 2) * h * 0.15;

    final docW = caseW * 0.6;
    final docH = caseH * 0.8;
    final docX = cx - docW / 2;
    final docY = caseCy - caseH / 2 - docH / 2 - docSlide;

    final docRect = Rect.fromLTWH(docX, docY, docW, docH);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(docRect, Radius.circular(w * 0.02)),
        paintFill,
      )
      // Inner clear lines on document to look like text
      ..drawLine(
        Offset(docX + w * 0.06, docY + h * 0.06),
        Offset(docX + docW * 0.7, docY + h * 0.06),
        clearStroke,
      )
      ..drawLine(
        Offset(docX + w * 0.06, docY + h * 0.12),
        Offset(docX + docW * 0.8, docY + h * 0.12),
        clearStroke,
      )
      ..drawLine(
        Offset(docX + w * 0.06, docY + h * 0.18),
        Offset(docX + docW * 0.5, docY + h * 0.18),
        clearStroke,
      )
      ..drawLine(
        Offset(docX + w * 0.06, docY + h * 0.24),
        Offset(docX + docW * 0.9, docY + h * 0.24),
        clearStroke,
      );

    // 2. Draw Handle (Stroked path resting on top of body)
    final handleRect = Rect.fromCenter(
      center: Offset(cx, caseCy - caseH / 2 - h * 0.04),
      width: caseW * 0.25,
      height: h * 0.12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, Radius.circular(w * 0.03)),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.04
        ..strokeCap = StrokeCap.round,
    );

    // 3. Briefcase body
    final caseRect = Rect.fromCenter(
      center: Offset(cx, caseCy),
      width: caseW,
      height: caseH,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(caseRect, Radius.circular(w * 0.04)),
        paintFill,
      )
      // Straps / vertical lines
      ..drawLine(
        Offset(cx - caseW * 0.25, caseCy - caseH / 2 + clearStroke.strokeWidth),
        Offset(cx - caseW * 0.25, caseCy + caseH / 2 - clearStroke.strokeWidth),
        clearStroke,
      )
      ..drawLine(
        Offset(cx + caseW * 0.25, caseCy - caseH / 2 + clearStroke.strokeWidth),
        Offset(cx + caseW * 0.25, caseCy + caseH / 2 - clearStroke.strokeWidth),
        clearStroke,
      )
      // Center lock base
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, caseCy - caseH * 0.1),
            width: caseW * 0.18,
            height: caseH * 0.18,
          ),
          Radius.circular(w * 0.02),
        ),
        clearPaint,
      )
      // Center lock button
      ..drawCircle(Offset(cx, caseCy - caseH * 0.1), w * 0.025, paintFill)
      // Separation line for the top opening
      ..drawLine(
        Offset(cx - caseW / 2 + w * 0.02, caseCy - caseH * 0.3),
        Offset(cx + caseW / 2 - w * 0.02, caseCy - caseH * 0.3),
        clearStroke,
      );

    // 4. Floating sparkles
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

    drawSparkle(cx - w * 0.4, h * 0.3, 0);
    drawSparkle(cx + w * 0.35, h * 0.25, 0.4);
    drawSparkle(cx - w * 0.3, h * 0.7, 0.7);
    drawSparkle(cx + w * 0.4, h * 0.65, 0.2);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _BusinessPainter oldDelegate) {
    return true;
  }
}
