import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/finance_model.dart';
import 'finance_spline_chart.dart';

/// Renders the Revenue Trend and Business Deals spline charts.
class FinanceChartSection extends StatelessWidget {
  final FinanceMetricsModel metrics;

  const FinanceChartSection({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildChartCard(
          title: 'Revenue Trend',
          subtitle: 'Monthly performance',
          points: metrics.revenueTrend,
          minY: 0.0,
          maxY: 600.0,
          yLabels: const [0, 150, 300, 450, 600],
          lineColor: const Color(0xFF16A34A),
          showTooltip: true,
        ),
        const SizedBox(height: 10),
        _buildChartCard(
          title: 'Business Deals',
          subtitle: 'Volume trend',
          points: metrics.businessDeals,
          minY: 35.0,
          maxY: 140.0,
          yLabels: const [35, 70, 105, 140],
          lineColor: const Color(0xFFD97706),
          showTooltip: false,
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required List<FinanceChartPoint> points,
    required double minY,
    required double maxY,
    required List<double> yLabels,
    required Color lineColor,
    required bool showTooltip,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FinanceSplineChart(
            points: points,
            minY: minY,
            maxY: maxY,
            yLabels: yLabels,
            lineColor: lineColor,
            showMarTooltip: showTooltip,
          ),
        ],
      ),
    );
  }
}
