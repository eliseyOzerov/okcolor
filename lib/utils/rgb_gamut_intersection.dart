import 'dart:math' as math;

import 'package:okcolor/converters/rgb_oklab.dart';

import '../models/okcolor_base.dart';

// Source: https://bottosson.github.io/posts/gamutclipping/#intersection-with-srgb-gamut

// Finds the maximum saturation possible for a given hue that fits in sRGB
// Saturation here is defined as S = C/L
// a and b must be normalized so a^2 + b^2 == 1
double computeMaxSaturation(double a, double b) {
  // Max saturation will be when one of r, g or b goes below zero.

  // Select different coefficients depending on which component goes below zero first
  double k0, k1, k2, k3, k4, wl, wm, ws;

  if (-1.88170328 * a - 0.80936493 * b > 1) {
    // Red component
    k0 = 1.19086277;
    k1 = 1.76576728;
    k2 = 0.59662641;
    k3 = 0.75515197;
    k4 = 0.56771245;
    wl = 4.0767416621;
    wm = -3.3077115913;
    ws = 0.2309699292;
  } else if (1.81444104 * a - 1.19445276 * b > 1) {
    // Green component
    k0 = 0.73956515;
    k1 = -0.45954404;
    k2 = 0.08285427;
    k3 = 0.12541070;
    k4 = 0.14503204;
    wl = -1.2684380046;
    wm = 2.6097574011;
    ws = -0.3413193965;
  } else {
    // Blue component
    k0 = 1.35733652;
    k1 = -0.00915799;
    k2 = -1.15130210;
    k3 = -0.50559606;
    k4 = 0.00692167;
    wl = -0.0041960863;
    wm = -0.7034186147;
    ws = 1.7076147010;
  }

  // Approximate max saturation using a polynomial:
  double S = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b;

  // Do one step Halley's method to get closer
  // this gives an error less than 10e6, except for some blue hues where the dS/dh is close to infinite
  // this should be sufficient for most applications, otherwise do two/three steps

  double kL = 0.3963377774 * a + 0.2158037573 * b;
  double kM = -0.1055613458 * a - 0.0638541728 * b;
  double kS = -0.0894841775 * a - 1.2914855480 * b;

  {
    double l_ = 1 + S * kL;
    double m_ = 1 + S * kM;
    double s_ = 1 + S * kS;

    double l = l_ * l_ * l_;
    double m = m_ * m_ * m_;
    double s = s_ * s_ * s_;

    double lDs = 3 * kL * l_ * l_;
    double mDs = 3 * kM * m_ * m_;
    double sDs = 3 * kS * s_ * s_;

    double lDs2 = 6 * kL * kL * l_;
    double mDs2 = 6 * kM * kM * m_;
    double sDs2 = 6 * kS * kS * s_;

    double f = wl * l + wm * m + ws * s;
    double f1 = wl * lDs + wm * mDs + ws * sDs;
    double f2 = wl * lDs2 + wm * mDs2 + ws * sDs2;

    S = S - f * f1 / (f1 * f1 - 0.5 * f * f2);
  }

  return S;
}

// finds L_cusp and C_cusp for a given hue
// a and b must be normalized so a^2 + b^2 == 1
LC findCusp(double a, double b) {
  // First, find the maximum saturation (saturation S = C/L)
  double sCusp = computeMaxSaturation(a, b);

  // Convert to linear sRGB to find the first point where at least one of r,g or b >= 1:
  RGB rgbAtMax = okLabToLinearRgb(Lab(1, sCusp * a, sCusp * b));
  double lCusp = math.pow(1 / math.max(math.max(rgbAtMax.r, rgbAtMax.g), rgbAtMax.b), 1 / 3).toDouble();
  double cCusp = lCusp * sCusp;

  return LC(lCusp, cCusp);
}

// Finds intersection of the line defined by
// L = L0 * (1 - t) + t * L1;
// C = t * C1;
// a and b must be normalized so a^2 + b^2 == 1
double findGamutIntersection(double a, double b, double L1, double C1, double L0, LC cusp) {
  // Find the intersection for upper and lower half separately
  double t;
  if (((L1 - L0) * cusp.C - (cusp.L - L0) * C1) <= 0) {
    // Lower half
    t = cusp.C * L0 / (C1 * cusp.L + cusp.C * (L0 - L1));
  } else {
    // Upper half

    // First intersect with triangle
    t = cusp.C * (L0 - 1) / (C1 * (cusp.L - 1) + cusp.C * (L0 - L1));

    // Then one step Halley's method
    {
      double dL = L1 - L0;
      double dC = C1;

      double kL = 0.3963377774 * a + 0.2158037573 * b;
      double kM = -0.1055613458 * a - 0.0638541728 * b;
      double kS = -0.0894841775 * a - 1.2914855480 * b;

      double lDt = dL + dC * kL;
      double mDt = dL + dC * kM;
      double sDt = dL + dC * kS;

      // If higher accuracy is required, 2 or 3 iterations of the following block can be used:
      {
        double L = L0 * (1 - t) + t * L1;
        double C = t * C1;

        double l_ = L + C * kL;
        double m_ = L + C * kM;
        double s_ = L + C * kS;

        double l = l_ * l_ * l_;
        double m = m_ * m_ * m_;
        double s = s_ * s_ * s_;

        double ldt = 3 * lDt * l_ * l_;
        double mdt = 3 * mDt * m_ * m_;
        double sdt = 3 * sDt * s_ * s_;

        double ldt2 = 6 * lDt * lDt * l_;
        double mdt2 = 6 * mDt * mDt * m_;
        double sdt2 = 6 * sDt * sDt * s_;

        double r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s - 1;
        double r1 = 4.0767416621 * ldt - 3.3077115913 * mdt + 0.2309699292 * sdt;
        double r2 = 4.0767416621 * ldt2 - 3.3077115913 * mdt2 + 0.2309699292 * sdt2;

        double uR = r1 / (r1 * r1 - 0.5 * r * r2);
        double tR = -r * uR;

        double g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s - 1;
        double g1 = -1.2684380046 * ldt + 2.6097574011 * mdt - 0.3413193965 * sdt;
        double g2 = -1.2684380046 * ldt2 + 2.6097574011 * mdt2 - 0.3413193965 * sdt2;

        double uG = g1 / (g1 * g1 - 0.5 * g * g2);
        double tG = -g * uG;

        double b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s - 1;
        double b1 = -0.0041960863 * ldt - 0.7034186147 * mdt + 1.7076147010 * sdt;
        double b2 = -0.0041960863 * ldt2 - 0.7034186147 * mdt2 + 1.7076147010 * sdt2;

        double uB = b1 / (b1 * b1 - 0.5 * b * b2);
        double tB = -b * uB;

        tR = uR >= 0 ? tR : double.infinity;
        tG = uG >= 0 ? tG : double.infinity;
        tB = uB >= 0 ? tB : double.infinity;

        t += math.min(tR, math.min(tG, tB));
      }
    }
  }

  return t;
}

double findGamutIntersectionSimple(double a, double b, double L1, double C1, double L0) {
  // Find the cusp of the gamut triangle
  LC cusp = findCusp(a, b);

  return findGamutIntersection(a, b, L1, C1, L0, cusp);
}
