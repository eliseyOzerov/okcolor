/// Imagine a circle with a range of [0, range].
/// If [shortestPath] is true, the shortest path between [start] and [end] will be used.
/// If [shortestPath] is false, the longest path between [start] and [end] will be used.
///
/// In case of 0...1 range, and start = 0 and end = 0.25, if shortestPath is true, the result will be 0.25.
/// If shortestPath is false, the result will be 0.375.
double lerpAngle(double start, double end, double fraction, {double range = 1, bool shortestPath = true}) {
  final dA = (end - start).abs(); // always inside the range (0.1 .. 0.7, 0.7 .. 0.1 will return the same value)
  final dB = range - dA; // always outside the range
  final shortestCrossesRange = shortestPath && dB < dA && dB != 0;
  final longerCrossesRange = !shortestPath && dB > dA && start != end;
  if (shortestCrossesRange || longerCrossesRange) {
    // crossing the range is shorter
    if (end > start) {
      // eg. start 0.1 .. end 0.7
      return lerp(start + range, end, fraction) % range; // 1.1, 0.7, 0.6 -> 1.1 + (0.7 - 1.1) * 0.8 = 1.1 - 0.32 = 0.78 % 1 + 0.78
    } else {
      // eg. start 0.7 .. end 0.1
      return lerp(start, end + range, fraction) % range; // 0.7, 1.1, 0.8 -> 0.7 + (1.1 - 0.7) * 0.8 = 0.7 + 0.32 = 1.02 % 1 = 0.02
    }
  }
  return lerp(start, end, fraction) % range;
}

double lerp(double a, double b, double t) {
  return a + (b - a) * t;
}
