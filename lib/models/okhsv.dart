import 'dart:ui';

import 'package:okcolor/converters/rgb_okhsv.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/utils/lerp.dart';

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

  OkHsv(this.h, this.s, this.v);

  // ------ Constructors ------ //

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

  OkHsv copyWith({double? h, double? s, double? v, double? alpha}) {
    return OkHsv(h ?? this.h, s ?? this.s, v ?? this.v);
  }

  OkHsv darker(double percentage) {
    return withValue(v * (1 - percentage));
  }

  OkHsv lighter(double percentage) {
    return withValue(v * (1 + percentage));
  }

  // ------ Conversions ------ //

  Color toColor() {
    return okhsvToSrgb(this).toColor();
  }

  // ------ Interpolation ------ //

  static OkHsv lerp(OkHsv start, OkHsv end, double fraction, {bool shortestPath = true}) {
    return OkHsv(
      lerpAngle(start.h, end.h, fraction, shortestPath: shortestPath),
      lerpDouble(start.s, end.s, fraction) ?? 0,
      lerpDouble(start.v, end.v, fraction) ?? 0,
    );
  }
}
