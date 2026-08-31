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
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
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
import 'widgets/dashboard_top_impacters.dart';

/// The View component of the Executive Dashboard feature.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (context) =>
          DashboardBloc()..add(const LoadDashboardData()),
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

  Widget _buildDashboardTab({
    required BuildContext context,
    required bool isLoading,
    required DashboardMetricsModel? metrics,
    required List<ImpacterModel> impacters,
    required String? selectedCircle,
  }) {
    if (isLoading || metrics == null) {
      return const CenteredLoadingIndicator(height: 300);
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
          onImpactTap: () => bloc.add(const TabChanged(1)),
          onDealsTap: () => bloc.add(const TabChanged(1)),
          onP2PTap: () => bloc.add(const TabChanged(1)),
          onRevenueTap: () => bloc.add(const TabChanged(2)),  
        ),
        const SizedBox(height: 6),
        DashboardKeyMetricsGrid(
          metrics: metrics,
          onPeersTap: () => bloc.add(const TabChanged(1)),
        ),
        const SizedBox(height: 16),
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
            onReviewTap: () => bloc.add(const TabChanged(1)),
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
          prev.errorMessage != curr.errorMessage && curr.errorMessage.isNotEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: AppColors.danger,
          ),
        );
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return PopScope(
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
                    activeTab: state.activeTab,
                    selectedCircle: state.selectedCircle,
                    unreadNotificationCount: state.unreadNotificationCount,
                    dynamicIndustries: state.dynamicIndustries,
                    onCircleSelected: (c) => bloc.add(SelectCircle(c)),
                    onNotificationTap: () async {
                      await Navigator.of(context)
                          .pushNamed(AppRoutes.notifications);
                      bloc.add(const RefreshNotificationsCount());
                    },
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: state.activeTab,
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            bloc.add(const LoadDashboardData(isRefresh: true));
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
                        PeersView(selectedCircle: state.selectedCircle),
                        TeamsView(selectedCircle: state.selectedCircle),
                        FinanceView(selectedCircle: state.selectedCircle),
                        ReportsView(selectedCircle: state.selectedCircle),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: DashboardBottomNavBar(
                activeTab: state.activeTab,
                onTabSelected: (idx) => bloc.add(TabChanged(idx)),
              ),
            ),
          );
        },
      ),
    );
  }
}
