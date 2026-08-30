import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/finance_model.dart';

/// Custom spline chart with smooth ease-out entry animation,
/// dynamic auto-scaling Y-axis, and fixed non-overlapping coordinates.
class FinanceSplineChart extends StatefulWidget {
  final List<FinanceChartPoint> points;
  final double? minY;
  final double? maxY;
  final List<double>? yLabels;
  final Color lineColor;
  final bool showMarTooltip;

  const FinanceSplineChart({
    super.key,
    required this.points,
    this.minY,
    this.maxY,
    this.yLabels,
    required this.lineColor,
    this.showMarTooltip = false,
  });

  @override
  State<FinanceSplineChart> createState() => _FinanceSplineChartState();
}

class _FinanceSplineChartState extends State<FinanceSplineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _curveAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant FinanceSplineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic scale calculation from points
    final effectiveMinY = 0.0;
    double maxDataVal = 0.0;
    for (final p in widget.points) {
      if (p.value > maxDataVal) maxDataVal = p.value;
    }

    double effectiveMaxY = widget.maxY ?? 0.0;
    List<double> effectiveYLabels = widget.yLabels ?? const [];

    if (effectiveMaxY <= 0 || effectiveYLabels.isEmpty) {
      final calculated = _calculateNiceScale(maxDataVal);
      effectiveMaxY = widget.maxY ?? calculated.maxY;
      effectiveYLabels = widget.yLabels ?? calculated.yLabels;
    }

    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
      child: AnimatedBuilder(
        animation: _curveAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _SplineChartPainter(
              points: widget.points,
              minY: effectiveMinY,
              maxY: effectiveMaxY,
              yLabels: effectiveYLabels,
              lineColor: widget.lineColor,
              showMarTooltip: widget.showMarTooltip,
              animationProgress: _curveAnimation.value,
            ),
          );
        },
      ),
    );
  }

  /// Calculates rounded, visually balanced step intervals and max Y headroom.
  _NiceScale _calculateNiceScale(double maxVal) {
    if (maxVal <= 0) {
      return _NiceScale(
        maxY: 100,
        yLabels: const [0, 25, 50, 75, 100],
      );
    }

    // Add 25-30% headroom so curves breathe nicely
    final targetMax = maxVal * 1.30;
    double step;

    if (targetMax <= 15) {
      step = 3.0;
    } else if (targetMax <= 40) {
      step = 10.0;
    } else if (targetMax <= 80) {
      step = 20.0;
    } else if (targetMax <= 150) {
      step = 30.0;
    } else if (targetMax <= 300) {
      step = 60.0;
    } else if (targetMax <= 600) {
      step = 120.0;
    } else if (targetMax <= 1200) {
      step = 250.0;
    } else {
      final exp = math.pow(10, (math.log(targetMax / 4) / math.ln10).floor()).toDouble();
      final factor = (targetMax / 4) / exp;
      if (factor <= 1.5) {
        step = 1 * exp;
      } else if (factor <= 3.0) {
        step = 2 * exp;
      } else if (factor <= 6.0) {
        step = 5 * exp;
      } else {
        step = 10 * exp;
      }
    }

    int steps = (targetMax / step).ceil();
    if (steps < 3) steps = 4;
    if (steps > 5) steps = 5;

    final maxY = steps * step;
    final labels = List<double>.generate(steps + 1, (i) => i * step);

    return _NiceScale(maxY: maxY, yLabels: labels);
  }
}

class _NiceScale {
  final double maxY;
  final List<double> yLabels;
  const _NiceScale({required this.maxY, required this.yLabels});
}

class _SplineChartPainter extends CustomPainter {
  final List<FinanceChartPoint> points;
  final double minY;
  final double maxY;
  final List<double> yLabels;
  final Color lineColor;
  final bool showMarTooltip;
  final double animationProgress;

