import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/teams_model.dart';

/// Renders a sleek, single-row 4-metric banner with gradient border icons for Teams tab.
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
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
              icon: Icons.groups_outlined,
              value: '$totalCircles',
              label: 'Circles',
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _buildMetricItem(
              icon: Icons.health_and_safety_outlined,
              value: '$avgHealth%',
              label: 'Avg Health',
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _buildMetricItem(
              icon: Icons.people_outline,
              value: '$totalPeers',
              label: 'Total Peers',
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _buildMetricItem(
              icon: Icons.monetization_on_outlined,
              value: totalRevenue,
              label: 'Revenue',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SquareRoundedGradientIcon(
          icon: icon,
          boxSize: 32,
          iconSize: 16,
          borderRadius: 8,
          showBorder: true,
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
