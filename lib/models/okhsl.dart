import 'dart:ui';

import 'package:okcolor/converters/rgb_okhsl.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/utils/lerp.dart';

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
    return withLightness(l * (1 - percentage));
  }

  OkHsl lighter(double percentage) {
    return withLightness(l * (1 + percentage));
  }

  // ------ Conversions ------ //

  Color toColor() {
    final rgb = okHslToRgb(this);
    return rgb.toColor();
  }

  static OkHsl lerp(OkHsl a, OkHsl b, double t, {bool shortestPath = true}) {
    return OkHsl(
      lerpAngle(a.h, b.h, t, shortestPath: shortestPath),
      lerpDouble(a.s, b.s, t) ?? 0,
      lerpDouble(a.l, b.l, t) ?? 0,
    );
  }
}
