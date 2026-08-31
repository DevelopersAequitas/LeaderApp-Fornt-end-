import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/dashboard_metrics_model.dart';

/// Renders the luxury dark gradient hero overview banner on the Dashboard.
/// Key metrics (Impact, Deals, P2P Meetings, Revenue) are fully interactive and route to their respective peer list views.
class DashboardHeroCard extends StatelessWidget {
  final DashboardMetricsModel metrics;
  final String? selectedCircle;
  final VoidCallback? onImpactTap;
  final VoidCallback? onDealsTap;
  final VoidCallback? onP2PTap;
  final VoidCallback? onRevenueTap;

  const DashboardHeroCard({
    super.key,
    required this.metrics,
    this.selectedCircle,
    this.onImpactTap,
    this.onDealsTap,
    this.onP2PTap,
    this.onRevenueTap,
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
          // Greeting
          Text(
            '${_getGreeting()}, $firstName 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          // Overall Revenue Bar (Clickable to Finance)
          if (hasOverallRevenue) ...[
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRevenueTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: Color(0xFFB0C4DE),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'OVERALL REVENUE',
                            style: TextStyle(
                              color: Color(0xFFB0C4DE),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            metrics.overallRevenue!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // 3-Column Interactive Metrics (Impact | Deals | P2P Meetings)
          Row(
            children: [
              // 1. Impact Metric
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onImpactTap ??
                        () => Navigator.of(context).pushNamed(
                              AppRoutes.peers,
                              arguments: {'sort': 'Impact'},
                            ),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
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
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Impact',
                                style: TextStyle(
                                  color: Color(0xFFB0C4DE),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 12,
                                color: Color(0xFFB0C4DE),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: Colors.white24),
              // 2. Deals Metric
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDealsTap ??
                        () => Navigator.of(context).pushNamed(
                              AppRoutes.peers,
                              arguments: {'sort': 'Deals'},
                            ),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Text(
                            metrics.deals,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Deals',
                                style: TextStyle(
                                  color: Color(0xFFB0C4DE),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 12,
                                color: Color(0xFFB0C4DE),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: Colors.white24),
              // 3. P2P Meetings Metric
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onP2PTap ??
                        () => Navigator.of(context).pushNamed(
                              AppRoutes.peers,
                              arguments: {'sort': 'Attendance'},
                            ),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
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
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'P2P Meetings',
                                style: TextStyle(
                                  color: Color(0xFFB0C4DE),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 12,
                                color: Color(0xFFB0C4DE),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
