import 'package:equatable/equatable.dart';
import '../model/circular_model.dart';

abstract class CircularsEvent extends Equatable {
  const CircularsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCirculars extends CircularsEvent {
  final bool isRefresh;
  const LoadCirculars({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FilterCircularsByPriority extends CircularsEvent {
  final String priority;
  const FilterCircularsByPriority(this.priority);

  @override
  List<Object?> get props => [priority];
}

class SearchCircularsEvent extends CircularsEvent {
  final String query;
  const SearchCircularsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class PublishCircularEvent extends CircularsEvent {
  final CircularModel circular;
  const PublishCircularEvent(this.circular);

  @override
  List<Object?> get props => [circular];
}
