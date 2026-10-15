import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/report_model.dart';
import 'report_history_card.dart';
import 'reports_history_filters.dart';
import 'reports_trend_card.dart';

/// Renders historical reports list, attendance trend spline, and multi-tier filters.
class ReportHistorySection extends StatelessWidget {
  final List<ReportModel> reports;
  final List<ReportsChartPoint> attendanceTrend;
  final String filterType;
  final String filterStatus;
  final String selectedCircle;
  final List<String> availableCircles;
  final ValueChanged<String>? onFilterTypeChanged;
  final ValueChanged<String>? onFilterStatusChanged;
  final ValueChanged<String>? onCircleChanged;

  const ReportHistorySection({
    super.key,
    required this.reports,
    this.attendanceTrend = const [],
    this.filterType = 'all',
    this.filterStatus = 'all',
    this.selectedCircle = '',
    this.availableCircles = const [],
    this.onFilterTypeChanged,
    this.onFilterStatusChanged,
    this.onCircleChanged,
  });

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SquareRoundedGradientIcon(
              icon: Icons.history_edu_rounded,
              iconSize: 28,
              boxSize: 56,
              showBorder: true,
            ),
            SizedBox(height: 14),
            Text(
              'No Reports Found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'No performance reports match the selected filters for this circle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportsTrendCard(attendanceTrend: attendanceTrend),
        const SizedBox(height: 4),
        ReportsHistoryFilters(
          filterType: filterType,
          filterStatus: filterStatus,
          selectedCircle: selectedCircle,
          availableCircles: availableCircles,
          onFilterTypeChanged: onFilterTypeChanged,
          onFilterStatusChanged: onFilterStatusChanged,
          onCircleChanged: onCircleChanged,
        ),
        const SizedBox(height: 8),
        if (reports.isEmpty)
          _buildEmptyState()
        else
          ...reports.map((r) => ReportHistoryCard(report: r)),
      ],
    );
  }
}
