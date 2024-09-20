import 'dart:ui';

import 'package:okcolor/converters/lab_lch.dart';
import 'package:okcolor/converters/rgb_okhsl.dart';
import 'package:okcolor/converters/rgb_okhsv.dart';
import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/converters/xyz_lab.dart';
import 'package:okcolor/converters/xyz_rgb.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/models/misc.dart';
import 'package:okcolor/models/okhsl.dart';
import 'package:okcolor/models/okhsv.dart';
import 'package:okcolor/models/oklch.dart';

/// Represents a color in the Oklab color space.
/// L: Lightness, typically in range [0, 1]
/// a: Green-red component, typically in range [-0.5, 0.5]
/// b: Blue-yellow component, typically in range [-0.5, 0.5]
/// Example usage:
///   Lab lab = linearSrgbToOklab(RGB(0.5, 0.5, 0.5));
///   // lab components are used directly in calculations:
///   double C = math.sqrt(lab.a * lab.a + lab.b * lab.b);
class OkLab {
  final double L;
  final double a;
  final double b;

  OkLab(this.L, this.a, this.b);

  // ------ Constructors ------ //

  factory OkLab.fromColor(Color color) {
    final rgb = color.toRgb();
    final linear = rgbToLinearRgb(rgb);
    return linearRgbToOkLab(linear);
  }

  OkLab copyWith({double? lightness, double? a, double? b}) {
    return OkLab(lightness ?? L, a ?? this.a, b ?? this.b);
  }

  OkLab withLightness(double l) {
    return copyWith(lightness: l);
  }

  OkLab withA(double a) {
    return copyWith(a: a);
  }

  OkLab withB(double b) {
    return copyWith(b: b);
  }
  // ------ Conversions ------ //

  Color toColor() {
    return okLabToRgb(this).toColor();
  }

  OkHsv toHsv() {
    return rgbToOkHsv(okLabToRgb(this));
  }

  OkHsl toHsl() {
    return rgbToOkHsl(okLabToRgb(this));
  }

  OkLch toLch() {
    return labToLch(this);
  }

  XYZ toXyz() {
    return labToXyz(this);
  }

  // ------ Interpolation ------ //

  static OkLab lerp(OkLab start, OkLab end, double fraction) {
    return OkLab(
      lerpDouble(start.L, end.L, fraction) ?? 0,
      lerpDouble(start.a, end.a, fraction) ?? 0,
      lerpDouble(start.b, end.b, fraction) ?? 0,
    );
  }

  // ------ Operators ------ //

  OkLab operator +(OkLab other) {
    return OkLab(L + other.L, a + other.a, b + other.b);
  }

  OkLab operator -(OkLab other) {
    return OkLab(L - other.L, a - other.a, b - other.b);
  }

  OkLab operator *(double scalar) {
    return OkLab(L * scalar, a * scalar, b * scalar);
  }

  OkLab operator /(double scalar) {
    return OkLab(L / scalar, a / scalar, b / scalar);
  }

  OkLab operator -() {
    return OkLab(-L, -a, -b);
  }

  OkLab operator %(double scalar) {
    return OkLab(L % scalar, a % scalar, b % scalar);
  }

  @override
  bool operator ==(Object other) {
    if (other is OkLab) {
      return L == other.L && a == other.a && b == other.b;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([L, a, b]);
}
