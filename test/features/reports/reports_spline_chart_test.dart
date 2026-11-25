import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/features/reports/model/report_model.dart';
import 'package:leaderapp/features/reports/view/widgets/reports_spline_chart.dart';

const _lineColor = Color(0xFF00FF00); // pure green: easy to find in pixels
const _chartKey = ValueKey('chart');

// Geometry of ReportsSplineChart (widget height 200, padding L4 T8 R8 B4;
// painter paddings: left 36, top 14, right 12, bottom 24).
const _widgetWidth = 360.0;
const _baselineY = 8 + (200 - 8 - 4 - 24); // 172 in widget coordinates

Widget _chart(List<double> values) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: _chartKey,
          child: Container(
            color: Colors.white,
            width: _widgetWidth,
            child: ReportsSplineChart(
              lineColor: _lineColor,
              points: [
                for (int i = 0; i < values.length; i++)
                  ReportsChartPoint(month: 'M$i', value: values[i]),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

bool _isLineGreen(int r, int g, int b) => g > 200 && r < 110 && b < 110;

Future<({int below, int above})> _countLinePixels(
  WidgetTester tester,
) async {
  late Uint8List rgba;
  late int width;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_chartKey),
    );
    final image = await boundary.toImage(pixelRatio: 1.0);
    width = image.width;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    rgba = data!.buffer.asUint8List();
  });

  // The strip 5..9 px under the baseline is below the 4 px dot ring and above
  // the month labels (drawn from baseline + 6 in grey/black, never green).
  int count(int y0, int y1) {
    var n = 0;
    for (int y = y0; y < y1; y++) {
      for (int x = 0; x < width; x++) {
        final i = (y * width + x) * 4;
        if (_isLineGreen(rgba[i], rgba[i + 1], rgba[i + 2])) n++;
      }
    }
    return n;
  }

  // Need the box's offset inside the screenshot: the boundary is exactly the
  // container, so widget coordinates equal image coordinates.
  return (
    below: count(_baselineY + 5, _baselineY + 9),
    above: count(14, _baselineY - 1),
  );
}

void main() {
  group('ReportsSplineChart never draws below the baseline', () {
    final datasets = <String, List<double>>{
      'all zero': [0, 0, 0, 0, 0, 0],
      'constant': [40, 40, 40, 40, 40, 40],
      'increasing': [5, 10, 20, 40, 80, 160],
      'decreasing': [160, 80, 40, 20, 10, 5],
      'zeros then a large spike (Finance-like)': [0, 0, 0, 0, 0, 72000],
      'spike in the middle': [0, 0, 100, 0, 0, 0],
      'large differences': [1, 1000000, 1, 1000000, 1, 5],
      'sparse (two points)': [0, 75],
      'sparse (mostly zero, scattered)': [0, 0, 9, 0, 0, 0, 0, 3, 0],
      'single point': [50],
    };

    datasets.forEach((name, values) {
      testWidgets(name, (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(400, 600);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_chart(values));
        await tester.pumpAndSettle(); // let the 950 ms entrance animation end
        expect(tester.takeException(), isNull);

        final px = await _countLinePixels(tester);
        expect(px.below, 0,
            reason: '"$name": line pixels found below the zero baseline');

        // Positive control: charts with some non-zero value draw a line above
        // the baseline, so the pixel scan is really seeing the curve.
        if (values.any((v) => v > 0)) {
          expect(px.above, greaterThan(0), reason: '"$name": no line drawn');
        }
      });
    });
  });

  testWidgets('empty series renders without errors', (tester) async {
    await tester.pumpWidget(_chart(const []));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('animation frames never go below the baseline either',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_chart(const [0, 0, 0, 0, 0, 72000]));
    for (final ms in [80, 160, 240, 320, 480]) {
      await tester.pump(const Duration(milliseconds: 80));
      final px = await _countLinePixels(tester);
      expect(px.below, 0, reason: 'frame at ~$ms ms dips below the baseline');
    }
    await tester.pumpAndSettle();
  });
}
