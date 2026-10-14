import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../teams/model/teams_model.dart';
import '../bloc/circle_details_bloc.dart';
import '../bloc/circle_details_event.dart';
import '../bloc/circle_details_state.dart';
import 'widgets/circle_events_section.dart';

/// Dedicated standalone screen for Circle Events & Gatherings.
class CircleEventsScreen extends StatelessWidget {
  final CircleTeamModel circle;

  const CircleEventsScreen({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CircleDetailsBloc>(
      create: (context) =>
          CircleDetailsBloc()..add(LoadCircleDetailsData(circleId: circle.id)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Events & Gatherings',
          subtitle: circle.name,
          showBackButton: true,
        ),
        body: SafeArea(
          child: BlocBuilder<CircleDetailsBloc, CircleDetailsState>(
            builder: (context, state) {
              final bloc = context.read<CircleDetailsBloc>();
              return RefreshIndicator(
                onRefresh: () async {
                  bloc.add(LoadCircleDetailsData(
                    circleId: circle.id,
                    isRefresh: true,
                  ));
                },
                child: CircleEventsSection(
                  events: state.filteredEvents,
                  allEvents: state.allEvents,
                  isLoading: state.isLoadingEvents,
                  selectedFilter: state.selectedEventFilter,
                  onFilterChanged: (filter) =>
                      bloc.add(FilterCircleEventsEvent(filter)),
                  circle: circle,
                  peers: state.circlePeers,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
