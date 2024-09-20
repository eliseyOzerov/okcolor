import 'dart:ui';

import 'package:okcolor/converters/rgb_okhsv.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/utils/hue_util.dart';

enum Hue {
  red,
  orange,
  yellow,
  lime,
  green,
  teal,
  cyan,
  sky,
  blue,
  purple,
  magenta,
  pink,
}

/// Represents a color in the HSV (Hue, Saturation, Value) color space.
/// h: Hue, in range [0, 1] representing 0 to 360 degrees
/// s: Saturation, in range [0, 1]
/// v: Value, in range [0, 1]
/// Example usage:
///   HSV hsv = srgbToOkhsv(RGB(0.5, 0.5, 0.5));
///   // Saturation and Value are used in calculations:
///   double L_v = 1 - hsv.s * S_0 / (S_0 + T_max - T_max * k * hsv.s);
///   double L = hsv.v * L_v;
class OkHsv {
  final double h;
  final double s;
  final double v;
  final double alpha;

  const OkHsv(this.h, this.s, this.v, {this.alpha = 1});

  // ------ Constructors ------ //

  factory OkHsv.fromHue(Hue hue, List<OkHsv> colors) {
    double highestDistance = double.infinity;
    late OkHsv result;
    int hueVal = hues[hue]!;
    if (hue == Hue.pink) {
      hueVal = 360;
    }
    for (final color in colors) {
      final distance = (color.h - hueVal).abs();
      if (distance < highestDistance) {
        highestDistance = distance;
        result = color;
      }
    }
    return result;
  }

  factory OkHsv.fromColor(Color color) {
    return rgbToOkHsv(color.toRgb());
  }

  OkHsv withHue(double hue) {
    return copyWith(h: hue);
  }

  OkHsv withSaturation(double saturation) {
    return copyWith(s: saturation);
  }

  OkHsv withValue(double value) {
    return copyWith(v: value);
  }

  OkHsv withAlpha(double alpha) {
    return copyWith(alpha: alpha);
  }

  OkHsv copyWith({double? h, double? s, double? v, double? alpha}) {
    return OkHsv(h ?? this.h, s ?? this.s, v ?? this.v, alpha: alpha ?? this.alpha);
  }

  // ------ Getters ------ //

  static const Map<Hue, int> hues = {
    Hue.pink: 0,
    Hue.red: 30,
    Hue.orange: 60,
    Hue.yellow: 90,
    Hue.lime: 120,
    Hue.green: 140,
    Hue.teal: 160,
    Hue.cyan: 190,
    Hue.sky: 230,
    Hue.blue: 270,
    Hue.purple: 300,
    Hue.magenta: 330,
  };

  Hue get hue {
    double highestDistance = double.infinity;
    late Hue result;
    for (final hue in hues.entries) {
      final distance = (h - hue.value).abs();
      if (distance < highestDistance) {
        highestDistance = distance;
        result = hue.key;
      }
    }
    return result;
  }

  List<OkHsv> hueCircle([int count = 12]) {
    final double step = 1 / count;
    return List.generate(count, (index) => addHue(step * index * 360));
  }

  // ------ Conversions ------ //

  Color toColor() {
    return okhsvToSrgb(this).toColor();
  }

  // ------ Interpolation ------ //

  static OkHsv lerp(OkHsv start, OkHsv end, double fraction, {bool shortestPath = true}) {
    return OkHsv(
      interpolateHue(start.h, end.h, fraction, shortestPath: shortestPath, normalizeHue: false),
      lerpDouble(start.s, end.s, fraction) ?? 0,
      lerpDouble(start.v, end.v, fraction) ?? 0,
      alpha: lerpDouble(start.alpha, end.alpha, fraction) ?? 0,
    );
  }

  // ------ Modifiers ------ //

  OkHsv darker(double percentage) {
    return withValue(v * (1 - percentage));
  }

  OkHsv lighter(double percentage) {
    return withValue(v * (1 + percentage));
  }

  OkHsv duller(double percentage) {
    return withSaturation(s * (1 - percentage));
  }

  OkHsv richer(double percentage) {
    return withSaturation(s * (1 + percentage));
  }

  OkHsv addHuePercentage(double percentage) {
    return withHue((h + percentage) % 1);
  }

  OkHsv addHue(double angle) {
    return withHue((h + angle / 360) % 1);
  }

  OkHsv withHueAngle(double angle) {
    return withHue((angle / 360) % 1);
  }
}
