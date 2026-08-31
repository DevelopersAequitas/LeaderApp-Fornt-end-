import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/finance_model.dart';

/// Renders a 2x2 Material 3 metrics grid for the Finance dashboard.
class FinanceMetricsGrid extends StatelessWidget {
  final FinanceMetricsModel metrics;

  const FinanceMetricsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  value: metrics.totalRevenue,
                  label: 'Total Revenue',
                  valueColor: const Color(0xFF16A34A),
                  icon: Icons.trending_up_rounded,
                  iconBg: const Color(0xFFDCFCE7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  value: metrics.circleRevenue,
                  label: 'Circle Revenue',
                  valueColor: AppColors.primary,
                  icon: Icons.account_balance_wallet_outlined,
                  iconBg: const Color(0xFFEBF3FB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  value: '${metrics.dealsClosed}',
                  label: 'Deals Closed',
                  valueColor: const Color(0xFFD97706),
                  icon: Icons.handshake_outlined,
                  iconBg: const Color(0xFFFEF3C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  value: metrics.commissionDue,
                  label: 'Commission Due',
                  valueColor: const Color(0xFF2563EB),
                  icon: Icons.percent_rounded,
                  iconBg: const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
    required Color valueColor,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: valueColor, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 20,
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
          ),
        ],
      ),
    );
  }
}
