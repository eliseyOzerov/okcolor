import 'package:flutter_test/flutter_test.dart';
import 'package:okcolor/utils/lerp.dart';

void main() {
  test('Lerp over angular range', () {
    final testCases = [
      // [start, end, fraction, range, expected result, shortestPath]
      // Normal cases for shortestPath true
      [0.0, 1.0, 0.5, 1.0, 0.5, true],
      [0.0, 0.8, 0.5, 1.0, 0.9, true],
      [0.0, 0.6, 0.5, 1.0, 0.8, true],
      [0.0, 0.4, 0.5, 1.0, 0.2, true],
      [0.0, 0.2, 0.5, 1.0, 0.1, true],
      [1.0, 0.0, 0.5, 1.0, 0.5, true],
      [0.8, 0.0, 0.5, 1.0, 0.9, true],
      [0.6, 0.0, 0.5, 1.0, 0.8, true],
      [0.4, 0.0, 0.5, 1.0, 0.2, true],
      [0.2, 0.0, 0.5, 1.0, 0.1, true],

      // Normal cases for shortestPath false
      [0.0, 1.0, 0.5, 1.0, 0.5, false],
      [0.0, 0.8, 0.5, 1.0, 0.4, false],
      [0.0, 0.6, 0.5, 1.0, 0.3, false],
      [0.0, 0.4, 0.5, 1.0, 0.7, false],
      [0.0, 0.2, 0.5, 1.0, 0.6, false],
      [1.0, 0.0, 0.5, 1.0, 0.5, false],
      [0.8, 0.0, 0.5, 1.0, 0.4, false],
      [0.6, 0.0, 0.5, 1.0, 0.3, false],
      [0.4, 0.0, 0.5, 1.0, 0.7, false],
      [0.2, 0.0, 0.5, 1.0, 0.6, false],

      // Normal cases for shortestPath true at 360
      [0.0, 360.0, 0.5, 360.0, 180.0, true],
      [0.0, 288.0, 0.5, 360.0, 324.0, true],
      [0.0, 216.0, 0.5, 360.0, 288.0, true],
      [0.0, 144.0, 0.5, 360.0, 72.0, true],
      [0.0, 72.0, 0.5, 360.0, 36.0, true],
      [360.0, 0.0, 0.5, 360.0, 180.0, true],
      [288.0, 0.0, 0.5, 360.0, 324.0, true],
      [216.0, 0.0, 0.5, 360.0, 288.0, true],
      [144.0, 0.0, 0.5, 360.0, 72.0, true],
      [72.0, 0.0, 0.5, 360.0, 36.0, true],

      // Normal cases for shortestPath false at 360
      [0.0, 360.0, 0.5, 360.0, 180.0, false],
      [0.0, 288.0, 0.5, 360.0, 144.0, false],
      [0.0, 216.0, 0.5, 360.0, 108.0, false],
      [0.0, 144.0, 0.5, 360.0, 252.0, false],
      [0.0, 72.0, 0.5, 360.0, 216.0, false],
      [360.0, 0.0, 0.5, 360.0, 180.0, false],
      [288.0, 0.0, 0.5, 360.0, 144.0, false],
      [216.0, 0.0, 0.5, 360.0, 108.0, false],
      [144.0, 0.0, 0.5, 360.0, 252.0, false],
      [72.0, 0.0, 0.5, 360.0, 216.0, false],

      // Edge cases
      [0.0, 0.0, 0.5, 1.0, 0.0, true],
      [1.0, 1.0, 0.5, 1.0, 0.0, true],
      [0.0, 0.0, 0.5, 360.0, 0.0, true],
      [360.0, 360.0, 0.5, 360.0, 0.0, true],

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
