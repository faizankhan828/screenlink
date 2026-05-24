import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Renders the official four-colour Google "G" logo using a [CustomPainter].
/// No external assets or packages required.
class GoogleLogoIcon extends StatelessWidget {
  const GoogleLogoIcon({super.key, this.size = 20.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue   = Color(0xFF4285F4);
  static const _red    = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green  = Color(0xFF34A853);

  static double _rad(double deg) => deg * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final outerRect = Rect.fromCircle(center: c, radius: r);
    final paint = Paint()..style = PaintingStyle.fill;

    // ── Four coloured pie slices (total = 360°) ───────────────────────────────
    // Blue: from -30° → 90° (120°)
    // Red:  from  90° → 210° (120°)
    // Yellow: 210° → 300° (90°)
    // Green:  300° → 330° (30°)
    final slices = <(Color, double, double)>[
      (_blue,   -30.0, 120.0),
      (_red,     90.0, 120.0),
      (_yellow, 210.0,  90.0),
      (_green,  300.0,  30.0),
    ];
    for (final (color, start, sweep) in slices) {
      paint.color = color;
      canvas.drawArc(outerRect, _rad(start), _rad(sweep), true, paint);
    }

    // ── White inner circle (donut hole) ───────────────────────────────────────
    paint.color = Colors.white;
    canvas.drawCircle(c, r * 0.58, paint);

    // ── Blue right arm of the G ───────────────────────────────────────────────
    paint.color = _blue;
    canvas.drawRect(
      Rect.fromLTRB(c.dx, c.dy - r * 0.23, c.dx + r, c.dy + r * 0.23),
      paint,
    );

    // ── White notch above the bar (the G's opening) ───────────────────────────
    paint.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTRB(c.dx, c.dy - r, c.dx + r, c.dy - r * 0.23),
      paint,
    );

    // ── Re-draw inner white circle to restore clean donut edge ────────────────
    canvas.drawCircle(c, r * 0.58, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
