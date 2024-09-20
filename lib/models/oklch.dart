import 'dart:math';
import 'dart:ui';

import 'package:okcolor/converters/lab_lch.dart';
import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/utils/hue_util.dart';

/// Represents a color in the OkLCH color space.
/// L: Lightness, typically in range [0, 1]
/// C: Chroma, non-negative value
/// h: Hue angle in radians, typically in range [0, 2π]

class OkLch {
  final double l;
  final double c;
  final double h;

  OkLch(double l, double c, double h)
      : l = l.clamp(0, 1),
        c = max(c, 0),
        h = h % (2 * pi);

  // ------ Constructors ------ //

  factory OkLch.fromColor(Color color) {
    final rgb = color.toRgb();
    final oklab = rgbToOkLab(rgb);
    return labToLch(oklab);
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

  // ------ Conversions ------ //

  Color toColor() {
    final lab = lchToLab(this);
    final rgb = okLabToRgb(lab);
    return rgb.toColor();
  }

  static OkLch lerp(OkLch start, OkLch end, double fraction, {bool shortestPath = true}) {
    return OkLch(
      lerpDouble(start.l, end.l, fraction) ?? 0,
      lerpDouble(start.c, end.c, fraction) ?? 0,
      interpolateHue(start.h, end.h, fraction, shortestPath: shortestPath, normalizeHue: false),
    );
  }
}
