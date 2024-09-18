import 'dart:math' as math;

import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/converters/xyz_rgb.dart';
import 'package:okcolor/models/okcolor_base.dart';
import 'package:okcolor/utils/common.dart';
import 'package:okcolor/utils/rgb_gamut_intersection.dart';

// Source: https://bottosson.github.io/posts/colorpicker/#hsl-2

RGB okhslToSrgb(HSL hsl) {
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

  RGB rgb = okLabToLinearRgb(Lab(L, C * a_, C * b_));
  return linearRgbToRgb(rgb);
}

HSL srgbToOkhsl(RGB rgb) {
  Lab lab = linearRgbToOkLab(rgbToLinearRgb(rgb));

  double C = math.sqrt(lab.a * lab.a + lab.b * lab.b);
  double a_ = lab.a / C;
  double b_ = lab.b / C;

  double L = lab.L;
  double h = 0.5 + 0.5 * math.atan2(-lab.b, -lab.a) / math.pi;

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
  return HSL(h, s, l);
}

// Returns a smooth approximation of the location of the cusp
// This polynomial was created by an optimization process
// It has been designed so that S_mid < S_max and T_mid < T_max
ST getSTMid(double a_, double b_) {
  double S = 0.11516993 +
      1 / (7.44778970 + 4.15901240 * b_ + a_ * (-2.19557347 + 1.75198401 * b_ + a_ * (-2.13704948 - 10.02301043 * b_ + a_ * (-4.24894561 + 5.38770819 * b_ + 4.69891013 * a_))));

  double T = 0.11239642 +
      1 / (1.61320320 - 0.68124379 * b_ + a_ * (0.40370612 + 0.90148123 * b_ + a_ * (-0.27087943 + 0.61223990 * b_ + a_ * (0.00299215 - 0.45399568 * b_ - 0.14661872 * a_))));

  return ST(S, T);
}

Cs getCs(double L, double a_, double b_) {
  LC cusp = findCusp(a_, b_);

  double cMax = findGamutIntersection(a_, b_, L, 1, L, cusp);
  ST stMax = toST(cusp);

  // Scale factor to compensate for the curved part of gamut shape:
  double k = cMax / math.min((L * stMax.S), (1 - L) * stMax.T);

  double cMid;
  {
    ST stMid = getSTMid(a_, b_);

    // Use a soft minimum function, instead of a sharp triangle shape to get a smooth value for chroma.
    double cA = L * stMid.S;
    double cB = (1 - L) * stMid.T;
    cMid = 0.9 * k * math.sqrt(math.sqrt(1 / (1 / (cA * cA * cA * cA) + 1 / (cB * cB * cB * cB))));
  }

  double c0;
  {
    // for C_0, the shape is independent of hue, so ST are constant. Values picked to roughly be the average values of ST.
    double cA = L * 0.4;
    double cB = (1 - L) * 0.8;

    // Use a soft minimum function, instead of a sharp triangle shape to get a smooth value for chroma.
    c0 = math.sqrt(1 / (1 / (cA * cA) + 1 / (cB * cB)));
  }

  return Cs(c0, cMid, cMax);
}
