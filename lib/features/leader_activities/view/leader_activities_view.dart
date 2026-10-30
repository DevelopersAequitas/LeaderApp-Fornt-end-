import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/leader_activities_bloc.dart';
import '../bloc/leader_activities_event.dart';
import '../bloc/leader_activities_state.dart';
import '../model/leader_activity_item_model.dart';
import 'widgets/leader_activity_item_card.dart';
import 'widgets/leader_ranked_peer_card.dart';

/// Unified screen opened when tapping any section on the Home tab:
/// - Uses the Peers Global Unity-styled `CustomAppBar` with normal back button,
///   screen name (`config.title`), and search icon button on the right.
/// - Shows ONLY the peers who have activity in this specific section (ranked top-to-bottom),
///   plus an optional `Records` tab for viewing individual activity records.
/// - Tapping any peer or activity record opens that peer's 360° profile details screen.
class LeaderActivitiesView extends StatelessWidget {
  final String activityType;
  final String? circleId;

  const LeaderActivitiesView({
    super.key,
    required this.activityType,
    this.circleId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaderActivitiesBloc>(
      create: (_) => LeaderActivitiesBloc()
        ..add(
          LoadLeaderActivities(
            type: activityType,
            circleId: circleId,
          ),
        ),
      child: _LeaderActivitiesContent(
        activityType: activityType,
        circleId: circleId,
      ),
    );
  }
}

class _LeaderActivitiesContent extends StatefulWidget {
  final String activityType;
  final String? circleId;

  const _LeaderActivitiesContent({
    required this.activityType,
    this.circleId,
  });

  @override
  State<_LeaderActivitiesContent> createState() =>
      _LeaderActivitiesContentState();
}

class _LeaderActivitiesContentState extends State<_LeaderActivitiesContent> {
  late final TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = LeaderActivityCategoryConfig.fromType(widget.activityType);
    final bloc = context.read<LeaderActivitiesBloc>();
    const leaderboardTypes = <String>{
      'peers',
      'coins',
      'impacts',
      'top-contributors',
      'highest-givers',
      'introduced-peers',
    };
    final isLeaderboardSection = leaderboardTypes.contains(config.type);

    return BlocListener<LeaderActivitiesBloc, LeaderActivitiesState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          prev.actionMessage != curr.actionMessage,
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        } else if (state.actionMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: BlocBuilder<LeaderActivitiesBloc, LeaderActivitiesState>(
        builder: (context, state) {
          final peers = state.filteredPeers;
          final items = state.filteredItems;
          final showRankedPeers = isLeaderboardSection
              ? (peers.isNotEmpty || items.isEmpty)
              : items.isEmpty && peers.isNotEmpty;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: config.title,
              showBackButton: true,
              showSearch: true,
              isSearching: _isSearching,
              searchController: _searchController,
              searchHint: 'Search ${config.title.toLowerCase()}...',
              onSearchTap: () => setState(() => _isSearching = true),
              onSearchChanged: (val) => bloc.add(SearchLeaderActivities(val)),
              onSearchClose: () {
                _searchController.clear();
                bloc.add(const SearchLeaderActivities(''));
                setState(() => _isSearching = false);
              },
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading &&
                      state.allPeers.isEmpty &&
                      state.allItems.isEmpty
                  ? const ListShimmerSkeleton()
                  : RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(
                          LoadLeaderActivities(
                            type: widget.activityType,
                            circleId: widget.circleId,
                          ),
                        );
                      },
                      child: showRankedPeers
                          ? _buildRankedPeersList(peers, config)
                          : _buildActivityItemsList(
                              items,
                              config,
                              bloc,
                              state.processingItemIds,
                            ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankedPeersList(
    List<LeaderRankedPeerModel> peers,
    LeaderActivityCategoryConfig config,
  ) {
    if (peers.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColor.badgeBlueBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      config.icon,
                      size: 28,
                      color: AppColor.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    config.emptyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: AppColor.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    config.emptySubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: peers.length,
      itemBuilder: (context, index) {
        return LeaderRankedPeerCard(
          item: peers[index],
          metricIcon: config.icon,
        );
      },
    );
  }

  Widget _buildActivityItemsList(
    List<LeaderActivityItemModel> items,
    LeaderActivityCategoryConfig config,
    LeaderActivitiesBloc bloc,
    Set<String> processingItemIds,
  ) {
    if (items.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColor.badgeBlueBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      config.icon,
                      size: 28,
                      color: AppColor.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    config.emptyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: AppColor.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    config.emptySubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return LeaderActivityItemCard(
          item: item,
          isProcessing: processingItemIds.contains(item.id),
          onApprove: item.isActionablePending
              ? () => bloc.add(ApproveLeaderActivityItem(item))
              : null,
          onReject: item.isActionablePending
              ? () => bloc.add(RejectLeaderActivityItem(item))
              : null,
        );
      },
    );
  }
}
