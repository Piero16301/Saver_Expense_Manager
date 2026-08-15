import 'dart:math' as math;

import 'package:flutter/material.dart';

class FreelanceAnimatedIcon extends StatefulWidget {
  const FreelanceAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<FreelanceAnimatedIcon> createState() => _FreelanceAnimatedIconState();
}

class _FreelanceAnimatedIconState extends State<FreelanceAnimatedIcon>
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
            painter: _FreelancePainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _FreelancePainter extends CustomPainter {
  _FreelancePainter({required this.color, required this.animationValue});

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

    final baseCy = h * 0.75;

    // Slight laptop bounce
    final bounce = math.sin(animationValue * math.pi * 4) * h * 0.015;

    canvas
      ..save()
      ..translate(0, bounce);

    // 1. Draw Coffee Cup (Right side)
    final cupW = w * 0.15;
    final cupH = h * 0.18;
    final cupX = cx + w * 0.28;
    final cupY =
        baseCy - cupH / 2 + h * 0.02; // slightly lower than laptop bottom

    final cupRect = Rect.fromCenter(
      center: Offset(cupX, cupY),
      width: cupW,
      height: cupH,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndCorners(
          cupRect,
          bottomLeft: Radius.circular(w * 0.04),
          bottomRight: Radius.circular(w * 0.04),
          topLeft: Radius.circular(w * 0.01),
          topRight: Radius.circular(w * 0.01),
        ),
        paintFill,
      )
      // Clear line on top to show opening
      ..drawLine(
        Offset(cupX - cupW * 0.4, cupY - cupH * 0.5 + h * 0.02),
        Offset(cupX + cupW * 0.4, cupY - cupH * 0.5 + h * 0.02),
        clearStroke,
      )
      // Coffee handle (left side of cup)
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cupX + cupW * 0.5, cupY),
          width: cupW * 0.6,
          height: cupH * 0.6,
        ),
        -math.pi / 2,
        math.pi,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.025
          ..strokeCap = StrokeCap.round,
      );

    // Coffee Steam
    void drawSteam(double offset, double phaseOffset) {
      final phase = (animationValue + phaseOffset) % 1.0;
      final steamY = cupY - cupH * 0.5 - phase * h * 0.2;
      // Wiggle
      final steamX = cupX + offset + math.sin(phase * math.pi * 4) * w * 0.02;

      var opacity = 1.0;
      if (phase < 0.2) {
        opacity = phase / 0.2;
      } else if (phase > 0.6) {
        opacity = 1.0 - (phase - 0.6) / 0.4;
      }

      final sPaint = Paint()
        ..color = color.withValues(alpha: (opacity * 0.6).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015
        ..strokeCap = StrokeCap.round;

      final p = Path()
        ..moveTo(steamX, steamY)
        ..quadraticBezierTo(
          steamX + w * 0.02,
          steamY - h * 0.05,
          steamX,
          steamY - h * 0.1,
        );
      canvas.drawPath(p, sPaint);
    }

    drawSteam(-w * 0.03, 0);
    drawSteam(w * 0.02, 0.4);

    // 2. Draw Laptop Base
    final lapBaseW = w * 0.65;
    final lapBaseH = h * 0.06;
    final lapBaseRect = Rect.fromCenter(
      center: Offset(
        cx - w * 0.05,
        baseCy,
      ), // offset slightly left to balance cup
      width: lapBaseW,
      height: lapBaseH,
    );
    final lapBaseRRect = RRect.fromRectAndRadius(
      lapBaseRect,
      Radius.circular(w * 0.02),
    );
    canvas
      ..drawRRect(lapBaseRRect, paintFill)
      // Trackpad clear cutout
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx - w * 0.05, baseCy),
            width: w * 0.15,
            height: lapBaseH * 0.5,
          ),
          Radius.circular(w * 0.01),
        ),
        clearPaint,
      );

    // 3. Draw Laptop Screen
    final screenW = w * 0.55;
    final screenH = h * 0.42;
    // Hinge logic: screen pivots from the top of the base.
    final hingeY = baseCy - lapBaseH * 0.5;

    // Screen open animation
    var screenAngle = 0.0;
    if (animationValue < 0.1) {
      // Opening
      screenAngle = math.pi / 2 * (1.0 - (animationValue / 0.1));
    } else if (animationValue > 0.9) {
      // Closing
      screenAngle = math.pi / 2 * ((animationValue - 0.9) / 0.1);
    }

    final screenCy = hingeY - screenH / 2;

    canvas
      ..save()
      ..translate(cx - w * 0.05, hingeY)
      // We simulate opening by scaling Y.
      // cos(angle) goes from 0 to 1.
      ..scale(1, math.cos(screenAngle).clamp(0.01, 1.0))
      ..translate(-(cx - w * 0.05), -hingeY);

    final screenRect = Rect.fromCenter(
      center: Offset(cx - w * 0.05, screenCy),
      width: screenW,
      height: screenH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, Radius.circular(w * 0.03)),
      paintFill,
    );

    // Inner screen (clear area)
    final innerScreen = Rect.fromCenter(
      center: Offset(cx - w * 0.05, screenCy - h * 0.01),
      width: screenW * 0.85,
      height: screenH * 0.75,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerScreen, Radius.circular(w * 0.02)),
      clearPaint,
    );

    // 4. Code / Content Lines on Screen
    // Only visible when the screen is mostly open.
    if (screenAngle < 0.2) {
      void drawCodeLine(
        double yOffset,
        double widthFactor,
        double speed,
        double phaseOffset,
      ) {
        final phase = (animationValue * speed + phaseOffset) % 1.0;
        final startX = cx - w * 0.05 - innerScreen.width / 2 + w * 0.04;
        final endX =
            startX +
            innerScreen.width *
                widthFactor *
                (0.3 + 0.7 * math.sin(phase * math.pi));

        canvas.drawLine(
          Offset(startX, screenCy + yOffset),
          Offset(endX, screenCy + yOffset),
          Paint()
            ..color = color.withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.02
            ..strokeCap = StrokeCap.round,
        );
      }

      // Draw several lines of typing code
      drawCodeLine(-h * 0.08, 0.7, 3, 0);
      drawCodeLine(-h * 0.03, 0.5, 2, 0.3);
      drawCodeLine(h * 0.02, 0.8, 3.5, 0.7);
      drawCodeLine(h * 0.07, 0.4, 1.5, 0.5);

      // Blinking cursor
      final blink = (animationValue * 15.0).floor().isEven;
      if (blink) {
        final cursorX = cx - w * 0.05 - innerScreen.width / 2 + w * 0.04;
        canvas.drawRect(
          Rect.fromLTWH(cursorX, screenCy + h * 0.1, w * 0.02, h * 0.03),
          Paint()..color = color,
        );
      }
    }

    canvas
      ..restore() // restore screen angle scale
      ..restore(); // restore global bounce

    // 5. Floating Sparkles
    void drawSparkle(double x, double y, double delay) {
      final phase = (animationValue + delay) % 1.0;
      final scale = math.sin(phase * math.pi); // 0 -> 1 -> 0
      final sLength = w * 0.035 * scale;

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

    drawSparkle(cx - w * 0.4, h * 0.35, 0.1);
    drawSparkle(cx + w * 0.1, h * 0.15, 0.6);
    drawSparkle(cx - w * 0.3, h * 0.65, 0.8);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _FreelancePainter oldDelegate) {
    return true;
  }
}
