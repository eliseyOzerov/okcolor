import 'dart:math';
import 'dart:ui';

import 'package:okcolor/models/misc.dart';
import 'package:okcolor/models/okhsl.dart';
import 'package:okcolor/models/okhsv.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:okcolor/models/oklch.dart';

extension ColorExt on Color {
  OkLab toOkLab() {
    return OkLab.fromColor(this);
  }

  OkHsv toOkHsv() {
    return OkHsv.fromColor(this);
  }

  OkHsl toOkHsl() {
    return OkHsl.fromColor(this);
  }

  OkLch toOkLch() {
    return OkLch.fromColor(this);
  }

  RGB toRgb() {
    return RGB(red / 255, green / 255, blue / 255);
  }
}

extension OkColorExt on Color {
  Color darker(double percentage) {
    return toOkHsl().darker(percentage).toColor();
  }

  Color lighter(double percentage) {
    return toOkHsl().lighter(percentage).toColor();
  }

  Color saturate(double percentage) {
    return toOkHsl().saturate(percentage).toColor();
  }

  Color desaturate(double percentage) {
    return toOkHsl().desaturate(percentage).toColor();
  }

  Color rotated(double degrees) {
    return toOkHsl().rotated(degrees).toColor();
  }

  Color complementary() {
    return toOkHsl().complementary().toColor();
  }

  List<Color> splitComplementary() {
    return toOkHsl().splitComplementary().map((c) => c.toColor()).toList();
  }

  List<Color> triadic() {
    return toOkHsl().triadic().map((c) => c.toColor()).toList();
  }

  List<Color> tetradic() {
    return toOkHsl().tetradic().map((c) => c.toColor()).toList();
  }

  List<Color> analogous({int count = 2, double angle = 30}) {
    return toOkHsl().analogous(count: count, angle: angle).map((c) => c.toColor()).toList();
  }

  List<Color> shades({int count = 5}) {
    return toOkHsl().shades(count: count).map((c) => c.toColor()).toList();
  }

  List<Color> tints({int count = 5}) {
    return toOkHsl().tints(count: count).map((c) => c.toColor()).toList();
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
