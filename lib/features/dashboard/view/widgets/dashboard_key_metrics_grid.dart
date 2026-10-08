import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_widgets.dart';
import '../../model/dashboard_metrics_model.dart';

/// Renders key metrics in a single horizontal row with square covered gradient icons.
class DashboardKeyMetricsGrid extends StatelessWidget {
  final DashboardMetricsModel metrics;
  final VoidCallback onPeersTap;

  const DashboardKeyMetricsGrid({
    super.key,
    required this.metrics,
    required this.onPeersTap,
  });

  String _formatCompactNumber(dynamic value) {
    if (value == null) return '0';
    int? numVal;
    if (value is int) {
      numVal = value;
    } else {
      numVal = int.tryParse(value.toString().replaceAll(',', '').trim());
    }
    if (numVal == null) return value.toString();
    if (numVal >= 1000000) {
      final double inM = numVal / 1000000.0;
      return '${inM.toStringAsFixed(inM.truncateToDouble() == inM ? 0 : 1)}M';
    } else if (numVal >= 1000) {
      final double inK = numVal / 1000.0;
      return '${inK.toStringAsFixed(inK.truncateToDouble() == inK ? 0 : 1)}k';
    }
    return '$numVal';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Key Metrics',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.people_alt_rounded,
                  value: '${metrics.totalPeers}',
                  label: 'Peers',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.swap_horiz_rounded,
                  value: '${metrics.referrals}',
                  label: 'Referrals',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.star_rounded,
                  value: '${metrics.testimonials}',
                  label: 'Endorsement',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.monetization_on_rounded,
                  value: _formatCompactNumber(metrics.coins),
                  label: 'Coins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SquareRoundedGradientIcon(
            icon: icon,
            iconSize: 16,
            boxSize: 30,
            borderRadius: 8,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
