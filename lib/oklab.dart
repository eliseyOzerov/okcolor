import 'dart:math';

import 'okcolor.dart';

// ✅
Lrgb convertOklabToLrgb(OkLab lab) {
  double l = lab.l;
  double a = lab.a;
  double b = lab.b;

  double L = pow(l * 0.99999999845051981432 + 0.39633779217376785678 * a + 0.21580375806075880339 * b, 3).toDouble();
  double M = pow(l * 1.0000000088817607767 - 0.1055613423236563494 * a - 0.063854174771705903402 * b, 3).toDouble();
  double S = pow(l * 1.0000000546724109177 - 0.089484182094965759684 * a - 1.2914855378640917399 * b, 3).toDouble();

  double r_ = 4.076741661347994 * L - 3.307711590408193 * M + 0.230969928729428 * S;
  double g_ = -1.2684380040921763 * L + 2.6097574006633715 * M - 0.3413193963102197 * S;

  double b_ = -0.004196086541837188 * L - 0.7034186144594493 * M + 1.7076147009309444 * S;

  return Lrgb(r: r_, g: g_, b: b_, alpha: lab.alpha);
}

// ✅
OkLab convertLrgbToOklab(Lrgb lrgb) {
  double r = lrgb.r;
  double g = lrgb.g;
  double b = lrgb.b;

  double L = pow(0.41222147079999993 * r + 0.5363325363 * g + 0.0514459929 * b, 1 / 3).toDouble();
  double M = pow(0.2119034981999999 * r + 0.6806995450999999 * g + 0.1073969566 * b, 1 / 3).toDouble();
  double S = pow(0.08830246189999998 * r + 0.2817188376 * g + 0.6299787005000002 * b, 1 / 3).toDouble();

  double l_ = 0.2104542553 * L + 0.793617785 * M - 0.0040720468 * S;
  double a_ = 1.9779984951 * L - 2.428592205 * M + 0.4505937099 * S;
  double b_ = 0.0259040371 * L + 0.7827717662 * M - 0.808675766 * S;

  return OkLab(l: l_, a: a_, b: b_, alpha: lrgb.alpha);
}
