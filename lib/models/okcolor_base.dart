import 'dart:math' as math;

import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/converters/xyz_rgb.dart';

/// Represents a color in the Oklab color space.
/// L: Lightness, typically in range [0, 1]
/// a: Green-red component, typically in range [-0.5, 0.5]
/// b: Blue-yellow component, typically in range [-0.5, 0.5]
/// Example usage:
///   Lab lab = linearSrgbToOklab(RGB(0.5, 0.5, 0.5));
///   // lab components are used directly in calculations:
///   double C = math.sqrt(lab.a * lab.a + lab.b * lab.b);
class Lab {
  double L;
  double a;
  double b;
  Lab(this.L, this.a, this.b);

  RGB toRgb() {
    final rgb = okLabToLinearRgb(this);
    return linearRgbToRgb(rgb);
  }

  LCH toLch() {
    double C = math.sqrt(a * a + b * b);
    double h = 0.5 + 0.5 * math.atan2(-b, -a) / math.pi;

    // Ensure h is in the range [0, 2π]
    if (h < 0) {
      h += 2 * math.pi;
    }
    if (L < 1e-8) {
      h = 0;
    }

    return LCH(L, C, h);
  }
}

/// Represents a color in the RGB color space.
/// All components are typically in range [0, 1] for sRGB.
/// For linear RGB, values can exceed 1 for colors outside the sRGB gamut.
/// Example usage:
///   RGB rgb = oklabToLinearSrgb(Lab(0.5, 0.1, -0.1));
///   // Values are clamped when converting to sRGB:
///   double r_srgb = srgbTransferFunction(rgb.r);
class RGB {
  double r;
  double g;
  double b;
  RGB(this.r, this.g, this.b);

  Lab toLab() {
    final linear = rgbToLinearRgb(this);
    return linearRgbToOkLab(linear);
  }

  @override
  String toString() {
    return 'RGB($r, $g, $b)';
  }
}

/// Represents a color in the HSL (Hue, Saturation, Lightness) color space.
/// h: Hue, in range [0, 1] representing 0 to 360 degrees
/// s: Saturation, in range [0, 1]
/// l: Lightness, in range [0, 1]
/// Example usage:
///   HSL hsl = srgbToOkhsl(RGB(0.5, 0.5, 0.5));
///   // Hue is used in trigonometric functions:
///   double a_ = math.cos(2 * math.pi * hsl.h);
///   double b_ = math.sin(2 * math.pi * hsl.h);
class HSL {
  double h;
  double s;
  double l;
  HSL(this.h, this.s, this.l);

  @override
  String toString() {
    return 'HSL($h, $s, $l)';
  }
}

/// Represents a color in the HSV (Hue, Saturation, Value) color space.
/// h: Hue, in range [0, 1] representing 0 to 360 degrees
/// s: Saturation, in range [0, 1]
/// v: Value, in range [0, 1]
/// Example usage:
///   HSV hsv = srgbToOkhsv(RGB(0.5, 0.5, 0.5));
///   // Saturation and Value are used in calculations:
///   double L_v = 1 - hsv.s * S_0 / (S_0 + T_max - T_max * k * hsv.s);
///   double L = hsv.v * L_v;
class HSV {
  double h;
  double s;
  double v;
  HSV(this.h, this.s, this.v);

  @override
  String toString() {
    return 'HSV($h, $s, $v)';
  }
}

/// Represents Lightness and Chroma.
/// L: Lightness, typically in range [0, 1]
/// C: Chroma, can exceed 1 for highly saturated colors
/// Example usage:
///   LC cusp = findCusp(a_, b_);
///   // L and C are used in calculations:
///   double L_0 = cusp.L + 0.5 * (sgn(Ld) * (e1 - math.sqrt(e1 * e1 - 2 * k * math.abs(Ld))));
class LC {
  double L;
  double C;
  LC(this.L, this.C);
}

/// Represents a color in the OkLCH color space.
/// L: Lightness, typically in range [0, 1]
/// C: Chroma, non-negative value
/// h: Hue angle in radians, typically in range [0, 2π]
class LCH {
  double L;
  double C;
  double h;
  LCH(this.L, this.C, this.h);

  Lab toLab() {
    return Lab(L, C * math.cos(h), C * math.sin(h));
  }
}

/// Represents a color in the CIE XYZ color space.
/// X: X coordinate
/// Y: Y coordinate
/// Z: Z coordinate
class XYZ {
  double X;
  double Y;
  double Z;

  XYZ(this.X, this.Y, this.Z);
}

/// Alternative representation of (L_cusp, C_cusp)
/// Encoded so S = C_cusp/L_cusp and T = C_cusp/(1-L_cusp)
/// The maximum value for C in the triangle is then found as min(S*L, T*(1-L)), for a given L
///
/// Represents Saturation and Tone.
/// S: Saturation, typically in range [0, 1] but can exceed 1
/// T: Tone, typically in range [0, 1] but can exceed 1
/// Example usage:
///   ST ST_max = toST(cusp);
///   // S and T are used in calculations:
///   double k = 1 - S_0 / ST_max.S;
///   double C_v = s * ST_max.T * S_0 / (S_0 + ST_max.T - ST_max.T * k * s);
class ST {
  double S;
  double T;
  ST(this.S, this.T);
}

/// Represents different levels of Chroma (color intensity).
/// All values are typically non-negative.
/// C_0: Minimum chroma
/// C_mid: Middle chroma
/// C_max: Maximum chroma
/// Example usage:
///   Cs cs = getCs(L, a_, b_);
///   // Different chroma levels are used in interpolation:
///   double C = k_0 + t * k_1 / (1 - k_2 * t);
///   // where k_0, k_1, k_2 are derived from cs.C_0, cs.C_mid, and cs.C_max
class Cs {
  double C_0;
  double C_mid;
  double C_max;
  Cs(this.C_0, this.C_mid, this.C_max);
}
