import 'dart:math' as math;

import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/models/misc.dart';
import 'package:okcolor/models/okhsv.dart';
import 'package:okcolor/models/oklab.dart';
import 'package:okcolor/utils/common.dart';
import 'package:okcolor/utils/rgb_gamut_intersection.dart';

// Source: https://bottosson.github.io/posts/colorpicker/#hsv-2

RGB okhsvToSrgb(OkHsv hsv) {
  double h = hsv.h;
  double s = hsv.s;
  double v = hsv.v;

  // Handle black color separately
  if (v == 0) {
    return RGB(0, 0, 0);
  }

  double a_ = math.cos(2 * math.pi * h);
  double b_ = math.sin(2 * math.pi * h);

  LC cusp = findCusp(a_, b_);
  ST stMax = toST(cusp);
  double sMax = stMax.S;
  double tMax = stMax.T;
  double s0 = 0.5;
  double k = 1 - s0 / sMax;

  // first we compute L and V as if the gamut is a perfect triangle:

  // L, C when v==1:
  double lV = 1 - s * s0 / (s0 + tMax - tMax * k * s);
  double cV = s * tMax * s0 / (s0 + tMax - tMax * k * s);

  double L = v * lV;
  double C = v * cV;

  // then we compensate for both toe and the curved top part of the triangle:
  double lVt = toeInv(lV);
  double cVt = cV * lVt / lV;

  double lNew = toeInv(L);
  C = C * lNew / math.max(L, 1e-10);
  L = lNew;

  RGB rgbScale = okLabToLinearRgb(OkLab(lVt, a_ * cVt, b_ * cVt));
  double scaleL = math.pow(1 / math.max(math.max(rgbScale.r, rgbScale.g), math.max(rgbScale.b, 1e-10)), 1 / 3).toDouble();

  L = L * scaleL;
  C = C * scaleL;

  return okLabToRgb(OkLab(L, C * a_, C * b_));
}

OkHsv rgbToOkHsv(RGB rgb) {
  if (rgb.r == 0 && rgb.g == 0 && rgb.b == 0) {
    return OkHsv(0, 0, 0);
  }

  OkLab lab = rgbToOkLab(rgb);

  double C = math.sqrt(lab.a * lab.a + lab.b * lab.b);
  double a_ = lab.a / C;
  double b_ = lab.b / C;

  double L = lab.L;

  double h = 0.5 + 0.5 * math.atan2(-lab.b, -lab.a) / math.pi;

  LC cusp = findCusp(a_, b_);
  ST stMax = toST(cusp);
  double sMax = stMax.S;
  double tMax = stMax.T;
  double s0 = 0.5;
  double k = 1 - s0 / sMax;

  // first we find L_v, C_v, L_vt and C_vt
  double t = tMax / (C + L * tMax);
  double lV = t * L;
  double cV = t * C;

  double lVt = toeInv(lV);
  double cVt = cV * lVt / lV;

  // we can then use these to invert the step that compensates for the toe and the curved top part of the triangle:
  RGB rgbScale = okLabToLinearRgb(OkLab(lVt, a_ * cVt, b_ * cVt));
  double scaleL = math.pow(1 / math.max(math.max(rgbScale.r, rgbScale.g), math.max(rgbScale.b, 1e-10)), 1 / 3).toDouble();

  L = L / scaleL;
  C = C / scaleL;

  C = C * toe(L) / L;
  L = toe(L);

  // we can now compute v and s:
  double v = L / lV;
  double s = (s0 + tMax) * cV / ((tMax * s0) + tMax * k * cV);

  if (rgb.r == rgb.g && rgb.g == rgb.b) {
    h = 0;
    s = 0;
  }

  return OkHsv(h, s, v);
}

extension NonZero on double {
  double get nonZero {
    return this == 0 ? 1e-10 : this;
  }
}
