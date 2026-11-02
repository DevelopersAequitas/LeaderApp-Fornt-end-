import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/finance_model.dart';

/// Renders a single-row 4-metric banner for the Finance dashboard.
class FinanceMetricsGrid extends StatelessWidget {
  final FinanceMetricsModel metrics;
  final bool isSuperAdmin;

  const FinanceMetricsGrid({
    super.key,
    required this.metrics,
    this.isSuperAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              icon: Icons.trending_up_rounded,
              value: metrics.totalRevenue,
              label: 'Total Revenue',
              valueColor: const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.account_balance_wallet_outlined,
              value: metrics.circleRevenue,
              label: 'Circle Revenue',
              valueColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.handshake_outlined,
              value: '${metrics.dealsClosed}',
              label: 'Deals Closed',
              valueColor: const Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isSuperAdmin
                ? _buildMetricCard(
                    icon: Icons.workspace_premium_outlined,
                    value: '${metrics.activeTenures ?? 42} Active',
                    label: 'Leadership Tenures',
                    valueColor: const Color(0xFFEC4899),
                  )
                : _buildMetricCard(
                    icon: Icons.percent_rounded,
                    value: metrics.commissionDue,
                    label: 'Commission Due',
                    valueColor: const Color(0xFF2563EB),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          SquareRoundedGradientIcon(
            icon: icon,
            iconSize: 18,
            boxSize: 34,
            showBorder: true,
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 25,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
