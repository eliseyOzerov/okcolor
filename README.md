# OkColor

A Flutter package for working with perceptually uniform color spaces, based on the groundbreaking work of Björn Ottosson. OkColor provides powerful utilities for color manipulation, conversion, and analysis.

## Features

- Work with perceptually uniform color spaces: OkLab, OkLCH, OkHSV, and OkHSL
- Seamless color conversions between RGB, HSV, HSL, and Ok* color spaces
- Advanced color manipulations: lightening, darkening, saturation adjustments, and more
- Generate harmonious color palettes and smooth gradients
- Gamut mapping and clipping functions for color accuracy

## Getting Started

Add `okcolor` to your `pubspec.yaml` file:

```yaml
dependencies:
  okcolor: ^1.0.1
```

Then run `flutter pub get`.

## Usage

### Color Extensions

OkColor extends the Flutter `Color` class with convenient methods:

```dart
import 'package:flutter/material.dart';
import 'package:okcolor/okcolor.dart';

void main() {
  Color color = Colors.blue;
  // Convert to different color spaces
  OkLab oklab = color.toOkLab();
  OkLch oklch = color.toOkLch();
  OkHsv okhsv = color.toOkHsv();
  OkHsl okhsl = color.toOkHsl();

  // Color manipulations
  Color darkerColor = color.darker(0.2);
  Color lighterColor = color.lighter(0.2);
  Color saturatedColor = color.saturate(0.2);
  Color desaturatedColor = color.desaturate(0.2);
  Color rotatedColor = color.rotated(45);
  Color complementaryColor = color.complementary();
  
  // Generate color harmonies
  List<Color> splitComplementaryColors = color.splitComplementary();
  List<Color> triadicColors = color.triadic();
  List<Color> tetradicColors = color.tetradic();
  List<Color> analogousColors = color.analogous(count: 3);
  List<Color> shades = color.shades(count: 5);
  List<Color> tints = color.tints(count: 5);
}
```

### Color Models

OkColor provides four main color models:

1. `OkLab`: Perceptually uniform lightness, a and b channels
2. `OkLch`: Perceptually uniform lightness, chroma, and hue
3. `OkHsv`: Perceptually uniform hue, saturation, and value
4. `OkHsl`: Perceptually uniform hue, saturation, and lightness

Each model comes with its own set of manipulation methods and conversions.

### Converters

OkColor includes converters between various color spaces:

```dart
import 'package:okcolor/okcolor.dart';
void main() {
  // RGB to OkLab
  OkLab oklab = rgbToOkLab(RGB(1.0, 0.5, 0.2));
  // OkLab to RGB
  RGB rgb = okLabToRgb(OkLab(0.7, 0.2, -0.1));
  // OkLab to OkLCH
  OkLch oklch = labToLch(OkLab(0.7, 0.2, -0.1));
  // OkLCH to OkLab
  OkLab oklab2 = lchToLab(OkLch(0.7, 0.2, 1.5));
  // RGB to OkHSV
  OkHsv okhsv = rgbToOkhsv(RGB(1.0, 0.5, 0.2));
  // OkHSV to RGB
  RGB rgb2 = okhsvToRgb(OkHsv(0.1, 0.8, 0.9));
  // Similar converters exist for OkHSL and other color space combinations
}
```

For more detailed examples and advanced usage, please refer to the API documentation.

## Acknowledgements

This package is a Dart/Flutter implementation of the Oklab color space and related color models, based on the work of Björn Ottosson. For more information about these perceptually uniform color spaces and their properties, please visit [Björn Ottosson's blog](https://bottosson.github.io/posts/oklab/).

## Contributing

Contributions to improve the package are welcome. Please feel free to submit issues or pull requests on the GitHub repository.

## Support

For questions, discussions, or support, please open an issue or discussion on the GitHub repository. We strive to respond to inquiries in a timely manner.