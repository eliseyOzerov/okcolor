import 'dart:math' as math;

import 'package:okcolor/models/misc.dart';
import 'package:okcolor/utils/rgb_gamut_intersection.dart';

// Source: https://bottosson.github.io/posts/colorpicker/#common-code

double toe(double x) {
  const double k1 = 0.206;
  const double k2 = 0.03;
  const double k3 = (1 + k1) / (1 + k2);
  return 0.5 * (k3 * x - k1 + math.sqrt((k3 * x - k1) * (k3 * x - k1) + 4 * k2 * k3 * x));
}

double toeInv(double x) {
  const double k1 = 0.206;
  const double k2 = 0.03;
  const double k3 = (1 + k1) / (1 + k2);
  return (x * x + k1 * x) / (k3 * (x + k2));
}

ST toST(LC cusp) {
  double L = cusp.L;
  double C = cusp.C;
  return ST(C / L, C / (1 - L));
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

// Returns the chroma values for the given L, a, and b values
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
