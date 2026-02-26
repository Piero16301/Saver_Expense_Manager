import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class SalaryAnimatedIcon extends StatefulWidget {
  const SalaryAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<SalaryAnimatedIcon> createState() => _SalaryAnimatedIconState();
}

class _SalaryAnimatedIconState extends State<SalaryAnimatedIcon>
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
            painter: _SalaryPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _SalaryPainter extends CustomPainter {
  _SalaryPainter({required this.color, required this.animationValue});

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

    final clearStroke = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final envCy = h * 0.7; // envelope base Y
    final envW = w * 0.65;
    final envH = h * 0.4;

    // 1. Bill (Cash) sliding up
    var billYOffset = 0.0;
    if (animationValue > 0.1 && animationValue <= 0.4) {
      final t = (animationValue - 0.1) / 0.3;
      // ease out back
      final ease = math.sin(t * math.pi / 2);
      billYOffset = -h * 0.35 * ease;
    } else if (animationValue > 0.4 && animationValue <= 0.7) {
      // floating slightly
      final floatT = (animationValue - 0.4) / 0.3;
      billYOffset = -h * 0.35 + math.sin(floatT * math.pi * 2) * h * 0.02;
    } else if (animationValue > 0.7 && animationValue <= 0.9) {
      // slide back down
      final t = (animationValue - 0.7) / 0.2;
      final ease = 1.0 - math.sin(t * math.pi / 2);
      billYOffset = -h * 0.35 * ease;
    } else {
      billYOffset = 0.0;
    }

    final billW = envW * 0.85;
    final billH = envH * 0.8;
    final billX = cx - billW / 2;
    final billY = envCy - envH / 2 + billYOffset;

    final billRect = Rect.fromLTWH(billX, billY + h * 0.05, billW, billH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(billRect, Radius.circular(w * 0.02)),
      paintFill,
    );

    // Bill inner details
    final billInner = Rect.fromLTWH(
      billX + w * 0.04,
      billY + h * 0.05 + h * 0.04,
      billW - w * 0.08,
      billH - h * 0.08,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(billInner, Radius.circular(w * 0.02)),
        clearStroke,
      )
      // Bill center logo (circle)
      ..drawCircle(
        Offset(cx, billY + h * 0.05 + billH / 2),
        w * 0.06,
        clearStroke,
      );

    // 2. Envelope back flap (inside)
    // To give depth, we just let the envelope body cover the bottom part of the
    // bill
    // We already drew the bill, now we draw the front of the envelope on top of
    // it.

    // Envelope Body
    final envLeft = cx - envW / 2;
    final envTop = envCy - envH / 2;
    final envRect = Rect.fromLTWH(envLeft, envTop, envW, envH);

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(envRect, Radius.circular(w * 0.03)),
        paintFill,
      )

      // Envelope flaps (clear lines)
      // Left flap
      ..drawLine(
        Offset(envLeft, envTop),
        Offset(cx, envTop + envH * 0.5),
        clearStroke,
      )
      // Right flap
      ..drawLine(
        Offset(envLeft + envW, envTop),
        Offset(cx, envTop + envH * 0.5),
        clearStroke,
      )
      // Bottom flap (overlapping up)
      ..drawLine(
        Offset(envLeft + w * 0.02, envTop + envH),
        Offset(cx, envTop + envH * 0.5 + h * 0.02),
        clearStroke,
      )
      ..drawLine(
        Offset(envLeft + envW - w * 0.02, envTop + envH),
        Offset(cx, envTop + envH * 0.5 + h * 0.02),
        clearStroke,
      )
      // Top flap fold line (dashed or solid clear line across top opening)
      ..drawLine(
        Offset(envLeft + w * 0.02, envTop),
        Offset(envLeft + envW - w * 0.02, envTop),
        clearStroke..strokeWidth = w * 0.03,
      );

    // 3. Popping Coins (Sparkles to simulate coins flipping)
    void drawCoin(double x, double delay, double heightBoost) {
      final phase = (animationValue + delay) % 1.0;
      if (phase < 0.1 || phase > 0.8) return;

      final t = (phase - 0.1) / 0.7; // 0.0 to 1.0
      // Parabolic arc for coin
      final oy = envTop + h * 0.1;
      final y = oy - math.sin(t * math.pi) * (h * 0.3 + heightBoost);
      // X drift slightly outwards
      final dir = x > cx ? 1.0 : -1.0;
      final px = x + dir * t * w * 0.1;

      // Flip scale
      final scaleX = math.cos(t * math.pi * 6); // spins multiple times

      final opacity = 1.0 - math.max(0.0, (t - 0.7) / 0.3);

      final cPaint = Paint()
        ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas
        ..save()
        ..translate(px, y)
        ..scale(scaleX, 1)
        ..drawCircle(Offset.zero, w * 0.05, cPaint)
        ..drawCircle(
          Offset.zero,
          w * 0.025,
          Paint()..blendMode = BlendMode.clear,
        )
        ..restore();
    }

    if (animationValue > 0.2) {
      drawCoin(
        cx - w * 0.15,
        -0.2,
        h * 0.05,
      ); // Left coin pops slightly earlier due to delay offset trick
      drawCoin(cx + w * 0.15, -0.3, h * 0.0); // Right coin
      drawCoin(cx, -0.4, h * 0.1); // Center coin
    }

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

    drawSparkle(cx - w * 0.4, envTop + h * 0.1, 0);
    drawSparkle(cx + w * 0.35, envTop - h * 0.05, 0.5);
    drawSparkle(cx - w * 0.2, envTop - h * 0.2, 0.7);

    canvas.restore(); // end global saveLayer
  }

  @override
  bool shouldRepaint(covariant _SalaryPainter oldDelegate) {
    return true;
  }
}
