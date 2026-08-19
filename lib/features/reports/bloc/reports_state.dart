import 'package:flutter/material.dart';
import '../model/report_model.dart';

@immutable
class ReportsState {
  final bool isLoading;
  final int activeSubTab; // 0: Submit, 1: History
  final String selectedType; // "Weekly" or "Monthly"
  final String circleName;
  final String reportContent;
  final List<ReportModel> submittedReports;
  final bool isSubmitting;
  final bool isSuccess;
  final String errorMessage;
  final String? selectedCircle;

  const ReportsState({
    this.isLoading = false,
    this.activeSubTab = 0,
    this.selectedType = 'Monthly',
    this.circleName = 'Mumbai Tech Sunrise',
    this.reportContent = '',
    this.submittedReports = const [],
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage = '',
    this.selectedCircle,
  });

  ReportsState copyWith({
    bool? isLoading,
    int? activeSubTab,
    String? selectedType,
    String? circleName,
    String? reportContent,
    List<ReportModel>? submittedReports,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    String? selectedCircle,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      activeSubTab: activeSubTab ?? this.activeSubTab,
      selectedType: selectedType ?? this.selectedType,
      circleName: circleName ?? this.circleName,
      reportContent: reportContent ?? this.reportContent,
      submittedReports: submittedReports ?? this.submittedReports,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCircle: selectedCircle ?? this.selectedCircle,
    );
  }
}
