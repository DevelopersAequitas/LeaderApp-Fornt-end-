// ==============================================================================
// File: lib/features/dashboard/view/dashboard_view.dart
// Description: Central Executive Dashboard & Bottom Navigation Hub
// Framework: Flutter | Architecture: MVP View Layer (BLoC State Driven)
// Features:
//   - Dynamic role-aware application bar with notification badges & avatar profile launcher
//   - Luxury executive hero overview banner with revenue & core metrics
//   - Quick KPI matrix navigation to Peers, Teams, Finance, and Reports
//   - IndexedStack persistence across bottom navigation tabs (Dashboard, Peers, Teams, Finance, Reports)
//   - Double-back press exit protection via `PopScope`
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../finance/view/finance_view.dart';
import '../../peers/view/peers_view.dart';
import '../../reports/view/reports_view.dart';
import '../../teams/view/teams_view.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../model/dashboard_metrics_model.dart';
import '../model/impacter_model.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_bottom_nav_bar.dart';
import 'widgets/dashboard_hero_card.dart';
import 'widgets/dashboard_key_metrics_grid.dart';
import 'widgets/dashboard_pending_peers_card.dart';
import 'widgets/dashboard_shimmer_skeleton.dart';
import 'widgets/dashboard_top_impacters.dart';

/// The View component of the Executive Dashboard feature.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (context) => DashboardBloc()..add(const LoadDashboardData()),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  DateTime? _lastBackPress;
  late final PageController _pageController;
  late final TextEditingController _peersSearchController;
  bool _isPeersSearching = false;
  String _peersSearchQuery = '';
  static String? _lastAlertedNotifId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _peersSearchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUnreadNotificationAlert();
    });
  }

  Future<void> _checkUnreadNotificationAlert() async {
    try {
      final res = await ApiClient().get<dynamic>(
        ApiEndpoints.leaderNotifications,
      );
      if (res.success && mounted) {
        List<dynamic> items = [];
        if (res.data is List) {
          items = res.data as List;
        } else if (res.data is Map) {
          final nested = res.data['data'] ?? res.data['notifications'] ?? [];
          if (nested is List) items = nested;
        }
        if (items.isNotEmpty) {
          final unreadItem = items.firstWhere(
            (it) =>
                (it['is_unread'] == true || it['is_read'] == false) &&
                it['id'] != _lastAlertedNotifId,
            orElse: () => null,
          );
          if (unreadItem != null) {
            _lastAlertedNotifId = unreadItem['id']?.toString();
            _showInAppNotificationBanner(
              title: unreadItem['title']?.toString() ?? 'Leader Notification',
              message: unreadItem['message']?.toString() ??
                  unreadItem['body']?.toString() ??
                  'You have a new update.',
              screen: unreadItem['screen']?.toString() ?? '/dashboard',
            );
          }
        }
      }
    } catch (_) {
      // Graceful silence
    }
  }

  void _showInAppNotificationBanner({
    required String title,
    required String message,
    required String screen,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 6,
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 18,
                color: Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: const Color(0xFF60A5FA),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.notifications);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _peersSearchController.dispose();
    super.dispose();
  }

  Widget _buildDashboardTab({
    required BuildContext context,
    required bool isLoading,
    required DashboardMetricsModel? metrics,
    required List<ImpacterModel> impacters,
    required String? selectedCircle,
  }) {
    if (isLoading || metrics == null) {
      return const DashboardSkeleton();
    }

    final session = SessionManager().currentSession;
    final int pendingApprovalsCount = metrics.pendingRequestsCount;
    final bool hasPendingRequests = pendingApprovalsCount > 0;
    final bloc = context.read<DashboardBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardHeroCard(
          metrics: metrics,
          selectedCircle: selectedCircle,
          onImpactTap: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': 'impacts',
              'circleId': ?selectedCircle,
            },
          ),
          onCoinsTap: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': 'coins',
              'circleId': ?selectedCircle,
            },
          ),
          onDealsTap: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': 'business-deals',
              'circleId': ?selectedCircle,
            },
          ),
          onP2PTap: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': 'p2p-meetings',
              'circleId': ?selectedCircle,
            },
          ),
          onRevenueTap: () => bloc.add(const TabChanged(3)),
        ),
        const SizedBox(height: 6),
        DashboardKeyMetricsGrid(
          metrics: metrics,
          selectedCircle: selectedCircle,
          onPeersTap: () => bloc.add(const TabChanged(1)),
        ),
        const SizedBox(height: 12),
        DashboardTopImpacters(
          impacters: impacters,
          metrics: metrics,
          selectedCircle: selectedCircle,
        ),
        if (hasPendingRequests &&
            session.role != UserRole.industryDirector &&
            session.role != UserRole.countryDirector &&
            session.role != UserRole.superAdmin)
          DashboardPendingPeersCard(
            count: pendingApprovalsCount,
            onReviewTap: () => Navigator.of(context).pushNamed(
              AppRoutes.leaderActivities,
              arguments: {
                'type': 'pending-requests',
                'circleId': ?selectedCircle,
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DashboardBloc>();

    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          prev.activeTab != curr.activeTab,
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.activeTab) {
          _pageController.animateToPage(
            state.activeTab,
            duration: const Duration(milliseconds: 240),
            curve: Curves.fastOutSlowIn,
          );
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              final now = DateTime.now();
              final isSecondPress =
                  _lastBackPress != null &&
                  now.difference(_lastBackPress!) < const Duration(seconds: 2);
              if (isSecondPress) {
                SystemNavigator.pop();
              } else {
                _lastBackPress = now;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Press back again to exit'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.chartPrimary,
                  ),
                );
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: Column(
                children: [
                  DashboardAppBar(
                    activeTab: state.activeTab,
                    selectedCircle: state.selectedCircle,
                    dynamicIndustries: state.dynamicIndustries,
                    availableCircles: state.availableCircles,
                    onCircleSelected: (c) => bloc.add(SelectCircle(c)),
                    isSearching: state.activeTab == 1 && _isPeersSearching,
                    searchController: _peersSearchController,
                    onSearchTap: () =>
                        setState(() => _isPeersSearching = true),
                    onSearchChanged: (val) =>
                        setState(() => _peersSearchQuery = val),
                    onSearchClose: () {
                      _peersSearchController.clear();
                      setState(() {
                        _peersSearchQuery = '';
                        _isPeersSearching = false;
                      });
                    },
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (idx) {
                        if (idx != 1 && _isPeersSearching) {
                          setState(() => _isPeersSearching = false);
                        }
                        if (state.activeTab != idx) {
                          bloc.add(TabChanged(idx));
                        }
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _KeepAlivePage(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              bloc.add(
                                const LoadDashboardData(isRefresh: true),
                              );
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: _buildDashboardTab(
                                context: context,
                                isLoading: state.isLoading,
                                metrics: state.metrics,
                                impacters: state.impacters,
                                selectedCircle: state.selectedCircle,
                              ),
                            ),
                          ),
                        ),
                        _KeepAlivePage(
                          child: PeersView(
                            selectedCircle: state.selectedCircle,
                            externalSearchQuery: _peersSearchQuery,
                          ),
                        ),
                        _KeepAlivePage(
                          child: TeamsView(
                            selectedCircle: state.selectedCircle,
                          ),
                        ),
                        _KeepAlivePage(
                          child: FinanceView(
                            selectedCircle: state.selectedCircle,
                          ),
                        ),
                        _KeepAlivePage(
                          child: ReportsView(
                            selectedCircle: state.selectedCircle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: DashboardBottomNavBar(
                activeTab: state.activeTab,
                onTabSelected: (idx) {
                  bloc.add(TabChanged(idx));
                  if (_pageController.hasClients &&
                      _pageController.page?.round() != idx) {
                    _pageController.animateToPage(
                      idx,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.fastOutSlowIn,
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// State-preserving wrapper for PageView pages.
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
