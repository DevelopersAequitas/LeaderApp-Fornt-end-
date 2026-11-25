// ==============================================================================
// File: lib/features/dashboard/view/dashboard_view.dart
// Description: Enterprise Leadership Command Center & Bottom Navigation Hub
// Framework: Flutter | Architecture: MVP + BLoC State Driven
// Features:
//   - Above-the-fold Executive KPI Overview + Concise 3-item Action Required
//   - Permission-aware organizational scope switching
//   - Retained Activity, Asks, Community & Leadership 32-stream drill-down hub
//   - Verified Circle performance, conclaves, activity ledger & top leaders
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/notifications/app_notification_navigator.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/notification_count_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../finance/view/finance_view.dart';
import '../../peers/view/peers_view.dart';
import '../../reports/view/reports_view.dart';
import '../../teams/view/teams_view.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../presenter/dashboard_presenter.dart';
import 'widgets/dashboard_action_center_card.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_bottom_nav_bar.dart';
import 'widgets/dashboard_domains_section.dart';
import 'widgets/dashboard_hero_card.dart';
import 'widgets/dashboard_performance_section.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_recent_activity_section.dart';
import 'widgets/dashboard_shimmer_skeleton.dart';
import 'widgets/dashboard_top_impacters.dart';
import 'widgets/dashboard_upcoming_events_section.dart';
import 'widgets/dashboard_welcome_header.dart';

