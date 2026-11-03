import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/three_d_number_display.dart';
import '../../model/dashboard_metrics_model.dart';

/// Represents a single user-input activity metric item inside a Dome Tab:
/// - `value` (count) is displayed inside the 56x56 rounded square badge in brand gradient.
/// - `label` (section name) is displayed outside below the badge.
class _DashboardActivityTileItem {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DashboardActivityTileItem({
    required this.label,
    required this.value,
    required this.onTap,
  });
}

/// Configuration for each main tab in the Dome Header.
class _DashboardDomeTab {
  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<_DashboardActivityTileItem> items;

  const _DashboardDomeTab({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.items,
  });
}

/// Renders all user-input activity counts across the Peers Global Unity ecosystem
/// using the `SwiggyDomePainter` + `HomeDomeTabHeader` layout with Leader App
/// category tabs (`Activity`, `Asks`, `Community`, `Leadership`) and 4-per-row
/// items where ONLY the gradient count is inside the 56x56 badge and the section
/// name is outside below it.
class DashboardKeyMetricsGrid extends StatefulWidget {
  final DashboardMetricsModel metrics;
  final VoidCallback onPeersTap;
  final String? selectedCircle;

  const DashboardKeyMetricsGrid({
    super.key,
    required this.metrics,
    required this.onPeersTap,
    this.selectedCircle,
  });

  @override
  State<DashboardKeyMetricsGrid> createState() =>
      _DashboardKeyMetricsGridState();
}

class _DashboardKeyMetricsGridState extends State<DashboardKeyMetricsGrid> {
  int _selectedTabIndex = 0;

  String _formatCompactNumber(dynamic value) {
    if (value == null) return '0';
    int? numVal;
    if (value is int) {
      numVal = value;
    } else {
      numVal = int.tryParse(value.toString().replaceAll(',', '').trim());
    }
    if (numVal == null) return value.toString();

    if (numVal >= 1000000000000000) {
      final val = (numVal / 1000000000000000).toStringAsFixed(1);
      return '${val.endsWith('.0') ? val.substring(0, val.length - 2) : val}Q';
    }
    if (numVal >= 1000000000000) {
      final val = (numVal / 1000000000000).toStringAsFixed(1);
      return '${val.endsWith('.0') ? val.substring(0, val.length - 2) : val}T';
    }
    if (numVal >= 1000000000) {
      final val = (numVal / 1000000000).toStringAsFixed(1);
      return '${val.endsWith('.0') ? val.substring(0, val.length - 2) : val}B';
    }
    if (numVal >= 1000000) {
      final val = (numVal / 1000000).toStringAsFixed(1);
      return '${val.endsWith('.0') ? val.substring(0, val.length - 2) : val}M';
    }
    if (numVal >= 100000) {
      final val = (numVal / 1000).toStringAsFixed(0);
      return '${val}K';
    }
    return '$numVal';
  }

  void _openLeaderActivity(BuildContext context, String type) {
    Navigator.of(context).pushNamed(
      AppRoutes.leaderActivities,
      arguments: {'type': type, 'circleId': ?widget.selectedCircle},
    );
  }

