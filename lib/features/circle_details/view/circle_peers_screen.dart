import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../../teams/model/teams_model.dart';
import '../bloc/circle_details_bloc.dart';
import '../bloc/circle_details_event.dart';
import '../bloc/circle_details_state.dart';
import 'widgets/circle_peers_section.dart';

/// Dedicated standalone screen for Circle Peers directory.
class CirclePeersScreen extends StatelessWidget {
  final CircleTeamModel circle;

  const CirclePeersScreen({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CircleDetailsBloc>(
      create: (context) =>
          CircleDetailsBloc()..add(LoadCircleDetailsData(circleId: circle.id)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Circle Peers',
          subtitle: circle.name,
          showBackButton: true,
        ),
        body: SafeArea(
          child: BlocBuilder<CircleDetailsBloc, CircleDetailsState>(
            builder: (context, state) {
              final bloc = context.read<CircleDetailsBloc>();
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    CirclePeersSection(
                      peers: state.circlePeers,
                      isLoading: state.isLoadingPeers,
                      isLoadingMore: state.isLoadingMorePeers,
                      hasMore: state.hasMorePeers,
                      totalCount: state.totalPeersCount,
                      onLoadMore: () => bloc.add(
                        LoadMoreCirclePeersEvent(
                          circleId: circle.id,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
