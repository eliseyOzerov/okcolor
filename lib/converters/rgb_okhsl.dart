import 'dart:math' as math;

import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/models/okcolor_base.dart';
import 'package:okcolor/utils/common.dart';

// Source: https://bottosson.github.io/posts/colorpicker/#hsl-2

RGB okHslToSrgb(OkHSL hsl) {
  double h = hsl.h;
  double s = hsl.s;
  double l = hsl.l;

  if (l == 1.0) {
    return RGB(1, 1, 1);
  } else if (l == 0) {
    return RGB(0, 0, 0);
  }

  double a_ = math.cos(2 * math.pi * h);
  double b_ = math.sin(2 * math.pi * h);
  double L = toeInv(l);

  Cs cs = getCs(L, a_, b_);
  double c0 = cs.C_0;
  double cMid = cs.C_mid;
  double cMax = cs.C_max;

  double mid = 0.8;
  double midInv = 1.25;

  double C, t, k_0, k_1, k_2;

  if (s < mid) {
    t = midInv * s;

    k_1 = mid * c0;
    k_2 = (1 - k_1 / cMid);

    C = t * k_1 / (1 - k_2 * t);
  } else {
    t = (s - mid) / (1 - mid);

    k_0 = cMid;
    k_1 = (1 - mid) * cMid * cMid * midInv * midInv / c0;
    k_2 = (1 - (k_1) / (cMax - cMid));

    C = k_0 + t * k_1 / (1 - k_2 * t);
  }

  return okLabToRgb(OkLab(L, C * a_, C * b_));
}

/// Non-linear RGB
OkHSL rgbToOkHsl(RGB rgb) {
  // Handle full black
  if (rgb.r <= 0 && rgb.g <= 0 && rgb.b <= 0) {
    return OkHSL(0, 0, 0);
  }

  OkLab lab = rgbToOkLab(rgb);

  double C = math.sqrt(lab.a * lab.a + lab.b * lab.b);
  double a_ = lab.a / C;
  double b_ = lab.b / C;

  double L = lab.L;
  double h = 0.5 + 0.5 * math.atan2(-lab.b, -lab.a) / math.pi;
  if (rgb.r == 0.5 && rgb.g == 0.5 && rgb.b == 0.5) {
    print("DART_rgbToOkHsl: L = ${lab.L.toStringAsFixed(20)}, a = ${lab.a.toStringAsFixed(20)}, b = ${lab.b.toStringAsFixed(20)}");
    print("DART_rgbToOkHsl: h = ${h.toStringAsFixed(20)}");
  }

  Cs cs = getCs(L, a_, b_);
  double c0 = cs.C_0;
  double cMid = cs.C_mid;
  double cMax = cs.C_max;

  // Inverse of the interpolation in okhsl_to_srgb:
  double mid = 0.8;
  double midInv = 1.25;

  double s;
  if (C < cMid) {
    double k_1 = mid * c0;
    double k_2 = (1 - k_1 / cMid);

    double t = C / (k_1 + k_2 * C);
    s = t * mid;
  } else {
    double k_0 = cMid;
    double k_1 = (1 - mid) * cMid * cMid * midInv * midInv / c0;
    double k_2 = (1 - (k_1) / (cMax - cMid));

    double t = (C - k_0) / (k_1 + k_2 * (C - k_0));
    s = mid + (1 - mid) * t;
  }

  double l = toe(L);

  return OkHSL(h, s, l);
}
