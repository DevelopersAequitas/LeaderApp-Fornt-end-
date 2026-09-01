import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../teams/model/teams_model.dart';
import '../bloc/circle_details_bloc.dart';
import '../bloc/circle_details_event.dart';
import '../bloc/circle_details_state.dart';
import 'widgets/circle_details_hero_card.dart';
import 'widgets/circle_details_tab_selector.dart';
import 'widgets/circle_events_section.dart';
import 'widgets/circle_leadership_card.dart';
import 'widgets/circle_overview_section.dart';
import 'widgets/circle_peers_section.dart';
import 'widgets/circle_sub_industries_section.dart';

/// Screen displaying comprehensive details about a specific Circle.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class CircleDetailsView extends StatelessWidget {
  final CircleTeamModel circle;

  const CircleDetailsView({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CircleDetailsBloc>(
      create: (context) => CircleDetailsBloc()
        ..add(LoadCircleDetailsData(circleId: circle.id)),
      child: _CircleDetailsContent(initialCircle: circle),
    );
  }
}

class _CircleDetailsContent extends StatelessWidget {
  final CircleTeamModel initialCircle;

  const _CircleDetailsContent({required this.initialCircle});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CircleDetailsBloc, CircleDetailsState>(
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
      child: BlocBuilder<CircleDetailsBloc, CircleDetailsState>(
        builder: (context, state) {
          final activeCircle = state.circle ?? initialCircle;
          final bloc = context.read<CircleDetailsBloc>();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Circle Details',
              subtitle: activeCircle.name,
              showBackButton: true,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                bloc.add(LoadCircleDetailsData(
                  circleId: initialCircle.id,
                  isRefresh: true,
                ));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleDetailsHeroCard(circle: activeCircle),
                    CircleLeadershipCard(circle: activeCircle),
                    CircleDetailsTabSelector(
                      activeTab: state.activeSubTab,
                      peersCount: state.totalPeersCount > 0
                          ? state.totalPeersCount
                          : state.circlePeers.length,
                      eventsCount: state.filteredEvents.length,
                      onTabChanged: (idx) =>
                          bloc.add(ChangeCircleSubTabEvent(idx)),
                    ),
                    if (state.activeSubTab == 0)
                      CircleOverviewSection(circle: activeCircle),
                    if (state.activeSubTab == 1)
                      CirclePeersSection(
                        peers: state.circlePeers,
                        isLoading: state.isLoadingPeers,
                        isLoadingMore: state.isLoadingMorePeers,
                        hasMore: state.hasMorePeers,
                        totalCount: state.totalPeersCount,
                        onLoadMore: () => bloc.add(LoadMoreCirclePeersEvent(
                          circleId: initialCircle.id,
                        )),
                      ),
                    if (state.activeSubTab == 2)
                      CircleSubIndustriesSection(
                        subIndustries: state.subIndustries,
                        isLoading: state.isLoadingSubIndustries,
                        categoryName: activeCircle.category,
                      ),
                    if (state.activeSubTab == 3)
                      CircleEventsSection(
                        events: state.filteredEvents,
                        isLoading: state.isLoadingEvents,
                        selectedFilter: state.selectedEventFilter,
                        onFilterChanged: (filter) =>
                            bloc.add(FilterCircleEventsEvent(filter)),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
