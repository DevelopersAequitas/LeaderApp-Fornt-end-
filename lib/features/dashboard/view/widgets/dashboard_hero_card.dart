import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../model/dashboard_metrics_model.dart';

/// Renders the 3 Peers Global Unity-styled Hero Metric Cards on the Leader App Dashboard:
/// 1. `Total Revenue` (Theme Emerald Green Gradient) + `assets/images/total_revenue_3d.png`
/// 2. `Lives Impacted` (Theme Brand Pink Gradient) + `assets/images/life_impact_3d.png`
/// 3. `Business Deals` (Theme Brand Blue Gradient) + `assets/images/business_deals_3d.png`
class DashboardHeroCard extends StatelessWidget {
  final DashboardMetricsModel metrics;
  final String? selectedCircle;
  final VoidCallback? onImpactTap;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onDealsTap;
  final VoidCallback? onP2PTap;
  final VoidCallback? onRevenueTap;

  const DashboardHeroCard({
    super.key,
    required this.metrics,
    this.selectedCircle,
    this.onImpactTap,
    this.onCoinsTap,
    this.onDealsTap,
    this.onP2PTap,
    this.onRevenueTap,
  });

  static String _formatCompactNumber(int number) {
    if (number >= 1000000000000000) {
      final val = (number / 1000000000000000).toStringAsFixed(1);
      return '${val.endsWith('.0') ? val.substring(0, val.length - 2) : val}Q';
    }
    if (number >= 1000000000000) {
      final val = (number / 1000000000000).toStringAsFixed(1);
      return '${val.endsWith('.0') ? val.substring(0, val.length - 2) : val}T';
    }
    if (number >= 1000000000) {
      final val = (number / 1000000000).toStringAsFixed(1);
      return '${val.endsWith('.0') ? val.substring(0, val.length - 2) : val}B';
    }
    if (number >= 1000000) {
      final val = (number / 1000000).toStringAsFixed(1);
      return '${val.endsWith('.0') ? val.substring(0, val.length - 2) : val}M';
    }
    if (number >= 1000) {
      final val = (number / 1000).toStringAsFixed(1);
      return '${val.endsWith('.0') ? val.substring(0, val.length - 2) : val}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final hasOverallRevenue =
        metrics.overallRevenue != null &&
        metrics.overallRevenue!.trim().isNotEmpty &&
        metrics.overallRevenue != '₹0.0' &&
        metrics.overallRevenue != '₹0';
    final revenueDisplay = hasOverallRevenue
        ? metrics.overallRevenue!
        : metrics.deals;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          // 1st Card: Total Revenue (Theme Emerald Green Gradient)
          Expanded(
            child: _UnityStyleMetricCard(
              count: revenueDisplay,
              subtitle: 'Total Revenue',
              assetImage: 'assets/images/total_revenue_3d.png',
              gradientColors: const [AppColor.success, AppColor.successDark],
              borderColor: AppColor.successDark,
              arrowColor: AppColor.successDark,
              onTap:
                  onRevenueTap ??
                  () => Navigator.of(context).pushNamed(
                    AppRoutes.leaderActivities,
                    arguments: {
                      'type': 'business-deals',
                      'circleId': ?selectedCircle,
                    },
                  ),
            ),
          ),
          const SizedBox(width: 8),
          // 2nd Card: Lives Impacted (Theme Brand Pink Gradient)
          Expanded(
            child: _UnityStyleMetricCard(
              count: _formatCompactNumber(metrics.impact),
              subtitle: 'Lives Impacted',
              assetImage: 'assets/images/life_impact_3d.png',
              gradientColors: const [AppColor.primaryPink, Color(0xFFBE123C)],
              borderColor: AppColor.primaryPink,
              arrowColor: AppColor.primaryPink,
              onTap:
                  onImpactTap ??
                  () => Navigator.of(context).pushNamed(
                    AppRoutes.leaderActivities,
                    arguments: {'type': 'impacts', 'circleId': ?selectedCircle},
                  ),
            ),
          ),
          const SizedBox(width: 8),
          // 3rd Card: Business Deals (Theme Brand Blue Gradient)
          Expanded(
            child: _UnityStyleMetricCard(
              count: metrics.deals,
              subtitle: 'Business Deals',
              assetImage: 'assets/images/business_deals_3d.png',
              gradientColors: const [Color(0xFF2563EB), AppColor.primaryBlue],
              borderColor: AppColor.primaryBlue,
              arrowColor: AppColor.primaryBlue,
              onTap:
                  onDealsTap ??
                  () => Navigator.of(context).pushNamed(
                    AppRoutes.leaderActivities,
                    arguments: {
                      'type': 'business-deals',
                      'circleId': ?selectedCircle,
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Peers Global Unity 3-Column Hero Metric Card:
/// - Top-left: Count & Subtitle
/// - Bottom-left: Clean circular white arrow button
/// - Bottom-right: Direct high-resolution background-less 3D asset (`assets/images/*.png`)
class _UnityStyleMetricCard extends StatelessWidget {
  final String count;
  final String subtitle;
  final String assetImage;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color arrowColor;
  final VoidCallback onTap;

  const _UnityStyleMetricCard({
    required this.count,
    required this.subtitle,
    required this.assetImage,
    required this.gradientColors,
    required this.borderColor,
    required this.arrowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: arrowColor.withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Top-Left Count & Subtitle
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        count,
                        style: const TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.92),
                          letterSpacing: -0.1,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom-Left Circular White Arrow Button
              Positioned(
                left: 10,
                bottom: 9,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: arrowColor,
                    ),
                  ),
                ),
              ),
              // Bottom-Right Direct High-Resolution 3D Asset Image
              Positioned(
                right: 1,
                bottom: 1,
                child: Image.asset(
                  assetImage,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
