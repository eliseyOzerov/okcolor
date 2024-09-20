import 'dart:math';
import 'dart:ui';

import 'package:okcolor/converters/lab_lch.dart';
import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/models/flutter_color_conversions.dart';
import 'package:okcolor/models/okcolor_base.dart';

class OkLch {
  final double l;
  final double c;
  final double h;

  OkLch(this.l, this.c, this.h);

  // ------ Constructors ------ //

  factory OkLch.fromLch(LCH lch) {
    return OkLch(lch.L, lch.C, lch.h);
  }

  factory OkLch.fromColor(Color color) {
    final rgb = color.toRgb();
    final oklab = rgbToOkLab(rgb);
    final lch = labToLch(oklab);
    return OkLch.fromLch(lch);
  }

  // ------ Conversions ------ //

  LCH toLch() {
    return LCH(l, c, h);
  }

  Color toColor() {
    final lch = toLch();
    final lab = lchToLab(lch);
    final rgb = okLabToRgb(lab);
    return rgb.toColor();
  }

  static OkLch lerp(OkLch start, OkLch end, double fraction, {bool shortestPath = true}) {
    double lerpedL = lerpDouble(start.l, end.l, fraction) ?? 0;
    double lerpedC = lerpDouble(start.c, end.c, fraction) ?? 0;

    double startH = start.h % (2 * pi);
    double endH = end.h % (2 * pi);

    if (shortestPath) {
      double diff = endH - startH;
      if (diff > pi) {
        if (diff > 0) {
          startH += 2 * pi;
        } else {
          endH += 2 * pi;
        }
      }
    }

    double lerpedH = (lerpDouble(startH, endH, fraction) ?? 0) % (2 * pi);
    return OkLch(lerpedL, lerpedC, lerpedH);
  }

  OkLch withLightness(double l) {
    return OkLch(l, c, h);
  }

  OkLch withChroma(double c) {
    return OkLch(l, c, h);
  }

  OkLch withHue(double h) {
    return OkLch(l, c, h);
  }

  OkLch copyWith({double? lightness, double? chroma, double? hue}) {
    return OkLch(lightness ?? l, chroma ?? c, hue ?? h);
  }
}
