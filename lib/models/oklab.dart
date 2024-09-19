import 'dart:ui';

import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/converters/xyz_rgb.dart';
import 'package:okcolor/models/flutter_color_conversions.dart';
import 'package:okcolor/models/okcolor_base.dart';

class OkLAB {
  final double l;
  final double a;
  final double b;

  OkLAB(this.l, this.a, this.b);

  // ------ Constructors ------ //

  factory OkLAB.fromLab(OkLab lab) {
    return OkLAB(lab.L, lab.a, lab.b);
  }

  // factory OkLab.fromColor(Color color) {
  //   final rgb = color.toRgb();
  //   // final lab = rgb.toLab();
  //   final lab = rgbToLab(rgb);
  //   return OkLab.fromLab(lab);
  // }

  factory OkLAB.fromColor(Color color) {
    final rgb = color.toRgb();
    final linear = rgbToLinearRgb(rgb);
    final lab = linearRgbToOkLab(linear);
    return OkLAB.fromLab(lab);
  }

  // ------ Conversions ------ //

  OkLab toLab() {
    return OkLab(l, a, b);
  }

  Color toColor() {
    final lab = toLab();
    final linear = okLabToLinearRgb(lab);
    final rgb = linearRgbToRgb(linear);
    return rgb.toColor();
  }

  // Color toColor() {
  //   // final rgb = toLab().toRgb();
  //   final rgb = labToRgb(toLab());
  //   return rgb.toColor();
  // }

  // ------ Interpolation ------ //

  static OkLAB lerp(OkLAB start, OkLAB end, double fraction) {
    return OkLAB(
      lerpDouble(start.l, end.l, fraction) ?? 0,
      lerpDouble(start.a, end.a, fraction) ?? 0,
      lerpDouble(start.b, end.b, fraction) ?? 0,
    );
  }
}
