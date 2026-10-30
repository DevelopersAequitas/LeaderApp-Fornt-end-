import 'package:flutter/material.dart';
import '../model/dashboard_circle_option.dart';
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

  /// The active filtered circle id (null = all circles in the user's scope).
  final String? selectedCircle;

  /// Dynamic industry categories for role filtering.
  final List<String> dynamicIndustries;

  /// Circles within the user's role scope, used by the circle switcher.
  final List<DashboardCircleOption> availableCircles;

  const DashboardState({
    this.isLoading = false,
    this.metrics,
    this.impacters = const [],
    this.activeTab = 0,
    this.errorMessage = '',
    this.selectedCircle,
    this.dynamicIndustries = const [],
    this.availableCircles = const [],
  });

  /// Helper to copy the state with updated parameters.
  /// Pass [clearSelectedCircle] to reset the circle filter back to "all".
  DashboardState copyWith({
    bool? isLoading,
    DashboardMetricsModel? metrics,
    List<ImpacterModel>? impacters,
    int? activeTab,
    String? errorMessage,
    String? selectedCircle,
    bool clearSelectedCircle = false,
    List<String>? dynamicIndustries,
    List<DashboardCircleOption>? availableCircles,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      metrics: metrics ?? this.metrics,
      impacters: impacters ?? this.impacters,
      activeTab: activeTab ?? this.activeTab,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCircle: clearSelectedCircle
          ? null
          : (selectedCircle ?? this.selectedCircle),
      dynamicIndustries: dynamicIndustries ?? this.dynamicIndustries,
      availableCircles: availableCircles ?? this.availableCircles,
    );
  }
}
