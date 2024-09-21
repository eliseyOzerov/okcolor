import 'dart:ui';

import 'package:okcolor/converters/rgb_okhsv.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/utils/lerp.dart' as lp;

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
    return withValue(lp.lerp(v, 0, percentage));
  }

  OkHsv lighter(double percentage) {
    return withValue(lp.lerp(v, 1, percentage));
  }

  OkHsv saturate(double percentage) {
    return withSaturation(lp.lerp(s, 1, percentage));
  }

  OkHsv desaturate(double percentage) {
    return withSaturation(lp.lerp(s, 0, percentage));
  }

  OkHsv rotated(double degrees) {
    return withHue((h + degrees / 360) % 1);
  }

  // ------ Conversions ------ //

  Color toColor() {
    return okhsvToSrgb(this).toColor();
  }

  // ------ Interpolation ------ //

  static OkHsv lerp(OkHsv start, OkHsv end, double fraction, {bool shortestPath = true}) {
    return OkHsv(
      lp.lerpAngle(start.h, end.h, fraction, shortestPath: shortestPath),
      lerpDouble(start.s, end.s, fraction) ?? 0,
      lerpDouble(start.v, end.v, fraction) ?? 0,
    );
  }

  // ------ Harmonies ------ //

  OkHsv complementary() {
    return rotated(180);
  }

  List<OkHsv> splitComplementary() {
    return [rotated(150), this, rotated(210)];
  }

  List<OkHsv> triadic() {
    return [rotated(120), this, rotated(240)];
  }

  List<OkHsv> tetradic() {
    return [this, complementary(), rotated(90), rotated(270)];
  }

  List<OkHsv> analogous({int count = 2, double angle = 30}) {
    List<OkHsv> colors = [this];
    for (int i = 1; i <= count; i++) {
      colors.insert(0, rotated(angle * i));
    }
    for (int i = 1; i <= count; i++) {
      colors.add(rotated(-angle * i));
    }
    return colors;
  }

  List<OkHsv> shades({int count = 5}) {
    return List.generate(count, (index) {
      double t = index / (count - 1);
      return darker(t);
    });
  }

  List<OkHsv> tints({int count = 5}) {
    return List.generate(count, (index) {
      double t = index / (count - 1);
      return lighter(t);
    });
  }
}
