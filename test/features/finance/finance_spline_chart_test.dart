import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/utils/monotone_spline.dart';
import 'package:leaderapp/features/finance/model/finance_model.dart';
import 'package:leaderapp/features/finance/view/widgets/finance_spline_chart.dart';

/// Evaluates the cubic Bézier of one segment at [t].
Offset _bezier(Offset p0, Offset c1, Offset c2, Offset p3, double t) {
  final u = 1 - t;
  return p0 * (u * u * u) +
      c1 * (3 * u * u * t) +
      c2 * (3 * u * t * t) +
      p3 * (t * t * t);
}

/// Maps a value series to pixel points the same way the painter does
/// (x evenly spaced, y grows downward from the baseline).
List<Offset> _toPixels(List<double> values,
    {double baseline = 100, double height = 100, double width = 300}) {
  final maxV = values.reduce(math.max);
  final seg = values.length > 1 ? width / (values.length - 1) : width;
  return [
    for (int i = 0; i < values.length; i++)
      Offset(i * seg, baseline - (maxV == 0 ? 0 : values[i] / maxV) * height),
  ];
}

void _expectNoOvershoot(List<double> values) {
  const baseline = 100.0;
  final pts = _toPixels(values, baseline: baseline);
  final cp = monotoneSplineControlPoints(pts);
  expect(cp.c1.length, values.length - 1);
  expect(cp.c2.length, values.length - 1);

  for (int i = 0; i < pts.length - 1; i++) {
    final lo = math.min(pts[i].dy, pts[i + 1].dy);
    final hi = math.max(pts[i].dy, pts[i + 1].dy);
    for (int k = 0; k <= 100; k++) {
      final p = _bezier(pts[i], cp.c1[i], cp.c2[i], pts[i + 1], k / 100);
      expect(p.dy, lessThanOrEqualTo(hi + 1e-6),
          reason: 'segment $i t=${k / 100} dips below its lower end point');
      expect(p.dy, greaterThanOrEqualTo(lo - 1e-6),
          reason: 'segment $i t=${k / 100} rises above its upper end point');
      // Non-negative series => curve never below the baseline (value 0).
      expect(p.dy, lessThanOrEqualTo(baseline + 1e-6));
    }
  }
}

void main() {
  group('monotoneSplineControlPoints', () {
    test('Finance revenue shape (zeros then a spike) never dips below zero', () {
      // Jun..Nov: the exact shape reported on the device.
      _expectNoOvershoot([0, 0, 0, 0, 0, 72000]);
    });

    test('Business Deals shape never leaves the range of its end points', () {
      _expectNoOvershoot([0, 0, 0, 3, 0, 4]);
    });

    test('flat, rising, falling and zig-zag series stay inside their ranges', () {
      _expectNoOvershoot([5, 5, 5, 5]);
      _expectNoOvershoot([1, 2, 4, 8, 16]);
      _expectNoOvershoot([16, 8, 4, 2, 1]);
      _expectNoOvershoot([0, 10, 0, 10, 0, 10]);
      _expectNoOvershoot([0, 1]);
    });

    test('curve passes exactly through every data point (values preserved)', () {
      final pts = _toPixels([0, 12, 7, 30, 30, 2]);
      final cp = monotoneSplineControlPoints(pts);
      for (int i = 0; i < pts.length - 1; i++) {
        expect(_bezier(pts[i], cp.c1[i], cp.c2[i], pts[i + 1], 0), pts[i]);
        expect(_bezier(pts[i], cp.c1[i], cp.c2[i], pts[i + 1], 1), pts[i + 1]);
      }
    });

    test('handles degenerate inputs', () {
      expect(monotoneSplineControlPoints(const []).c1, isEmpty);
      expect(monotoneSplineControlPoints(const [Offset(0, 0)]).c1, isEmpty);
    });

    test('animation frames (values scaled toward the baseline) stay valid', () {
      for (final progress in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        _expectNoOvershoot(
            [0.0, 0.0, 0.0, 0.0, 0.0, 72000.0].map((v) => v * progress + 0.0).toList()
              ..[5] = progress == 0 ? 0 : 72000 * progress);
      }
    });
  });

  testWidgets('FinanceSplineChart renders and animates without errors',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinanceSplineChart(
            lineColor: Colors.green,
            points: [
              FinanceChartPoint(month: 'Jun', value: 0),
              FinanceChartPoint(month: 'Jul', value: 0),
              FinanceChartPoint(month: 'Aug', value: 0),
              FinanceChartPoint(month: 'Sep', value: 0),
              FinanceChartPoint(month: 'Oct', value: 0),
              FinanceChartPoint(month: 'Nov', value: 72000),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
