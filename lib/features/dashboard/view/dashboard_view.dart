import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../../../data/repositories/teams_repository.dart';
import '../../finance/view/finance_view.dart';
import '../../peers/view/peers_view.dart';
import '../../reports/view/reports_view.dart';
import '../../teams/view/teams_view.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
import '../model/dashboard_metrics_model.dart';
import '../model/impacter_model.dart';
import '../presenter/dashboard_presenter.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_bottom_nav_bar.dart';
import 'widgets/dashboard_hero_card.dart';
import 'widgets/dashboard_key_metrics_grid.dart';
import 'widgets/dashboard_pending_peers_card.dart';
import 'widgets/dashboard_top_impacters.dart';

/// The View component of the Executive Dashboard feature.
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
  DateTime? _lastBackPress;
  int _unreadNotificationCount = 0;
  List<String> _dynamicIndustries = const [];

  @override
  void initState() {
    super.initState();
    _bloc = DashboardBloc();
    _presenter = DashboardPresenter(view: this, bloc: _bloc);
    _presenter.load();
    _loadUnreadNotifications();
    _loadDynamicIndustries();
  }

  Future<void> _loadDynamicIndustries() async {
    try {
      final res = await TeamsRepositoryImpl().getIndustries();
      if (mounted && res.success && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          _dynamicIndustries = res.data!;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final res = await NotificationsRepositoryImpl().getNotifications();
      if (mounted && res.success && res.data != null) {
        setState(() {
          _unreadNotificationCount = res.data!.where((n) => n.isUnread).length;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- DashboardViewContract Implementations ---

  @override
  void onDashboardLoading() {
    setState(() => _isLoading = true);
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
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void onTabUpdated(int activeIndex) {
    if (_activeTab != activeIndex) {
      setState(() => _activeTab = activeIndex);
    }
  }

  int get _pendingApprovalsCount {
    return _metrics?.pendingRequestsCount ?? 0;
  }

  Widget _buildDashboardTab() {
    if (_isLoading || _metrics == null) {
      return const CenteredLoadingIndicator(height: 300);
    }

    final session = SessionManager().currentSession;
    final bool hasPendingRequests = _pendingApprovalsCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardHeroCard(
          metrics: _metrics!,
          selectedCircle: _selectedCircle,
        ),
        const SizedBox(height: 6),
        DashboardKeyMetricsGrid(
          metrics: _metrics!,
          onPeersTap: () => _presenter.changeTab(1),
        ),
        const SizedBox(height: 16),
        DashboardTopImpacters(
          impacters: _impacters,
          metrics: _metrics,
          selectedCircle: _selectedCircle,
        ),
        if (hasPendingRequests &&
            session.role != UserRole.industryDirector &&
            session.role != UserRole.countryDirector &&
            session.role != UserRole.superAdmin)
          DashboardPendingPeersCard(
            count: _pendingApprovalsCount,
            onReviewTap: () => _presenter.changeTab(1),
          ),
        const SizedBox(height: 16),
      ],
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
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            final now = DateTime.now();
            final isSecondPress = _lastBackPress != null &&
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
                  activeTab: _activeTab,
                  selectedCircle: _selectedCircle,
                  unreadNotificationCount: _unreadNotificationCount,
                  dynamicIndustries: _dynamicIndustries,
                  onCircleSelected: (c) => _presenter.selectCircle(c),
                  onNotificationTap: () async {
                    await Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.notifications);
                    _loadUnreadNotifications();
                  },
                ),
                Expanded(
                  child: IndexedStack(
                    index: _activeTab,
                    children: [
                      SingleChildScrollView(
                        child: _buildDashboardTab(),
                      ),
                      SingleChildScrollView(
                        child: PeersView(selectedCircle: _selectedCircle),
                      ),
                      SingleChildScrollView(
                        child: TeamsView(selectedCircle: _selectedCircle),
                      ),
                      SingleChildScrollView(
                        child: FinanceView(selectedCircle: _selectedCircle),
                      ),
                      SingleChildScrollView(
                        child: ReportsView(selectedCircle: _selectedCircle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: DashboardBottomNavBar(
              activeTab: _activeTab,
              onTabSelected: (idx) => _presenter.changeTab(idx),
            ),
          ),
        ),
      ),
    );
  }
}
