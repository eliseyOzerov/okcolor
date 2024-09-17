import 'package:flutter/material.dart';
import 'package:okcolor/okcolor.dart';

import 'okhsv.dart';

List<Color> okHsvGradientColors(Color start, Color end, {bool shortestPath = true, int numberOfColors = 5}) {
  final startHsv = Rgb.fromColor(start).toLrgb().toOklab().toOkhsv();
  final endHsv = Rgb.fromColor(end).toLrgb().toOklab().toOkhsv();

  final colors = <Color>[];

  for (int i = 0; i < numberOfColors; i++) {
    final fraction = i / (numberOfColors - 1);
    final interpolatedHsv = interpolateOkHsv(
      OkHsv(h: startHsv.h, s: startHsv.s, v: startHsv.v),
      OkHsv(h: endHsv.h, s: endHsv.s, v: endHsv.v),
      fraction,
      shortestPath: shortestPath,
    );
    final interpolatedRgb = interpolatedHsv.toOklab().toLrgb().toRgb();
    colors.add(Color.fromARGB(
      (interpolatedRgb.alpha * 255).round(),
      interpolatedRgb.r,
      interpolatedRgb.g,
      interpolatedRgb.b,
    ));
  }

  return colors;
}
