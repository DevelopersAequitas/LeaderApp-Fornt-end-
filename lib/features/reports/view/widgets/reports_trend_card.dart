import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/report_model.dart';
import 'reports_spline_chart.dart';

/// Card displaying the 6-month circle attendance percentage trend spline.
class ReportsTrendCard extends StatelessWidget {
  final List<ReportsChartPoint> attendanceTrend;

  const ReportsTrendCard({super.key, required this.attendanceTrend});

  @override
  Widget build(BuildContext context) {
    if (attendanceTrend.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SquareRoundedGradientIcon(
                icon: Icons.show_chart_rounded,
                iconSize: 18,
                boxSize: 34,
                showBorder: true,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '6-Month Attendance Trend',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Average monthly circle attendance (%)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Latest: ${attendanceTrend.last.value.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ReportsSplineChart(
            points: attendanceTrend,
            minY: 0.0,
            maxY: 100.0,
            yLabels: const [0, 25, 50, 75, 100],
            lineColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