  _SplineChartPainter({
    required this.points,
    required this.minY,
    required this.maxY,
    required this.yLabels,
    required this.lineColor,
    required this.showMarTooltip,
    required this.animationProgress,
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
          (currentX + dashWidth) > end.dx ? end.dx : (currentX + dashWidth),
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
          (currentY + dashHeight) > end.dy ? end.dy : (currentY + dashHeight),
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
    const double rightPadding = 12.0;
    const double topPadding = 14.0;
    const double bottomPadding = 24.0;

    final double chartWidth = size.width - leftPadding - rightPadding;
    final double chartHeight = size.height - topPadding - bottomPadding;
    final double baselineY = topPadding + chartHeight;

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.7)
      ..strokeWidth = 1.0;

    final baselinePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5;

    // 1. Draw vertical dashed grid lines for X axis coordinates
    if (points.isNotEmpty) {
      final double xSegment = points.length > 1 ? chartWidth / (points.length - 1) : chartWidth;
      for (int i = 0; i < points.length; i++) {
        final x = leftPadding + (i * xSegment);
        _drawDashedVerticalLine(
          canvas,
          Offset(x, topPadding),
          Offset(x, baselineY),
          gridPaint,
        );
      }
    }

    // 2. Draw horizontal dashed grid lines and Y-axis labels
    final rangeY = (maxY - minY) > 0 ? (maxY - minY) : 1.0;
    for (final label in yLabels) {
      final yRatio = ((label - minY) / rangeY).clamp(0.0, 1.0);
      final yPos = baselineY - (yRatio * chartHeight);

      // Only draw dashed lines for inner labels, solid for bottom
      if (yRatio > 0.01) {
        _drawDashedHorizontalLine(
          canvas,
          Offset(leftPadding, yPos),
          Offset(size.width - rightPadding, yPos),
          gridPaint,
        );
      }

      final labelText = label >= 1000 ? '${(label / 1000).toStringAsFixed(1)}k' : '${label.toInt()}';
      textPainter.text = TextSpan(
        text: labelText,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftPadding - textPainter.width - 6,
          yPos - textPainter.height / 2,
        ),
      );
    }

    // 3. Draw solid horizontal baseline at the bottom
    canvas.drawLine(
      Offset(leftPadding, baselineY),
      Offset(size.width - rightPadding, baselineY),
      baselinePaint,
    );

    if (points.isEmpty) return;

    // 4. Calculate pixel coordinates with progress scaling
    final double xSegment = points.length > 1 ? chartWidth / (points.length - 1) : chartWidth;
    final List<Offset> pixelPoints = [];

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = leftPadding + (i * xSegment);
      final rawYRatio = ((p.value - minY) / rangeY).clamp(0.0, 1.0);
      final animatedYRatio = rawYRatio * animationProgress;
      final y = baselineY - (animatedYRatio * chartHeight);
      pixelPoints.add(Offset(x, y));
    }

    // 5. Build smooth spline curve
    final int n = pixelPoints.length;
    final List<Offset> controlPoints1 = [];
    final List<Offset> controlPoints2 = [];
    const double factor = 0.18;

    final List<Offset> tangents = List.filled(n, Offset.zero);
    for (int i = 0; i < n; i++) {
      if (n == 1) {
        tangents[i] = Offset.zero;
      } else if (i == 0) {
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

    // 6. Draw Gradient Area Fill under the spline
    if (n > 1) {
      final fillPath = Path();
      fillPath.moveTo(pixelPoints[0].dx, baselineY);
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
      fillPath.lineTo(pixelPoints.last.dx, baselineY);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.18 * animationProgress),
            lineColor.withValues(alpha: 0.01),
          ],
        ).createShader(Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight));

      canvas.drawPath(fillPath, fillPaint);
    }

    // 7. Draw Spline Stroke Line
    final linePath = Path();
    linePath.moveTo(pixelPoints[0].dx, pixelPoints[0].dy);

    if (n > 1) {
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
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // 8. Draw Data Dots and Month X Labels
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final pt = pixelPoints[i];

      // Draw dot with outer white ring
      canvas.drawCircle(pt, 4.0, dotBorderPaint);
      canvas.drawCircle(pt, 2.8, dotPaint);

      // Draw month label strictly below the baseline
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
        Offset(pt.dx - textPainter.width / 2, baselineY + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.points != points ||
        oldDelegate.maxY != maxY;
  }
}

