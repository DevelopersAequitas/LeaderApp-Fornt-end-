import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../model/dashboard_metrics_model.dart';

/// Renders the luxury dark gradient hero overview banner on the Dashboard.
class DashboardHeroCard extends StatelessWidget {
  final DashboardMetricsModel metrics;
  final String? selectedCircle;

  const DashboardHeroCard({
    super.key,
    required this.metrics,
    this.selectedCircle,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager().currentSession;
    final firstName =
        session.name.isNotEmpty ? session.name.split(' ').first : 'Leader';
    final activeCircleName = selectedCircle ??
        (session.managedCircles.isNotEmpty
            ? session.managedCircles.first
            : session.regionalScope);

    final scopeLabel = activeCircleName.isNotEmpty
        ? activeCircleName.toUpperCase()
        : (session.customRoleLabel ?? session.role.label).toUpperCase();

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
    final periodText = '${months[now.month - 1]} ${now.year}';

    final hasOverallRevenue = metrics.overallRevenue != null &&
        metrics.overallRevenue!.isNotEmpty &&
        metrics.overallRevenue != '₹0.0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3C72),
            Color(0xFF2A5298),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3C72).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    scopeLabel,
                    style: const TextStyle(
                      color: Color(0xFFB0C4DE),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  periodText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${_getGreeting()}, $firstName 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            session.customRoleLabel ?? session.role.label,
            style: const TextStyle(
              color: Color(0xFFB0C4DE),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasOverallRevenue) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OVERALL REVENUE',
                          style: TextStyle(
                            color: Color(0xFFB0C4DE),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          metrics.overallRevenue!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 26, color: Colors.white24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DEALS CLOSED',
                          style: TextStyle(
                            color: Color(0xFFB0C4DE),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          metrics.overallDealsClosed ?? metrics.deals,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Split metrics display
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${metrics.impact}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Impact',
                      style: TextStyle(
                        color: Color(0xFFB0C4DE),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: Colors.white24),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      metrics.deals,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Deals',
                      style: TextStyle(
                        color: Color(0xFFB0C4DE),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: Colors.white24),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${metrics.p2pMeetings}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'P2P Meetings',
                      style: TextStyle(
                        color: Color(0xFFB0C4DE),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
