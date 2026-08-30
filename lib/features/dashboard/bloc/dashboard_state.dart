import 'package:flutter/material.dart';
import '../model/dashboard_metrics_model.dart';
import '../model/impacter_model.dart';

@immutable
class DashboardState {
  /// True when remote API data is fetching.
  final bool isLoading;

  /// Loaded dashboard metrics figures.
  final DashboardMetricsModel? metrics;

  /// Top impacter profiles.
  final List<ImpacterModel> impacters;

  /// Selected tab in bottom navigation (0: Dashboard, 1: Peers, 2: Teams, 3: Finance, 4: Report).
  final int activeTab;

  /// Load error explanation if any.
  final String errorMessage;

  /// The active filtered circle name.
  final String? selectedCircle;

  /// Unread notifications count for app bar badge.
  final int unreadNotificationCount;

  /// Dynamic industry categories for role filtering.
  final List<String> dynamicIndustries;

  const DashboardState({
    this.isLoading = false,
    this.metrics,
    this.impacters = const [],
    this.activeTab = 0,
    this.errorMessage = '',
    this.selectedCircle,
    this.unreadNotificationCount = 0,
    this.dynamicIndustries = const [],
  });

  /// Helper to copy the state with updated parameters.
  DashboardState copyWith({
    bool? isLoading,
    DashboardMetricsModel? metrics,
    List<ImpacterModel>? impacters,
    int? activeTab,
    String? errorMessage,
    String? selectedCircle,
    int? unreadNotificationCount,
    List<String>? dynamicIndustries,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      metrics: metrics ?? this.metrics,
      impacters: impacters ?? this.impacters,
      activeTab: activeTab ?? this.activeTab,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCircle: selectedCircle ?? this.selectedCircle,
      unreadNotificationCount:
          unreadNotificationCount ?? this.unreadNotificationCount,
      dynamicIndustries: dynamicIndustries ?? this.dynamicIndustries,
    );
  }
}
