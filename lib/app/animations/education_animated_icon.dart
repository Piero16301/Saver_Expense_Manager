import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class EducationAnimatedIcon extends StatefulWidget {
  const EducationAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<EducationAnimatedIcon> createState() => _EducationAnimatedIconState();
}

class _EducationAnimatedIconState extends State<EducationAnimatedIcon>
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
            painter: _EducationPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _EducationPainter extends CustomPainter {
  _EducationPainter({required this.color, required this.animationValue});

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
      ..strokeJoin = StrokeJoin.round;

    // 1. Draw an open book at the bottom
    final bookCy = h * 0.75;

    // Book base
    final bookPath = Path()
      ..moveTo(cx, bookCy + h * 0.05)
      ..quadraticBezierTo(cx - w * 0.2, bookCy, cx - w * 0.4, bookCy - h * 0.05)
      ..lineTo(cx - w * 0.4, bookCy + h * 0.08)
      ..quadraticBezierTo(
        cx - w * 0.2,
        bookCy + h * 0.13,
        cx,
        bookCy + h * 0.18,
      )
      ..quadraticBezierTo(
        cx + w * 0.2,
        bookCy + h * 0.13,
        cx + w * 0.4,
        bookCy + h * 0.08,
      )
      ..lineTo(cx + w * 0.4, bookCy - h * 0.05)
      ..quadraticBezierTo(cx + w * 0.2, bookCy, cx, bookCy + h * 0.05)
      ..close();

    canvas.drawPath(bookPath, paintFill);

    // Book spine clear line
    final spinePath = Path()
      ..moveTo(cx, bookCy + h * 0.05)
      ..lineTo(cx, bookCy + h * 0.18);
    canvas.drawPath(spinePath, clearPaint);

    // Book pages horizontal lines
    final pageLinePaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawLine(
        Offset(cx - w * 0.1, bookCy + h * 0.06),
        Offset(cx - w * 0.3, bookCy + h * 0.01),
        pageLinePaint,
      )
      ..drawLine(
        Offset(cx - w * 0.1, bookCy + h * 0.11),
        Offset(cx - w * 0.3, bookCy + h * 0.06),
        pageLinePaint,
      )
      ..drawLine(
        Offset(cx + w * 0.1, bookCy + h * 0.06),
        Offset(cx + w * 0.3, bookCy + h * 0.01),
        pageLinePaint,
      )
      ..drawLine(
        Offset(cx + w * 0.1, bookCy + h * 0.11),
        Offset(cx + w * 0.3, bookCy + h * 0.06),
        pageLinePaint,
      );

    // 2. Levitation animation for the cap
    final hoverOffset = math.sin(animationValue * math.pi * 2) * h * 0.03;
    final capCy = h * 0.38 + hoverOffset;

    // Bottom part of the cap (skull cap)
    final capBottomPath = Path()
      ..moveTo(cx - w * 0.2, capCy + h * 0.06)
      ..lineTo(cx - w * 0.2, capCy + h * 0.18)
      ..quadraticBezierTo(cx, capCy + h * 0.26, cx + w * 0.2, capCy + h * 0.18)
      ..lineTo(cx + w * 0.2, capCy + h * 0.06)
      ..close();

    canvas.drawPath(capBottomPath, paintFill);

    // Mortarboard Cap top (square rotated)
    final capTopPath = Path()
      ..moveTo(cx, capCy - h * 0.14) // Top
      ..lineTo(cx + w * 0.45, capCy) // Right
      ..lineTo(cx, capCy + h * 0.14) // Bottom
      ..lineTo(cx - w * 0.45, capCy) // Left
      ..close();

    canvas
      ..drawPath(capTopPath, paintFill)
      ..drawPath(capTopPath, clearPaint);

    // 3. Animated Tassel
    final tasselPhase = animationValue * math.pi * 2;
    // Swinging motion
    final swingAngle = math.cos(tasselPhase) * 0.3;

    final pivotX = cx;
    final pivotY = capCy;

    canvas
      ..save()
      ..translate(pivotX, pivotY)
      ..rotate(swingAngle)
      ..translate(-pivotX, -pivotY);

    // Tassel String
    final stringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;

    // Slanted starting angle for the tassel
    canvas.drawLine(
      Offset(cx, pivotY),
      Offset(cx + w * 0.25, pivotY + h * 0.08),
      stringPaint,
    );

    // Tassel end (knot bounds)
    final tasselEndPath = Path()
      ..moveTo(cx + w * 0.25, pivotY + h * 0.08)
      ..lineTo(cx + w * 0.22, pivotY + h * 0.18)
      ..lineTo(cx + w * 0.28, pivotY + h * 0.18)
      ..close();

    canvas
      ..drawPath(tasselEndPath, paintFill)
      ..drawCircle(Offset(cx, pivotY), w * 0.03, paintFill)
      ..restore(); // restore swing transformation

    // 4. Floating sparkles
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

    drawSparkle(cx - w * 0.35, capCy - h * 0.1, 0);
    drawSparkle(cx + w * 0.3, capCy - h * 0.25, 0.4);
    drawSparkle(cx - w * 0.25, capCy + h * 0.15, 0.7);

    canvas.restore(); // end saveLayer
  }

  @override
  bool shouldRepaint(covariant _EducationPainter oldDelegate) {
    return true;
  }
}
