import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:okcolor/models/extensions.dart';
import 'package:okcolor/models/oklch.dart';

void main() {
  group('OkLch', () {
    test('constructor and getters', () {
      final testCases = [
        [0.5, 0.2, 0.3],
        [0.75, 0.1, 1.5],
        [0.1, 0.3, 3.14],
        [0.0, 0.0, 0.0],
        [1.0, 0.4, 2 * pi],
        [0.3, 0.05, pi / 2],
        [0.8, 0.15, 3 * pi / 2],
        [0.6, 0.25, pi / 4],
        [0.2, 0.35, 5 * pi / 4],
        [0.9, 0.01, 7 * pi / 4],
      ];

      List<String> failedTests = [];

      for (var testCase in testCases) {
        try {
          final oklch = OkLch(testCase[0], testCase[1], testCase[2]);

          expect(oklch.l, testCase[0], reason: 'Lightness mismatch');
          expect(oklch.c, testCase[1], reason: 'Chroma mismatch');
          expect(oklch.h, testCase[2], reason: 'Hue mismatch');

          expect(oklch.l, isA<double>(), reason: 'Lightness is not a double');
          expect(oklch.c, isA<double>(), reason: 'Chroma is not a double');
          expect(oklch.h, isA<double>(), reason: 'Hue is not a double');

          expect(oklch.l, inInclusiveRange(0, 1), reason: 'Lightness out of range');
          expect(oklch.c, isNonNegative, reason: 'Chroma is negative');
          expect(oklch.h, inInclusiveRange(0, 2 * pi), reason: 'Hue out of range');
        } catch (e) {
          failedTests.add('Test case failed for input: $testCase with error: $e');
        }
      }

      if (failedTests.isNotEmpty) {
        fail('The following test cases failed:\n${failedTests.join('\n')}');
      }
    });

    test('fromColor', () {
      final testCases = [
        [const Color.fromRGBO(0, 0, 0, 1), OkLch(0.000000000, 0.000000000, 0.000000000)],
        [const Color.fromRGBO(255, 255, 255, 1), OkLch(1.000000000, 0.000000060, 0.000000000)], // replaced hue with 0 for neutral color
        [const Color.fromRGBO(255, 0, 0, 1), OkLch(0.627955377, 0.257683247, 0.510227621)],
        [const Color.fromRGBO(0, 255, 0, 1), OkLch(0.866439581, 0.294827133, 2.487012625)],
        [const Color.fromRGBO(0, 0, 255, 1), OkLch(0.452013701, 0.313214391, -1.674608111)],
        [const Color.fromRGBO(255, 255, 0, 1), OkLch(0.967982650, 0.211005881, 1.915834665)],
        [const Color.fromRGBO(0, 255, 255, 1), OkLch(0.905399263, 0.154550031, -2.883826017)],
        [const Color.fromRGBO(255, 0, 255, 1), OkLch(0.701673806, 0.322490990, -0.552162647)],
        [const Color.fromRGBO(128, 128, 128, 1), OkLch(0.599870801, 0.000000017, 0.000000000)], // replaced hue with 0 for neutral color
        [const Color.fromRGBO(179, 51, 77, 1), OkLch(0.520603061, 0.163837135, 0.231912121)],
        [const Color.fromRGBO(26, 204, 153, 1), OkLch(0.751598895, 0.151115268, 2.905014515)],
        [const Color.fromRGBO(230, 26, 128, 1), OkLch(0.607353747, 0.236501649, -0.023032380)],
        [const Color.fromRGBO(77, 153, 26, 1), OkLch(0.610386252, 0.171698719, 2.379818916)],
        [const Color.fromRGBO(51, 102, 204, 1), OkLch(0.532482564, 0.167865545, -1.705307722)],
        [const Color.fromRGBO(204, 128, 51, 1), OkLch(0.666736126, 0.129885465, 1.084937334)],
        [const Color.fromRGBO(153, 102, 179, 1), OkLch(0.594255924, 0.125905812, -0.811363339)],
        [const Color.fromRGBO(26, 26, 26, 1), OkLch(0.217786491, 0.000000009, 0.000000000)], // replaced hue with 0 for neutral color
        [const Color.fromRGBO(230, 230, 230, 1), OkLch(0.924939513, 0.000000128, 0.000000000)], // replaced hue with 0 for neutral color
        [const Color.fromRGBO(128, 0, 128, 1), OkLch(0.420913666, 0.193452924, -0.552162409)],
        [const Color.fromRGBO(0, 128, 128, 1), OkLch(0.543122590, 0.092709966, -2.883825302)],
      ];

      List<String> failedTests = [];

      for (var testCase in testCases) {
        try {
          final color = testCase[0] as Color;
          final expectedL = (testCase[1] as OkLch).l;
          final expectedC = (testCase[1] as OkLch).c;
          final expectedH = (testCase[1] as OkLch).h;

          final oklch = OkLch.fromColor(color);

          expect(oklch.l, closeTo(expectedL, 1e-4), reason: 'Lightness mismatch for color: ${color.toRgb().toString()}');
          expect(oklch.c, closeTo(expectedC, 1e-4), reason: 'Chroma mismatch for color: ${color.toRgb().toString()}');
          expect(oklch.h, closeTo(expectedH, 1e-4), reason: 'Hue mismatch for color: ${color.toRgb().toString()}');
        } catch (e) {
          failedTests.add('Test case failed for input: $testCase with error: $e');
        }
      }

      if (failedTests.isNotEmpty) {
        fail('The following test cases failed:\n${failedTests.join('\n')}');
      }
    });

    test('copyWith', () {
      final color = OkLch(0.5, 0.2, 0.3);
      final cases = [
        color.copyWith(lightness: 0.6),
        color.copyWith(chroma: 0.3),
        color.copyWith(hue: 1.0),
        color.copyWith(lightness: 0.7, chroma: 0.4, hue: 2.0),
      ];
      expect(cases[0].l, 0.6);
      expect(cases[1].c, 0.3);
      expect(cases[2].h, 1.0);
      expect(cases[3], OkLch(0.7, 0.4, 2.0));
    });

    test('withLightness, withChroma, withHue', () {
      final color = OkLch(0.5, 0.2, 0.3);
      expect(color.withLightness(0.7).l, 0.7);
      expect(color.withChroma(0.4).c, 0.4);
      expect(color.withHue(1.5).h, 1.5);

      final color2 = OkLch(0.8, 0.3, 1.0);
      expect(color2.withLightness(0.2).l, 0.2);
      expect(color2.withChroma(0.1).c, 0.1);
      expect(color2.withHue(3.0).h, 3.0);

      final color3 = OkLch(0.3, 0.5, 2.0);
      expect(color3.withLightness(1.0).l, 1.0);
      expect(color3.withChroma(0.8).c, 0.8);
      expect(color3.withHue(0.5).h, 0.5);
    });

    test('darker and lighter', () {
      final color = OkLch(0.5, 0.2, 0.3);
      expect(color.darker(0.2).l, closeTo(0.4, 1e-6));
      expect(color.lighter(0.2).l, closeTo(0.6, 1e-6));

      final color2 = OkLch(0.8, 0.3, 1.0);
      expect(color2.darker(0.5).l, closeTo(0.4, 1e-6));
      expect(color2.lighter(0.1).l, closeTo(0.88, 1e-6));

      final color3 = OkLch(0.3, 0.5, 2.0);
      expect(color3.darker(0.1).l, closeTo(0.27, 1e-6));
      expect(color3.lighter(1.0).l, closeTo(0.6, 1e-6));
    });

    test('saturated and desaturated', () {
      final color = OkLch(0.5, 0.2, 0.3);
      expect(color.saturate(0.5).c, closeTo(0.3, 1e-6));
      expect(color.desaturate(0.5).c, closeTo(0.1, 1e-6));

      final color2 = OkLch(0.8, 0.4, 1.0);
      expect(color2.saturate(0.25).c, closeTo(0.5, 1e-6));
      expect(color2.desaturate(0.75).c, closeTo(0.1, 1e-6));

      final color3 = OkLch(0.3, 0.6, 2.0);
      expect(color3.saturate(1.0).c, closeTo(1.2, 1e-6));
      expect(color3.desaturate(0.1).c, closeTo(0.54, 1e-6));
    });

    test('rotated', () {
      final color = OkLch(0.5, 0.2, 0.3);
      expect(color.rotated(180).h, closeTo(0.3 + pi, 1e-6));
      expect(color.rotated(360).h, closeTo(0.3, 1e-6));

      final color2 = OkLch(0.8, 0.3, 1.0);
      expect(color2.rotated(90).h, closeTo(1.0 + pi / 2, 1e-6));
      expect(color2.rotated(-45).h, closeTo((1.0 - pi / 4) % (2 * pi), 1e-6));

      final color3 = OkLch(0.3, 0.5, 2.0);
      expect(color3.rotated(720).h, closeTo(2.0, 1e-6));
      expect(color3.rotated(-180).h, closeTo((2.0 - pi) % (2 * pi), 1e-6));
    });

    test('hue getter', () {
      final testCases = [
        [0.052, Hue.pink], // 3 degrees
        [0.506, Hue.red], // 29 degrees
        [0.925, Hue.orange], // 53 degrees
        [1.920, Hue.yellow], // 110 degrees
        [2.373, Hue.lime], // 136 degrees
        [2.478, Hue.green], // 142 degrees
        [2.635, Hue.teal], // 151 degrees
        [3.403, Hue.cyan], // 195 degrees
        [4.467, Hue.sky], // 256 degrees
        [4.607, Hue.blue], // 264 degrees
        [5.131, Hue.purple], // 294 degrees
        [5.725, Hue.magenta], // 328 degrees
        [0.000, Hue.pink], // Edge case: 0 degrees
        [2 * pi, Hue.pink], // Edge case: 360 degrees
        [pi, Hue.cyan], // 180 degrees
        [pi / 2, Hue.yellow], // 90 degrees
        [3 * pi / 2, Hue.blue], // 270 degrees
      ];

      List<String> failedTests = [];

      for (var testCase in testCases) {
        try {
          final hueAngle = testCase[0] as double;
          final expectedHue = testCase[1] as Hue;

          final oklch = OkLch(0.5, 0.2, hueAngle);
          expect(oklch.hue, expectedHue, reason: 'Hue mismatch for angle: ${(hueAngle * 180 / pi).toStringAsFixed(2)} degrees');
        } catch (e) {
          failedTests.add('Test case failed for input: $testCase with error: $e');
        }
      }

      if (failedTests.isNotEmpty) {
        fail('The following test cases failed:\n${failedTests.join('\n')}');
      }
    });

    test('toColor', () {
      final cases = [
        OkLch(0.5, 0.2, 0.0),
        OkLch(0.75, 0.1, pi / 2),
        OkLch(0.25, 0.3, pi),
      ];
      for (final oklch in cases) {
        final color = oklch.toColor();
        expect(color, isA<Color>());
        expect(color.alpha, 255);
      }
    });

    test('toOkLab', () {
      final cases = [
        OkLch(0.5, 0.2, 0.0),
        OkLch(0.75, 0.1, pi / 2),
        OkLch(0.25, 0.3, pi),
      ];
      for (final oklch in cases) {
        final oklab = oklch.toOkLab();
        expect(oklab.L, oklch.l);
        expect(sqrt(oklab.a * oklab.a + oklab.b * oklab.b), closeTo(oklch.c, 1e-6));
      }
    });

    test('lerp', () {
      final start = OkLch(0.2, 0.3, 0.1);
      final end = OkLch(0.8, 0.1, 2.0);
      final cases = [0.0, 0.25, 0.5, 0.75, 1.0];
      for (final t in cases) {
        final result = OkLch.lerp(start, end, t);
        expect(result.l, closeTo(start.l + (end.l - start.l) * t, 1e-6));
        expect(result.c, closeTo(start.c + (end.c - start.c) * t, 1e-6));
      }
    });

    test('harmonies', () {
      final color = OkLch(0.5, 0.2, 0.3);
      expect(color.complementary().h, closeTo(0.3 + pi, 1e-6));
      expect(color.splitComplementary().length, 4);
      expect(color.triadic().length, 3);
      expect(color.tetradic().length, 4);
      expect(color.analogous().length, 5);
    });

    test('shades and tints', () {
      final color = OkLch(0.5, 0.2, 0.3);
      final shades = color.shades();
      final tints = color.tints();
      expect(shades.length, 5);
      expect(tints.length, 5);
      expect(shades.first.l, 0.5);
      expect(shades.last.l, closeTo(0, 1e-6));
      expect(tints.first.l, 0.5);
      expect(tints.last.l, closeTo(1, 1e-6));
    });

    test('operators', () {
      final color1 = OkLch(0.5, 0.2, 0.3);
      final color2 = OkLch(0.1, 0.1, 0.1);
      final sum = color1 + color2;
      final diff = color1 - color2;
      expect(sum.l, closeTo(0.6, 1e-6));
      expect(sum.c, closeTo(0.3, 1e-6));
      expect(sum.h, closeTo(0.4, 1e-6));
      expect(diff.l, closeTo(0.4, 1e-6));
      expect(diff.c, closeTo(0.1, 1e-6));
      expect(diff.h, closeTo(0.2, 1e-6));
    });

    test('equality and hash code', () {
      final color1 = OkLch(0.5, 0.2, 0.3);
      final color2 = OkLch(0.5, 0.2, 0.3);
      final color3 = OkLch(0.5, 0.2, 0.4);
      expect(color1 == color2, isTrue);
      expect(color1 == color3, isFalse);
      expect(color1.hashCode == color2.hashCode, isTrue);
      expect(color1.hashCode == color3.hashCode, isFalse);
    });
  });
}
