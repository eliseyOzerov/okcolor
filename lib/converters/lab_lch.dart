import 'dart:math' as math;

import 'package:okcolor/models/okcolor_base.dart';

// Source: https://bottosson.github.io/posts/oklab/#the-oklab-color-space

LCH labToLch(Lab lab) {
  final c = math.sqrt(lab.a * lab.a + lab.b * lab.b);
  final h = math.atan2(lab.b, lab.a);
  return LCH(lab.L, c, h);
}

Lab lchToLab(LCH lch) {
  final a = lch.C * math.cos(lch.h);
  final b = lch.C * math.sin(lch.h);
  return Lab(lch.L, a, b);
}
