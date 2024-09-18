import 'dart:math' as math;

import '../models/okcolor_base.dart';

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
