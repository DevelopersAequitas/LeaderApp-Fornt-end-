import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/utils/monotone_spline.dart';

/// Evaluates the cubic Bézier of one segment at [t].
Offset _bezier(Offset p0, Offset c1, Offset c2, Offset p3, double t) {
  final u = 1 - t;
  return p0 * (u * u * u) +
      c1 * (3 * u * u * t) +
      c2 * (3 * u * t * t) +
      p3 * (t * t * t);
}

/// Maps a value series to pixel points the way the charts do: x evenly
/// spaced, y grows downward from [baseline]. Zero-range series map to the
/// baseline.
List<Offset> _toPixels(
  List<double> values, {
  double baseline = 100,
  double height = 100,
  double width = 300,
  List<double>? xs,
}) {
  final maxV = values.reduce(math.max);
  final seg = values.length > 1 ? width / (values.length - 1) : width;
  return [
    for (int i = 0; i < values.length; i++)
      Offset(
        xs != null ? xs[i] : i * seg,
        baseline - (maxV <= 0 ? 0 : values[i] / maxV) * height,
      ),
  ];
}

/// Asserts the spline between every pair of neighbours never leaves the
/// vertical range of those two points and never crosses the baseline, and
/// that it reproduces every data point exactly.
void _expectMonotone(List<Offset> pts, {double baseline = 100}) {
  final cp = monotoneSplineControlPoints(pts);
  expect(cp.c1.length, pts.length - 1);
  expect(cp.c2.length, pts.length - 1);

  for (int i = 0; i < pts.length - 1; i++) {
    expect(_bezier(pts[i], cp.c1[i], cp.c2[i], pts[i + 1], 0), pts[i]);
    expect(_bezier(pts[i], cp.c1[i], cp.c2[i], pts[i + 1], 1), pts[i + 1]);

    final lo = math.min(pts[i].dy, pts[i + 1].dy);
    final hi = math.max(pts[i].dy, pts[i + 1].dy);
    for (int k = 0; k <= 200; k++) {
      final p = _bezier(pts[i], cp.c1[i], cp.c2[i], pts[i + 1], k / 200);
      expect(p.dy, lessThanOrEqualTo(hi + 1e-6),
          reason: 'segment $i t=${k / 200} goes below its lower end point');
      expect(p.dy, greaterThanOrEqualTo(lo - 1e-6),
          reason: 'segment $i t=${k / 200} rises above its upper end point');
      expect(p.dy, lessThanOrEqualTo(baseline + 1e-6),
          reason: 'segment $i dips below the baseline (negative value)');
    }
  }
}

void _expectValues(List<double> values) => _expectMonotone(_toPixels(values));

void main() {
  group('monotoneSplineControlPoints', () {
    test('all-zero values stay exactly on the baseline', () {
      final pts = _toPixels([0, 0, 0, 0, 0, 0]);
      _expectMonotone(pts);
      final cp = monotoneSplineControlPoints(pts);
      for (final c in [...cp.c1, ...cp.c2]) {
        expect(c.dy, 100.0); // no control point leaves the baseline
      }
    });

    test('constant values give a perfectly flat curve', () {
      final pts = _toPixels([42, 42, 42, 42, 42]);
      final cp = monotoneSplineControlPoints(pts);
      for (final c in [...cp.c1, ...cp.c2]) {
        expect(c.dy, pts.first.dy);
      }
      _expectMonotone(pts);
    });

    test('strictly increasing values never overshoot', () {
      _expectValues([1, 2, 3, 4, 5, 6]);
      _expectValues([1, 2, 4, 8, 16, 32, 64]);
    });

    test('strictly decreasing values never overshoot', () {
      _expectValues([6, 5, 4, 3, 2, 1]);
      _expectValues([64, 32, 16, 8, 4, 2, 1]);
    });

    test('non-negative values with very large differences', () {
      _expectValues([0, 0, 0, 0, 0, 72000]); // the Finance revenue shape
      _expectValues([1, 1000000, 1, 1000000, 1]);
      _expectValues([0, 1e9, 0]);
      _expectValues([5e6, 5, 5e6, 5]);
      _expectValues([0, 0, 1e7, 1e7, 0, 0]);
    });

    test('minimum and maximum are never exceeded anywhere on the curve', () {
      final values = [3.0, 9.0, 1.0, 7.0, 7.0, 2.0, 10.0, 0.0];
      final pts = _toPixels(values);
      final cp = monotoneSplineControlPoints(pts);
      final yMin = pts.map((p) => p.dy).reduce(math.min); // series max
      final yMax = pts.map((p) => p.dy).reduce(math.max); // series min
      for (int i = 0; i < pts.length - 1; i++) {
        for (int k = 0; k <= 200; k++) {
          final y = _bezier(pts[i], cp.c1[i], cp.c2[i], pts[i + 1], k / 200).dy;
          expect(y, greaterThanOrEqualTo(yMin - 1e-6)); // never above the max
          expect(y, lessThanOrEqualTo(yMax + 1e-6)); // never below the min
        }
      }
      _expectMonotone(pts);
    });

    test('sparse data: two points, three points, a single spike, uneven x', () {
      _expectValues([0, 5]);
      _expectValues([5, 0]);
      _expectValues([0, 5, 0]);
      _expectValues([0, 0, 9, 0, 0, 0, 0, 3, 0]);
      _expectMonotone(
        _toPixels([0, 4, 0, 0, 8], xs: const [0, 10, 90, 100, 300]),
      );
    });

    test('degenerate inputs return no segments', () {
      expect(monotoneSplineControlPoints(const []).c1, isEmpty);
      expect(monotoneSplineControlPoints(const [Offset(0, 0)]).c1, isEmpty);
      expect(monotoneSplineControlPoints(const [Offset(0, 0)]).c2, isEmpty);
    });

    test('animation frames (values scaled toward the baseline) stay valid', () {
      for (final progress in [0.0, 0.1, 0.25, 0.5, 0.75, 1.0]) {
        final base = _toPixels([0, 0, 0, 0, 0, 72000]);
        final scaled = [
          for (final p in base) Offset(p.dx, 100 - (100 - p.dy) * progress),
        ];
        _expectMonotone(scaled);
      }
    });

    test('property sweep: 300 random non-negative series', () {
      final rng = math.Random(2026);
      for (int run = 0; run < 300; run++) {
        final n = 2 + rng.nextInt(10);
        final values = List<double>.generate(n, (_) {
          final r = rng.nextInt(4);
          if (r == 0) return 0.0;
          if (r == 1) return rng.nextDouble() * 10;
          if (r == 2) return rng.nextDouble() * 100000;
          return (rng.nextInt(5)).toDouble();
        });
        if (values.every((v) => v == 0)) values[0] = 1;
        _expectValues(values);
      }
    });
  });
}
