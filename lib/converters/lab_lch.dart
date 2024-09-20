import 'dart:math' as math;

import 'package:okcolor/models/okcolor_base.dart';

// Source: https://bottosson.github.io/posts/oklab/#the-oklab-color-space

LCH labToLch(OkLab lab) {
  final c = math.sqrt(lab.a * lab.a + lab.b * lab.b);
  final h = math.atan2(lab.b, lab.a);
  if (lab.a.roundTo(6) == 0 && lab.b.roundTo(6) == 0) {
    return LCH(lab.L, 0, 0);
  }
  return LCH(lab.L, c, h);
}

OkLab lchToLab(LCH lch) {
  final a = lch.C * math.cos(lch.h);
  final b = lch.C * math.sin(lch.h);
  return OkLab(lch.L, a, b);
}

extension DoubleExtension on double {
  double roundTo(int places) {
    return (this * math.pow(10, places)).round() / math.pow(10, places);
  }
}
