import 'package:flutter_test/flutter_test.dart';
import 'package:okcolor/utils/lerp.dart';

void main() {
  test('Lerp over angular range', () {
    final testCases = [
      // [start, end, fraction, range, expected result, shortestPath]
      [0.0, 1.0, 0.5, 1.0, 0.5, true],
      [0.0, 1.0, 0.25, 1.0, 0.25, true],
      [1.0, 0.0, 0.5, 1.0, 0.5, true],
      [0.0, 0.75, 0.5, 1.0, 0.875, true],
      [0.75, 0.0, 0.5, 1.0, 0.875, true],
      [0.0, 0.75, 0.5, 1.0, 0.375, false],
      [0.75, 0.0, 0.5, 1.0, 0.375, false],
      [0.0, 270.0, 0.5, 360.0, 315.0, true],
      [270.0, 0.0, 0.5, 360.0, 315.0, true],
      [0.0, 180.0, 0.5, 360.0, 90.0, true],
      [180.0, 0.0, 0.5, 360.0, 90.0, true],
      [350.0, 10.0, 0.5, 360.0, 0.0, true],
      [10.0, 350.0, 0.5, 360.0, 0.0, true],
      [0.0, 1.0, 0.0, 1.0, 0.0, true],
      [0.0, 1.0, 1.0, 1.0, 0.0, true],
      // Edge cases
      [0.0, 0.0, 0.5, 1.0, 0.0, true],
      [1.0, 1.0, 0.5, 1.0, 0.0, true],
      [360.0, 360.0, 0.5, 360.0, 0.0, true],
      // Non-shortest path cases
      [0.25, 0.75, 0.5, 1.0, 0.5, false],
      [0.75, 0.25, 0.5, 1.0, 0.5, false],
      [270.0, 90.0, 0.5, 360.0, 180.0, false],
      [90.0, 270.0, 0.5, 360.0, 180.0, false],
      // Potentially invalid inputs (should still produce a result)
      [-0.5, 1.5, 0.5, 1.0, 0.0, true],
      [0.0, 1.0, -0.5, 1.0, 0.5, true],
      [0.0, 1.0, 1.5, 1.0, 0.5, true],
      // Large range
      [0.0, 1000000.0, 0.5, 1000000.0, 500000.0, true],
      // Small range
      [0.0, 0.1, 0.5, 0.1, 0.05, true],
    ];

    List<String> failedTests = [];

    for (var testCase in testCases) {
      try {
        final start = testCase[0] as double;
        final end = testCase[1] as double;
        final fraction = testCase[2] as double;
        final range = testCase[3] as double;
        final expected = testCase[4] as double;
        final shortestPath = testCase[5] as bool;

        final result = lerpAngle(start, end, fraction, range: range, shortestPath: shortestPath);
        expect(result, closeTo(expected, 1e-6), reason: 'Failed for input: start=$start, end=$end, fraction=$fraction, range=$range, shortestPath=$shortestPath');
      } catch (e) {
        failedTests.add('Test case failed for input: $testCase with error: $e');
      }
    }

    if (failedTests.isNotEmpty) {
      fail('The following test cases failed:\n${failedTests.join('\n')}');
    }
  });
}
