import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
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
/// - Shows total activities logged metric banner and peer contributors count.
/// - Segmented tabs between individual Activity Records (with pagination) and
///   Ranked Peer Contributors.
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
  late final ScrollController _scrollController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 200) {
        context
            .read<LeaderActivitiesBloc>()
            .add(const LoadMoreLeaderActivities());
      }
    }
  }

  String _formatCompact(int val) {
    if (val >= 10000000) {
      final cr = (val / 10000000).toStringAsFixed(1);
      return '${cr.endsWith('.0') ? cr.substring(0, cr.length - 2) : cr}Cr';
    }
    if (val >= 100000) {
      final l = (val / 100000).toStringAsFixed(1);
      return '${l.endsWith('.0') ? l.substring(0, l.length - 2) : l}L';
    }
    if (val >= 1000) {
      final k = (val / 1000).toStringAsFixed(1);
      return '${k.endsWith('.0') ? k.substring(0, k.length - 2) : k}K';
    }
    return val.toString();
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

          final hasItems = items.isNotEmpty || state.allItems.isNotEmpty;
          final hasPeers = peers.isNotEmpty || state.allPeers.isNotEmpty;
          final showTabs = hasItems && hasPeers && !isLeaderboardSection;

          final totalActivitiesCount = state.totalActivities > 0
              ? state.totalActivities
              : (items.isNotEmpty
                  ? items.length
                  : peers.fold<int>(0, (s, p) => s + p.metricCount));

          final totalPeersCount = state.totalPeers > 0
              ? state.totalPeers
              : (peers.isNotEmpty ? peers.length : state.allPeers.length);

          final activeTab = state.activeTab;
          final showRankedPeers = isLeaderboardSection
              ? (hasPeers || !hasItems)
              : (!hasItems && hasPeers) || (showTabs && activeTab == 1);

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Prominent Executive KPI Summary Card
                          _buildHeaderSummary(
                            context: context,
                            config: config,
                            totalActivities: totalActivitiesCount,
                            totalPeers: totalPeersCount,
                            unitLabel: state.unitLabel.isNotEmpty
                                ? state.unitLabel
                                : config.unitLabel,
                          ),

                          // 2. Segmented Tabs Bar (if both Records & Contributors exist)
                          if (showTabs)
                            _buildTabBar(
                              context: context,
                              bloc: bloc,
                              activeTab: activeTab,
                              recordsCount: state.total > 0
                                  ? state.total
                                  : state.allItems.length,
                              contributorsCount: state.allPeers.length,
                            ),

                          // 3. Content List
                          Expanded(
                            child: showRankedPeers
                                ? _buildRankedPeersList(peers, config)
                                : _buildActivityItemsList(
                                    items: items,
                                    config: config,
                                    bloc: bloc,
                                    processingItemIds: state.processingItemIds,
                                    scrollController: _scrollController,
                                    isLoadingMore: state.isLoadingMore,
                                    hasMore: state.hasMore,
                                    totalCount: state.total,
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSummary({
    required BuildContext context,
    required LeaderActivityCategoryConfig config,
    required int totalActivities,
    required int totalPeers,
    required String unitLabel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColor.brandGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              config.icon,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatCompact(totalActivities),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$unitLabel Logged',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalPeers Peer Contributors',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? Colors.white54
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar({
    required BuildContext context,
    required LeaderActivitiesBloc bloc,
    required int activeTab,
    required int recordsCount,
    required int contributorsCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => bloc.add(const SwitchLeaderActivitiesTab(0)),
                child: Container(
                  decoration: BoxDecoration(
                    color: activeTab == 0
                        ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: activeTab == 0
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.25 : 0.05,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Activity Records ($recordsCount)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          activeTab == 0 ? FontWeight.w700 : FontWeight.w500,
                      color: activeTab == 0
                          ? AppColor.primaryBlue
                          : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () => bloc.add(const SwitchLeaderActivitiesTab(1)),
                child: Container(
                  decoration: BoxDecoration(
                    color: activeTab == 1
                        ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: activeTab == 1
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.25 : 0.05,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Contributors ($contributorsCount)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          activeTab == 1 ? FontWeight.w700 : FontWeight.w500,
                      color: activeTab == 1
                          ? AppColor.primaryBlue
                          : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          _buildEmptyState(config),
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

  Widget _buildActivityItemsList({
    required List<LeaderActivityItemModel> items,
    required LeaderActivityCategoryConfig config,
    required LeaderActivitiesBloc bloc,
    required Set<String> processingItemIds,
    required ScrollController scrollController,
    required bool isLoadingMore,
    required bool hasMore,
    required int totalCount,
  }) {
    if (items.isEmpty) {
      return ListView(
        children: [
          _buildEmptyState(config),
        ],
      );
    }

    final hasFooter = isLoadingMore || (!hasMore && items.length >= 25);

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: items.length + (hasFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.primaryBlue,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Loading more records...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            final shownCount = totalCount > 0 ? totalCount : items.length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'All $shownCount records loaded',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColor.lightTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }
        }

        final item = items[index];
        final canModerate = SessionManager().isSuperAdmin ||
            SessionManager().currentRole.canModeratePendingRequests ||
            SessionManager().permissions.canReviewPendingPeers;
        final isActionable = item.isActionablePending && canModerate;
        return LeaderActivityItemCard(
          item: item,
          isProcessing: processingItemIds.contains(item.id),
          onApprove: isActionable
              ? () => bloc.add(ApproveLeaderActivityItem(item))
              : null,
          onReject: isActionable
              ? () => bloc.add(RejectLeaderActivityItem(item))
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(LeaderActivityCategoryConfig config) {
    return Padding(
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
    );
  }
}
