import 'dart:math' as math;

import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/utils/rgb_gamut_intersection.dart';

import '../models/okcolor_base.dart';

// Source: https://bottosson.github.io/posts/gamutclipping/#gamut-clipping-2

double clamp(double x, double min, double max) {
  if (x < min) return min;
  if (x > max) return max;
  return x;
}

double sgn(double x) {
  return (x > 0 ? 1 : 0) - (x < 0 ? 1 : 0);
}

RGB gamutClipPreserveChroma(RGB rgb) {
  if (rgb.r < 1 && rgb.g < 1 && rgb.b < 1 && rgb.r > 0 && rgb.g > 0 && rgb.b > 0) {
    return rgb;
  }

  Lab lab = linearRgbToOkLab(rgb);

  double L = lab.L;
  double eps = 0.00001;
  double C = math.max(eps, math.sqrt(lab.a * lab.a + lab.b * lab.b));
  double a_ = lab.a / C;
  double b_ = lab.b / C;

  double L0 = clamp(L, 0, 1);

  double t = findGamutIntersectionSimple(a_, b_, L, C, L0);
  double lClipped = L0 * (1 - t) + t * L;
  double cClipped = t * C;

  return okLabToLinearRgb(Lab(lClipped, cClipped * a_, cClipped * b_));
}

RGB gamutClipProjectTo05(RGB rgb) {
  if (rgb.r < 1 && rgb.g < 1 && rgb.b < 1 && rgb.r > 0 && rgb.g > 0 && rgb.b > 0) {
    return rgb;
  }

  Lab lab = linearRgbToOkLab(rgb);

  double L = lab.L;
  double eps = 0.00001;
  double C = math.max(eps, math.sqrt(lab.a * lab.a + lab.b * lab.b));
  double a_ = lab.a / C;
  double b_ = lab.b / C;

  double L0 = 0.5;

  double t = findGamutIntersectionSimple(a_, b_, L, C, L0);
  double lClipped = L0 * (1 - t) + t * L;
  double cClipped = t * C;

  return okLabToLinearRgb(Lab(lClipped, cClipped * a_, cClipped * b_));
}

RGB gamutClipProjectToLCusp(RGB rgb) {
  if (rgb.r < 1 && rgb.g < 1 && rgb.b < 1 && rgb.r > 0 && rgb.g > 0 && rgb.b > 0) {
    return rgb;
  }

  Lab lab = linearRgbToOkLab(rgb);

  double L = lab.L;
  double eps = 0.00001;
  double C = math.max(eps, math.sqrt(lab.a * lab.a + lab.b * lab.b));
  double a_ = lab.a / C;
  double b_ = lab.b / C;

  // The cusp is computed here and in find_gamut_intersection, an optimized solution would only compute it once.
  LC cusp = findCusp(a_, b_);

  double L0 = cusp.L;

  double t = findGamutIntersection(a_, b_, L, C, L0, cusp);

  double lClipped = L0 * (1 - t) + t * L;
  double cClipped = t * C;

  return okLabToLinearRgb(Lab(lClipped, cClipped * a_, cClipped * b_));
}

RGB gamutClipAdaptiveL005(RGB rgb, {double alpha = 0.05}) {
  if (rgb.r < 1 && rgb.g < 1 && rgb.b < 1 && rgb.r > 0 && rgb.g > 0 && rgb.b > 0) {
    return rgb;
  }

  Lab lab = linearRgbToOkLab(rgb);

  double L = lab.L;
  double eps = 0.00001;
  double C = math.max(eps, math.sqrt(lab.a * lab.a + lab.b * lab.b));
  double a_ = lab.a / C;
  double b_ = lab.b / C;

  double Ld = L - 0.5;
  double e1 = 0.5 + Ld.abs() + alpha * C;
  double L0 = 0.5 * (1 + sgn(Ld) * (e1 - math.sqrt(e1 * e1 - 2 * Ld.abs())));

  double t = findGamutIntersectionSimple(a_, b_, L, C, L0);
  double lClipped = L0 * (1 - t) + t * L;
  double cClipped = t * C;

  return okLabToLinearRgb(Lab(lClipped, cClipped * a_, cClipped * b_));
}

RGB gamutClipAdaptiveL0LCusp(RGB rgb, {double alpha = 0.05}) {
  if (rgb.r < 1 && rgb.g < 1 && rgb.b < 1 && rgb.r > 0 && rgb.g > 0 && rgb.b > 0) {
    return rgb;
  }

  Lab lab = linearRgbToOkLab(rgb);

  double L = lab.L;
  double eps = 0.00001;
  double C = math.max(eps, math.sqrt(lab.a * lab.a + lab.b * lab.b));
  double a_ = lab.a / C;
  double b_ = lab.b / C;

  // The cusp is computed here and in find_gamut_intersection, an optimized solution would only compute it once.
  LC cusp = findCusp(a_, b_);

  double Ld = L - cusp.L;
  double k = 2 * (Ld > 0 ? 1 - cusp.L : cusp.L);

  double e1 = 0.5 * k + Ld.abs() + alpha * C / k;
  double L0 = cusp.L + 0.5 * (sgn(Ld) * (e1 - math.sqrt(e1 * e1 - 2 * k * Ld.abs())));

  double t = findGamutIntersection(a_, b_, L, C, L0, cusp);
  double lClipped = L0 * (1 - t) + t * L;
  double cClipped = t * C;

  return okLabToLinearRgb(Lab(lClipped, cClipped * a_, cClipped * b_));
}
