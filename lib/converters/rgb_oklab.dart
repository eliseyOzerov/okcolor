import 'dart:math' as math;

import 'package:okcolor/models/okcolor_base.dart';
import 'package:vector_math/vector_math.dart';

// Source: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab

// Define the matrices
final Matrix3 m1 = Matrix3(0.4122214708, 0.2119034982, 0.0883024619, 0.5363325363, 0.6806995451, 0.2817188376, 0.0514459929, 0.1073969566, 0.6299787005);

final Matrix3 m2 = Matrix3(0.2104542553, 1.9779984951, 0.0259040371, 0.7936177850, -2.4285922050, 0.7827717662, -0.0040720468, 0.4505937099, -0.8086757660);

// Compute inverse matrices
final Matrix3 m1Inverse = m1.clone()..invert();
final Matrix3 m2Inverse = m2.clone()..invert();

Lab linearRgbToOkLab(RGB rgb) {
  // Convert RGB to Vector3
  final rgbVector = Vector3(rgb.r, rgb.g, rgb.b);

  // First matrix multiplication
  final lms = m1.transformed(rgbVector);

  // Apply cube root
  final lmsCubeRoot = Vector3(
    math.pow(lms.x.abs(), 1 / 3) * (lms.x < 0 ? -1 : 1),
    math.pow(lms.y.abs(), 1 / 3) * (lms.y < 0 ? -1 : 1),
    math.pow(lms.z.abs(), 1 / 3) * (lms.z < 0 ? -1 : 1),
  );

  // Second matrix multiplication
  final lab = m2.transformed(lmsCubeRoot);

  return Lab(lab.x, lab.y, lab.z);
}

RGB okLabToLinearRgb(Lab lab) {
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
