import '../model/leader_activity_item_model.dart';

abstract class LeaderActivitiesEvent {
  const LeaderActivitiesEvent();
}

class LoadLeaderActivities extends LeaderActivitiesEvent {
  final String type;
  final String? circleId;
  final String? search;

  const LoadLeaderActivities({
    required this.type,
    this.circleId,
    this.search,
  });
}

class SearchLeaderActivities extends LeaderActivitiesEvent {
  final String query;

  const SearchLeaderActivities(this.query);
}

class LoadMoreLeaderActivities extends LeaderActivitiesEvent {
  const LoadMoreLeaderActivities();
}

class SwitchLeaderActivitiesTab extends LeaderActivitiesEvent {
  final int tabIndex;

  const SwitchLeaderActivitiesTab(this.tabIndex);
}

class ChangeLeaderActivitiesFilter extends LeaderActivitiesEvent {
  final bool? sortByRecent;
  final String? selectedFilterType;
  final bool clearFilterType;

  const ChangeLeaderActivitiesFilter({
    this.sortByRecent,
    this.selectedFilterType,
    this.clearFilterType = false,
  });
}

class ApproveLeaderActivityItem extends LeaderActivitiesEvent {
  final LeaderActivityItemModel item;
  final String? remarks;

  const ApproveLeaderActivityItem(this.item, {this.remarks});
}

class RejectLeaderActivityItem extends LeaderActivitiesEvent {
  final LeaderActivityItemModel item;
  final String? reason;

  const RejectLeaderActivityItem(this.item, {this.reason});
}
