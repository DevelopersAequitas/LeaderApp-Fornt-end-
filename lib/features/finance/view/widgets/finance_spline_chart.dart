import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/finance_model.dart';

/// Custom spline chart painter widget for rendering financial trends.
class FinanceSplineChart extends StatelessWidget {
  final List<FinanceChartPoint> points;
  final double minY;
  final double maxY;
  final List<double> yLabels;
  final Color lineColor;
  final bool showMarTooltip;

  const FinanceSplineChart({
    super.key,
    required this.points,
    required this.minY,
    required this.maxY,
    required this.yLabels,
    required this.lineColor,
    this.showMarTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: CustomPaint(
        painter: _SplineChartPainter(
          points: points,
          minY: minY,
          maxY: maxY,
          yLabels: yLabels,
          lineColor: lineColor,
          showMarTooltip: showMarTooltip,
        ),
      ),
    );
  }
}

class _SplineChartPainter extends CustomPainter {
  final List<FinanceChartPoint> points;
  final double minY;
  final double maxY;
  final List<double> yLabels;
  final Color lineColor;
  final bool showMarTooltip;

  _SplineChartPainter({
    required this.points,
    required this.minY,
    required this.maxY,
    required this.yLabels,
    required this.lineColor,
    required this.showMarTooltip,
  });

  void _drawDashedHorizontalLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double currentX = start.dx;
    while (currentX < end.dx) {
      canvas.drawLine(
        Offset(currentX, start.dy),
        Offset(
          currentX + dashWidth > end.dx ? end.dx : currentX + dashWidth,
          start.dy,
        ),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  void _drawDashedVerticalLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const double dashHeight = 4.0;
    const double dashSpace = 4.0;
    double currentY = start.dy;
    while (currentY < end.dy) {
      canvas.drawLine(
        Offset(start.dx, currentY),
        Offset(
          start.dx,
          currentY + dashHeight > end.dy ? end.dy : currentY + dashHeight,
        ),
        paint,
      );
      currentY += dashHeight + dashSpace;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const double leftPadding = 36.0;
    const double bottomPadding = 26.0;

    final double chartWidth = size.width - leftPadding;
    final double chartHeight = size.height - bottomPadding;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.0;

    final baselinePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5;

    // Draw vertical dashed grid lines for X axis coordinates
    final double xSegment = chartWidth / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final x = leftPadding + (i * xSegment);
      _drawDashedVerticalLine(
        canvas,
        Offset(x, 0),
        Offset(x, chartHeight),
        gridPaint,
      );
    }

    // Draw horizontal dashed grid lines and Y-axis labels
    for (final label in yLabels) {
      final yRatio = (label - minY) / (maxY - minY);
      final yPos = chartHeight - (yRatio * chartHeight);

      _drawDashedHorizontalLine(
        canvas,
        Offset(leftPadding, yPos),
        Offset(size.width, yPos),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: '${label.toInt()}',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftPadding - textPainter.width - 8,
          yPos - textPainter.height / 2,
        ),
      );
    }

    // Draw solid horizontal baseline at the bottom of the chart
    canvas.drawLine(
      Offset(leftPadding, chartHeight),
      Offset(size.width, chartHeight),
      baselinePaint,
    );

    if (points.isEmpty) return;

    final List<Offset> pixelPoints = [];
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = leftPadding + (i * xSegment);
      final yRatio = (p.value - minY) / (maxY - minY);
      final y = chartHeight - (yRatio * chartHeight);
      pixelPoints.add(Offset(x, y));
    }

    // Natural flowing spline tangent calculation
    final int n = pixelPoints.length;
    final List<Offset> controlPoints1 = [];
    final List<Offset> controlPoints2 = [];
    const double factor = 0.20;

    final List<Offset> tangents = List.filled(n, Offset.zero);
    for (int i = 0; i < n; i++) {
      if (i == 0) {
        tangents[i] = (pixelPoints[1] - pixelPoints[0]) * factor;
      } else if (i == n - 1) {
        tangents[i] = (pixelPoints[n - 1] - pixelPoints[n - 2]) * factor;
      } else {
        tangents[i] = (pixelPoints[i + 1] - pixelPoints[i - 1]) * factor;
      }
    }

    for (int i = 0; i < n - 1; i++) {
      controlPoints1.add(pixelPoints[i] + tangents[i]);
      controlPoints2.add(pixelPoints[i + 1] - tangents[i + 1]);
    }

    // 1. Gradient Fill Path under curve
    final fillPath = Path();
    fillPath.moveTo(pixelPoints[0].dx, chartHeight);
    fillPath.lineTo(pixelPoints[0].dx, pixelPoints[0].dy);

    for (int i = 0; i < n - 1; i++) {
      fillPath.cubicTo(
        controlPoints1[i].dx,
        controlPoints1[i].dy,
        controlPoints2[i].dx,
        controlPoints2[i].dy,
        pixelPoints[i + 1].dx,
        pixelPoints[i + 1].dy,
      );
    }
    fillPath.lineTo(pixelPoints.last.dx, chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.12),
          lineColor.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(leftPadding, 0, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // 2. Line Path
    final linePath = Path();
    linePath.moveTo(pixelPoints[0].dx, pixelPoints[0].dy);

    for (int i = 0; i < n - 1; i++) {
      linePath.cubicTo(
        controlPoints1[i].dx,
        controlPoints1[i].dy,
        controlPoints2[i].dx,
        controlPoints2[i].dy,
        pixelPoints[i + 1].dx,
        pixelPoints[i + 1].dy,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // 3. Dots & X labels
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final pt = pixelPoints[i];

      canvas.drawCircle(pt, 4.5, dotBorderPaint);
      canvas.drawCircle(pt, 3.0, dotPaint);

      textPainter.text = TextSpan(
        text: points[i].month,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pt.dx - textPainter.width / 2, chartHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) => true;
}
