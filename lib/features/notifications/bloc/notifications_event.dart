import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  final bool isRefresh;
  const LoadNotifications({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FilterNotifications extends NotificationsEvent {
  final String filter;
  const FilterNotifications(this.filter);

  @override
  List<Object?> get props => [filter];
}

class MarkAllAsRead extends NotificationsEvent {
  const MarkAllAsRead();
}

class ClearAllNotifications extends NotificationsEvent {
  const ClearAllNotifications();
}
