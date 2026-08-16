import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class DwellingAnimatedIcon extends StatefulWidget {
  const DwellingAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<DwellingAnimatedIcon> createState() => _DwellingAnimatedIconState();
}

class _DwellingAnimatedIconState extends State<DwellingAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
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
            painter: _DwellingPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _DwellingPainter extends CustomPainter {
  _DwellingPainter({required this.color, required this.animationValue});

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

    final clearPaintList = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final clearFill = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    // Base Y offset for house
    final baseCy = h * 0.82;

    // Slight squish/bounce effect for the house
    final bouncePhase = math.sin(animationValue * math.pi * 4);
    final houseScaleY = 1.0 - (bouncePhase * 0.02);

    canvas
      ..save()
      ..translate(cx, baseCy)
      ..scale(1, houseScaleY)
      ..translate(-cx, -baseCy);

    // 1. Draw House Base (Square/Rect)
    final houseWidth = w * 0.6;
    final houseHeight = h * 0.45;
    final houseRect = Rect.fromCenter(
      center: Offset(cx, baseCy - houseHeight / 2),
      width: houseWidth,
      height: houseHeight,
    );

    // House body
    final bodyPath = Path()
      ..addRRect(RRect.fromRectAndRadius(houseRect, Radius.circular(w * 0.04)));
    canvas.drawPath(bodyPath, paintFill);

    // 2. Draw Roof (Triangle)
    final roofHeight = h * 0.25;
    final roofY = baseCy - houseHeight;
    final roofPath = Path()
      ..moveTo(cx - houseWidth * 0.6, roofY)
      ..lineTo(cx + houseWidth * 0.6, roofY)
      ..lineTo(cx, roofY - roofHeight)
      ..close();

    // Clear separation between roof and house
    canvas
      ..drawPath(roofPath, paintFill)
      ..drawLine(
        Offset(cx - houseWidth * 0.6, roofY),
        Offset(cx + houseWidth * 0.6, roofY),
        clearPaintList..strokeWidth = w * 0.025,
      );

    // 3. Draw Door
    final doorWidth = w * 0.18;
    final doorHeight = h * 0.25;
    final doorRect = Rect.fromCenter(
      center: Offset(cx - w * 0.15, baseCy - doorHeight / 2),
      width: doorWidth,
      height: doorHeight,
    );
    final doorRRect = RRect.fromRectAndCorners(
      doorRect,
      topLeft: Radius.circular(w * 0.04),
      topRight: Radius.circular(w * 0.04),
    );
    canvas.drawRRect(doorRRect, clearFill);

    // 4. Draw Window
    final windowWidth = w * 0.2;
    final windowCenterY = baseCy - houseHeight * 0.55;
    final windowRect = Rect.fromCenter(
      center: Offset(cx + w * 0.15, windowCenterY),
      width: windowWidth,
      height: windowWidth,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, Radius.circular(w * 0.03)),
      clearFill,
    );

    // Glowing window pane
    // The window pulses light
    final windowGlowPhase = math.sin(
      animationValue * math.pi * 2 - math.pi / 2,
    ); // -1 to 1
    final glowAlpha = (windowGlowPhase + 1) / 2 * 0.6 + 0.4; // 0.4 to 1.0

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(windowRect, Radius.circular(w * 0.03)),
        Paint()
          ..color = color.withValues(alpha: glowAlpha.clamp(0.0, 1.0))
          ..style = PaintingStyle.fill,
      )
      // Window cross details
      ..drawLine(
        Offset(cx + w * 0.05, windowCenterY),
        Offset(cx + w * 0.25, windowCenterY),
        clearPaintList..strokeWidth = w * 0.015,
      )
      ..drawLine(
        Offset(cx + w * 0.15, windowCenterY - w * 0.1),
        Offset(cx + w * 0.15, windowCenterY + w * 0.1),
        clearPaintList,
      );

    // 5. Draw Chimney
    final chimneyPath = Path()
      ..moveTo(cx + w * 0.15, roofY - h * 0.12)
      ..lineTo(cx + w * 0.15, roofY - h * 0.35)
      ..lineTo(cx + w * 0.25, roofY - h * 0.35)
      ..lineTo(cx + w * 0.25, roofY - h * 0.05)
      ..close();

    // Clear separation where chimney cuts into the roof
    canvas
      ..drawPath(chimneyPath, paintFill)
      ..drawLine(
        Offset(cx + w * 0.15, roofY - h * 0.15),
        Offset(cx + w * 0.25, roofY - h * 0.05),
        clearPaintList..strokeWidth = w * 0.02,
      )
      // Optional: Doorknob
      ..drawCircle(
        Offset(cx - w * 0.09, baseCy - doorHeight * 0.45),
        w * 0.015,
        paintFill,
      )
      ..restore(); // Restore squish scale

    // 6. Smoke rings from chimney
    void drawSmokeRing(double delay) {
      final phase = (animationValue + delay) % 1.0;
      final startY = roofY - h * 0.38;
      final endY = h * 0.02;
      final smokeY = startY - phase * (startY - endY);

      // Drift slightly right
      final smokeX =
          cx +
          w * 0.2 +
          phase * w * 0.15 +
          math.sin(phase * math.pi * 2) * w * 0.05;

      final scale = 0.5 + phase * 1.5; // Starts small, gets bigger

      var opacity = 1.0;
      if (phase < 0.1) {
        opacity = phase / 0.1;
      } else if (phase > 0.6) {
        opacity = 1.0 - (phase - 0.6) / 0.4;
      }

      final smokePaint = Paint()
        ..color = color.withValues(alpha: (opacity * 0.5).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015
        ..strokeCap = StrokeCap.round;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(smokeX, smokeY),
          width: w * 0.08 * scale,
          height: h * 0.04 * scale,
        ),
        smokePaint,
      );
    }

    drawSmokeRing(0);
    drawSmokeRing(0.35);
    drawSmokeRing(0.7);

    // 7. Floating sparkles near the house
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

    drawSparkle(cx - w * 0.35, baseCy - h * 0.15, 0.2);
    drawSparkle(cx - w * 0.40, baseCy - h * 0.45, 0.8);
    drawSparkle(cx + w * 0.38, baseCy - h * 0.25, 0.5);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _DwellingPainter oldDelegate) {
    return true;
  }
}
