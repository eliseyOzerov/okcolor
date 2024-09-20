import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/converters/xyz_rgb.dart';
import 'package:okcolor/models/oklab.dart';

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

  OkLab toLab() {
    final linear = rgbToLinearRgb(this);
    return linearRgbToOkLab(linear);
  }

  @override
  String toString() {
    return 'RGB($r, $g, $b)';
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
