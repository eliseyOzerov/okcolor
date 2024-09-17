import 'dart:math';

import 'package:collection/collection.dart';

import 'helpers.dart';
import 'lerp.dart';
import 'okcolor.dart';
import 'oklab.dart';

OkHsv interpolateOkHsv(OkHsv start, OkHsv end, double fraction, {bool shortestPath = true}) {
  // Ensure fraction is within [0, 1]
  fraction = fraction.clamp(0.0, 1.0);

  // Use the lerp function for s and v
  double s = lerp(start.s, end.s, fraction);
  double v = lerp(start.v, end.v, fraction);

  // Use the hueInterpolation function for h
  double h = interpolateHue(start.h, end.h, fraction, shortestPath: shortestPath);

  return OkHsv(h: h, s: s, v: v);
}

// ✅
OkLab okhsvToOklab(OkHsv okHsv) {
  double h = okHsv.h;
  double s = okHsv.s;
  double v = okHsv.v;

  double a = cos((h / 180) * pi);
  double b = sin((h / 180) * pi);

  final [sMax, t] = getStMax(a, b);
  const s0 = 0.5;
  double k = 1 - s0 / sMax;
  double lV = 1 - (s * s0) / (s0 + t - t * k * s);
  double cV = (s * t * s0) / (s0 + t - t * k * s);

  double lVt = toeInv(lV);
  double cVt = (cV * lVt) / lV;
  Lrgb rgbScale = convertOklabToLrgb(OkLab(l: lVt, a: a * cVt, b: b * cVt));
  // In the original code (culori), the max op also includes 0, but dividing by 0 gives infinity so idk
  double scaleL = pow((1 / [rgbScale.r, rgbScale.g, rgbScale.b].max), 1 / 3.0).toDouble();

  double lNew = toeInv(v * lV);
  double c = (cV * lNew) / lV;

  return OkLab(
    l: lNew * scaleL,
    a: c * a * scaleL,
    b: c * b * scaleL,
  );
}

// ✅
OkHsv convertOklabToOkhsv(OkLab lab) {
  double l = lab.l;
  double a = lab.a;
  double b = lab.b;

  double c = sqrt(a * a + b * b);

  double a_ = c != 0 ? a / c : 1;
  double b_ = c != 0 ? b / c : 1;

  final [sMax, T] = getStMax(a_, b_);
  const s0 = 0.5;
  double k = 1 - s0 / sMax;

  double t = T / (c + l * T);
  double Lv = t * l;
  double Cv = t * c;

  double Lvt = toeInv(Lv);
  double Cvt = (Cv * Lvt) / Lv;

  Lrgb rgbScale = convertOklabToLrgb(OkLab(l: Lvt, a: a_ * Cvt, b: b_ * Cvt));
  // In the original code (culori), the max op also includes 0, but dividing by 0 gives infinity so idk
  double scaleL = pow((1 / [rgbScale.r, rgbScale.g, rgbScale.b].max), 1 / 3.0).toDouble();

  l = l / scaleL;
  c = ((c / scaleL) * toe(l)) / l;
  l = toe(l);

  double s = c != 0 ? ((s0 + T) * Cv) / (T * s0 + T * k * Cv) : 0;
  double v = l != 0 ? l / Lv : 0;
  double h = 0;
  if (s != 0) {
    h = normalizeHue((atan2(b, a) * 180) / pi);
  }

  return OkHsv(h: h, s: s, v: v, alpha: lab.alpha);
}
