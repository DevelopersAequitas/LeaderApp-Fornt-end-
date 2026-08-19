import 'package:flutter/material.dart';

@immutable
abstract class TeamsEvent {
  const TeamsEvent();
}

/// Triggers loading of teams permissions.
class LoadTeamsData extends TeamsEvent {
  final String? selectedCircle;
  const LoadTeamsData({this.selectedCircle});
}

/// Dispatched when search string changes for circle teams.
class SearchCirclesQueryChanged extends TeamsEvent {
  final String query;
  const SearchCirclesQueryChanged(this.query);
}

/// Dispatched when status filter changes for circle teams.
class StatusCirclesFilterChanged extends TeamsEvent {
  final String status;
  const StatusCirclesFilterChanged(this.status);
}

/// Dispatched when industry filter changes for circle teams.
class IndustryCirclesFilterChanged extends TeamsEvent {
  final String industry;
  const IndustryCirclesFilterChanged(this.industry);
}
