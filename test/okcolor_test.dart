import 'package:flutter_test/flutter_test.dart';
import 'package:okcolor/converters/rgb_okhsl.dart';
import 'package:okcolor/converters/rgb_okhsv.dart';
import 'package:okcolor/converters/rgb_oklab.dart';
import 'package:okcolor/converters/xyz_rgb.dart';
import 'package:okcolor/models/okcolor_base.dart';
import 'package:okcolor/utils/common.dart';
import 'package:okcolor/utils/rgb_gamut_intersection.dart';

void main() {
  test('RGB to Linear RGB and back', () {
    final testCases = [
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      [1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
      [1.0, 0.0, 0.0, 1.0, 0.0, 0.0],
      [0.0, 1.0, 0.0, 0.0, 1.0, 0.0],
      [0.0, 0.0, 1.0, 0.0, 0.0, 1.0],
      [1.0, 1.0, 0.0, 1.0, 1.0, 0.0],
      [0.0, 1.0, 1.0, 0.0, 1.0, 1.0],
      [1.0, 0.0, 1.0, 1.0, 0.0, 1.0],
      [0.5, 0.5, 0.5, 0.214041, 0.214041, 0.214041],
      [0.7, 0.2, 0.3, 0.447988, 0.033105, 0.073239],
      [0.1, 0.8, 0.6, 0.010023, 0.603827, 0.318547],
      [0.9, 0.1, 0.5, 0.787412, 0.010023, 0.214041],
      [0.3, 0.6, 0.1, 0.073239, 0.318547, 0.010023],
      [0.2, 0.4, 0.8, 0.033105, 0.132868, 0.603827],
      [0.8, 0.5, 0.2, 0.603827, 0.214041, 0.033105],
      [0.6, 0.4, 0.7, 0.318547, 0.132868, 0.447988],
      [0.1, 0.1, 0.1, 0.010023, 0.010023, 0.010023],
      [0.9, 0.9, 0.9, 0.787412, 0.787412, 0.787412],
      [0.5, 0.0, 0.5, 0.214041, 0.0, 0.214041],
      [0.0, 0.5, 0.5, 0.0, 0.214041, 0.214041],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final rgb = RGB(testCase[0], testCase[1], testCase[2]);
        final expectedLinearRgb = RGB(testCase[3], testCase[4], testCase[5]);

        final linearRgb = rgbToLinearRgb(rgb);
        expect(linearRgb.r, closeTo(expectedLinearRgb.r, 1e-6));
        expect(linearRgb.g, closeTo(expectedLinearRgb.g, 1e-6));
        expect(linearRgb.b, closeTo(expectedLinearRgb.b, 1e-6));

        final convertedRgb = linearRgbToRgb(linearRgb);
        expect(convertedRgb.r, closeTo(rgb.r, 1e-6));
        expect(convertedRgb.g, closeTo(rgb.g, 1e-6));
        expect(convertedRgb.b, closeTo(rgb.b, 1e-6));
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('computeMaxSaturation', () {
    final List<List<double>> testCases = [
      [1.0, 0.0, 0.405391],
      [-0.5, 0.866025, 0.237417],
      [-0.5, -0.866025, 0.229061],
      [0.5, 0.866025, 0.234513],
      [-1.0, 0.0, 0.181430],
      [0.5, -0.866025, 0.533082],
      [0.707107, 0.707107, 0.285900],
      [-0.707107, 0.707107, 0.292061],
      [-0.707107, -0.707107, 0.189467],
      [0.707107, -0.707107, 0.492243],
      [0.0, 1.0, 0.204357],
      [0.0, -1.0, 0.655372],
      [1.0, 1.0, 0.110804], // WARNING: Input not normalized, a^2 + b^2 = 2.000000
      [-1.0, -1.0, 0.133977], // WARNING: Input not normalized, a^2 + b^2 = 2.000000
      [0.0, 0.0, double.nan], // WARNING: Input not normalized, a^2 + b^2 = 0.000000
      [0.866025, 0.5, 0.401059],
      [-0.866025, 0.5, 0.275397],
      [-0.866025, -0.5, 0.172948],
      [0.866025, -0.5, 0.455754],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final a = testCase[0];
        final b = testCase[1];
        final expected = testCase[2];

        final result = computeMaxSaturation(a, b);
        if (expected.isNaN) {
          expect(result.isNaN, isTrue);
        } else {
          expect(result, closeTo(expected, 1e-6));
        }
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('findCusp', () {
    final List<List<double>> testCases = [
      [1.0, 0.0, 0.647704, 0.262574],
      [-0.5, 0.866025, 0.939571, 0.223070],
      [-0.5, -0.866025, 0.717402, 0.164329],
      [0.5, 0.866025, 0.756457, 0.177399],
      [-1.0, 0.0, 0.895963, 0.162555],
      [0.5, -0.866025, 0.552545, 0.294552],
      [0.707107, 0.707107, 0.701853, 0.200660],
      [-0.707107, 0.707107, 0.893696, 0.261014],
      [-0.707107, -0.707107, 0.782650, 0.148286],
      [0.707107, -0.707107, 0.620074, 0.305227],
      [0.0, 1.0, 0.863629, 0.176489],
      [0.0, -1.0, 0.464921, 0.304696],
      [0.0, 0.0, double.nan, double.nan], // WARNING: Input not normalized, a^2 + b^2 = 0.000000
      [0.866025, 0.5, 0.632284, 0.253583],
      [-0.866025, 0.5, 0.873998, 0.240697],
      [-0.866025, -0.5, 0.841330, 0.145506],
      [0.866025, -0.5, 0.697316, 0.317805],
      [1.0, 1.0, 0.796463, 0.088252], // WARNING: Input not normalized, a^2 + b^2 = 2.000000
      [-2.0, -2.0, 0.240156, 0.218149], // WARNING: Input not normalized, a^2 + b^2 = 8.000000
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final a = testCase[0];
        final b = testCase[1];
        final expectedLcusp = testCase[2];
        final expectedCcusp = testCase[3];

        final result = findCusp(a, b);
        if (expectedLcusp.isNaN) {
          expect(result.L.isNaN, isTrue);
        } else {
          expect(result.L, closeTo(expectedLcusp, 1e-6));
        }
        if (expectedCcusp.isNaN) {
          expect(result.C.isNaN, isTrue);
        } else {
          expect(result.C, closeTo(expectedCcusp, 1e-6));
        }
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('findGamutIntersection', () {
    final testCases = [
      [1.0, 0.0, 0.5, 0.1, 0.7, 0.8, 0.3, 1.5],
      [0.0, 1.0, 0.6, 0.2, 0.4, 0.7, 0.2, 0.8],
      [-1.0, 0.0, 0.3, 0.05, 0.8, 0.9, 0.1, 0.842105],
      [0.0, -1.0, 0.7, 0.15, 0.5, 0.6, 0.25, 1.024120],
      [0.707107, 0.707107, 0.4, 0.3, 0.6, 0.75, 0.35, 0.711864],
      [-0.707107, 0.707107, 0.8, 0.1, 0.2, 0.5, 0.4, 1.236430],
      [0.5, -0.866025, 0.55, 0.25, 0.65, 0.85, 0.15, 0.428571],
      [-0.866025, -0.5, 0.35, 0.18, 0.75, 0.95, 0.05, 0.196335],
      [1.0, 0.0, 1.0, 0.5, 0.0, 0.8, 0.3, 0.0],
      [0.0, 1.0, 0.0, 0.5, 1.0, 0.7, 0.2, 0.363636],
      [1.0, 0.0, 0.5, 0.0, 0.5, 0.8, 0.3, double.infinity],
      [0.0, 1.0, 0.5, 1.0, 0.5, 0.7, 0.2, 0.142857],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final a = testCase[0];
        final b = testCase[1];
        final L1 = testCase[2];
        final C1 = testCase[3];
        final L0 = testCase[4];
        final cuspL = testCase[5];
        final cuspC = testCase[6];
        final expected = testCase[7];

        final result = findGamutIntersection(a, b, L1, C1, L0, LC(cuspL, cuspC));
        if (expected.isInfinite) {
          expect(result.isInfinite, isTrue);
        } else {
          expect(result, closeTo(expected, 1e-6));
        }
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('toe', () {
    final testCases = [
      [0.0, 0.0],
      [0.5, 0.421141],
      [1.0, 1.0],
      [0.25, 0.146614],
      [0.75, 0.709297],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final input = testCase[0];
        final expected = testCase[1];

        final result = toe(input);
        expect(result, closeTo(expected, 1e-6));
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('toe_inv', () {
    final testCases = [
      [0.0, 0.0],
      [0.5, 0.568838],
      [1.0, 1.0],
      [0.25, 0.347726],
      [0.75, 0.785081],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final input = testCase[0];
        final expected = testCase[1];

        final result = toeInv(input);
        expect(result, closeTo(expected, 1e-6));
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('to_ST', () {
    final testCases = [
      [0.5, 0.5, 1.0, 1.0],
      [0.75, 0.25, 0.333333, 1.0],
      [0.25, 0.75, 3.0, 1.0],
      [0.1, 0.9, 9.0, 1.0],
      [0.9, 0.1, 0.111111, 1.0],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final L = testCase[0];
        final C = testCase[1];
        final expectedS = testCase[2];
        final expectedT = testCase[3];

        final result = toST(LC(L, C));
        expect(result.S, closeTo(expectedS, 1e-6));
        expect(result.T, closeTo(expectedT, 1e-6));
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('get_ST_mid', () {
    final testCases = [
      [0.0, 0.0, 0.249438, 0.732281],
      [1.0, 0.0, 0.395665, 0.736459],
      [0.0, 1.0, 0.201326, 1.185405],
      [-1.0, 0.0, 0.175945, 1.379813],
      [0.0, -1.0, 0.419234, 0.548231],
      [0.5, 0.5, 0.254452, 0.710679],
      [-0.5, -0.5, 0.229011, 0.669444],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final a = testCase[0];
        final b = testCase[1];
        final expectedS = testCase[2];
        final expectedT = testCase[3];

        final result = getSTMid(a, b);
        expect(result.S, closeTo(expectedS, 1e-6));
        expect(result.T, closeTo(expectedT, 1e-6));
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('get_Cs', () {
    final testCases = [
      [0.5, 0.0, 0.0, 0.178885, double.nan, double.nan],
      [0.5, 1.0, 0.0, 0.178885, 0.174522, 0.202696],
      [0.5, 0.0, 1.0, 0.178885, 0.090578, 0.102179],
      [0.5, -1.0, 0.0, 0.178885, 0.079170, 0.090715],
      [0.5, 0.0, -1.0, 0.178885, 0.173104, 0.281184],
      [0.25, 0.5, 0.5, 0.098639, 0.057249, 0.105430],
      [0.75, -0.5, -0.5, 0.166410, 0.128270, 0.201008],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final L = testCase[0];
        final a = testCase[1];
        final b = testCase[2];
        final expectedC0 = testCase[3];
        final expectedCmid = testCase[4];
        final expectedCmax = testCase[5];

        final result = getCs(L, a, b);
        expect(result.C_0, closeTo(expectedC0, 1e-6));
        if (expectedCmid.isNaN) {
          expect(result.C_mid.isNaN, isTrue);
        } else {
          expect(result.C_mid, closeTo(expectedCmid, 1e-6));
        }
        if (expectedCmax.isNaN) {
          expect(result.C_max.isNaN, isTrue);
        } else {
          expect(result.C_max, closeTo(expectedCmax, 1e-6));
        }
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('RGB to LAB and back', () {
    final List<List> testCases = [
      [RGB(0.0, 0.0, 0.0), Lab(0.0, 0.0, 0.0)],
      [RGB(1.0, 1.0, 1.0), Lab(1.0, 0.0, 0.0)],
      [RGB(1.0, 0.0, 0.0), Lab(0.627955, 0.224863, 0.125846)],
      [RGB(0.0, 1.0, 0.0), Lab(0.866440, -0.233887, 0.179498)],
      [RGB(0.0, 0.0, 1.0), Lab(0.452014, -0.032457, -0.311528)],
      [RGB(1.0, 1.0, 0.0), Lab(0.967983, -0.071369, 0.198570)],
      [RGB(0.0, 1.0, 1.0), Lab(0.905399, -0.149444, -0.03939)],
      [RGB(1.0, 0.0, 1.0), Lab(0.701674, 0.274566, -0.169156)],
      [RGB(0.5, 0.5, 0.5), Lab(0.598181, 0.0, 0.0)],
      [RGB(0.7, 0.2, 0.3), Lab(0.519632, 0.158814, 0.03801)],
      [RGB(0.1, 0.8, 0.6), Lab(0.751552, -0.146994, 0.03540)],
      [RGB(0.9, 0.1, 0.5), Lab(0.606135, 0.236190, -0.00521)],
      [RGB(0.3, 0.6, 0.1), Lab(0.610136, -0.124724, 0.11867)],
      [RGB(0.2, 0.4, 0.8), Lab(0.532483, -0.022512, -0.16634)],
      [RGB(0.8, 0.5, 0.2), Lab(0.665835, 0.061456, 0.11460)],
      [RGB(0.6, 0.4, 0.7), Lab(0.594006, 0.086594, -0.09057)],
      [RGB(0.1, 0.1, 0.1), Lab(0.215607, 0.0, -0.0)],
      [RGB(0.9, 0.9, 0.9), Lab(0.923423, 0.0, -0.0)],
      [RGB(0.5, 0.0, 0.5), Lab(0.419728, 0.164240, -0.10118)],
      [RGB(0.0, 0.5, 0.5), Lab(0.541592, -0.089394, -0.02356)],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final rgb = testCase[0];
        final expectedLab = testCase[1];

        final lab = rgbToOkLab(rgb);

        expect(lab.L, closeTo(expectedLab.L, 1e-5)); // reduced precision due to floating point errors
        expect(lab.a, closeTo(expectedLab.a, 1e-5));
        expect(lab.b, closeTo(expectedLab.b, 1e-5));

        final rgbOut = okLabToRgb(lab);

        expect(rgbOut.r, closeTo(rgb.r, 1e-5));
        expect(rgbOut.g, closeTo(rgb.g, 1e-5));
        expect(rgbOut.b, closeTo(rgb.b, 1e-5));
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('sRGB to OkHSL and back', () {
    final List<List> testCases = [
      [RGB(0.0, 0.0, 0.0), HSL(0.0, 0, 0.0)],
      [RGB(1.0, 1.0, 1.0), HSL(0.25, 0, 1.0)],
      [RGB(1.0, 0.0, 0.0), HSL(0.081205, 1.0, 0.568085)],
      [RGB(0.0, 1.0, 0.0), HSL(0.395820, 1.0, 0.844529)],
      [RGB(0.0, 0.0, 1.0), HSL(0.733478, 1.0, 0.366565)],
      [RGB(1.0, 1.0, 0.0), HSL(0.304915, 1.0, 0.962704)],
      [RGB(0.0, 1.0, 1.0), HSL(0.541025, 1.0, 0.889848)],
      [RGB(1.0, 0.0, 1.0), HSL(0.912121, 1.000039, 0.653299)],
      [RGB(0.5, 0.5, 0.5), HSL(0.136387, 0.0, 0.533760)],
      [RGB(0.7, 0.2, 0.3), HSL(0.037391, 0.775071, 0.443573)],
      [RGB(0.1, 0.8, 0.6), HSL(0.462387, 0.962914, 0.711097)],
      [RGB(0.9, 0.1, 0.5), HSL(0.996487, 0.949953, 0.542923)],
      [RGB(0.3, 0.6, 0.1), HSL(0.378954, 0.971604, 0.547534)],
      [RGB(0.2, 0.4, 0.8), HSL(0.728592, 0.825065, 0.458283)],
      [RGB(0.8, 0.5, 0.2), HSL(0.171661, 0.775658, 0.611836)],
      [RGB(0.6, 0.4, 0.7), HSL(0.871421, 0.531781, 0.528952)],
      [RGB(0.1, 0.1, 0.1), HSL(0.985120, 0.0, 0.113296)],
      [RGB(0.9, 0.9, 0.9), HSL(0.976477, 0.000002, 0.910824)],
      [RGB(0.5, 0.0, 0.5), HSL(0.912121, 1.000620, 0.330110)],
      [RGB(0.0, 0.5, 0.5), HSL(0.541025, 0.999999, 0.468723)],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final rgb = testCase[0];
        final expectedHsl = testCase[1];

        final hsl = rgbToOkHsl(rgb);

        expect(hsl.h, closeTo(expectedHsl.h, 1e-5)); // reduced precision due to floating point errors
        expect(hsl.s, closeTo(expectedHsl.s, 1e-5));
        expect(hsl.l, closeTo(expectedHsl.l, 1e-5));

        final rgbOut = okHslToSrgb(hsl);

        expect(rgbOut.r, closeTo(rgb.r, 1e-5));
        expect(rgbOut.g, closeTo(rgb.g, 1e-5));
        expect(rgbOut.b, closeTo(rgb.b, 1e-5));
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });

  test('sRGB to OkHSV and back', () {
    final List<List> testCases = [
      [RGB(0.0, 0.0, 0.0), HSV(0.000000, 0.000000, 0.000000)],
      [RGB(1.0, 1.0, 1.0), HSV(0.250000, 0.000000, 1.000000)],
      [RGB(1.0, 0.0, 0.0), HSV(0.081205, 1.000000, 1.000000)],
      [RGB(0.0, 1.0, 0.0), HSV(0.395820, 1.000000, 1.000000)],
      [RGB(0.0, 0.0, 1.0), HSV(0.733478, 0.999991, 1.000000)],
      [RGB(1.0, 1.0, 0.0), HSV(0.304915, 1.000000, 1.000000)],
      [RGB(0.0, 1.0, 1.0), HSV(0.541025, 1.000000, 1.000000)],
      [RGB(1.0, 0.0, 1.0), HSV(0.912121, 1.000122, 1.000000)],
      [RGB(0.5, 0.5, 0.5), HSV(0.136387, 0.000000, 0.533760)],
      [RGB(0.7, 0.2, 0.3), HSV(0.037391, 0.834492, 0.711834)],
      [RGB(0.1, 0.8, 0.6), HSV(0.462387, 0.954817, 0.816986)],
      [RGB(0.9, 0.1, 0.5), HSV(0.996487, 0.969158, 0.905012)],
      [RGB(0.3, 0.6, 0.1), HSV(0.378954, 0.920810, 0.626223)],
      [RGB(0.2, 0.4, 0.8), HSV(0.728592, 0.782249, 0.807227)],
      [RGB(0.8, 0.5, 0.2), HSV(0.171661, 0.810606, 0.813831)],
      [RGB(0.6, 0.4, 0.7), HSV(0.871421, 0.545854, 0.717722)],
      [RGB(0.1, 0.1, 0.1), HSV(0.985120, 0.000001, 0.113296)],
      [RGB(0.9, 0.9, 0.9), HSV(0.976477, 0.000000, 0.910824)],
      [RGB(0.5, 0.0, 0.5), HSV(0.912121, 1.000122, 0.510620)],
      [RGB(0.0, 0.5, 0.5), HSV(0.541025, 0.999999, 0.527824)],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final rgb = testCase[0];
        final expectedHsv = testCase[1];

        final hsv = srgbToOkhsv(rgb);

        expect(hsv.h, closeTo(expectedHsv.h, 1e-5)); // reduced precision due to floating point errors
        expect(hsv.s, closeTo(expectedHsv.s, 1e-5));
        expect(hsv.v, closeTo(expectedHsv.v, 1e-5));

        final rgbOut = okhsvToSrgb(hsv);

        expect(rgbOut.r, closeTo(rgb.r, 1e-5));
        expect(rgbOut.g, closeTo(rgb.g, 1e-5));
        expect(rgbOut.b, closeTo(rgb.b, 1e-5));
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });
}
