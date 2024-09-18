import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';

class HSVColorWheel extends StatelessWidget {
  final double size;
  final void Function(HSVColor)? onColorSelected;

  final List<Color> gradientColors;

  const HSVColorWheel({
    super.key,
    this.size = 300,
    this.onColorSelected,
    this.gradientColors = const [Colors.white, Colors.black],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        _handleColorSelection(details.localPosition);
      },
      onTapDown: (details) {
        _handleColorSelection(details.localPosition);
      },
      child: CustomPaint(
        size: Size(size, size),
        painter: _HSVColorWheelPainter(
          gradientColors: gradientColors,
        ),
      ),
    );
  }

  void _handleColorSelection(Offset position) {
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;
    final relativeOffset = position - center;

    if (relativeOffset.distance <= radius) {
      final angle = (relativeOffset.direction + math.pi) % (2 * math.pi);
      final distance = relativeOffset.distance / radius;

      final hue = angle / (2 * math.pi);
      final saturation = distance;

      final color = HSVColor.fromAHSV(1.0, hue * 360, saturation, 1.0);
      onColorSelected?.call(color);
    }
  }
}

class _HSVColorWheelPainter extends CustomPainter {
  final List<Color> gradientColors;

  _HSVColorWheelPainter({
    this.gradientColors = const [Colors.white, Colors.black],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final hueShader = SweepGradient(
      colors: List.generate(360, (index) {
        return HSVColor.fromAHSV(1.0, index.toDouble(), 1.0, 1.0).toColor();
      }),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final huePaint = Paint()
      ..shader = hueShader
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, huePaint);

    final lightnessShader = RadialGradient(
      colors: [Colors.white, Colors.white.withOpacity(0)],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final lightnessPaint = Paint()
      ..shader = lightnessShader
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, lightnessPaint);

    for (final grColor in gradientColors) {
      final hsv = HSVColor.fromColor(grColor);
      final saturation = hsv.saturation;
      final hue = hsv.hue;
      final color = hsv.toColor();
      final fill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final background = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final stroke = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final dotCenter = PolarOffset.fromPolar(saturation * radius, hue * pi / 180).translate(center.dx, center.dy);
      canvas.drawCircle(dotCenter, 12, background);
      canvas.drawCircle(dotCenter, 8, fill);
      canvas.drawCircle(dotCenter, 12, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension PolarOffset on Offset {
  /// Returns the polar coordinates (radius, theta) of this offset.
  ///
  /// - radius: The distance from the origin (0,0) to this point.
  /// - theta: The angle in radians from the positive x-axis to the line from the origin to this point.
  ///   The angle is normalized to be in the range [0, 2π).
  (double radius, double theta) toPolar() {
    final radius = distance;
    var theta = math.atan2(dy, dx);

    // Normalize theta to be in the range [0, 2π)
    if (theta < 0) {
      theta += 2 * math.pi;
    }

    return (radius, theta);
  }

  /// Creates an Offset from polar coordinates.
  ///
  /// - radius: The distance from the origin.
  /// - theta: The angle in radians from the positive x-axis.
  static Offset fromPolar(double radius, double theta) {
    return Offset(radius * math.cos(theta), radius * math.sin(theta));
  }
}
