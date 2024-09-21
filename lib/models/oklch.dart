import 'dart:math';
import 'dart:ui';

import 'package:okcolor/converters/lab_lch.dart';
import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:okcolor/utils/lerp.dart';

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

/// Represents a color in the OkLCH color space.
/// L: Lightness, typically in range [0, 1]
/// C: Chroma, non-negative value
/// h: Hue angle in radians, typically in range [0, 2π]

class OkLch {
  final double l;
  final double c;
  final double h;

  OkLch(this.l, this.c, this.h); // Removed the clamps from the initializer as they cause tests to fail

  // ------ Constructors ------ //

  factory OkLch.fromColor(Color color) {
    final rgb = color.toRgb();
    final oklab = rgbToOkLab(rgb);
    return labToLch(oklab);
  }

  factory OkLch.fromOkLab(OkLab lab) {
    return labToLch(lab);
  }

  OkLch copyWith({double? lightness, double? chroma, double? hue}) {
    return OkLch(lightness ?? l, chroma ?? c, hue ?? h);
  }

  OkLch withLightness(double l) {
    return copyWith(lightness: l);
  }

  OkLch withChroma(double c) {
    return copyWith(chroma: c);
  }

  OkLch withHue(double h) {
    return copyWith(hue: h);
  }

  OkLch darker(double percentage) {
    return copyWith(lightness: l * (1 - percentage));
  }

  OkLch lighter(double percentage) {
    return copyWith(lightness: l * (1 + percentage));
  }

  OkLch saturated(double percentage) {
    return copyWith(chroma: c * (1 + percentage));
  }

  OkLch desaturated(double percentage) {
    return copyWith(chroma: c * (1 - percentage));
  }

  OkLch rotated(double degrees) {
    return copyWith(hue: (h + degrees.degToRad) % (2 * pi));
  }

  // ------ Getters ------ //

  // Source: https://bottosson.github.io/misc/colorpicker/#ff00ff
  static const Map<Hue, int> hues = {
    Hue.pink: 3, // rgb 330
    Hue.red: 29, // rgb 360/0
    Hue.orange: 53, // rgb 30
    Hue.yellow: 110, // rgb 60
    Hue.lime: 136, // rgb 90
    Hue.green: 142, // rgb 120
    Hue.teal: 151, // rgb 150
    Hue.cyan: 195, // rgb 180
    Hue.sky: 256, // rgb 210
    Hue.blue: 264, // rgb 240
    Hue.purple: 294, // rgb 270
    Hue.magenta: 328, // rgb 300
  };

  Hue get hue {
    double highestDistance = double.infinity;
    late Hue result;
    for (final hue in hues.entries) {
      final distance = (h % (2 * pi) - hue.value.toDouble().degToRad).abs();
      if (distance < highestDistance) {
        highestDistance = distance;
        result = hue.key;
      }
    }
    return result;
  }

  // ------ Conversions ------ //

  Color toColor() {
    final lab = lchToLab(this);
    final rgb = okLabToRgb(lab);
    return rgb.toColor();
  }

  OkLab toOkLab() {
    return lchToLab(this);
  }

  static OkLch lerp(OkLch start, OkLch end, double fraction, {bool shortestPath = true}) {
    return OkLch(
      lerpDouble(start.l, end.l, fraction) ?? 0,
      lerpDouble(start.c, end.c, fraction) ?? 0,
      lerpAngle(start.h, end.h, fraction, range: 2 * pi, shortestPath: shortestPath),
    );
  }

  @override
  String toString() {
    return 'OkLch($l, $c, $h)';
  }

  // ------ Harmonies ------ //

  OkLch complementary() {
    return rotated(180);
  }

  List<OkLch> splitComplementary() {
    return [this, complementary(), rotated(150), rotated(210)];
  }

  List<OkLch> triadic() {
    return [this, complementary(), rotated(120)];
  }

  List<OkLch> tetradic() {
    return [this, complementary(), rotated(90), rotated(270)];
  }

  List<OkLch> analogous({int count = 2, double angle = 30}) {
    List<OkLch> colors = [this];
    for (int i = 1; i <= count; i++) {
      colors.add(rotated(angle * i));
      colors.add(rotated(-angle * i));
    }
    return colors;
  }

  List<OkLch> shades({int count = 5}) {
    return List.generate(count, (index) {
      double t = index / (count - 1);
      return OkLch(lerpDouble(l, 0, t) ?? 0, c, h);
    });
  }

  List<OkLch> tints({int count = 5}) {
    return List.generate(count, (index) {
      double t = index / (count - 1);
      return OkLch(lerpDouble(l, 1, t) ?? 0, c, h);
    });
  }

  // ------ Operators ------ //

  OkLch operator +(OkLch other) {
    return OkLch(
      l + other.l,
      c + other.c,
      (h + other.h) % (2 * pi),
    );
  }

  OkLch operator -(OkLch other) {
    return OkLch(
      l - other.l,
      c - other.c,
      (h - other.h) % (2 * pi),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is OkLch) {
      return l == other.l && c == other.c && h == other.h;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(l, c, h);
}
