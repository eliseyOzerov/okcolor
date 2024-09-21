import 'dart:ui';

import 'package:okcolor/converters/rgb_okhsl.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/utils/lerp.dart' as lp;

/// Represents a color in the HSL (Hue, Saturation, Lightness) color space.
/// h: Hue, in range [0, 1] representing 0 to 360 degrees
/// s: Saturation, in range [0, 1]
/// l: Lightness, in range [0, 1]
/// Example usage:
///   HSL hsl = srgbToOkhsl(RGB(0.5, 0.5, 0.5));
///   // Hue is used in trigonometric functions:
///   double a_ = math.cos(2 * math.pi * hsl.h);
///   double b_ = math.sin(2 * math.pi * hsl.h);
class OkHsl {
  double h;
  double s;
  double l;

  OkHsl(this.h, this.s, this.l);

  @override
  String toString() {
    return 'HSL($h, $s, $l)';
  }

  // ------ Constructors ------ //

  factory OkHsl.fromColor(Color color) {
    final rgb = color.toRgb();
    return rgbToOkHsl(rgb);
  }

  OkHsl copyWith({double? hue, double? saturation, double? lightness}) {
    return OkHsl(hue ?? h, saturation ?? s, lightness ?? l);
  }

  OkHsl withHue(double hue) {
    return copyWith(hue: hue);
  }

  OkHsl withSaturation(double saturation) {
    return copyWith(saturation: saturation);
  }

  OkHsl withLightness(double lightness) {
    return copyWith(lightness: lightness);
  }

  OkHsl darker(double percentage) {
    return withLightness(lp.lerp(l, 0, percentage));
  }

  OkHsl lighter(double percentage) {
    return withLightness(lp.lerp(l, 1, percentage));
  }

  OkHsl saturate(double percentage) {
    return withSaturation(lp.lerp(s, 1, percentage));
  }

  OkHsl desaturate(double percentage) {
    return withSaturation(lp.lerp(s, 0, percentage));
  }

  OkHsl rotated(double degrees) {
    return withHue((h + degrees / 360) % 1);
  }

  // ------ Conversions ------ //

  Color toColor() {
    final rgb = okHslToRgb(this);
    return rgb.toColor();
  }

  static OkHsl lerp(OkHsl a, OkHsl b, double t, {bool shortestPath = true}) {
    return OkHsl(
      lp.lerpAngle(a.h, b.h, t, shortestPath: shortestPath),
      lerpDouble(a.s, b.s, t) ?? 0,
      lerpDouble(a.l, b.l, t) ?? 0,
    );
  }

  // ------ Harmonies ------ //

// ------ Harmonies ------ //

  OkHsl complementary() {
    return rotated(180);
  }

  List<OkHsl> splitComplementary() {
    return [rotated(150), this, rotated(210)];
  }

  List<OkHsl> triadic() {
    return [rotated(120), this, rotated(240)];
  }

  List<OkHsl> tetradic() {
    return [this, complementary(), rotated(90), rotated(270)];
  }

  List<OkHsl> analogous({int count = 2, double angle = 30}) {
    List<OkHsl> colors = [this];
    for (int i = 1; i <= count; i++) {
      colors.insert(0, rotated(angle * i));
    }
    for (int i = 1; i <= count; i++) {
      colors.add(rotated(-angle * i));
    }
    return colors;
  }

  List<OkHsl> shades({int count = 5}) {
    return List.generate(count, (index) {
      double t = index / (count - 1);
      return darker(t);
    });
  }

  List<OkHsl> tints({int count = 5}) {
    return List.generate(count, (index) {
      double t = index / (count - 1);
      return lighter(t);
    });
  }
}
