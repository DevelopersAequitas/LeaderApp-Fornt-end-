import '../model/member_activity_model.dart';

class MemberActivitiesState {
  final String memberId;
  final MemberActivityType type;
  final List<MemberActivityModel> activities;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String errorMessage;

  const MemberActivitiesState({
    this.memberId = '',
    this.type = MemberActivityType.other,
    this.activities = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.page = 1,
    this.errorMessage = '',
  });

  MemberActivitiesState copyWith({
    String? memberId,
    MemberActivityType? type,
    List<MemberActivityModel>? activities,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? errorMessage,
  }) {
    return MemberActivitiesState(
      memberId: memberId ?? this.memberId,
      type: type ?? this.type,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
