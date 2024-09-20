import 'dart:math' as math;

import 'package:okcolor/converters/xyz_rgb.dart';
import 'package:okcolor/models/okcolor_base.dart';
import 'package:vector_math/vector_math.dart';

// Source: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab

// Define the matrices
final Matrix3 m1 = Matrix3(0.4122214708, 0.2119034982, 0.0883024619, 0.5363325363, 0.6806995451, 0.2817188376, 0.0514459929, 0.1073969566, 0.6299787005);

final Matrix3 m2 = Matrix3(0.2104542553, 1.9779984951, 0.0259040371, 0.7936177850, -2.4285922050, 0.7827717662, -0.0040720468, 0.4505937099, -0.8086757660);

// Compute inverse matrices
final Matrix3 m1Inverse = m1.clone()..invert();
final Matrix3 m2Inverse = m2.clone()..invert();

OkLab rgbToOkLab(RGB rgb) {
  final linear = rgbToLinearRgb(rgb);
  return linearRgbToOkLab(linear);
}

RGB okLabToRgb(OkLab lab) {
  final linear = okLabToLinearRgb(lab);
  return linearRgbToRgb(linear);
}

OkLab linearRgbToOkLab(RGB rgb) {
  // Convert RGB to Vector3
  final rgbVector = Vector3(rgb.r, rgb.g, rgb.b);

  // First matrix multiplication
  final lms = m1.transformed(rgbVector);

  // Apply cube root
  final lmsCubeRoot = Vector3(
    math.pow(lms.x.abs(), 1 / 3).toDouble(),
    math.pow(lms.y.abs(), 1 / 3).toDouble(),
    math.pow(lms.z.abs(), 1 / 3).toDouble(),
  );

  // Second matrix multiplication
  final lab = m2.transformed(lmsCubeRoot);

  return OkLab(lab.x, lab.y, lab.z);
}

RGB okLabToLinearRgb(OkLab lab) {
  // Convert Lab to Vector3
  final labVector = Vector3(lab.L, lab.a, lab.b);

  // First inverse matrix multiplication
  final lmsCubeRoot = m2Inverse.transformed(labVector);

  // Apply cube
  final lms = Vector3(
    math.pow(lmsCubeRoot.x, 3).toDouble(),
    math.pow(lmsCubeRoot.y, 3).toDouble(),
    math.pow(lmsCubeRoot.z, 3).toDouble(),
  );

  // Second inverse matrix multiplication
  final rgb = m1Inverse.transformed(lms);

  return RGB(rgb.x, rgb.y, rgb.z);
}

OkLab linearRgbToOkLabManual(RGB c) {
  double l = 0.4122214708 * c.r + 0.5363325363 * c.g + 0.0514459929 * c.b;
  double m = 0.2119034982 * c.r + 0.6806995451 * c.g + 0.1073969566 * c.b;
  double s = 0.0883024619 * c.r + 0.2817188376 * c.g + 0.6299787005 * c.b;

  double l_ = math.pow(l, 1 / 3).toDouble();
  double m_ = math.pow(m, 1 / 3).toDouble();
  double s_ = math.pow(s, 1 / 3).toDouble();

  return OkLab(
    0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
    1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
    0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
  );
}

RGB okLabToLinearRgbManual(OkLab c) {
  double l_ = c.L + 0.3963377774 * c.a + 0.2158037573 * c.b;
  double m_ = c.L - 0.1055613458 * c.a - 0.0638541728 * c.b;
  double s_ = c.L - 0.0894841775 * c.a - 1.2914855480 * c.b;

  double l = l_ * l_ * l_;
  double m = m_ * m_ * m_;
  double s = s_ * s_ * s_;

  return RGB(
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  );
}
