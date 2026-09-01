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
