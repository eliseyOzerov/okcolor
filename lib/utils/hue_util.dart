import 'dart:ui';

double interpolateHue(double start, double end, double fraction, {bool shortestPath = true, bool normalizeHue = false}) {
  final range = normalizeHue ? 1 : 360;
  double fStart = normalizeHue ? start % 360 : start;
  double fEnd = normalizeHue ? end % 360 : end;

  if (shortestPath && (fEnd - fStart).abs() > (range / 2)) {
    if (fEnd > fStart) {
      fStart += range;
    } else {
      fEnd -= range;
    }
  }

  return (lerpDouble(fStart, fEnd, fraction) ?? 0) % range;
}
