import 'dart:math' as math;

import 'package:okcolor/models/okcolor_base.dart';
import 'package:vector_math/vector_math_64.dart';

// Source: https://bottosson.github.io/posts/oklab/#converting-from-xyz-to-oklab

// Define M1 matrix (transposed for column-major input)
final Matrix3 m1 = Matrix3(0.8189330101, 0.0329845436, 0.0482003018, 0.3618667424, 0.9293118715, 0.2643662691, -0.1288597137, 0.0361456387, 0.6338517070);

// Define M2 matrix (transposed for column-major input)
final Matrix3 m2 = Matrix3(0.2104542553, 1.9779984951, 0.0259040371, 0.7936177850, -2.4285922050, 0.7827717662, -0.0040720468, 0.4505937099, -0.8086757660);

final Matrix3 m1Inverse = m1.clone()..invert();
final Matrix3 m2Inverse = m2.clone()..invert();

OkLab xyzToLab(XYZ xyz) {
  final inputVector = Vector3(xyz.X, xyz.Y, xyz.Z);
  final approximateConeResponse = m1.transformed(inputVector);
  final cubeRoot = Vector3(
    math.pow(approximateConeResponse.x.abs(), 1 / 3) * (approximateConeResponse.x < 0 ? -1 : 1),
    math.pow(approximateConeResponse.y.abs(), 1 / 3) * (approximateConeResponse.y < 0 ? -1 : 1),
    math.pow(approximateConeResponse.z.abs(), 1 / 3) * (approximateConeResponse.z < 0 ? -1 : 1),
  );
  final linearLab = m2.transformed(cubeRoot);
  return OkLab(linearLab.x, linearLab.y, linearLab.z);
}

XYZ labToXyz(OkLab lab) {
  final inputVector = Vector3(lab.L, lab.a, lab.b);
  final approximateConeResponse = m2Inverse.transformed(inputVector);
  final cubeRoot = Vector3(
    math.pow(approximateConeResponse.x, 3).toDouble(),
    math.pow(approximateConeResponse.y, 3).toDouble(),
    math.pow(approximateConeResponse.z, 3).toDouble(),
  );
  final xyz = m1Inverse.transformed(cubeRoot);
  return XYZ(xyz.x, xyz.y, xyz.z);
}
