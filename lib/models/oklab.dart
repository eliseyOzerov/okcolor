import 'dart:ui';

import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/converters/xyz_rgb.dart';
import 'package:okcolor/models/flutter_color_conversions.dart';
import 'package:okcolor/models/okcolor_base.dart';

class OkLab {
  final double l;
  final double a;
  final double b;

  OkLab(this.l, this.a, this.b);

  // ------ Constructors ------ //

  factory OkLab.fromLab(Lab lab) {
    return OkLab(lab.L, lab.a, lab.b);
  }

  // factory OkLab.fromColor(Color color) {
  //   final rgb = color.toRgb();
  //   // final lab = rgb.toLab();
  //   final lab = rgbToLab(rgb);
  //   return OkLab.fromLab(lab);
  // }

  factory OkLab.fromColor(Color color) {
    final rgb = color.toRgb();
    final linear = rgbToLinearRgb(rgb);
    final lab = linearRgbToOkLab(linear);
    return OkLab.fromLab(lab);
  }

  // ------ Conversions ------ //

  Lab toLab() {
    return Lab(l, a, b);
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

  static OkLab lerp(OkLab start, OkLab end, double fraction) {
    return OkLab(
      lerpDouble(start.l, end.l, fraction) ?? 0,
      lerpDouble(start.a, end.a, fraction) ?? 0,
      lerpDouble(start.b, end.b, fraction) ?? 0,
    );
  }
}
