import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class TripsAnimatedIcon extends StatefulWidget {
  const TripsAnimatedIcon({required this.color, super.key, this.size = 60.0});

  final Color color;
  final double size;

  @override
  State<TripsAnimatedIcon> createState() => _TripsAnimatedIconState();
}

class _TripsAnimatedIconState extends State<TripsAnimatedIcon>
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
            painter: _TripsPainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _TripsPainter extends CustomPainter {
  _TripsPainter({required this.color, required this.animationValue});

  final Color color;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final w = size.width;
    final h = size.height;
    final cx = w / 2.0;
    final cy = h / 2.0 + h * 0.05;

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Tilted orbit configuration
    const tilt = -math.pi / 12.0;
    final rx = w * 0.42;
    final ry = h * 0.15;

    Offset getOrbitPosition(double t) {
      final x = rx * math.cos(t);
      final y = ry * math.sin(t);
      final rotatedX = x * math.cos(tilt) - y * math.sin(tilt);
      final rotatedY = x * math.sin(tilt) + y * math.cos(tilt);
      return Offset(cx + rotatedX, cy + rotatedY);
    }

    final tOrbit = -animationValue * math.pi * 2.0;
    final planeInFront = math.sin(tOrbit) >= 0.0;
    final planePos = getOrbitPosition(tOrbit);
    final nextPos = getOrbitPosition(tOrbit - 0.01);
    final planeAngle = math.atan2(
      nextPos.dy - planePos.dy,
      nextPos.dx - planePos.dx,
    );

    void drawTrail({required bool isFront, required bool clearMode}) {
      for (var i = 0; i < 20; i++) {
        final t1 = tOrbit + i * 0.03;
        final t2 = t1 + 0.03;
        final t1Front = math.sin(t1) >= 0.0;
        final t2Front = math.sin(t2) >= 0.0;

        if (t1Front == isFront && t2Front == isFront) {
          final p1 = getOrbitPosition(t1);
          final p2 = getOrbitPosition(t2);

          if (clearMode && isFront) {
            final clearTrailPaint = Paint()
              ..blendMode = BlendMode.clear
              ..style = PaintingStyle.stroke
              ..strokeWidth =
                  w *
                  0.035 // Thicker for a nice gap
              ..strokeCap = StrokeCap.round;
            canvas.drawLine(p1, p2, clearTrailPaint);
          } else if (!clearMode) {
            final opacity = (1.0 - (i / 20.0)) * 0.6;
            final tracePaint = Paint()
              ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.015
              ..strokeCap = StrokeCap.round;
            canvas.drawLine(p1, p2, tracePaint);
          }
        }
      }
    }

    void drawAirplane({
      required Offset pos,
      required double angle,
      required bool isFront,
      required bool clearMode,
    }) {
      canvas
        ..save()
        ..translate(pos.dx, pos.dy)
        ..rotate(angle);

      final jetPath = Path()
        ..moveTo(w * 0.08, 0)
        ..lineTo(-w * 0.02, w * 0.04)
        ..lineTo(-w * 0.01, w * 0.01)
        ..lineTo(-w * 0.06, w * 0.025)
        ..lineTo(-w * 0.05, 0)
        ..lineTo(-w * 0.06, -w * 0.025)
        ..lineTo(-w * 0.01, -w * 0.01)
        ..lineTo(-w * 0.02, -w * 0.04)
        ..close();

      if (clearMode && isFront) {
        final clearOutline = Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = w * 0.025;
        canvas.drawPath(jetPath, clearOutline);
      } else if (!clearMode) {
        canvas.drawPath(jetPath, paintFill);
      }

      canvas.restore();
    }

    // 1. Draw BACK elements
    drawTrail(isFront: false, clearMode: false);
    if (!planeInFront) {
      drawAirplane(
        pos: planePos,
        angle: planeAngle,
        isFront: false,
        clearMode: false,
      );
    }

    // 2. Draw Globe Layer
    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());

    final globeRadius = w * 0.28;
    canvas.drawCircle(Offset(cx, cy), globeRadius, paintFill);

    final globeClear = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015;

    canvas
      ..save()
      ..clipRect(Rect.fromCircle(center: Offset(cx, cy), radius: globeRadius))
      ..drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy - globeRadius * 0.35),
          width: globeRadius * 2.0,
          height: globeRadius * 0.4,
        ),
        globeClear,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + globeRadius * 0.35),
          width: globeRadius * 2.0,
          height: globeRadius * 0.4,
        ),
        globeClear,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: globeRadius * 0.6,
          height: globeRadius * 2.0,
        ),
        globeClear,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: globeRadius * 1.4,
          height: globeRadius * 2.0,
        ),
        globeClear,
      )
      ..drawLine(
        Offset(cx - globeRadius, cy),
        Offset(cx + globeRadius, cy),
        globeClear,
      )
      ..restore() // end globe clip
      ..restore(); // composite globe layer onto main layer

    // 3. Draw FRONT elements
    // Pass 1: Clear outlines
    drawTrail(isFront: true, clearMode: true);
    if (planeInFront) {
      drawAirplane(
        pos: planePos,
        angle: planeAngle,
        isFront: true,
        clearMode: true,
      );
    }

    // Pass 2: Solid
    drawTrail(isFront: true, clearMode: false);
    if (planeInFront) {
      drawAirplane(
        pos: planePos,
        angle: planeAngle,
        isFront: true,
        clearMode: false,
      );
    }

    canvas.restore(); // End main saveLayer
  }

  @override
  bool shouldRepaint(covariant _TripsPainter oldDelegate) {
    return true;
  }
}
