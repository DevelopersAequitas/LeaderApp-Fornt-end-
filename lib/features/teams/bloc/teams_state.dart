import 'package:flutter/material.dart';
import '../model/teams_model.dart';

@immutable
class TeamsState {
  final bool isLoading;
  final TeamsPermissionModel? permission;
  final String errorMessage;
  final List<CircleTeamModel> allCircles;
  final List<CircleTeamModel> filteredCircles;
  final String searchQuery;
  final String selectedStatusFilter;
  final String selectedIndustryFilter;
  final String? selectedCircle;

  const TeamsState({
    this.isLoading = false,
    this.permission,
    this.errorMessage = '',
    this.allCircles = const [],
    this.filteredCircles = const [],
    this.searchQuery = '',
    this.selectedStatusFilter = 'All',
    this.selectedIndustryFilter = 'All Industries',
    this.selectedCircle,
  });

  TeamsState copyWith({
    bool? isLoading,
    TeamsPermissionModel? permission,
    String? errorMessage,
    List<CircleTeamModel>? allCircles,
    List<CircleTeamModel>? filteredCircles,
    String? searchQuery,
    String? selectedStatusFilter,
    String? selectedIndustryFilter,
    String? selectedCircle,
  }) {
    return TeamsState(
      isLoading: isLoading ?? this.isLoading,
      permission: permission ?? this.permission,
      errorMessage: errorMessage ?? this.errorMessage,
      allCircles: allCircles ?? this.allCircles,
      filteredCircles: filteredCircles ?? this.filteredCircles,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedIndustryFilter:
          selectedIndustryFilter ?? this.selectedIndustryFilter,
      selectedCircle: selectedCircle ?? this.selectedCircle,
    );
  }
}
