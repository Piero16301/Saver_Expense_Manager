import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class HealthAnimatedIcon extends StatefulWidget {
  const HealthAnimatedIcon({required this.color, super.key, this.size = 60.0});

  final Color color;
  final double size;

  @override
  State<HealthAnimatedIcon> createState() => _HealthAnimatedIconState();
}

class _HealthAnimatedIconState extends State<HealthAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
          return Transform.scale(
            scale: 0.8,
            child: CustomPaint(
              painter: _HealthPainter(
                color: widget.color,
                animationValue: _controller.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HealthPainter extends CustomPainter {
  _HealthPainter({required this.color, required this.animationValue});

  final Color color;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final w = size.width;
    final h = size.height;

    // Heartbeat scale
    var scale = 1.0;
    if (animationValue < 0.1) {
      scale = 1.0 + (animationValue / 0.1) * 0.15;
    } else if (animationValue < 0.2) {
      scale = 1.15 - ((animationValue - 0.1) / 0.1) * 0.15;
    } else if (animationValue < 0.3) {
      scale = 1.0 + ((animationValue - 0.2) / 0.1) * 0.15;
    } else if (animationValue < 0.4) {
      scale = 1.15 - ((animationValue - 0.3) / 0.1) * 0.15;
    }

    final cx = w / 2;
    final cy = h * 0.55;

    canvas
      ..save()
      ..translate(cx, cy)
      ..scale(scale)
      ..translate(-cx, -cy);

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Heart Path
    final heartPath = Path()
      ..moveTo(cx, cy - h * 0.15)
      ..cubicTo(
        cx - w * 0.5,
        cy - h * 0.5,
        cx - w * 0.6,
        cy + h * 0.1,
        cx,
        cy + h * 0.4,
      )
      ..cubicTo(
        cx + w * 0.6,
        cy + h * 0.1,
        cx + w * 0.5,
        cy - h * 0.5,
        cx,
        cy - h * 0.15,
      );

    canvas.drawPath(heartPath, paintFill);

    // Medical Cross Cutout (Clear)
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    final crossSize = w * 0.3;
    final crossCy = cy - h * 0.05; // slightly higher
    final cWidth = crossSize * 0.3; // width of the arm
    final cLength = crossSize; // total length

    final crossPath = Path()
      ..moveTo(cx - cWidth / 2, crossCy - cLength / 2)
      ..lineTo(cx + cWidth / 2, crossCy - cLength / 2)
      ..lineTo(cx + cWidth / 2, crossCy - cWidth / 2)
      ..lineTo(cx + cLength / 2, crossCy - cWidth / 2)
      ..lineTo(cx + cLength / 2, crossCy + cWidth / 2)
      ..lineTo(cx + cWidth / 2, crossCy + cWidth / 2)
      ..lineTo(cx + cWidth / 2, crossCy + cLength / 2)
      ..lineTo(cx - cWidth / 2, crossCy + cLength / 2)
      ..lineTo(cx - cWidth / 2, crossCy + cWidth / 2)
      ..lineTo(cx - cLength / 2, crossCy + cWidth / 2)
      ..lineTo(cx - cLength / 2, crossCy - cWidth / 2)
      ..lineTo(cx - cWidth / 2, crossCy - cWidth / 2)
      ..close();

    canvas
      ..drawPath(crossPath, clearPaint)
      ..restore();

    // Floating particles (mini pluses)
    void drawParticle(double offsetX, double phaseOffset, double pScale) {
      final phase = (animationValue + phaseOffset) % 1.0;
      final y = h * 0.9 - phase * (h * 0.8);
      // sway
      final x = offsetX + math.sin(phase * math.pi * 4) * (w * 0.08);

      var opacity = 1.0;
      if (phase < 0.1) {
        opacity = phase / 0.1;
      } else if (phase > 0.6) {
        opacity = math.max(0, 1.0 - ((phase - 0.6) / 0.4));
      }

      final pColor = color.withValues(alpha: opacity.clamp(0.0, 1.0));
      final pPaint = Paint()
        ..color = pColor
        ..style = PaintingStyle.fill;

      // Draw a mini cross
      final cpWidth = w * 0.04 * pScale;
      final cpLength = w * 0.12 * pScale;

      final pPath = Path()
        ..moveTo(x - cpWidth / 2, y - cpLength / 2)
        ..lineTo(x + cpWidth / 2, y - cpLength / 2)
        ..lineTo(x + cpWidth / 2, y - cpWidth / 2)
        ..lineTo(x + cpLength / 2, y - cpWidth / 2)
        ..lineTo(x + cpLength / 2, y + cpWidth / 2)
        ..lineTo(x + cpWidth / 2, y + cpWidth / 2)
        ..lineTo(x + cpWidth / 2, y + cpLength / 2)
        ..lineTo(x - cpWidth / 2, y + cpLength / 2)
        ..lineTo(x - cpWidth / 2, y + cpWidth / 2)
        ..lineTo(x - cpLength / 2, y + cpWidth / 2)
        ..lineTo(x - cpLength / 2, y - cpWidth / 2)
        ..lineTo(x - cpWidth / 2, y - cpWidth / 2)
        ..close();

      canvas.drawPath(pPath, pPaint);
    }

    drawParticle(w * 0.2, 0, 1);
    drawParticle(w * 0.8, 0.5, 0.8);
    drawParticle(w * 0.3, 0.8, 0.6);

    canvas.restore(); // End saveLayer
  }

  @override
  bool shouldRepaint(covariant _HealthPainter oldDelegate) {
    return true;
  }
}
