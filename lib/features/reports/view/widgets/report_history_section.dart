import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/report_model.dart';
import 'report_history_card.dart';
import 'reports_spline_chart.dart';

/// Renders the list of submitted historical reports, 6-month attendance trend spline, and type/status filters.
class ReportHistorySection extends StatelessWidget {
  final List<ReportModel> reports;
  final List<ReportsChartPoint> attendanceTrend;
  final String filterType;
  final String filterStatus;
  final ValueChanged<String>? onFilterTypeChanged;
  final ValueChanged<String>? onFilterStatusChanged;

  const ReportHistorySection({
    super.key,
    required this.reports,
    this.attendanceTrend = const [],
    this.filterType = 'all',
    this.filterStatus = 'all',
    this.onFilterTypeChanged,
    this.onFilterStatusChanged,
  });

  Widget _buildTrendChartCard() {
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Average monthly circle attendance (%)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (attendanceTrend.isNotEmpty)
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
                      fontWeight: FontWeight.w600,
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

  Widget _buildFilterChips() {
    const typeFilters = ['all', 'Monthly', 'Weekly', 'Quarterly', 'Annual'];
    const statusFilters = ['all', 'Approved', 'Under Review', 'Draft'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Type Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: typeFilters.map((t) {
                final isSelected = filterType.toLowerCase() == t.toLowerCase();
                final label = t == 'all' ? 'All Types' : t;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => onFilterTypeChanged?.call(t),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.brandGradient : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Status Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statusFilters.map((s) {
                final isSelected = filterStatus.toLowerCase() == s.toLowerCase();
                final label = s == 'all' ? 'All Statuses' : s;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => onFilterStatusChanged?.call(s),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEBF3FB) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SquareRoundedGradientIcon(
              icon: Icons.history_edu_rounded,
              iconSize: 28,
              boxSize: 56,
              showBorder: true,
            ),
            const SizedBox(height: 14),
            const Text(
              'No Reports Found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No performance reports match the selected filters for this circle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
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
        // 6-Month Attendance Trend Chart
        _buildTrendChartCard(),
        const SizedBox(height: 4),
        // Filter bar
        _buildFilterChips(),
        const SizedBox(height: 8),
        // Reports list or empty state
        if (reports.isEmpty)
          _buildEmptyState()
        else
          ...reports.map((r) => ReportHistoryCard(report: r)),
      ],
    );
  }
}
