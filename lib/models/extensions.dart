import 'dart:math';
import 'dart:ui';

import 'package:okcolor/models/misc.dart';
import 'package:okcolor/models/okhsv.dart';
import 'package:okcolor/models/oklab.dart';

extension ColorExt on Color {
  OkLab toOkLab() {
    return OkLab.fromColor(this);
  }

  OkHsv toOkHsv() {
    return OkHsv.fromColor(this);
  }

  RGB toRgb() {
    return RGB(red / 255, green / 255, blue / 255);
  }
}

extension RgbExt on RGB {
  Color toColor() {
    return Color.fromRGBO(
      (r * 255).round().clamp(0, 255),
      (g * 255).round().clamp(0, 255),
      (b * 255).round().clamp(0, 255),
      1,
    );
  }
}

extension DoubleExtension on double {
  double roundTo(int places) {
    return (this * pow(10, places)).round() / pow(10, places);
  }

  double get degToRad => this * pi / 180;
  double get radToDeg => this * 180 / pi;
}
