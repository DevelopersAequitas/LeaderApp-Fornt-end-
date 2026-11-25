import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/notifications/notification_highlight_wrapper.dart';
import '../../../core/notifications/notification_list_focus.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../impacts/view/widgets/impact_moderation_dialogs.dart';
import '../bloc/leader_activities_bloc.dart';
import '../bloc/leader_activities_event.dart';
import '../bloc/leader_activities_state.dart';
import '../model/leader_activity_item_model.dart';
import 'widgets/leader_activity_item_card.dart';
import 'widgets/leader_ranked_peer_card.dart';

/// Unified drill-down screen opened when tapping any activity count or stream.
///
/// Always centers on the participating **List of Peers** (without repeating
/// noisy aggregate count headers or count-badged tabs). For contribution-led
/// streams (`supportsTopContributorsTab`), offers a clean two-tab switcher
/// (`Peers` | `Top Contributors`), and for timestamped/categorized streams
/// (`supportsListFilters`), offers clean `Recent` + activity type filters.
/// Preserves actionable moderation cards for `pending-requests` and `circulars`.
class LeaderActivitiesView extends StatelessWidget {
  final String activityType;
  final String? circleId;
  final String? focusItemId;
  final LeaderActivitiesBloc? bloc;

  const LeaderActivitiesView({
    super.key,
    required this.activityType,
    this.circleId,
    this.focusItemId,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final child = _LeaderActivitiesContent(
      activityType: activityType,
      circleId: circleId,
      focusItemId: focusItemId,
    );
    if (bloc != null) {
      return BlocProvider<LeaderActivitiesBloc>.value(
        value: bloc!,
        child: child,
      );
    }
    return BlocProvider<LeaderActivitiesBloc>(
      create: (_) => LeaderActivitiesBloc()
        ..add(
          LoadLeaderActivities(
            type: activityType,
            circleId: circleId,
          ),
        ),
      child: child,
    );
  }
}

class _LeaderActivitiesContent extends StatefulWidget {
  final String activityType;
  final String? circleId;
  final String? focusItemId;

  const _LeaderActivitiesContent({
    required this.activityType,
    this.circleId,
    this.focusItemId,
  });

  @override
  State<_LeaderActivitiesContent> createState() =>
      _LeaderActivitiesContentState();
}

class _LeaderActivitiesContentState extends State<_LeaderActivitiesContent> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  final NotificationListFocusController _focusController =
      NotificationListFocusController();
  final Map<String, GlobalKey> _itemKeys = <String, GlobalKey>{};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    final id = widget.focusItemId?.trim() ?? '';
    if (id.isNotEmpty) {
      _focusController.setTarget(
        NotificationListFocusRequest(
          targetId: id,
          targetType: 'approval',
          circleId: widget.circleId,
        ),
      );
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String id) =>
      _itemKeys.putIfAbsent(id, () => GlobalKey());

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

