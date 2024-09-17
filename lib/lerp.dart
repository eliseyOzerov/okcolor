double lerp(double a, double b, double t) => a + t * (b - a);
double unlerp(double a, double b, double v) => (v - a) / (b - a);

double blerp(double a00, double a01, double a10, double a11, double tx, double ty) {
  return lerp(lerp(a00, a01, tx), lerp(a10, a11, tx), ty);
}

double trilerp(double a000, double a010, double a100, double a110, double a001, double a011, double a101, double a111, double tx, double ty, double tz) {
  return lerp(blerp(a000, a010, a100, a110, tx, ty), blerp(a001, a011, a101, a111, tx, ty), tz);
}
