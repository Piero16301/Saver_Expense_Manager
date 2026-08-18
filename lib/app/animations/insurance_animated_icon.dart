import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class InsuranceAnimatedIcon extends StatefulWidget {
  const InsuranceAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<InsuranceAnimatedIcon> createState() => _InsuranceAnimatedIconState();
}

class _InsuranceAnimatedIconState extends State<InsuranceAnimatedIcon>
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
            painter: _InsurancePainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _InsurancePainter extends CustomPainter {
  _InsurancePainter({required this.color, required this.animationValue});

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

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Shield bobbing animation
    final bobY = math.sin(animationValue * math.pi * 2) * h * 0.03;
    final shieldCy = cy + bobY;

    // Shield path
    final shieldPath = Path()
      ..moveTo(cx, shieldCy - h * 0.32)
      ..quadraticBezierTo(
        cx + w * 0.15,
        shieldCy - h * 0.32,
        cx + w * 0.3,
        shieldCy - h * 0.25,
      )
      ..lineTo(cx + w * 0.3, shieldCy + h * 0.05)
      ..quadraticBezierTo(
        cx + w * 0.3,
        shieldCy + h * 0.25,
        cx,
        shieldCy + h * 0.38,
      )
      ..quadraticBezierTo(
        cx - w * 0.3,
        shieldCy + h * 0.25,
        cx - w * 0.3,
        shieldCy + h * 0.05,
      )
      ..lineTo(cx - w * 0.3, shieldCy - h * 0.25)
      ..quadraticBezierTo(
        cx - w * 0.15,
        shieldCy - h * 0.32,
        cx,
        shieldCy - h * 0.32,
      )
      ..close();

    // Draw Forcefield Ripples (expanding from shield)
    void drawRipple(double offset) {
      final rippleScale = ((animationValue * 2.0) + offset) % 1.0;
      final rippleOpacity = 1.0 - rippleScale;

      if (rippleOpacity > 0) {
        canvas
          ..save()
          ..translate(cx, shieldCy)
          ..scale(1.0 + rippleScale * 0.3)
          ..translate(-cx, -shieldCy);

        final ripplePaint = Paint()
          ..color = color.withValues(
            alpha: (rippleOpacity * 0.4).clamp(0.0, 1.0),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.015;

        canvas
          ..drawPath(shieldPath, ripplePaint)
          ..restore();
      }
    }

    drawRipple(0);
    drawRipple(0.5);

    // Draw main shield
    canvas.drawPath(shieldPath, paintFill);

    // Inner clear line
    const innerScale = 0.8;
    canvas
      ..save()
      ..translate(cx, shieldCy)
      ..scale(innerScale)
      ..translate(-cx, -shieldCy)
      ..drawPath(shieldPath, clearPaint)
      ..restore();

    // Check mark inside
    final checkPath = Path()
      ..moveTo(cx - w * 0.08, shieldCy)
      ..lineTo(cx - w * 0.01, shieldCy + h * 0.07)
      ..lineTo(cx + w * 0.12, shieldCy - h * 0.08);

    canvas.drawPath(checkPath, clearPaint..strokeWidth = w * 0.035);

    // Floating sparkles/stars
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

    drawSparkle(cx - w * 0.38, cy - h * 0.25, 0);
    drawSparkle(cx + w * 0.38, cy - h * 0.1, 0.3);
    drawSparkle(cx, cy + h * 0.48, 0.6);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _InsurancePainter oldDelegate) {
    return true;
  }
}
