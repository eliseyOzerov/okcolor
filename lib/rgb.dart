import 'dart:math';

import 'okcolor.dart';

// ✅
double fnRgb(double c) {
  double absC = c.abs();
  if (absC > 0.0031308) {
    return (c.sign == 0 ? 1 : c.sign) * (1.055 * pow(absC, 1 / 2.4) - 0.055);
  }
  return c * 12.92;
}

// ✅
double fnLrgb(double c) {
  double absC = c.abs();
  if (absC <= 0.04045) {
    return c / 12.92;
  }
  return (c.sign == 0 ? 1 : c.sign) * pow((absC + 0.055) / 1.055, 2.4).toDouble();
}

Rgb convertLrgbToRgb(Lrgb lrgb) {
  return Rgb(
    r: (fnRgb(lrgb.r) * 255).toInt(),
    g: (fnRgb(lrgb.g) * 255).toInt(),
    b: (fnRgb(lrgb.b) * 255).toInt(),
    alpha: lrgb.alpha,
  );
}

Lrgb convertRgbToLrgb(Rgb rgb) {
  return Lrgb(
    r: fnLrgb(rgb.r / 255),
    g: fnLrgb(rgb.g / 255),
    b: fnLrgb(rgb.b / 255),
    alpha: rgb.alpha,
  );
}
