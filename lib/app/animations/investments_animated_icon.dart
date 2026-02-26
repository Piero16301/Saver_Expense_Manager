import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class InvestmentsAnimatedIcon extends StatefulWidget {
  const InvestmentsAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<InvestmentsAnimatedIcon> createState() =>
      _InvestmentsAnimatedIconState();
}

class _InvestmentsAnimatedIconState extends State<InvestmentsAnimatedIcon>
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
            painter: _InvestmentsPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _InvestmentsPainter extends CustomPainter {
  _InvestmentsPainter({required this.color, required this.animationValue});

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

    final baseCy = h * 0.75;

    // Grid / Base Line
    canvas.drawLine(
      Offset(w * 0.1, baseCy),
      Offset(w * 0.9, baseCy),
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round,
    );

    // 1. Draw 3 bars that grow and shrink slightly
    // Max heights: 1st=20%, 2nd=35%, 3rd=50%
    void drawBar(int index, double maxH, double delay) {
      final phase = (animationValue * 2.0 + delay) % 1.0;
      // Bounce effect for the bar height
      final bounce = math.sin(phase * math.pi) * 0.2 + 0.8;
      // Base height
      final currentH = maxH * bounce;

      final barW = w * 0.15;
      final barSpace = w * 0.05;
      final startX = w * 0.18;

      final rect = Rect.fromLTWH(
        startX + index * (barW + barSpace),
        baseCy - currentH,
        barW,
        currentH,
      );

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(w * 0.02),
          topRight: Radius.circular(w * 0.02),
        ),
        paintFill,
      );
    }

    drawBar(0, h * 0.2, 0);
    drawBar(1, h * 0.35, 0.2);
    drawBar(2, h * 0.5, 0.4);

    // 2. Draw Arrow shooting up and right
    // The arrow follows a path
    final arrowPhase = animationValue;
    // from left bottom to right top
    final startP = Offset(w * 0.15, baseCy - h * 0.1);
    final endP = Offset(w * 0.85, h * 0.15);

    final ctrl1 = Offset(w * 0.4, baseCy - h * 0.1);
    final ctrl2 = Offset(w * 0.6, h * 0.3);

    // Get position on bezier curve
    Offset getBezierPoint(double t) {
      final u = 1 - t;
      final tt = t * t;
      final uu = u * u;
      final uuu = uu * u;
      final ttt = tt * t;

      final p = startP * uuu +
          ctrl1 * (3 * uu * t) +
          ctrl2 * (3 * u * tt) +
          endP * ttt;
      return p;
    }

    // Draw the full trajectory as a faded line
    final pPath = Path()
      ..moveTo(startP.dx, startP.dy)
      ..cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, endP.dx, endP.dy);
    canvas.drawPath(
      pPath,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round,
    );

    // Arrow head moves along the path
    var tArrow = arrowPhase * 1.5 - 0.2; // 0 to 1 with some delay/exit
    tArrow = tArrow.clamp(0.0, 1.0);

    final currentPos = getBezierPoint(tArrow);

    // calc angle
    const delta = 0.01;
    final nextPos = getBezierPoint(math.min(1, tArrow + delta));
    final angle =
        math.atan2(nextPos.dy - currentPos.dy, nextPos.dx - currentPos.dx);

    var opacity = 1.0;
    if (arrowPhase < 0.1) {
      opacity = arrowPhase / 0.1;
    } else if (arrowPhase > 0.8) {
      opacity = (1.0 - (arrowPhase - 0.8) / 0.2).clamp(0.0, 1.0);
    }

    if (opacity > 0) {
      canvas
        ..save()
        ..translate(currentPos.dx, currentPos.dy)
        ..rotate(angle);

      final arrowScale = 1.0 + math.sin(arrowPhase * math.pi) * 0.2; // pulse
      canvas.scale(arrowScale);

      final arrPaint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Draw arrow head (pointing right because of rotate)
      final arrPath = Path()
        ..moveTo(w * 0.1, 0)
        ..lineTo(-w * 0.08, w * 0.08)
        ..lineTo(-w * 0.08, -w * 0.08)
        ..close();

      canvas
        ..drawPath(arrPath, arrPaint)

        // Arrow trail (rocket tail)
        ..drawRect(
          Rect.fromLTWH(-w * 0.25, -w * 0.03, w * 0.17, w * 0.06),
          arrPaint,
        )

        // Inner clear to make it sleek
        ..drawLine(
          Offset(-w * 0.22, 0),
          Offset(w * 0.02, 0),
          Paint()
            ..blendMode = BlendMode.clear
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.015
            ..strokeCap = StrokeCap.round,
        )
        ..restore();
    }

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

    drawSparkle(cx - w * 0.35, h * 0.2, 0.2);
    drawSparkle(cx + w * 0.3, h * 0.3, 0.7);
    drawSparkle(cx + w * 0.1, h * 0.6, 0.5);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _InvestmentsPainter oldDelegate) {
    return true;
  }
}
