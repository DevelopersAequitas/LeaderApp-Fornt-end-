import 'dart:ui' show Offset;

/// Converts a polyline into cubic Bézier control points using a monotone cubic
/// Hermite construction (Fritsch–Butland tangents), so the curve is smooth yet
/// never overshoots the data: on every segment the curve's y stays between the
/// y of its two end points. Flat runs (e.g. 0, 0) stay flat, local extrema get
/// a horizontal tangent, and the curve passes exactly through every point.
///
/// Used by the Finance and Reports trend charts so a non-negative series can
/// never be drawn below its baseline.
///
/// Returns one control point pair per segment (`n - 1` entries each, empty for
/// fewer than two points). X values must be strictly increasing.
({List<Offset> c1, List<Offset> c2}) monotoneSplineControlPoints(
  List<Offset> pts,
) {
  final n = pts.length;
  final c1 = <Offset>[];
  final c2 = <Offset>[];
  if (n < 2) return (c1: c1, c2: c2);

  final dx = List<double>.generate(n - 1, (i) => pts[i + 1].dx - pts[i].dx);
  final slope = List<double>.generate(
    n - 1,
    (i) => dx[i] == 0 ? 0.0 : (pts[i + 1].dy - pts[i].dy) / dx[i],
  );

  // Tangent (dy/dx) at every point.
  final m = List<double>.filled(n, 0.0);
  m[0] = slope[0];
  m[n - 1] = slope[n - 2];
  for (int i = 1; i < n - 1; i++) {
    if (slope[i - 1] * slope[i] <= 0) {
      m[i] = 0.0; // local extremum or flat run: no overshoot allowed
    } else {
      final w1 = 2 * dx[i] + dx[i - 1];
      final w2 = dx[i] + 2 * dx[i - 1];
      m[i] = (w1 + w2) / (w1 / slope[i - 1] + w2 / slope[i]);
    }
  }

  for (int i = 0; i < n - 1; i++) {
    final h = dx[i];
    c1.add(Offset(pts[i].dx + h / 3, pts[i].dy + m[i] * h / 3));
    c2.add(Offset(pts[i + 1].dx - h / 3, pts[i + 1].dy - m[i + 1] * h / 3));
  }
  return (c1: c1, c2: c2);
}
