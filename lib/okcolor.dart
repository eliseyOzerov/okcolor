import 'dart:ui';

import 'okhsv.dart';
import 'oklab.dart';
import 'rgb.dart';

enum Hue {
  red,
  orange,
  yellow,
  lime,
  green,
  teal,
  cyan,
  sky,
  blue,
  purple,
  magenta,
  pink,
}

/// Hue must be between 0 and 360, saturation, value and alpha between 0 and 1
class OkHsv {
  final double h;
  final double s;
  final double v;
  final double alpha;

  const OkHsv({
    required double h,
    required double s,
    required double v,
    double alpha = 1,
  })  : h = h % 360,
        s = (s * 100) ~/ 100 > 1 ? s / 100 : s,
        v = (v * 100) ~/ 100 > 1 ? v / 100 : v,
        alpha = alpha > 1 ? alpha / 100 : alpha;

  @override
  String toString() {
    return 'OkHsv(h: $h, s: $s, v: $v, alpha: $alpha)';
  }

  static const Map<Hue, int> hues = {
    Hue.pink: 0,
    Hue.red: 30,
    Hue.orange: 60,
    Hue.yellow: 90,
    Hue.lime: 120,
    Hue.green: 140,
    Hue.teal: 160,
    Hue.cyan: 190,
    Hue.sky: 230,
    Hue.blue: 270,
    Hue.purple: 300,
    Hue.magenta: 330,
  };

  static OkHsv colorForHue(Hue hue, List<OkHsv> colors) {
    double highestDistance = double.infinity;
    late OkHsv result;
    int hueVal = hues[hue]!;
    if (hue == Hue.pink) {
      hueVal = 360;
    }
    for (final color in colors) {
      final distance = (color.h - hueVal).abs();
      if (distance < highestDistance) {
        highestDistance = distance;
        result = color;
      }
    }
    return result;
  }

  static Hue hueForColor(OkHsv color) {
    double highestDistance = double.infinity;
    late Hue result;
    for (final hue in hues.entries) {
      final distance = (color.h - hue.value).abs();
      if (distance < highestDistance) {
        highestDistance = distance;
        result = hue.key;
      }
    }
    return result;
  }

  Color toColor() {
    return toOklab().toLrgb().toRgb().toColor();
  }

  factory OkHsv.fromColor(Color color) {
    final rgb = Rgb.fromColor(color);
    final lrgb = rgb.toLrgb();
    final oklab = lrgb.toOklab();
    final res = oklab.toOkhsv();
    return res;
  }

  OkLab toOklab() {
    return okhsvToOklab(this);
  }

  OkHsv withHue(double hue) {
    return OkHsv(h: hue, s: s, v: v, alpha: alpha);
  }

  OkHsv withSaturation(double saturation) {
    return OkHsv(h: h, s: saturation, v: v, alpha: alpha);
  }

  OkHsv withValue(double value) {
    return OkHsv(h: h, s: s, v: value, alpha: alpha);
  }

  OkHsv withAlpha(double alpha) {
    return OkHsv(h: h, s: s, v: v, alpha: alpha);
  }

  OkHsv darker(double percentage) {
    return withValue(v * (1 - percentage));
  }

  OkHsv lighter(double percentage) {
    return withValue(v * (1 + percentage));
  }

  OkHsv duller(double percentage) {
    return withSaturation(s * (1 - percentage));
  }

  OkHsv richer(double percentage) {
    return withSaturation(s * (1 + percentage));
  }

  OkHsv rotateRatio(double percentage) {
    return withHue((h + percentage * 360) % 360);
  }

  OkHsv rotateAbsolute(double angle) {
    return withHue((h + angle) % 360);
  }

  OkHsv rotateTo(double angle) {
    return withHue(angle);
  }

  List<OkHsv> hueCircle([int count = 12]) {
    final double step = 360 / count;
    return List.generate(count, (index) => rotateAbsolute(step * index));
  }
}

class OkLab {
  final double l;
  final double a;
  final double b;
  final double alpha;

  const OkLab({
    required this.l,
    required this.a,
    required this.b,
    this.alpha = 1,
  });

  OkHsv toOkhsv() {
    return convertOklabToOkhsv(this);
  }

  Lrgb toLrgb() {
    return convertOklabToLrgb(this);
  }

  @override
  String toString() {
    return 'OkLab(l: $l, a: $a, b: $b, alpha: $alpha)';
  }
}

class Lrgb {
  final double r;
  final double g;
  final double b;
  final double alpha;

  const Lrgb({
    required this.r,
    required this.g,
    required this.b,
    this.alpha = 1,
  });

  Rgb toRgb() {
    return convertLrgbToRgb(this);
  }

  OkLab toOklab() {
    return convertLrgbToOklab(this);
  }
}

class Rgb {
  final int r;
  final int g;
  final int b;
  final double alpha;

  const Rgb({
    required this.r,
    required this.g,
    required this.b,
    this.alpha = 1,
  });

  Lrgb toLrgb() {
    return convertRgbToLrgb(this);
  }

  factory Rgb.fromColor(Color color) {
    return Rgb(r: color.red, g: color.green, b: color.blue, alpha: color.alpha / 255);
  }

  Color toColor() {
    return Color.fromARGB((alpha * 255).round(), r, g, b);
  }
}
