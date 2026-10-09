import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../teams/model/teams_model.dart';
import '../bloc/circle_details_bloc.dart';
import '../bloc/circle_details_event.dart';
import '../bloc/circle_details_state.dart';
import 'circle_events_screen.dart';
import 'circle_overview_screen.dart';
import 'circle_peers_screen.dart';
import 'circle_sub_industries_screen.dart';
import 'widgets/circle_details_hero_card.dart';
import 'widgets/circle_leadership_card.dart';

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
            body: SafeArea(
              top: false,
              child: RefreshIndicator(
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
                      _CircleModulesSection(circle: activeCircle),
                      const SizedBox(height: 24),
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

class _CircleModulesSection extends StatelessWidget {
  final CircleTeamModel circle;

  const _CircleModulesSection({required this.circle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Circle Directory & Modules',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  label: 'Overview',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CircleOverviewScreen(circle: circle),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildActionTile(
                  context,
                  icon: Icons.people_outline_rounded,
                  label: 'Peers',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CirclePeersScreen(circle: circle),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildActionTile(
                  context,
                  icon: Icons.domain_rounded,
                  label: 'Sub-Industries',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CircleSubIndustriesScreen(circle: circle),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildActionTile(
                  context,
                  icon: Icons.event_outlined,
                  label: 'Events',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CircleEventsScreen(circle: circle),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          SquareRoundedGradientIcon(
            icon: icon,
            iconSize: 22,
            boxSize: 44,
            showBorder: true,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
