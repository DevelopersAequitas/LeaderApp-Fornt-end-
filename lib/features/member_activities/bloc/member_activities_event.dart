import '../model/member_activity_model.dart';

abstract class MemberActivitiesEvent {
  const MemberActivitiesEvent();
}

/// Loads (or refreshes) the first page of activities for a member + category.
class LoadMemberActivities extends MemberActivitiesEvent {
  final String memberId;
  final MemberActivityType type;

  const LoadMemberActivities({required this.memberId, required this.type});
}

/// Appends the next page when the user scrolls to the end of the list.
class LoadMoreMemberActivities extends MemberActivitiesEvent {
  const LoadMoreMemberActivities();
}
