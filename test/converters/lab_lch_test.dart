import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:okcolor/converters/lab_lch.dart';
import 'package:okcolor/models/okcolor_base.dart';

void main() {
  group('Lab to LCH conversion', () {
    test('Convert Lab(50, 0, 0) to LCH', () {
      final lab = OkLab(50, 0, 0);
      final lch = labToLch(lab);
      expect(lch.L, closeTo(50, 1e-6));
      expect(lch.C, closeTo(0, 1e-6));
      expect(lch.h, closeTo(0, 1e-6));
    });

    test('Convert Lab(50, 10, 20) to LCH', () {
      final lab = OkLab(50, 10, 20);
      final lch = labToLch(lab);
      expect(lch.L, closeTo(50, 1e-6));
      expect(lch.C, closeTo(22.36067977, 1e-6));
      expect(lch.h, closeTo(1.10714872, 1e-6));
    });

    test('Convert Lab(75, -20, 30) to LCH', () {
      final lab = OkLab(75, -20, 30);
      final lch = labToLch(lab);
      expect(lch.L, closeTo(75, 1e-6));
      expect(lch.C, closeTo(36.05551275, 1e-6));
      expect(lch.h, closeTo(2.15879893, 1e-6));
    });
  });

  group('LCH to Lab conversion', () {
    test('Convert LCH(50, 0, 0) to Lab', () {
      final lch = LCH(50, 0, 0);
      final lab = lchToLab(lch);
      expect(lab.L, closeTo(50, 1e-6));
      expect(lab.a, closeTo(0, 1e-6));
      expect(lab.b, closeTo(0, 1e-6));
    });

    test('Convert LCH(50, 22.36067977, 1.10714872) to Lab', () {
      final lch = LCH(50, 22.36067977, 1.10714872);
      final lab = lchToLab(lch);
      expect(lab.L, closeTo(50, 1e-6));
      expect(lab.a, closeTo(10, 1e-6));
      expect(lab.b, closeTo(20, 1e-6));
    });

    test('Convert LCH(75, 36.05551275, 2.15879893) to Lab', () {
      final lch = LCH(75, 36.05551275, 2.15879893);
      final lab = lchToLab(lch);
      expect(lab.L, closeTo(75, 1e-6));
      expect(lab.a, closeTo(-20, 1e-6));
      expect(lab.b, closeTo(30, 1e-6));
    });
  });

  group('Roundtrip conversion', () {
    test('Lab to LCH to Lab', () {
      final original = OkLab(60, 15, -25);
      final lch = labToLch(original);
      final converted = lchToLab(lch);
      expect(converted.L, closeTo(original.L, 1e-6));
      expect(converted.a, closeTo(original.a, 1e-6));
      expect(converted.b, closeTo(original.b, 1e-6));
    });

    test('LCH to Lab to LCH', () {
      final original = LCH(80, 40, math.pi / 3);
      final lab = lchToLab(original);
      final converted = labToLch(lab);
      expect(converted.L, closeTo(original.L, 1e-6));
      expect(converted.C, closeTo(original.C, 1e-6));
      expect(converted.h, closeTo(original.h, 1e-6));
    });
  });
}
