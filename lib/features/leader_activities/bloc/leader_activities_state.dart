import '../model/leader_activity_item_model.dart';

class LeaderActivitiesState {
  final bool isLoading;
  final String type;
  final String? circleId;
  final String searchQuery;
  final int activeTab;
  final List<LeaderRankedPeerModel> allPeers;
  final List<LeaderRankedPeerModel> filteredPeers;
  final List<LeaderActivityItemModel> allItems;
  final List<LeaderActivityItemModel> filteredItems;
  final Set<String> processingItemIds;
  final String actionMessage;
  final String errorMessage;

  const LeaderActivitiesState({
    this.isLoading = false,
    this.type = '',
    this.circleId,
    this.searchQuery = '',
    this.activeTab = 0,
    this.allPeers = const [],
    this.filteredPeers = const [],
    this.allItems = const [],
    this.filteredItems = const [],
    this.processingItemIds = const <String>{},
    this.actionMessage = '',
    this.errorMessage = '',
  });

  LeaderActivitiesState copyWith({
    bool? isLoading,
    String? type,
    String? circleId,
    String? searchQuery,
    int? activeTab,
    List<LeaderRankedPeerModel>? allPeers,
    List<LeaderRankedPeerModel>? filteredPeers,
    List<LeaderActivityItemModel>? allItems,
    List<LeaderActivityItemModel>? filteredItems,
    Set<String>? processingItemIds,
    String? actionMessage,
    String? errorMessage,
  }) {
    return LeaderActivitiesState(
      isLoading: isLoading ?? this.isLoading,
      type: type ?? this.type,
      circleId: circleId ?? this.circleId,
      searchQuery: searchQuery ?? this.searchQuery,
      activeTab: activeTab ?? this.activeTab,
      allPeers: allPeers ?? this.allPeers,
      filteredPeers: filteredPeers ?? this.filteredPeers,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      processingItemIds: processingItemIds ?? this.processingItemIds,
      actionMessage: actionMessage ?? this.actionMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
