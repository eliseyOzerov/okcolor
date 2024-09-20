import 'dart:math' as math;

import 'package:okcolor/models/oklab.dart';
import 'package:okcolor/models/oklch.dart';

// Source: https://bottosson.github.io/posts/oklab/#the-oklab-color-space

OkLch labToLch(OkLab lab) {
  final c = math.sqrt(lab.a * lab.a + lab.b * lab.b);
  final h = math.atan2(lab.b, lab.a);
  if (lab.a.roundTo(6) == 0 && lab.b.roundTo(6) == 0) {
    return OkLch(lab.L, 0, 0);
  }
  return OkLch(lab.L, c, h);
}

OkLab lchToLab(OkLch lch) {
  final a = lch.c * math.cos(lch.h);
  final b = lch.c * math.sin(lch.h);
  return OkLab(lch.l, a, b);
}

extension DoubleExtension on double {
  double roundTo(int places) {
    return (this * math.pow(10, places)).round() / math.pow(10, places);
  }
}
