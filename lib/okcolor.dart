import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:okcolor/models/okhsv.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:okcolor/models/oklch.dart';

// Additional resources:
// https://bottosson.github.io/misc/colorpicker/
// https://colordesigner.io/gradient-generator
// https://observablehq.com/@aras-p/oklab-interpolation-test
// https://observablehq.com/d/20c6bfb9965dd521 (oklch interpolation)

// ------ ENUMS ------ //

enum InterpolationMethod { oklab, okhsv, oklch, hsv, rgb }

Color interpolate(Color start, Color end, double fraction, {bool shortestPath = true, InterpolationMethod method = InterpolationMethod.oklab}) {
  if (method == InterpolationMethod.oklab) {
    final startLab = OkLAB.fromColor(start);
    final endLab = OkLAB.fromColor(end);
    return OkLAB.lerp(startLab, endLab, fraction).toColor();
  } else if (method == InterpolationMethod.okhsv) {
    final startHsv = OkHsv.fromColor(start);
    final endHsv = OkHsv.fromColor(end);
    return OkHsv.lerp(startHsv, endHsv, fraction, shortestPath: shortestPath).toColor();
  } else if (method == InterpolationMethod.oklch) {
    final startLch = OkLch.fromColor(start);
    final endLch = OkLch.fromColor(end);
    return OkLch.lerp(startLch, endLch, fraction, shortestPath: shortestPath).toColor();
  } else if (method == InterpolationMethod.hsv) {
    HSVColor startHsv = HSVColor.fromColor(start);
    HSVColor endHsv = HSVColor.fromColor(end);
    double hue = interpolateHue(startHsv.hue, endHsv.hue, fraction, shortestPath: shortestPath, normalizeHue: false);
    HSVColor lerpedColor = HSVColor.lerp(startHsv, endHsv, fraction)!.withHue(hue);
    return lerpedColor.toColor();
  } else {
    return Color.lerp(start, end, fraction)!;
  }
}

List<Color> gradient(Color start, Color end, {int numberOfColors = 5, InterpolationMethod method = InterpolationMethod.oklab, bool shortestPath = true}) {
  final colors = <Color>[];

  for (int i = 0; i < numberOfColors; i++) {
    final fraction = i / (numberOfColors - 1);
    final lerped = interpolate(start, end, fraction, method: method, shortestPath: shortestPath);
    colors.add(lerped);
  }

  return colors;
}

double interpolateHue(double start, double end, double fraction, {bool shortestPath = true, bool normalizeHue = false}) {
  final range = normalizeHue ? 1 : 360;
  double fStart = normalizeHue ? start % 360 : start;
  double fEnd = normalizeHue ? end % 360 : end;

  if (shortestPath && (fEnd - fStart).abs() > (range / 2)) {
    if (fEnd > fStart) {
      fStart += range;
    } else {
      fEnd -= range;
    }
  }

  return (lerpDouble(fStart, fEnd, fraction) ?? 0) % range;
}
