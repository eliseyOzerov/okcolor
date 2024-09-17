// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:okcolor/gradient.dart';
// import 'package:okcolor/okcolor.dart';

// void main() {
//   group('OkHsv', () {
//     test('Constructor should handle various input ranges', () {
//       const color1 = OkHsv(h: 180, s: 0.5, v: 0.7);
//       expect(color1.h, 180);
//       expect(color1.s, 0.5);
//       expect(color1.v, 0.7);
//       expect(color1.alpha, 1);

//       const color2 = OkHsv(h: 400, s: 1.2, v: 1.5, alpha: 1.2);
//       expect(color2.h, 40); // 400 % 360
//       expect(color2.s, 1); // Clamped to 1
//       expect(color2.v, 1); // Clamped to 1
//       expect(color2.alpha, 1); // Clamped to 1
//     });

//     test('toString should return a correct string representation', () {
//       const color = OkHsv(h: 180, s: 0.5, v: 0.7, alpha: 0.8);
//       expect(color.toString(), 'OkHsv(h: 180.0, s: 0.5, v: 0.7, alpha: 0.8)');
//     });
//   });

//   group('Color conversions', () {
//     test('RGB to OkLab conversion', () {
//       const rgb = Rgb(r: 255, g: 0, b: 0);
//       final oklab = rgb.toLrgb().toOklab();
//       expect(oklab.l, closeTo(0.627, 0.001));
//       expect(oklab.a, closeTo(0.229, 0.001));
//       expect(oklab.b, closeTo(0.125, 0.001));
//     });

//     test('OkLab to RGB conversion', () {
//       const oklab = OkLab(l: 0.627, a: 0.229, b: 0.125);
//       final rgb = oklab.toLrgb().toRgb();
//       expect(rgb.r, closeTo(255, 1));
//       expect(rgb.g, closeTo(0, 1));
//       expect(rgb.b, closeTo(0, 1));
//     });
//   });

//   group('Gradient', () {
//     test('okHsvGradientColors should return correct number of colors', () {
//       const start = Colors.red;
//       const end = Colors.blue;
//       final colors = okHsvGradientColors(start, end, numberOfColors: 5);
//       expect(colors.length, 5);
//     });

//     test('okHsvGradientColors should interpolate colors correctly', () {
//       const start = Colors.red;
//       const end = Colors.blue;
//       final colors = okHsvGradientColors(start, end, numberOfColors: 3);
//       expect(colors[0], start);
//       expect(colors[2], end);
//       // Middle color should be different from start and end
//       expect(colors[1], isNot(equals(start)));
//       expect(colors[1], isNot(equals(end)));
//     });
//   });
// }
