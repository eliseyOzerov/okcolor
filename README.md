<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# OkColor

A Flutter package for working with colors in the Oklab color space, providing utilities for color manipulation, conversion, and analysis.

## Features

- Convert between RGB, HSV, HSL, and Oklab color spaces
- Perform color manipulations like lightening, darkening, and saturation adjustments
- Generate color palettes and gradients
- Gamut mapping and clipping functions

## Getting started

Add `okcolor` to your `pubspec.yaml` file:

```yaml
dependencies:
  okcolor: ^1.0.0
```

Then run `dart pub get` or `flutter pub get`.

## Usage

Here are some examples demonstrating how to use the OkColor package:

### Converting between color spaces

```dart
import 'package:flutter/material.dart';
import 'package:okcolor/okcolor.dart';

void main() {
  // Convert from Color to OkLab
  Color color = Colors.blue;
  OkLab oklab = OkLab.fromColor(color);
  // Convert from OkLab back to Color
  Color convertedColor = oklab.toColor();
  // Convert from Color to OkHsv
  OkHsv okhsv = OkHsv.fromColor(color);
}
```

### Interpolating between colors

```dart
import 'package:flutter/material.dart';
import 'package:okcolor/okcolor.dart';

void main() {
  Color startColor = Colors.red;
  Color endColor = Colors.blue;
  double fraction = 0.5;
  
  // Interpolate using OkLab color space
  Color interpolatedColor = interpolate(
    startColor, 
    endColor, 
    fraction,
    method: InterpolationMethod.oklab
  );

  // Interpolate using OkHSV color space
  Color interpolatedColorHSV = interpolate(
    startColor, 
    endColor, 
    fraction,
    method: InterpolationMethod.okhsv
  );
}
```

## Acknowledgements

This package is a Dart/Flutter implementation of the Oklab color space, based on the work of Björn Ottosson. For more information about the Oklab color space and its properties, please visit [https://bottosson.github.io/posts/oklab/](https://bottosson.github.io/posts/oklab/).

## Contributing

Contributions to improve the package are welcome. Please feel free to submit issues or pull requests on the GitHub repository.

## Issues

If you encounter any problems or have suggestions for improvements, please file an issue on the GitHub issue tracker.

## Support

For questions or discussions about using the package, you can open a discussion on the GitHub repository or reach out to the package maintainers.

We strive to respond to issues and pull requests in a timely manner, typically within a few days.
