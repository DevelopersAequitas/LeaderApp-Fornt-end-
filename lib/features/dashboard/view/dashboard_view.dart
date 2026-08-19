import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../peers/view/peers_view.dart';
import '../../teams/view/teams_view.dart';
import '../../finance/view/finance_view.dart';
import '../../reports/view/reports_view.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
import '../model/dashboard_metrics_model.dart';
import '../model/impacter_model.dart';
import '../presenter/dashboard_presenter.dart';

/// The View component of the Circle Chair Dashboard feature.
/// Renders a highly polished dashboard layout including banner stats, key metrics,
/// a list of top impacters, and a tabbed navigation bar.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    implements DashboardViewContract {
  late final DashboardBloc _bloc;
  late final DashboardPresenter _presenter;

  int _activeTab = 0;
  bool _isLoading = false;
  DashboardMetricsModel? _metrics;
  List<ImpacterModel> _impacters = const [];
  String? _selectedCircle;

  @override
  void initState() {
    super.initState();
    _bloc = DashboardBloc();
    _presenter = DashboardPresenter(view: this, bloc: _bloc);
    _presenter.load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- DashboardViewContract Implementations ---

  @override
  void onDashboardLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void onDashboardLoaded() {
    setState(() {
      _isLoading = false;
      _metrics = _bloc.state.metrics;
      _impacters = _bloc.state.impacters;
      _selectedCircle = _bloc.state.selectedCircle;
    });
  }

  @override
  void onDashboardError(String error) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void onTabUpdated(int activeIndex) {
    if (_activeTab != activeIndex) {
      setState(() {
        _activeTab = activeIndex;
      });
    }
  }

  // --- UI Widget Helpers ---

  Widget _buildAppBar() {
    final session = SessionManager().currentSession;
    final initials = session.name
        .split(' ')
        .map((n) => n[0])
        .take(2)
        .join()
        .toUpperCase();
    final isIndustryDirector = session.role == UserRole.industryDirector;
    final activeCircleName = _activeTab == 2
        ? 'Technology'
        : (_selectedCircle ??
              (isIndustryDirector ||
                      session.role == UserRole.districtExecDirector ||
                      session.role == UserRole.countryDirector ||
                      session.role == UserRole.superAdmin
                  ? 'Technology'
                  : (session.managedCircles.isNotEmpty
                        ? session.managedCircles.first
                        : '')));

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Left Node Logo Badge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/icons/whitelogo.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                // Header Titles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PEERS Global',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activeCircleName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Right Control Buttons
                IconButton(
                  icon: const Icon(Icons.shield_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.notifications),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.profile),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.12),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_activeTab != 2) ...[
              if (isIndustryDirector) ...[
                const SizedBox(height: 16),
                _buildCircleSelectionRow(const [
                  'Technology',
                  'Healthcare',
                  'Startups',
                ]),
              ] else if (session.managedCircles.length > 1 &&
                  session.role != UserRole.districtExecDirector) ...[
                const SizedBox(height: 16),
                _buildCircleSelectionRow(session.managedCircles),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCircleSelectionRow(List<String> circles) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: circles.map((circle) {
          final isSelected = _selectedCircle == circle;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  _presenter.selectCircle(circle);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      circle,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

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

  Widget _buildHeroCard(DashboardMetricsModel metrics) {
    final session = SessionManager().currentSession;
    final firstName = session.name.split(' ').first;
    final isIndustryDirector = session.role == UserRole.industryDirector;
    final activeCircleName =
        _selectedCircle ??
        (isIndustryDirector
            ? 'Technology'
            : (session.managedCircles.isNotEmpty
                  ? session.managedCircles.first
                  : ''));

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A60),
            Color(0xFF102640),
          ], // Premium blue gradient as shown in design
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isIndustryDirector
                        ? '${activeCircleName.toUpperCase()} INDUSTRY'
                        : (session.role == UserRole.districtExecDirector
                              ? 'MUMBAI DISTRICT'
                              : (session.role == UserRole.countryDirector
                                    ? 'NATIONAL OVERVIEW - INDIA'
                                    : (session.role == UserRole.superAdmin
                                          ? 'WORLDWIDE - GLOBAL'
                                          : activeCircleName.toUpperCase()))),
                    style: const TextStyle(
                      color: Color(0xFF8B9CB4),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Text(
                'Aug 2026',
                style: TextStyle(
                  color: Color(0xFF8B9CB4),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_getGreeting()}, $firstName 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session.role.label,
            style: const TextStyle(
              color: Color(0xFF8B9CB4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          // Split metrics display
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${metrics.impact}',
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Impact',
                      style: TextStyle(
                        color: Color(0xFF8B9CB4),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white12),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      metrics.deals,
                      style: const TextStyle(
                        color: Color(0xFFFFAB00),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Deals',
                      style: TextStyle(
                        color: Color(0xFF8B9CB4),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white12),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${metrics.p2pMeetings}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'P2P Meetings',
                      style: TextStyle(
                        color: Color(0xFF8B9CB4),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF3)),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitle.startsWith('+')
                          ? const Color(0xFF8B9CB4)
                          : Colors.grey.shade400,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade300,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(DashboardMetricsModel metrics) {
    final session = SessionManager().currentSession;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Key Metrics',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Jul 2026',
                style: TextStyle(
                  color: Color(0xFF8B9CB4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 2x2 Grid using rows
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  value: '${metrics.totalPeers}',
                  label: 'Total Peers',
                  subtitle: session.role == UserRole.superAdmin
                      ? '12 circles worldw...'
                      : '+${metrics.totalPeersGrowth} this month',
                  valueColor: const Color(0xFF102640),
                  onTap: () => _presenter.changeTab(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  value: '${metrics.referrals}',
                  label: 'Referrals',
                  subtitle: 'this month',
                  valueColor: const Color(0xFF00C853),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.referrals),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  value: '${metrics.testimonials}',
                  label: 'Testimonials',
                  subtitle: 'peer endorsements',
                  valueColor: const Color(0xFFFF9100),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.testimonials),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  value: '3,840', // Hardcoded formatted coin string
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

  Widget _buildImpacterTile(ImpacterModel impacter) {
    // Top 5 rank badge colors
    Color badgeColor = const Color(0xFF78909C);
    if (impacter.rank == 1) {
      badgeColor = const Color(0xFFD87D32);
    } else if (impacter.rank == 2) {
      badgeColor = const Color(0xFF32567D);
    } else if (impacter.rank == 3) {
      badgeColor = const Color(0xFF2E7D32);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          // Rank-Badged Initials Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF162D4A),
                child: Text(
                  impacter.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${impacter.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Impacter details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  impacter.name,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  impacter.company,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  impacter.location,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Lives / Coins impact counts
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${impacter.lives} lives',
                style: const TextStyle(
                  color: Color(0xFF00C853),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${impacter.coins} coins',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTopImpacters() {
    final session = SessionManager().currentSession;
    final activeCircleName =
        _selectedCircle ??
        (session.managedCircles.isNotEmpty ? session.managedCircles.first : '');
    final displayCircleName = (activeCircleName == 'Technology' ||
            activeCircleName == 'All National Circles')
        ? 'Mumbai Tech Sunrise'
        : activeCircleName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top 5 Impacters',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                displayCircleName,
                style: const TextStyle(
                  color: Color(0xFF8B9CB4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._impacters.map((impacter) => _buildImpacterTile(impacter)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDashboardTab() {
    if (_isLoading || _metrics == null) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final session = SessionManager().currentSession;
    final showOverallMetrics =
        session.role == UserRole.circleFounder ||
        session.role == UserRole.circleDirector ||
        session.role == UserRole.industryDirector ||
        session.role == UserRole.districtExecDirector ||
        session.role == UserRole.countryDirector ||
        session.role == UserRole.superAdmin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showOverallMetrics) _buildOverallMetricsCard(_metrics!),
        _buildHeroCard(_metrics!),
        _buildKeyMetrics(_metrics!),
        const SizedBox(height: 24),
        _buildTopImpacters(),
        if (session.role != UserRole.industryDirector &&
            session.role != UserRole.countryDirector &&
            session.role != UserRole.superAdmin)
          _buildPendingPeersCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPendingPeersCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        children: [
          // Mustard/Gold Rounded Rectangle Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFB78628), // Premium mustard gold color
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text(
              '4',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Middle Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '4 pending peers',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Awaiting review',
                  style: TextStyle(
                    color: Color(0xFF8B9CB4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Review Button
          ElevatedButton(
            onPressed: () {
              // Switches active tab to Peers (index 1) where users manage peers
              _presenter.changeTab(1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEDF2FA),
              foregroundColor: const Color(0xFF1E3A60),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Review',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallMetricsCard(DashboardMetricsModel metrics) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F7A50), // Rich forest green
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Left segment: OVERALL REVENUE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OVERALL REVENUE',
                  style: TextStyle(
                    color: Color(0xFFBCE7D6),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metrics.overallRevenue ?? '₹0.0',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(width: 20),
          // Right segment: Deals Closed
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deals Closed',
                  style: TextStyle(
                    color: Color(0xFFBCE7D6),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metrics.overallDealsClosed ?? '₹0.0',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => _presenter.changeTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE8EEF8)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : const Color(0xFF8B9CB4),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.primary : const Color(0xFF8B9CB4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(0, Icons.dashboard_rounded, 'Dashboard'),
          _buildNavBarItem(1, Icons.people_outline_rounded, 'Peers'),
          _buildNavBarItem(2, Icons.group_work_outlined, 'Teams'),
          _buildNavBarItem(3, Icons.credit_card_rounded, 'Finance'),
          _buildNavBarItem(4, Icons.description_outlined, 'Report'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>.value(
      value: _bloc,
      child: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          body: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: _activeTab == 0
                      ? _buildDashboardTab()
                      : _activeTab == 1
                      ? PeersView(selectedCircle: _selectedCircle)
                      : _activeTab == 2
                      ? TeamsView(selectedCircle: _selectedCircle)
                      : _activeTab == 3
                      ? FinanceView(selectedCircle: _selectedCircle)
                      : ReportsView(selectedCircle: _selectedCircle),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }
}
