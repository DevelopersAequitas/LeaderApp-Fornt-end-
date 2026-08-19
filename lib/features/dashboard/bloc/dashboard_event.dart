import 'package:flutter/material.dart';

@immutable
abstract class DashboardEvent {
  const DashboardEvent();
}

/// Triggers loading of metrics and impacter lists.
class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

/// Dispatched when the user switches tabs in the bottom navigation bar.
class TabChanged extends DashboardEvent {
  final int index;
  const TabChanged(this.index);
}

/// Dispatched when the user switches active managed circles.
class SelectCircle extends DashboardEvent {
  final String circleName;
  const SelectCircle(this.circleName);
}
