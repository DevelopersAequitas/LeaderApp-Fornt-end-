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

class SwitchLeaderActivitiesTab extends LeaderActivitiesEvent {
  final int tabIndex;

  const SwitchLeaderActivitiesTab(this.tabIndex);
}

class ApproveLeaderActivityItem extends LeaderActivitiesEvent {
  final LeaderActivityItemModel item;

  const ApproveLeaderActivityItem(this.item);
}

class RejectLeaderActivityItem extends LeaderActivitiesEvent {
  final LeaderActivityItemModel item;
  final String? reason;

  const RejectLeaderActivityItem(this.item, {this.reason});
}
