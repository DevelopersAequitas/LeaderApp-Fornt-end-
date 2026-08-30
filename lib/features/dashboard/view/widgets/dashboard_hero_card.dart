import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/dashboard_metrics_model.dart';

/// Renders the luxury dark gradient hero overview banner on the Dashboard.
/// Clean, minimal, and compact layout without redundant role or header tags.
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

    final hasOverallRevenue = metrics.overallRevenue != null &&
        metrics.overallRevenue!.isNotEmpty &&
        metrics.overallRevenue != '₹0.0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary, // #102640 Brand Primary Navy
            Color(0xFF1A3860), // Harmonized Executive Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting only (Role is already in the App Bar)
          Text(
            '${_getGreeting()}, $firstName 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          // Overall Revenue Bar
          if (hasOverallRevenue) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'OVERALL REVENUE',
                    style: TextStyle(
                      color: Color(0xFFB0C4DE),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    metrics.overallRevenue!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // 3-Column Overall Metrics (Impact | Deals | P2P Meetings)
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${metrics.impact}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Impact',
                      style: TextStyle(
                        color: Color(0xFFB0C4DE),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: Colors.white24),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      metrics.deals,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Deals',
                      style: TextStyle(
                        color: Color(0xFFB0C4DE),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: Colors.white24),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${metrics.p2pMeetings}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'P2P Meetings',
                      style: TextStyle(
                        color: Color(0xFFB0C4DE),
                        fontSize: 10.5,
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
