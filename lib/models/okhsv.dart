import 'dart:ui';

import 'package:okcolor/converters/rgb_okhsv.dart';
import 'package:okcolor/models/flutter_color_conversions.dart';
import 'package:okcolor/models/okcolor_base.dart';
import 'package:okcolor/okcolor.dart';

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

class OkHsv {
  final double h;
  final double s;
  final double v;
  final double alpha;

  const OkHsv({
    required this.h,
    required this.s,
    required this.v,
    this.alpha = 1,
  });

  // ------ Constructors ------ //

  factory OkHsv.fromHsv(OkHSV hsv) {
    return OkHsv(h: hsv.h, s: hsv.s, v: hsv.v, alpha: 1);
  }

  factory OkHsv.fromHue(Hue hue, List<OkHsv> colors) {
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

  factory OkHsv.fromColor(Color color) {
    final hsv = srgbToOkhsv(color.toRgb());
    return OkHsv(h: hsv.h, s: hsv.s, v: hsv.v, alpha: color.alpha / 255);
  }

  // ------ Getters ------ //

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

  Hue get hue {
    double highestDistance = double.infinity;
    late Hue result;
    for (final hue in hues.entries) {
      final distance = (h - hue.value).abs();
      if (distance < highestDistance) {
        highestDistance = distance;
        result = hue.key;
      }
    }
    return result;
  }

  List<OkHsv> hueCircle([int count = 12]) {
    final double step = 1 / count;
    return List.generate(count, (index) => rotateAbsolute(step * index * 360));
  }

  // ------ Conversions ------ //

  OkHSV toHsv() {
    return OkHSV(h, s, v);
  }

  Color toColor() {
    final rgb = okhsvToSrgb(OkHSV(h, s, v));
    return rgb.toColor();
  }

  // ------ Interpolation ------ //

  static OkHsv lerp(OkHsv start, OkHsv end, double fraction, {bool shortestPath = true}) {
    final h = interpolateHue(start.h, end.h, fraction, shortestPath: shortestPath, normalizeHue: true);
    return OkHsv(
      h: h,
      s: lerpDouble(start.s, end.s, fraction) ?? 0,
      v: lerpDouble(start.v, end.v, fraction) ?? 0,
      alpha: lerpDouble(start.alpha, end.alpha, fraction) ?? 0,
    );
  }

  // ------ Modifiers ------ //

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
    return withHue((h + percentage) % 1);
  }

  OkHsv rotateAbsolute(double angle) {
    return withHue((h + angle / 360) % 1);
  }

  OkHsv rotateTo(double angle) {
    return withHue((angle / 360) % 1);
  }
}
