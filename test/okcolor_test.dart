import 'package:flutter_test/flutter_test.dart';
import 'package:okcolor/converters/xyz_lab.dart';
import 'package:okcolor/models/okcolor_base.dart';

void main() {
  // Expected values from https://bottosson.github.io/posts/oklab/#table-of-example-xyz-and-oklab-pairs
  group('xyzlab', () {
    group('xyz-lab', () {
      test('1', () {
        final xyz = XYZ(0.950, 1.000, 1.089);
        final lab = xyzToLab(xyz);
        expect(lab.L, closeTo(1.0, 0.001));
        expect(lab.a, closeTo(0.0, 0.001));
        expect(lab.b, closeTo(0.0, 0.001));
      });

      test('2', () {
        final xyz = XYZ(1, 0, 0);
        final lab = xyzToLab(xyz);
        expect(lab.L, closeTo(0.45, 0.01));
        expect(lab.a, closeTo(1.236, 0.001));
        expect(lab.b, closeTo(-0.019, 0.001));
      });

      test('3', () {
        final xyz = XYZ(0, 1, 0);
        final lab = xyzToLab(xyz);
        expect(lab.L, closeTo(0.922, 0.001));
        expect(lab.a, closeTo(-0.671, 0.001));
        expect(lab.b, closeTo(0.263, 0.001));
      });

      test('4', () {
        final xyz = XYZ(0, 0, 1);
        final lab = xyzToLab(xyz);
        expect(lab.L, closeTo(0.153, 0.001));
        expect(lab.a, closeTo(-1.415, 0.001));
        expect(lab.b, closeTo(-0.449, 0.001));
      });
    });

    // Expected values from https://bottosson.github.io/posts/oklab/#table-of-example-xyz-and-oklab-pairs
    group('lab-xyz', () {
      test('1', () {
        final lab = Lab(1.0, 0.0, 0.0);
        final xyz = labToXyz(lab);
        expect(xyz.X, closeTo(0.950, 0.001));
        expect(xyz.Y, closeTo(1.000, 0.001));
        expect(xyz.Z, closeTo(1.089, 0.001));
      });

      test('2', () {
        final lab = Lab(0.45, 1.236, -0.019);
        final xyz = labToXyz(lab);
        expect(xyz.X, closeTo(1.0, 0.01));
        expect(xyz.Y, closeTo(0.0, 0.01));
        expect(xyz.Z, closeTo(0.0, 0.01));
      });

      test('3', () {
        final lab = Lab(0.922, -0.671, 0.263);
        final xyz = labToXyz(lab);
        expect(xyz.X, closeTo(0.0, 0.01));
        expect(xyz.Y, closeTo(1.0, 0.01));
        expect(xyz.Z, closeTo(0.0, 0.01));
      });

      test('4', () {
        final lab = Lab(0.153, -1.415, -0.449);
        final xyz = labToXyz(lab);
        expect(xyz.X, closeTo(0.0, 0.01));
        expect(xyz.Y, closeTo(0.0, 0.01));
        expect(xyz.Z, closeTo(1.0, 0.01));
      });
    });

    group('roundtrip', () {
      test('1', () {
        final xyz = XYZ(0.950, 1.000, 1.089);
        final lab = xyzToLab(xyz);
        final xyz2 = labToXyz(lab);
        expect(xyz2.X, closeTo(xyz.X, 0.001));
        expect(xyz2.Y, closeTo(xyz.Y, 0.001));
        expect(xyz2.Z, closeTo(xyz.Z, 0.001));
      });

      test('2', () {
        final xyz = XYZ(1, 0, 0);
        final lab = xyzToLab(xyz);
        final xyz2 = labToXyz(lab);
        expect(xyz2.X, closeTo(xyz.X, 0.001));
        expect(xyz2.Y, closeTo(xyz.Y, 0.001));
        expect(xyz2.Z, closeTo(xyz.Z, 0.001));
      });

      test('3', () {
        final xyz = XYZ(0, 1, 0);
        final lab = xyzToLab(xyz);
        final xyz2 = labToXyz(lab);
        expect(xyz2.X, closeTo(xyz.X, 0.001));
        expect(xyz2.Y, closeTo(xyz.Y, 0.001));
        expect(xyz2.Z, closeTo(xyz.Z, 0.001));
      });

      test('4', () {
        final xyz = XYZ(0, 0, 1);
        final lab = xyzToLab(xyz);
        final xyz2 = labToXyz(lab);
        expect(xyz2.X, closeTo(xyz.X, 0.001));
        expect(xyz2.Y, closeTo(xyz.Y, 0.001));
        expect(xyz2.Z, closeTo(xyz.Z, 0.001));
      });
    });
  });
}
