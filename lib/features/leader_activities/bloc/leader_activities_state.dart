import '../model/leader_activity_item_model.dart';

class LeaderActivitiesState {
  final bool isLoading;
  final bool isLoadingMore;
  final String type;
  final String? circleId;
  final String searchQuery;
  final int activeTab;
  final bool sortByRecent;
  final String? selectedFilterType;
  final List<String> availableFilterTypes;
  final int totalActivities;
  final int totalPeers;
  final int total;
  final int page;
  final bool hasMore;
  final String unitLabel;
  final List<LeaderRankedPeerModel> allPeers;
  final List<LeaderRankedPeerModel> filteredPeers;
  final List<LeaderRankedPeerModel> topContributors;
  final List<LeaderActivityItemModel> allItems;
  final List<LeaderActivityItemModel> filteredItems;
  final Set<String> processingItemIds;
  final String actionMessage;
  final String errorMessage;

  const LeaderActivitiesState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.type = '',
    this.circleId,
    this.searchQuery = '',
    this.activeTab = 0,
    this.sortByRecent = false,
    this.selectedFilterType,
    this.availableFilterTypes = const [],
    this.totalActivities = 0,
    this.totalPeers = 0,
    this.total = 0,
    this.page = 1,
    this.hasMore = false,
    this.unitLabel = 'Activities',
    this.allPeers = const [],
    this.filteredPeers = const [],
    this.topContributors = const [],
    this.allItems = const [],
    this.filteredItems = const [],
    this.processingItemIds = const <String>{},
    this.actionMessage = '',
    this.errorMessage = '',
  });

  LeaderActivitiesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? type,
    String? circleId,
    String? searchQuery,
    int? activeTab,
    bool? sortByRecent,
    String? selectedFilterType,
    bool clearSelectedFilterType = false,
    List<String>? availableFilterTypes,
    int? totalActivities,
    int? totalPeers,
    int? total,
    int? page,
    bool? hasMore,
    String? unitLabel,
    List<LeaderRankedPeerModel>? allPeers,
    List<LeaderRankedPeerModel>? filteredPeers,
    List<LeaderRankedPeerModel>? topContributors,
    List<LeaderActivityItemModel>? allItems,
    List<LeaderActivityItemModel>? filteredItems,
    Set<String>? processingItemIds,
    String? actionMessage,
    String? errorMessage,
  }) {
    return LeaderActivitiesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      type: type ?? this.type,
      circleId: circleId ?? this.circleId,
      searchQuery: searchQuery ?? this.searchQuery,
      activeTab: activeTab ?? this.activeTab,
      sortByRecent: sortByRecent ?? this.sortByRecent,
      selectedFilterType: clearSelectedFilterType
          ? null
          : (selectedFilterType ?? this.selectedFilterType),
      availableFilterTypes: availableFilterTypes ?? this.availableFilterTypes,
      totalActivities: totalActivities ?? this.totalActivities,
      totalPeers: totalPeers ?? this.totalPeers,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      unitLabel: unitLabel ?? this.unitLabel,
      allPeers: allPeers ?? this.allPeers,
      filteredPeers: filteredPeers ?? this.filteredPeers,
      topContributors: topContributors ?? this.topContributors,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      processingItemIds: processingItemIds ?? this.processingItemIds,
      actionMessage: actionMessage ?? this.actionMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
