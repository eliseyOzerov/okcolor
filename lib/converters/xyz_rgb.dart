import 'dart:math' as math;

import 'package:okcolor/models/misc.dart';
import 'package:vector_math/vector_math_64.dart';

// Source: https://en.wikipedia.org/wiki/SRGB#Transformation

/// Converts linear sRGB to sRGB (gamma correction)
///
/// RGB components must be in the range [0, 1]
RGB linearRgbToRgb(RGB rgb) {
  double cTranform(double cLinear) {
    if (cLinear <= 0.0031308) {
      return 12.92 * cLinear;
    } else {
      return 1.055 * math.pow(cLinear, 1.0 / 2.4) - 0.055;
    }
  }

  return RGB(cTranform(rgb.r), cTranform(rgb.g), cTranform(rgb.b));
}

/// Converts sRGB to linear sRGB (gamma correction)
///
/// RGB components must be in the range [0, 1]
RGB rgbToLinearRgb(RGB rgb) {
  double cTransform(double csRgb) {
    if (csRgb <= 0.04045) {
      return csRgb / 12.92;
    } else {
      return math.pow((csRgb + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  return RGB(cTransform(rgb.r), cTransform(rgb.g), cTransform(rgb.b));
}

// sRGB (linear) to CIE XYZ matrix
final Matrix3 linearRgbToXyzMatrix = Matrix3(0.4124, 0.3576, 0.1805, 0.2126, 0.7152, 0.0722, 0.0193, 0.1192, 0.9505);

// CIE XYZ to sRGB (linear) matrix
final Matrix3 xyzToLinearRgbMatrix = Matrix3(3.2406, -1.5372, -0.4986, -0.9689, 1.8758, 0.0415, 0.0557, -0.2040, 1.0570);

// Function to convert linear sRGB to XYZ
XYZ linearRgbToXyz(RGB rgb) {
  Vector3 result = linearRgbToXyzMatrix.transformed(Vector3(rgb.r, rgb.g, rgb.b));
  return XYZ(result.x, result.y, result.z);
}

// Function to convert XYZ to linear sRGB
RGB xyzToLinearRgb(XYZ xyz) {
  Vector3 result = xyzToLinearRgbMatrix.transformed(Vector3(xyz.X, xyz.Y, xyz.Z));
  return RGB(result.x, result.y, result.z);
}