  @override
  Widget build(BuildContext context) {
    final config = LeaderActivityCategoryConfig.fromType(widget.activityType);
    final bloc = context.read<LeaderActivitiesBloc>();
    final isActionableQueue =
        config.type == 'pending-requests' || config.type == 'circulars';

    return BlocListener<LeaderActivitiesBloc, LeaderActivitiesState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          prev.actionMessage != curr.actionMessage,
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColor.danger,
            ),
          );
        } else if (state.actionMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage),
              backgroundColor: AppColor.success,
            ),
          );
        }
      },
      child: BlocBuilder<LeaderActivitiesBloc, LeaderActivitiesState>(
        builder: (context, state) {
          final peers = state.filteredPeers;
          final items = state.filteredItems;
          final hasPeers = peers.isNotEmpty || state.allPeers.isNotEmpty;
          final hasItems = items.isNotEmpty || state.allItems.isNotEmpty;
          final isInitialLoading =
              state.isLoading && state.allPeers.isEmpty && state.allItems.isEmpty;

          final selectedLower = state.selectedFilterType?.toLowerCase();
          final isModerationFilter = config.type == 'impacts' &&
              (selectedLower == 'pending' ||
                  selectedLower == 'approved' ||
                  selectedLower == 'rejected' ||
                  (widget.focusItemId?.trim().isNotEmpty == true));

          final showPeersList = isModerationFilter
              ? false
              : (isActionableQueue
                  ? (!hasItems && hasPeers)
                  : (hasPeers || !hasItems));

          final showTopContributorsTab =
              config.supportsTopContributorsTab &&
                  !isActionableQueue &&
                  state.allPeers.isNotEmpty;

          final activeTab = showTopContributorsTab ? state.activeTab.clamp(0, 1) : 0;

          final showFilterBar = !isInitialLoading &&
              activeTab == 0 &&
              config.supportsListFilters &&
              (state.allPeers.isNotEmpty || state.allItems.isNotEmpty);

          final contributors = state.topContributors.isNotEmpty
              ? state.topContributors
              : peers;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: config.title,
              showBackButton: true,
              showSearch: true,
              isSearching: _isSearching,
              searchController: _searchController,
              searchHint: isActionableQueue
                  ? 'Search ${config.title.toLowerCase()}...'
                  : 'Search Peers in ${config.title.toLowerCase()}...',
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
              child: isInitialLoading
                  ? const ListShimmerSkeleton()
                  : Column(
                      children: [
                        if (showTopContributorsTab)
                          _buildSegmentedTabs(
                            context,
                            activeTab: activeTab,
                            onSelectTab: (idx) =>
                                bloc.add(SwitchLeaderActivitiesTab(idx)),
                          ),
                        if (showFilterBar)
                          _buildFilterBar(
                            context,
                            sortByRecent: state.sortByRecent,
                            selectedFilterType: state.selectedFilterType,
                            availableTypes: state.availableFilterTypes,
                            onToggleRecent: () => bloc.add(
                              ChangeLeaderActivitiesFilter(
                                sortByRecent: !state.sortByRecent,
                              ),
                            ),
                            onSelectType: (type) {
                              if (type == null ||
                                  state.selectedFilterType == type) {
                                bloc.add(
                                  const ChangeLeaderActivitiesFilter(
                                    clearFilterType: true,
                                  ),
                                );
                              } else {
                                bloc.add(
                                  ChangeLeaderActivitiesFilter(
                                    selectedFilterType: type,
                                  ),
                                );
                              }
                            },
                          ),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColor.primary,
                            onRefresh: () async {
                              bloc.add(
                                LoadLeaderActivities(
                                  type: widget.activityType,
                                  circleId: widget.circleId,
                                ),
                              );
                            },
                            child: activeTab == 1 && showTopContributorsTab
                                ? _buildPeersList(
                                    contributors,
                                    config,
                                    showContributionRank: true,
                                  )
                                : (showPeersList
                                    ? _buildPeersList(
                                        peers,
                                        config,
                                        showRecency: state.sortByRecent,
                                      )
                                    : _buildActivityItemsList(
                                        items: items,
                                        config: config,
                                        bloc: bloc,
                                        processingItemIds:
                                            state.processingItemIds,
                                        scrollController: _scrollController,
                                        isLoadingMore: state.isLoadingMore,
                                        hasMore: state.hasMore,
                                      )),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSegmentedTabs(
    BuildContext context, {
    required int activeTab,
    required ValueChanged<int> onSelectTab,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColor.darkSurface : AppColor.lightSurface;
    final containerBg =
        isDark ? AppColor.darkSurfaceElevated : AppColor.surfaceContainer;
    final borderColor = isDark ? AppColor.darkBorder : AppColor.outline;

    Widget buildTab({
      required int index,
      required String label,
      required IconData icon,
    }) {
      final isSelected = activeTab == index;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            onTap: () => onSelectTab(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColor.primary : surface)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected
                        ? (isDark ? Colors.white : AppColor.primary)
                        : (isDark
                            ? AppColor.darkTextSecondary
                            : AppColor.lightTextSecondary),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColor.lightTextPrimary)
                            : (isDark
                                ? AppColor.darkTextSecondary
                                : AppColor.lightTextSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        8,
        AppSpacing.screenMargin,
        8,
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Row(
          children: [
            buildTab(
              index: 0,
              label: 'Peers',
              icon: Icons.people_outline_rounded,
            ),
            const SizedBox(width: 4),
            buildTab(
              index: 1,
              label: 'Top Contributors',
              icon: Icons.workspace_premium_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context, {
    required bool sortByRecent,
    required String? selectedFilterType,
    required List<String> availableTypes,
    required VoidCallback onToggleRecent,
    required ValueChanged<String?> onSelectType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColor.darkSurface : AppColor.lightSurface;
    final borderColor = isDark ? AppColor.darkBorder : AppColor.outline;

    Widget buildChip({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      IconData? icon,
    }) {
      final activeBg =
          isDark ? AppColor.primary.withValues(alpha: 0.22) : AppColor.primaryContainer;
      final idleBg =
          isDark ? AppColor.darkSurfaceElevated : AppColor.surfaceContainer;
      final activeBorder = isDark
          ? const Color(0xFF93C5FD).withValues(alpha: 0.5)
          : AppColor.primary;
      final activeFg = isDark ? const Color(0xFF93C5FD) : AppColor.primary;
      final idleFg =
          isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? activeBg : idleBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: selected ? activeBorder : borderColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 13.5, color: selected ? activeFg : idleFg),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? activeFg : idleFg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        4,
        AppSpacing.screenMargin,
        9,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            buildChip(
              label: 'Recent',
              icon: Icons.schedule_rounded,
              selected: sortByRecent,
              onTap: onToggleRecent,
            ),
            if (availableTypes.isNotEmpty) ...[
              Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: borderColor,
              ),
              buildChip(
                label: 'All',
                selected: selectedFilterType == null,
                onTap: () => onSelectType(null),
              ),
              for (final typeLabel in availableTypes) ...[
                const SizedBox(width: 6),
                buildChip(
                  label: typeLabel,
                  selected: selectedFilterType == typeLabel,
                  onTap: () => onSelectType(typeLabel),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeersList(
    List<LeaderRankedPeerModel> peers,
    LeaderActivityCategoryConfig config, {
    bool showContributionRank = false,
    bool showRecency = false,
  }) {
    if (peers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMargin,
          vertical: 48,
        ),
        children: [
          EnterpriseEmptyState(
            icon: config.icon,
            title: config.emptyTitle,
            description: config.emptySubtitle,
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        12,
        AppSpacing.screenMargin,
        24,
      ),
      itemCount: peers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return LeaderRankedPeerCard(
          item: peers[index],
          metricIcon: config.icon,
          showContributionRank: showContributionRank,
          showRecency: showRecency,
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
  }) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMargin,
          vertical: 48,
        ),
        children: [
          EnterpriseEmptyState(
            icon: config.icon,
            title: config.emptyTitle,
            description: config.emptySubtitle,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      itemCount: items.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.primary,
                ),
              ),
            ),
          );
        }

        final item = items[index];
        final session = SessionManager().currentSession;
        final canModerate = item.isLifeImpact
            ? (session.role.canReviewLifeImpacts &&
                item.peerId.trim() != session.id.trim() &&
                (item.canReview ?? true))
            : (SessionManager().isSuperAdmin ||
                (SessionManager().currentRole.canModeratePendingRequests &&
                    SessionManager().permissions.canReviewPendingPeers));
        final isActionable = item.isActionablePending && canModerate;

        return ListenableBuilder(
          listenable: _focusController,
          builder: (context, _) {
            if (index == 0 && _focusController.pendingRequest != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                await _focusController.resolveTarget<LeaderActivityItemModel>(
                  items: bloc.state.filteredItems,
                  idOf: (it) => it.id,
                  hasMore: () => bloc.state.hasMore,
                  loadMore: () async {
                    bloc.add(const LoadMoreLeaderActivities());
                    await bloc.stream
                        .firstWhere((s) => !s.isLoadingMore)
                        .timeout(
                          const Duration(seconds: 6),
                          onTimeout: () => bloc.state,
                        );
                  },
                  keyLookup: (id) => _itemKeys[id],
                );
                if (mounted &&
                    _focusController.notFound &&
                    _focusController.statusMessage != null) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text(_focusController.statusMessage!)),
                  );
                }
              });
            }
            return NotificationHighlightWrapper(
              key: _keyFor(item.id),
              itemId: item.id,
              activeTargetId: _focusController.highlightedId,
              onHighlightCompleted: () =>
                  _focusController.markHighlightCompleted(item.id),
              child: LeaderActivityItemCard(
                item: item,
                isProcessing: processingItemIds.contains(item.id),
                onTapCard: item.isLifeImpact
                    ? () async {
                        final mutated = await Navigator.of(context).pushNamed(
                          AppRoutes.lifeImpactDetail,
                          arguments: {
                            'id': item.id,
                            'initialItem': item,
                          },
                        );
                        if (mutated == true && context.mounted) {
                          bloc.add(
                            LoadLeaderActivities(
                              type: widget.activityType,
                              circleId: widget.circleId,
                            ),
                          );
                        }
                      }
                    : null,
                onApprove: isActionable
                    ? () async {
                        if (item.isLifeImpact) {
                          final decision = await ImpactModerationDialogs
                              .showApproveConfirmation(
                            context,
                            peerName: item.peerName,
                            impactTitle: item.title,
                          );
                          if (decision.confirmed && context.mounted) {
                            bloc.add(
                              ApproveLeaderActivityItem(
                                item,
                                remarks: decision.remarks,
                              ),
                            );
                          }
                        } else {
                          bloc.add(ApproveLeaderActivityItem(item));
                        }
                      }
                    : null,
                onReject: isActionable
                    ? () async {
                        if (item.isLifeImpact) {
                          final reason =
                              await ImpactModerationDialogs.showRejectDialog(
                            context,
                            peerName: item.peerName,
                            impactTitle: item.title,
                          );
                          if (reason != null && context.mounted) {
                            bloc.add(
                              RejectLeaderActivityItem(item, reason: reason),
                            );
                          }
                        } else {
                          bloc.add(RejectLeaderActivityItem(item));
                        }
                      }
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
