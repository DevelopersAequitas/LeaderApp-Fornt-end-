// ==============================================================================
// File: lib/features/circle_details/view/circle_details_view.dart
// Description: Comprehensive Circle Details, Leadership, Peers & Meetings Suite
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Category-tinted Hero Banner with overlapping Category Badge & Meta Row
//   - Expandable About Circle card & Focus Areas / Sub-Industry Specialization tags
//   - Interactive Category Availability (Open vs Closed Categories) breakdown
//   - Circle Leaders & Regional Leaders cards rendered with standard PeerCard
//   - Circle Peers preview directory and Meetings & Events summary card
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../../teams/model/teams_model.dart';
import '../bloc/circle_details_bloc.dart';
import '../bloc/circle_details_event.dart';
import '../bloc/circle_details_state.dart';
import 'widgets/circle_about_card.dart';
import 'widgets/circle_category_status_card.dart';
import 'widgets/circle_details_hero_card.dart';
import 'widgets/circle_focus_areas_card.dart';
import 'widgets/circle_leadership_card.dart';
import 'widgets/circle_meeting_card.dart';
import 'widgets/circle_peers_preview_section.dart';

/// Screen displaying comprehensive details about a specific Circle.
/// 100% Pure StatelessWidget powered by BLoC state machine.
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
    final bloc = context.read<CircleDetailsBloc>();

    return BlocListener<CircleDetailsBloc, CircleDetailsState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage &&
          curr.errorMessage.isNotEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: AppColor.danger,
          ),
        );
      },
      child: BlocBuilder<CircleDetailsBloc, CircleDetailsState>(
        builder: (context, state) {
          final activeCircle = state.circle ?? initialCircle;

          return Scaffold(
            backgroundColor: AppColor.background,
            appBar: CustomAppBar(
              title: activeCircle.name,
              showBackButton: true,
            ),
            body: SafeArea(
              top: false,
              child: state.isLoadingCircle && state.circle == null && activeCircle.id.isEmpty
                  ? const CenteredLoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(
                          LoadCircleDetailsData(
                            circleId: initialCircle.id,
                            isRefresh: true,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            CircleDetailsHeroCard(
                              circle: activeCircle,
                              totalPeersCount: state.totalPeersCount > 0
                                  ? state.totalPeersCount
                                  : activeCircle.peersCount,
                            ),
                            const SizedBox(height: 14),
                            CircleAboutCard(circle: activeCircle),
                            const SizedBox(height: 14),
                            CircleFocusAreasCard(
                              circle: activeCircle,
                              subIndustries: state.subIndustries,
                            ),
                            const SizedBox(height: 14),
                            CircleCategoryStatusCard(
                              circle: activeCircle,
                              subIndustries: state.subIndustries,
                              isLoading: state.isLoadingSubIndustries,
                            ),
                            const SizedBox(height: 14),
                            CircleLeadershipCard(
                              circle: activeCircle,
                              circlePeers: state.circlePeers,
                            ),
                            const SizedBox(height: 14),
                            CirclePeersPreviewSection(
                              circle: activeCircle,
                              peers: state.circlePeers,
                              totalPeersCount: state.totalPeersCount > 0
                                  ? state.totalPeersCount
                                  : activeCircle.peersCount,
                              isLoading: state.isLoadingPeers,
                            ),
                            const SizedBox(height: 14),
                            CircleMeetingCard(
                              circle: activeCircle,
                              events: state.allEvents,
                              isLoading: state.isLoadingEvents,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
