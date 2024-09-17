import 'dart:math';

import 'package:collection/collection.dart';

import 'lerp.dart';
import 'okcolor.dart';
import 'oklab.dart';

double toe(double x) {
  const k1 = 0.206;
  const k2 = 0.03;
  const k3 = (1 + k1) / (1 + k2);
  return 0.5 * (k3 * x - k1 + sqrt((k3 * x - k1) * (k3 * x - k1) + 4 * k2 * k3 * x));
}

double toeInv(double x) {
  const k1 = 0.206;
  const k2 = 0.03;
  const k3 = (1 + k1) / (1 + k2);
  return (x * x + k1 * x) / (k3 * (x + k2));
}

double computeMaxSaturation(double a, double b) {
  // Max saturation will be when one of r, g, or b goes below zero.

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
    k3 = 0.1254107;
    k4 = 0.14503204;
    wl = -1.2684380046;
    wm = 2.6097574011;
    ws = -0.3413193965;
  } else {
    // Blue component
    k0 = 1.35733652;
    k1 = -0.00915799;
    k2 = -1.1513021;
    k3 = -0.50559606;
    k4 = 0.00692167;
    wl = -0.0041960863;
    wm = -0.7034186147;
    ws = 1.707614701;
  }

  // Approximate max saturation using a polynomial:
  double s = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b;

  // Do one step Halley's method to get closer
  double kl = 0.3963377774 * a + 0.2158037573 * b;
  double km = -0.1055613458 * a - 0.0638541728 * b;
  double ks = -0.0894841775 * a - 1.291485548 * b;

  {
    double l_ = 1 + s * kl;
    double m_ = 1 + s * km;
    double s_ = 1 + s * ks;

    double l = l_ * l_ * l_;
    double m = m_ * m_ * m_;
    double sCube = s_ * s_ * s_;

    double ldS = 3 * kl * l_ * l_;
    double mdS = 3 * km * m_ * m_;
    double sdS = 3 * ks * s_ * s_;

    double ldS2 = 6 * kl * kl * l_;
    double mdS2 = 6 * km * km * m_;
    double sdS2 = 6 * ks * ks * s_;

    double f = wl * l + wm * m + ws * sCube;
    double f1 = wl * ldS + wm * mdS + ws * sdS;
    double f2 = wl * ldS2 + wm * mdS2 + ws * sdS2;

    s = s - (f * f1) / (f1 * f1 - 0.5 * f * f2);
  }

  return s;
}

List<double> findCusp(double a, double b) {
  // First, find the maximum saturation (saturation S = C/L)
  double sCusp = computeMaxSaturation(a, b);

  // Convert to linear sRGB to find the first point where at least one of r,g or b >= 1:
  Lrgb rgb = convertOklabToLrgb(OkLab(l: 1, a: sCusp * a, b: sCusp * b));
  double lCusp = pow((1 / [rgb.r, rgb.g, rgb.b].max), 1 / 3).toDouble();
  double cCusp = lCusp * sCusp;

  return [lCusp, cCusp];
}

double findGamutIntersection(double a, double b, double L1, double C1, double L0, [List<double>? cusp]) {
  final List<double> cusp0 = cusp ?? findCusp(a, b);

  // Find the intersection for upper and lower half separately
  double t;
  if ((L1 - L0) * cusp0[1] - (cusp0[0] - L0) * C1 <= 0) {
    // Lower half
    t = (cusp0[1] * L0) / (C1 * cusp0[0] + cusp0[1] * (L0 - L1));
  } else {
    // Upper half
    // First intersect with triangle
    t = (cusp0[1] * (L0 - 1)) / (C1 * (cusp0[0] - 1) + cusp0[1] * (L0 - L1));

    // Then one step Halley's method
    double dL = L1 - L0;
    double dC = C1;

    double kL = 0.3963377774 * a + 0.2158037573 * b;
    double kM = -0.1055613458 * a - 0.0638541728 * b;
    double kS = -0.0894841775 * a - 1.291485548 * b;

    double lDt = dL + dC * kL;
    double mDt = dL + dC * kM;
    double sDt = dL + dC * kS;

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

      double b = -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s - 1;
      double b1 = -0.0041960863 * ldt - 0.7034186147 * mdt + 1.707614701 * sdt;
      double b2 = -0.0041960863 * ldt2 - 0.7034186147 * mdt2 + 1.707614701 * sdt2;

      double uB = b1 / (b1 * b1 - 0.5 * b * b2);
      double tB = -b * uB;

      tR = uR >= 0 ? tR : 10e5;
      tG = uG >= 0 ? tG : 10e5;
      tB = uB >= 0 ? tB : 10e5;

      t += [tR, tG, tB].min;
    }
  }

  return t;
}

List<double> getStMax(double a, double b, [List<double>? cusp]) {
  final List<double> cusp0 = cusp ?? findCusp(a, b);
  double l = cusp0[0];
  double c = cusp0[1];
  return [c / l, c / (1 - l)];
}

List<double> getStMid(double a, double b) {
  double s =
      0.11516993 + 1 / (7.4477897 + 4.1590124 * b + a * (-2.19557347 + 1.75198401 * b + a * (-2.13704948 - 10.02301043 * b + a * (-4.24894561 + 5.38770819 * b + 4.69891013 * a))));
  double t =
      0.11239642 + 1 / (1.6132032 - 0.68124379 * b + a * (0.40370612 + 0.90148123 * b + a * (-0.27087943 + 0.6122399 * b + a * (0.00299215 - 0.45399568 * b - 0.14661872 * a))));
  return [s, t];
}

List<double> getCs(double L, double a, double b) {
  List<double> cusp = findCusp(a, b);

  double cMax = findGamutIntersection(a, b, L, 1, L, cusp);
  List<double> stMax = getStMax(a, b, cusp);

  double sMid =
      0.11516993 + 1 / (7.4477897 + 4.1590124 * b + a * (-2.19557347 + 1.75198401 * b + a * (-2.13704948 - 10.02301043 * b + a * (-4.24894561 + 5.38770819 * b + 4.69891013 * a))));

  double tMid =
      0.11239642 + 1 / (1.6132032 - 0.68124379 * b + a * (0.40370612 + 0.90148123 * b + a * (-0.27087943 + 0.6122399 * b + a * (0.00299215 - 0.45399568 * b - 0.14661872 * a))));

  double k = cMax / min(L * stMax[0], (1 - L) * stMax[1]);

  double cA = L * sMid;
  double cB = (1 - L) * tMid;
  double cMid = 0.9 * k * sqrt(sqrt(1 / (1 / (cA * cA * cA * cA) + 1 / (cB * cB * cB * cB))));

  cA = L * 0.4;
  cB = (1 - L) * 0.8;
  double c0 = sqrt(1 / (1 / (cA * cA) + 1 / (cB * cB)));
  return [c0, cMid, cMax];
}

double normalizeHue(double hue) => (hue % 360 + 360) % 360;

double interpolateHue(double start, double end, double fraction, {bool shortestPath = true}) {
  start = normalizeHue(start);
  end = normalizeHue(end);

  if (shortestPath && (end - start).abs() > 180) {
    if (end > start) {
      start += 360;
    } else {
      end += 360;
    }
  }

  return lerp(start, end, fraction) % 360;
}
