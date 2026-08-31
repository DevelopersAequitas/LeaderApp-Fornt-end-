import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/teams_model.dart';

/// Renders a sleek, compact 4-metric banner for the Teams/Circles tab.
class TeamsMetricsBanner extends StatelessWidget {
  final List<CircleTeamModel> circles;

  const TeamsMetricsBanner({super.key, required this.circles});

  @override
  Widget build(BuildContext context) {
    final totalCircles = circles.length;
    final totalPeers = circles.fold<int>(
      0,
      (sum, c) => sum + c.peersCount,
    );
    final avgHealth = totalCircles == 0
        ? 0
        : (circles.fold<int>(0, (sum, c) => sum + c.healthPercentage) /
                  totalCircles)
              .round();

    double totalRevenueVal = 0.0;
    for (final c in circles) {
      final revStr = c.revenue
          .replaceAll('₹', '')
          .replaceAll('L', '')
          .replaceAll('Cr', '')
          .trim();
      final revVal = double.tryParse(revStr) ?? 0.0;
      totalRevenueVal += revVal;
    }
    final totalRevenue = totalRevenueVal == 0.0
        ? '₹0.0'
        : '₹${totalRevenueVal.toStringAsFixed(1).replaceAll('.0', '')}L';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricItem(
              value: '$totalCircles',
              label: 'Circles',
              valueColor: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          Expanded(
            child: _buildMetricItem(
              value: '$avgHealth%',
              label: 'Avg Health',
              valueColor: const Color(0xFFD97706),
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          Expanded(
            child: _buildMetricItem(
              value: '$totalPeers',
              label: 'Total Peers',
              valueColor: const Color(0xFF16A34A),
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          Expanded(
            child: _buildMetricItem(
              value: totalRevenue,
              label: 'Revenue',
              valueColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