/// The View component of the Executive Dashboard feature.
/// Powered by [DashboardPresenter] (MVP) + [DashboardBloc] (State Management).
class DashboardView extends StatelessWidget {
  final int initialTab;
  final String? focusTransactionId;
  const DashboardView({
    super.key,
    this.initialTab = 0,
    this.focusTransactionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (context) => DashboardBloc()..add(const LoadDashboardData()),
      child: _DashboardContent(
        initialTab: initialTab,
        focusTransactionId: focusTransactionId,
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final int initialTab;
  final String? focusTransactionId;
  const _DashboardContent({
    this.initialTab = 0,
    this.focusTransactionId,
  });

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    implements DashboardViewContract {
  DateTime? _lastBackPress;
  late final TextEditingController _peersSearchController;
  late final DashboardPresenter _presenter;
  final Set<int> _mountedTabs = <int>{};
  bool _isPeersSearching = false;
  String _peersSearchQuery = '';

  @override
  void onDashboardLoading() {}

  @override
  void onDashboardLoaded() {}

  @override
  void onDashboardError(String error) {
    if (!mounted) return;
    final state = context.read<DashboardBloc>().state;
    if (error.isNotEmpty && state.metrics != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColor.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void onTabUpdated(int activeIndex) {
    if (activeIndex != 1 && _isPeersSearching && mounted) {
      setState(() => _isPeersSearching = false);
    }
  }

  bool _isTabPermitted(int tabIndex) {
    if (tabIndex == 0) return true;
    final isSuper = SessionManager().isSuperAdmin;
    if (isSuper) return true;
    final perms = SessionManager().permissions;
    switch (tabIndex) {
      case 1:
        return perms.canAccessPeersTab;
      case 2:
        return perms.canAccessTeamsTab;
      case 3:
        return perms.canAccessFinanceTab;
      case 4:
        return perms.canAccessReportsTab;
      default:
        return false;
    }
  }

  void _openTabOrFallback(
    BuildContext context, {
    required int tabIndex,
    required String fallbackRoute,
    Object? fallbackArguments,
  }) {
    if (_isTabPermitted(tabIndex)) {
      _presenter.changeTab(tabIndex);
    } else {
      Navigator.of(context).pushNamed(
        fallbackRoute,
        arguments: fallbackArguments,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _presenter = DashboardPresenter(
      view: this,
      bloc: context.read<DashboardBloc>(),
    );
    final initial = _isTabPermitted(widget.initialTab) ? widget.initialTab : 0;
    _mountedTabs.add(initial);
    _peersSearchController = TextEditingController();
    PushNotificationService.instance.initialize();
    PushNotificationService.instance.fetchAndRegisterFcmToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNotificationNavigator.instance.markReady();
    });
    NotificationCountService.instance.fetchUnreadCount();
    if (initial > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _presenter.changeTab(initial);
        }
      });
    }
  }

  @override
  void dispose() {
    _peersSearchController.dispose();
    super.dispose();
  }

  Widget _buildDashboardTab({
    required BuildContext context,
    required DashboardState state,
  }) {
    if (state.isLoading && state.metrics == null) {
      return const DashboardSkeleton();
    }

    if (state.metrics == null) {
      return EnterpriseErrorState(
        message: state.errorMessage.isNotEmpty
            ? state.errorMessage
            : 'Dashboard metrics could not be retrieved right now. Please try again.',
        onRetry: _presenter.refresh,
      );
    }

    final metrics = state.metrics!;
    final scopedCircles = state.scopedCircles;
    final selectedCircle = state.selectedCircle;

    final totalCircles = scopedCircles.isNotEmpty
        ? scopedCircles.length
        : state.availableCircles.length;
    final activeCircles = scopedCircles.isNotEmpty
        ? scopedCircles
            .where((c) => c.status.toLowerCase() == 'active')
            .length
        : totalCircles;

    void openPeersTab() => _openTabOrFallback(
          context,
          tabIndex: 1,
          fallbackRoute: AppRoutes.leaderActivities,
          fallbackArguments: {
            'type': 'peers',
            'circleId': ?selectedCircle,
          },
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Compact Personalized Executive Identity & Permission-Aware Scope Header
        DashboardWelcomeHeader(
          circles: state.circles,
          availableCircles: state.availableCircles,
          industries: state.dynamicIndustries,
          selectedCircleId: selectedCircle,
          onCircleSelected: _presenter.selectCircle,
        ),
        const SizedBox(height: 12),

        // 2. Above the Fold: Primary Organizational KPIs + Scope Strip
        DashboardHeroCard(
          metrics: metrics,
          selectedCircle: selectedCircle,
          totalCirclesCount: totalCircles,
          activeCirclesCount: activeCircles > 0 ? activeCircles : totalCircles,
          onPeersTap: openPeersTab,
          onCirclesTap: () => _openTabOrFallback(
            context,
            tabIndex: 2,
            fallbackRoute: AppRoutes.leaderActivities,
            fallbackArguments: {
              'type': 'peers',
              'circleId': ?selectedCircle,
            },
          ),
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
          onRevenueTap: () => _openTabOrFallback(
            context,
            tabIndex: 3,
            fallbackRoute: '/finance',
          ),
          onPendingTap: () => Navigator.of(context).pushNamed(
            AppRoutes.leaderActivities,
            arguments: {
              'type': 'pending-requests',
              'circleId': ?selectedCircle,
            },
          ),
        ),
        const SizedBox(height: 14),

        // 3. Above the Fold: Concise Action Required (Top 3 Priority Items + View All)
        DashboardActionCenterCard(
          metrics: metrics,
          circles: scopedCircles,
          selectedCircle: selectedCircle,
          onOpenTeamsTab: () => _openTabOrFallback(
            context,
            tabIndex: 2,
            fallbackRoute: AppRoutes.leaderActivities,
            fallbackArguments: {'type': 'pending-requests'},
          ),
          onOpenReportsTab: () => _openTabOrFallback(
            context,
            tabIndex: 4,
            fallbackRoute: AppRoutes.circulars,
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // 4. Retained 4-Domain Drill-Down Architecture (Activity, Asks, Community, Leadership)
        DashboardDomainsSection(
          metrics: metrics,
          selectedCircle: selectedCircle,
          onPeersTap: openPeersTab,
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // 5. Organizational Performance (Regions / Industries / Circles / Asks)
        DashboardPerformanceSection(
          metrics: metrics,
          circles: scopedCircles,
          selectedCircle: selectedCircle,
          onOpenTeamsTab: () => _openTabOrFallback(
            context,
            tabIndex: 2,
            fallbackRoute: AppRoutes.leaderActivities,
            fallbackArguments: {
              'type': 'all-asks',
              'circleId': ?selectedCircle,
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // 6. Permission-Gated Quick Actions
        DashboardQuickActions(
          metrics: metrics,
          selectedCircle: selectedCircle,
          onOpenPeersTab: openPeersTab,
          onOpenTeamsTab: () => _openTabOrFallback(
            context,
            tabIndex: 2,
            fallbackRoute: AppRoutes.circulars,
          ),
          onOpenReportsTab: () => _openTabOrFallback(
            context,
            tabIndex: 4,
            fallbackRoute: AppRoutes.circulars,
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // 7. Upcoming Circle Conclaves & Events (Verified Cadence Schedules)
        DashboardUpcomingEventsSection(
          circles: scopedCircles,
          metrics: metrics,
          selectedCircle: selectedCircle,
        ),

        // 8. Below Primary Executive Sections: Top Impact Leaders & Activity Ledger
        if (state.impacters.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          DashboardTopImpacters(
            impacters: state.impacters,
            metrics: metrics,
            selectedCircle: selectedCircle,
          ),
        ],
        const SizedBox(height: AppSpacing.sectionGap),
        DashboardRecentActivitySection(
          metrics: metrics,
          selectedCircle: selectedCircle,
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          prev.activeTab != curr.activeTab ||
          prev.isLoading != curr.isLoading,
      listener: (context, state) => _presenter.handleStateChange(state),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          _mountedTabs.add(state.activeTab);
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
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    backgroundColor: AppColor.lightTextPrimary,
                  ),
                );
              }
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Column(
                children: [
                  DashboardAppBar(
                    activeTab: state.activeTab,
                    selectedCircle: state.selectedCircle,
                    dynamicIndustries: state.dynamicIndustries,
                    availableCircles: state.availableCircles,
                    onCircleSelected: _presenter.selectCircle,
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
                    child: _FadeIndexedTabStack(
                      activeIndex: state.activeTab,
                      children: [
                        _mountedTabs.contains(0)
                            ? RefreshIndicator(
                                color: AppColor.primary,
                                onRefresh: () async {
                                  _presenter.refresh();
                                },
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: _buildDashboardTab(
                                    context: context,
                                    state: state,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        _mountedTabs.contains(1)
                            ? PeersView(
                                selectedCircle: state.selectedCircle,
                                externalSearchQuery: _peersSearchQuery,
                              )
                            : const SizedBox.shrink(),
                        _mountedTabs.contains(2)
                            ? TeamsView(
                                selectedCircle: state.selectedCircle,
                              )
                            : const SizedBox.shrink(),
                        _mountedTabs.contains(3)
                            ? FinanceView(
                                selectedCircle: state.selectedCircle,
                                focusTransactionId: widget.focusTransactionId,
                              )
                            : const SizedBox.shrink(),
                        _mountedTabs.contains(4)
                            ? ReportsView(
                                selectedCircle: state.selectedCircle,
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: DashboardBottomNavBar(
                activeTab: state.activeTab,
                onTabSelected: (idx) {
                  if (!_isTabPermitted(idx) || idx == state.activeTab) return;
                  _presenter.changeTab(idx);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// State-preserving in-place tab host with a crisp 150ms crossfade.
class _FadeIndexedTabStack extends StatefulWidget {
  final int activeIndex;
  final List<Widget> children;

  const _FadeIndexedTabStack({
    required this.activeIndex,
    required this.children,
  });

  @override
  State<_FadeIndexedTabStack> createState() => _FadeIndexedTabStackState();
}

class _FadeIndexedTabStackState extends State<_FadeIndexedTabStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.tabSwitch,
      value: 1.0,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.easeOut,
    );
  }

  @override
  void didUpdateWidget(covariant _FadeIndexedTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      if (AppMotion.reduceMotion(context)) {
        _controller.value = 1.0;
      } else {
        _controller.forward(from: 0.72);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: IndexedStack(
        index: widget.activeIndex,
        children: widget.children,
      ),
    );
  }
}
