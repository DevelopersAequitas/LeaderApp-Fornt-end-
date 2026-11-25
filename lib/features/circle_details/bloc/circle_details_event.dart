import 'package:equatable/equatable.dart';

abstract class CircleDetailsEvent extends Equatable {
  const CircleDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCircleDetailsData extends CircleDetailsEvent {
  final String circleId;
  final bool isRefresh;

  const LoadCircleDetailsData({required this.circleId, this.isRefresh = false});

  @override
  List<Object?> get props => [circleId, isRefresh];
}

class ChangeCircleSubTabEvent extends CircleDetailsEvent {
  final int tabIndex;

  const ChangeCircleSubTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class FilterCircleEventsEvent extends CircleDetailsEvent {
  final String filter;

  const FilterCircleEventsEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class LoadMoreCirclePeersEvent extends CircleDetailsEvent {
  final String circleId;

  const LoadMoreCirclePeersEvent({required this.circleId});

  @override
  List<Object?> get props => [circleId];
}

class SearchCirclePeersEvent extends CircleDetailsEvent {
  final String query;

  const SearchCirclePeersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterCirclePeersStatusEvent extends CircleDetailsEvent {
  final String status;

  const FilterCirclePeersStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class AssignCircleRoleEvent extends CircleDetailsEvent {
  final String circleId;
  final String userId;
  final String role;
  final String? committeeName;

  const AssignCircleRoleEvent({
    required this.circleId,
    required this.userId,
    required this.role,
    this.committeeName,
  });

  @override
  List<Object?> get props => [circleId, userId, role, committeeName];
}

