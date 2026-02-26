import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class TechnologyAnimatedIcon extends StatefulWidget {
  const TechnologyAnimatedIcon({
    required this.color,
    super.key,
    this.size = 60.0,
  });

  final Color color;
  final double size;

  @override
  State<TechnologyAnimatedIcon> createState() => _TechnologyAnimatedIconState();
}

class _TechnologyAnimatedIconState extends State<TechnologyAnimatedIcon>
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
            painter: _TechnologyPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _TechnologyPainter extends CustomPainter {
  _TechnologyPainter({required this.color, required this.animationValue});

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

    // Background pulsing glow (behind CPU)
    final pulseScale = 1.0 + math.sin(animationValue * math.pi * 2) * 0.15;
    final glowOpacity =
        (0.5 + math.sin(animationValue * math.pi * 2) * 0.3).clamp(0.0, 1.0);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowOpacity * 0.4)
      ..style = PaintingStyle.fill;

    canvas
      ..save()
      ..translate(cx, cy)
      ..scale(pulseScale)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w * 0.6, height: h * 0.6),
          Radius.circular(w * 0.1),
        ),
        glowPaint,
      )
      ..restore();

    // The Circuit Lines (drawn outwards)
    void drawCircuitLine({
      required double startX,
      required double startY,
      required double endX,
      required double endY,
      required double startTick,
    }) {
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Calculate localized animation phase for this line.
      // Lines slowly light up.
      var t = (animationValue - startTick) * 3.0; // speed up line completion
      t = t.clamp(0.0, 1.0);

      // Determine color based on time
      final lineColorOpacity = (0.3 + t * 0.7).clamp(0.0, 1.0);
      linePaint.color = color.withValues(alpha: lineColorOpacity);

      // Only draw the percentage of the line dictated by t
      final dx = endX - startX;
      final dy = endY - startY;

      final p = Path()
        ..moveTo(startX, startY)
        ..lineTo(startX + dx * t, startY + dy * t);
      canvas.drawPath(p, linePaint);
    }

    // Circuit layout: 4 legs on each side (total 16 lines around center).
    // Let's draw traces flowing outwards starting from the box edges.
    final boxSize = w * 0.45;
    final bHalf = boxSize / 2.0;

    // Top Lines
    drawCircuitLine(
      startX: cx - bHalf * 0.6,
      startY: cy - bHalf,
      endX: cx - bHalf * 0.6,
      endY: cy - bHalf - h * 0.15,
      startTick: 0.1,
    );
    drawCircuitLine(
      startX: cx - bHalf * 0.2,
      startY: cy - bHalf,
      endX: cx - bHalf * 0.2,
      endY: cy - bHalf - h * 0.2,
      startTick: 0.3,
    );
    drawCircuitLine(
      startX: cx + bHalf * 0.2,
      startY: cy - bHalf,
      endX: cx + bHalf * 0.2,
      endY: cy - bHalf - h * 0.15,
      startTick: 0.5,
    );
    drawCircuitLine(
      startX: cx + bHalf * 0.6,
      startY: cy - bHalf,
      endX: cx + bHalf * 0.6,
      endY: cy - bHalf - h * 0.1,
      startTick: 0.2,
    );

    // Bottom Lines
    drawCircuitLine(
      startX: cx - bHalf * 0.6,
      startY: cy + bHalf,
      endX: cx - bHalf * 0.6,
      endY: cy + bHalf + h * 0.15,
      startTick: 0.6,
    );
    drawCircuitLine(
      startX: cx - bHalf * 0.2,
      startY: cy + bHalf,
      endX: cx - bHalf * 0.2,
      endY: cy + bHalf + h * 0.1,
      startTick: 0.4,
    );
    drawCircuitLine(
      startX: cx + bHalf * 0.2,
      startY: cy + bHalf,
      endX: cx + bHalf * 0.2,
      endY: cy + bHalf + h * 0.15,
      startTick: 0.7,
    );
    drawCircuitLine(
      startX: cx + bHalf * 0.6,
      startY: cy + bHalf,
      endX: cx + bHalf * 0.6,
      endY: cy + bHalf + h * 0.1,
      startTick: 0.3,
    );

    // Left Lines
    drawCircuitLine(
      startX: cx - bHalf,
      startY: cy - bHalf * 0.6,
      endX: cx - bHalf - w * 0.15,
      endY: cy - bHalf * 0.6,
      startTick: 0.2,
    );
    drawCircuitLine(
      startX: cx - bHalf,
      startY: cy - bHalf * 0.2,
      endX: cx - bHalf - w * 0.1,
      endY: cy - bHalf * 0.2,
      startTick: 0.5,
    );
    drawCircuitLine(
      startX: cx - bHalf,
      startY: cy + bHalf * 0.2,
      endX: cx - bHalf - w * 0.15,
      endY: cy + bHalf * 0.2,
      startTick: 0.3,
    );
    drawCircuitLine(
      startX: cx - bHalf,
      startY: cy + bHalf * 0.6,
      endX: cx - bHalf - w * 0.1,
      endY: cy + bHalf * 0.6,
      startTick: 0.6,
    );

    // Right Lines
    drawCircuitLine(
      startX: cx + bHalf,
      startY: cy - bHalf * 0.6,
      endX: cx + bHalf + w * 0.1,
      endY: cy - bHalf * 0.6,
      startTick: 0.4,
    );
    drawCircuitLine(
      startX: cx + bHalf,
      startY: cy - bHalf * 0.2,
      endX: cx + bHalf + w * 0.15,
      endY: cy - bHalf * 0.2,
      startTick: 0.1,
    );
    drawCircuitLine(
      startX: cx + bHalf,
      startY: cy + bHalf * 0.2,
      endX: cx + bHalf + w * 0.1,
      endY: cy + bHalf * 0.2,
      startTick: 0.7,
    );
    drawCircuitLine(
      startX: cx + bHalf,
      startY: cy + bHalf * 0.6,
      endX: cx + bHalf + w * 0.15,
      endY: cy + bHalf * 0.6,
      startTick: 0.2,
    );

    // Central CPU block
    final cpuRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: boxSize,
      height: boxSize,
    );
    final cpuPath = Path()
      ..addRRect(RRect.fromRectAndRadius(cpuRect, Radius.circular(w * 0.08)));

    canvas.drawPath(cpuPath, paintFill);

    // Inner details (clear/transparent cutouts)
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round;

    // Draw inner square
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: boxSize * 0.5,
            height: boxSize * 0.5,
          ),
          Radius.circular(w * 0.03),
        ),
        clearPaint,
      )

      // Diagonal corner cuts inside CPU
      ..drawLine(
        Offset(cx - boxSize * 0.25, cy - boxSize * 0.25),
        Offset(cx - boxSize * 0.4, cy - boxSize * 0.4),
        clearPaint,
      )
      ..drawLine(
        Offset(cx + boxSize * 0.25, cy - boxSize * 0.25),
        Offset(cx + boxSize * 0.4, cy - boxSize * 0.4),
        clearPaint,
      )
      ..drawLine(
        Offset(cx - boxSize * 0.25, cy + boxSize * 0.25),
        Offset(cx - boxSize * 0.4, cy + boxSize * 0.4),
        clearPaint,
      )
      ..drawLine(
        Offset(cx + boxSize * 0.25, cy + boxSize * 0.25),
        Offset(cx + boxSize * 0.4, cy + boxSize * 0.4),
        clearPaint,
      );

    // Center active node (fades in and out with power)
    final centerPowerOpacity =
        (0.2 + math.sin(animationValue * math.pi * 2 + math.pi / 2) * 0.8)
            .clamp(0.0, 1.0);
    // Erase center
    canvas
      ..drawCircle(
        Offset(cx, cy),
        w * 0.06,
        Paint()..blendMode = BlendMode.clear,
      )
      // Draw fading core
      ..drawCircle(
        Offset(cx, cy),
        w * 0.04,
        Paint()..color = color.withValues(alpha: centerPowerOpacity),
      )
      ..restore(); // End global saveLayer
  }

  @override
  bool shouldRepaint(covariant _TechnologyPainter oldDelegate) {
    return true;
  }
}
