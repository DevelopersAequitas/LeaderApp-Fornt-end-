import 'package:flutter/material.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/dashboard_metrics_model.dart';

/// Renders a 2x2 Material 3 metrics grid with navigation triggers.
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
    final session = SessionManager().currentSession;
    final now = DateTime.now();
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final currentMonthYear = '${months[now.month - 1]} ${now.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Key Metrics',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                currentMonthYear,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  value: '${metrics.totalPeers}',
                  label: 'Total Peers',
                  subtitle: session.role == UserRole.superAdmin
                      ? 'Worldwide network'
                      : '+${metrics.totalPeersGrowth} this month',
                  valueColor: const Color(0xFF1E3C72),
                  onTap: onPeersTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  value: '${metrics.referrals}',
                  label: 'Referrals',
                  subtitle: 'this month',
                  valueColor: const Color(0xFF16A34A),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.referrals),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  value: '${metrics.testimonials}',
                  label: 'Testimonials',
                  subtitle: 'peer endorsements',
                  valueColor: const Color(0xFFD97706),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.testimonials),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  value: _formatCompactNumber(metrics.coins),
                  label: 'Coins',
                  subtitle: 'all peers',
                  valueColor: const Color(0xFFB58E3D),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.peersByCoins),
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
    required String subtitle,
    required Color valueColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
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
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade300,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitle.startsWith('+')
                      ? AppColors.textSecondary
                      : Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