  List<_DashboardDomeTab> _buildDomeTabs(BuildContext context) {
    final m = widget.metrics;
    return [
      // 1. Activity — Peer Networking & Daily Actions (8 items = 2 full rows of 4)
      _DashboardDomeTab(
        id: 'activity',
        title: 'Activity',
        icon: Icons.bolt_rounded,
        accentColor: const Color(0xFFE11D48),
        items: [
          _DashboardActivityTileItem(
            label: 'Peers',
            value: _formatCompactNumber(m.totalPeers),
            onTap: () => _openLeaderActivity(context, 'peers'),
          ),
          _DashboardActivityTileItem(
            label: 'P2P Meetings',
            value: _formatCompactNumber(m.p2pMeetings),
            onTap: () => _openLeaderActivity(context, 'p2p-meetings'),
          ),
          _DashboardActivityTileItem(
            label: 'Referrals',
            value: _formatCompactNumber(m.referrals),
            onTap: () => _openLeaderActivity(context, 'referrals'),
          ),
          _DashboardActivityTileItem(
            label: 'Endorsements',
            value: _formatCompactNumber(m.testimonials),
            onTap: () => _openLeaderActivity(context, 'testimonials'),
          ),
          _DashboardActivityTileItem(
            label: 'Visitor Registrations',
            value: _formatCompactNumber(m.visitorRegistrations),
            onTap: () => _openLeaderActivity(context, 'visitor-registrations'),
          ),
          _DashboardActivityTileItem(
            label: 'Peer Recommendations',
            value: _formatCompactNumber(m.peerRecommendations),
            onTap: () => _openLeaderActivity(context, 'peer-recommendations'),
          ),
          _DashboardActivityTileItem(
            label: 'Peers Introduced',
            value: _formatCompactNumber(m.introducedPeers),
            onTap: () => _openLeaderActivity(context, 'introduced-peers'),
          ),
          if (SessionManager().currentRole.canModeratePendingRequests)
            _DashboardActivityTileItem(
              label: 'Pending Approvals',
              value: _formatCompactNumber(m.pendingRequestsCount),
              onTap: () => _openLeaderActivity(context, 'pending-requests'),
            )
          else
            _DashboardActivityTileItem(
              label: 'Deals',
              value: _formatCompactNumber(m.dealsCount),
              onTap: () => _openLeaderActivity(context, 'business-deals'),
            ),
        ],
      ),

      // 2. Asks — 3 flows + Requirements, then status breakdown (8 items = 2 full rows of 4)
      _DashboardDomeTab(
        id: 'asks',
        title: 'Asks',
        icon: Icons.handshake_rounded,
        accentColor: const Color(0xFF7C3AED),
        items: [
          _DashboardActivityTileItem(
            label: 'Collaboration Asks',
            value: _formatCompactNumber(m.collaborationAsks),
            onTap: () => _openLeaderActivity(context, 'collaboration-asks'),
          ),
          _DashboardActivityTileItem(
            label: 'Referral Asks',
            value: _formatCompactNumber(m.referralAsks),
            onTap: () => _openLeaderActivity(context, 'referral-asks'),
          ),
          _DashboardActivityTileItem(
            label: 'Help Asks',
            value: _formatCompactNumber(m.helpAsks),
            onTap: () => _openLeaderActivity(context, 'help-asks'),
          ),
          _DashboardActivityTileItem(
            label: 'Requirements',
            value: _formatCompactNumber(m.requirements),
            onTap: () => _openLeaderActivity(context, 'requirements'),
          ),
          _DashboardActivityTileItem(
            label: 'All Asks',
            value: _formatCompactNumber(m.allAsks),
            onTap: () => _openLeaderActivity(context, 'all-asks'),
          ),
          _DashboardActivityTileItem(
            label: 'Open Asks',
            value: _formatCompactNumber(m.openAsks),
            onTap: () => _openLeaderActivity(context, 'open-asks'),
          ),
          _DashboardActivityTileItem(
            label: 'In Progress Asks',
            value: _formatCompactNumber(m.inProgressAsks),
            onTap: () => _openLeaderActivity(context, 'in-progress-asks'),
          ),
          _DashboardActivityTileItem(
            label: 'Fulfilled Asks',
            value: _formatCompactNumber(m.fulfilledAsks),
            onTap: () => _openLeaderActivity(context, 'fulfilled-asks'),
          ),
        ],
      ),

      // 3. Community — Coins, Timeline Posts, Creatives, Stories, Certifications & Circulars (8 items = 2 full rows of 4)
      _DashboardDomeTab(
        id: 'community',
        title: 'Community',
        icon: Icons.emoji_events_rounded,
        accentColor: const Color(0xFFF59E0B),
        items: [
          _DashboardActivityTileItem(
            label: 'Total Coins',
            value: _formatCompactNumber(m.coins),
            onTap: () => _openLeaderActivity(context, 'coins'),
          ),
          _DashboardActivityTileItem(
            label: 'Coin Claims',
            value: _formatCompactNumber(m.coinClaims),
            onTap: () => _openLeaderActivity(context, 'coin-claims'),
          ),
          _DashboardActivityTileItem(
            label: 'Timeline Posts',
            value: _formatCompactNumber(m.posts),
            onTap: () => _openLeaderActivity(context, 'posts'),
          ),
          _DashboardActivityTileItem(
            label: 'Activity Creatives',
            value: _formatCompactNumber(m.creatives),
            onTap: () => _openLeaderActivity(context, 'creatives'),
          ),
          _DashboardActivityTileItem(
            label: 'Business Stories',
            value: _formatCompactNumber(m.stories),
            onTap: () => _openLeaderActivity(context, 'stories'),
          ),
          _DashboardActivityTileItem(
            label: 'Entrepreneur Certs',
            value: _formatCompactNumber(
              m.entrepreneurCertifications > 0
                  ? m.entrepreneurCertifications
                  : m.certifications,
            ),
            onTap: () =>
                _openLeaderActivity(context, 'entrepreneur-certifications'),
          ),
          _DashboardActivityTileItem(
            label: 'Leadership Certs',
            value: _formatCompactNumber(
              m.leadershipCertifications > 0
                  ? m.leadershipCertifications
                  : m.leadershipInterests,
            ),
            onTap: () =>
                _openLeaderActivity(context, 'leadership-certifications'),
          ),
          _DashboardActivityTileItem(
            label: 'Official Circulars',
            value: _formatCompactNumber(m.circulars),
            onTap: () => _openLeaderActivity(context, 'circulars'),
          ),
        ],
      ),

      // 4. Leadership — Events, Leadership Interest, Mentors, Speakers, Partners & Leaderboards (8 items = 2 full rows of 4)
      _DashboardDomeTab(
        id: 'leadership',
        title: 'Leadership',
        icon: Icons.workspace_premium_rounded,
        accentColor: const Color(0xFF059669),
        items: [
          _DashboardActivityTileItem(
            label: 'Event Registrations',
            value: _formatCompactNumber(m.eventRegistrations),
            onTap: () => _openLeaderActivity(context, 'event-registrations'),
          ),
          _DashboardActivityTileItem(
            label: 'Event Attendance',
            value: _formatCompactNumber(m.eventAttendance),
            onTap: () => _openLeaderActivity(context, 'event-attendance'),
          ),
          _DashboardActivityTileItem(
            label: 'Leadership Interest',
            value: _formatCompactNumber(m.leadershipInterests),
            onTap: () => _openLeaderActivity(context, 'leadership-interests'),
          ),
          _DashboardActivityTileItem(
            label: 'Become a Mentor',
            value: _formatCompactNumber(m.mentorApplications),
            onTap: () => _openLeaderActivity(context, 'mentor-applications'),
          ),
          _DashboardActivityTileItem(
            label: 'Become a Speaker',
            value: _formatCompactNumber(m.speakerApplications),
            onTap: () => _openLeaderActivity(context, 'speaker-applications'),
          ),
          _DashboardActivityTileItem(
            label: 'Partner Inquiries',
            value: _formatCompactNumber(m.partnerInquiries),
            onTap: () => _openLeaderActivity(context, 'partner-inquiries'),
          ),
          _DashboardActivityTileItem(
            label: 'Top Contributors',
            value: _formatCompactNumber(m.totalPeers),
            onTap: () => _openLeaderActivity(context, 'top-contributors'),
          ),
          _DashboardActivityTileItem(
            label: 'Highest Givers',
            value: _formatCompactNumber(m.referrals),
            onTap: () => _openLeaderActivity(context, 'highest-givers'),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = _buildDomeTabs(context);
    final safeIndex = _selectedTabIndex.clamp(0, tabs.length - 1);
    final activeTab = tabs[safeIndex];

    final bgFill = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? activeTab.accentColor.withValues(alpha: 0.5)
        : const Color(0xFF334155).withValues(alpha: 0.25);
    final baselineColor = isDark
        ? Colors.white12
        : const Color(0xFF334155).withValues(alpha: 0.18);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: safeIndex.toDouble(),
        end: safeIndex.toDouble(),
      ),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
      builder: (context, animatedIndex, _) {
        return CustomPaint(
          painter: _SwiggyDomePainter(
            selectedIndex: animatedIndex,
            tabCount: tabs.length,
            backgroundColor: bgFill,
            borderColor: borderColor,
            baselineColor: baselineColor,
            tabHeaderHeight: 74.0,
            borderWidth: 1.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dome Tab Header (Activity, Asks, Community, Leadership)
              SizedBox(
                height: 74,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(tabs.length, (index) {
                    final tab = tabs[index];
                    final isSelected = index == safeIndex;
                    return Expanded(
                      child: _buildDomeTabItem(
                        tab: tab,
                        index: index,
                        isSelected: isSelected,
                        isDark: isDark,
                        totalTabs: tabs.length,
                      ),
                    );
                  }),
                ),
              ),
              // Animated 4-per-row Subsections Grid inside the Dome
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<String>(activeTab.id),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 12, 6, 14),
                    child: _buildAlignedFourColumnRows(activeTab.items, isDark),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDomeTabItem({
    required _DashboardDomeTab tab,
    required int index,
    required bool isSelected,
    required bool isDark,
    required int totalTabs,
  }) {
    final textColor = isSelected
        ? (isDark ? Colors.white : const Color(0xFF0F172A))
        : (isDark ? Colors.white54 : const Color(0xFF64748B));

    final isFirst = index == 0;
    final isLast = index == totalTabs - 1;

    return Padding(
      padding: EdgeInsets.only(
        left: isFirst ? 0 : 1.5,
        right: isLast ? 0 : 1.5,
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isSelected ? 16 : 14),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.only(
            top: isSelected ? 4 : 8,
            bottom: 4,
            left: 2,
            right: 2,
          ),
          decoration: isSelected
              ? null
              : BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : const Color(0xFFF8FAFC).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isFirst || isLast ? 16 : 14),
                  ),
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: isSelected
                      ? tab.accentColor
                      : tab.accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: tab.accentColor.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    tab.icon,
                    size: 18,
                    color: isSelected ? Colors.white : tab.accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tab.title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  fontSize: 10.5,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlignedFourColumnRows(
    List<_DashboardActivityTileItem> items,
    bool isDark,
  ) {
    final List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 4) {
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: 10));
      }
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int col = 0; col < 4; col++)
                Expanded(
                  child: (i + col < items.length)
                      ? _buildSquareSectionItem(items[i + col], isDark)
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  /// Peers Global Unity `HomeDomeSubPillsBar` item style:
  /// - 56x56 rounded square container with ONLY the gradient count inside
  /// - Full section name outside below the 56x56 container
  Widget _buildSquareSectionItem(_DashboardActivityTileItem item, bool isDark) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColor.primaryBlue.withValues(alpha: 0.12),
        highlightColor: AppColor.primaryBlue.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 56x56 Square Badge containing the 3D Transparent Number Images (0-9)
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2433)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0).withValues(alpha: 0.9),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.25 : 0.03,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: ThreeDNumberDisplay(
                    value: item.value,
                    digitHeight: 28,
                    spacing: -1.5,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              // Section Name OUTSIDE below the 56x56 badge
              Text(
                item.label,
                style: TextStyle(
                  color: isDark
                      ? AppColor.darkTextPrimary
                      : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                  fontSize: 10.5,
                  letterSpacing: -0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Exact Peers Global Unity `SwiggyDomePainter` that draws the curved dome contour
/// around the selected tab and the subsection grid container below it.
class _SwiggyDomePainter extends CustomPainter {
  final double selectedIndex;
  final int tabCount;
  final Color backgroundColor;
  final Color borderColor;
  final Color baselineColor;
  final double tabHeaderHeight;
  final double borderWidth;

  const _SwiggyDomePainter({
    required this.selectedIndex,
    this.tabCount = 4,
    required this.backgroundColor,
    required this.borderColor,
    required this.baselineColor,
    this.tabHeaderHeight = 74.0,
    this.borderWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tabCount <= 0) return;

    final W = size.width;
    final H = size.height;
    final tabWidth = W / tabCount;
    const tabRadius = 14.0;
    const flareRadius = 8.0;
    const tabTop = 4.0;
    final baseH = tabHeaderHeight;

    final rawLeft = selectedIndex * tabWidth;
    final rawRight = (selectedIndex + 1) * tabWidth;
    final x0 = rawLeft.clamp(0.0, W);
    final x1 = rawRight.clamp(0.0, W);

    final isFirst = x0 <= 0.5;
    final isLast = x1 >= W - 0.5;

    final unifiedPath = Path();
    unifiedPath.moveTo(0, baseH);

    if (!isFirst) {
      unifiedPath.lineTo((x0 - flareRadius).clamp(0.0, W), baseH);
      unifiedPath.quadraticBezierTo(x0, baseH, x0, baseH - flareRadius);
      unifiedPath.lineTo(x0, tabTop + tabRadius);
      unifiedPath.arcToPoint(
        Offset(x0 + tabRadius, tabTop),
        radius: const Radius.circular(tabRadius),
      );
    } else {
      unifiedPath.lineTo(0, tabTop + tabRadius);
      unifiedPath.arcToPoint(
        const Offset(tabRadius, tabTop),
        radius: const Radius.circular(tabRadius),
      );
    }

    if (!isLast) {
      unifiedPath.lineTo(x1 - tabRadius, tabTop);
      unifiedPath.arcToPoint(
        Offset(x1, tabTop + tabRadius),
        radius: const Radius.circular(tabRadius),
      );
      unifiedPath.lineTo(x1, baseH - flareRadius);
      unifiedPath.quadraticBezierTo(
        x1,
        baseH,
        (x1 + flareRadius).clamp(0.0, W),
        baseH,
      );
      unifiedPath.lineTo(W, baseH);
    } else {
      unifiedPath.lineTo(W - tabRadius, tabTop);
      unifiedPath.arcToPoint(
        Offset(W, tabTop + tabRadius),
        radius: const Radius.circular(tabRadius),
      );
      unifiedPath.lineTo(W, baseH);
    }

    unifiedPath.lineTo(W, H);
    unifiedPath.lineTo(0, H);
    unifiedPath.close();

    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(unifiedPath, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(unifiedPath, borderPaint);

    final baseLinePaint = Paint()
      ..color = baselineColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    if (!isFirst) {
      final leftEnd = (x0 - flareRadius).clamp(0.0, W);
      if (leftEnd > 0) {
        canvas.drawLine(
          Offset(0, baseH),
          Offset(leftEnd, baseH),
          baseLinePaint,
        );
      }
    }

    if (!isLast) {
      final rightStart = (x1 + flareRadius).clamp(0.0, W);
      if (rightStart < W) {
        canvas.drawLine(
          Offset(rightStart, baseH),
          Offset(W, baseH),
          baseLinePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SwiggyDomePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.baselineColor != baselineColor;
  }
}
