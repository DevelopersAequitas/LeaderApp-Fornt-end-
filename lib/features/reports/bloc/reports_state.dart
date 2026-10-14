import 'package:flutter/material.dart';
import '../model/report_download_model.dart';
import '../model/report_model.dart';

@immutable
class ReportsState {
  final bool isLoading;
  final int activeSubTab; // 0: Submit, 1: History
  final String selectedType; // "Weekly", "Monthly", "Quarterly", "Annual"
  final String circleName;
  final String? selectedCircleId;
  final List<String> availableCircles;

  // Form Fields
  final String period;
  final String reportContent;
  final String highlights;
  final String challengesFaced;
  final String actionItems;
  final double? attendancePercentage;
  final String dealsClosedValue;
  final String totalRevenue;

  // History & Filters
  final String filterType; // "all", "Weekly", "Monthly", "Quarterly", "Annual"
  final String filterStatus; // "all", "Approved", "Under Review", "Draft"
  final List<ReportModel> submittedReports;
  final List<ReportsChartPoint> attendanceTrend;

  // Single Report Details & PDF Download
  final ReportModel? selectedReportDetail;
  final bool isLoadingDetail;
  final ReportDownloadModel? activeDownload;
  final bool isDownloading;

  // Submission Status
  final bool isSubmitting;
  final bool isSuccess;
  final String errorMessage;
  final String successMessage;
  final String? selectedCircle;

  const ReportsState({
    this.isLoading = false,
    this.activeSubTab = 0,
    this.selectedType = 'Monthly',
    this.circleName = '',
    this.selectedCircleId,
    this.availableCircles = const [],
    this.period = '',
    this.reportContent = '',
    this.highlights = '',
    this.challengesFaced = '',
    this.actionItems = '',
    this.attendancePercentage,
    this.dealsClosedValue = '',
    this.totalRevenue = '',
    this.filterType = 'all',
    this.filterStatus = 'all',
    this.submittedReports = const [],
    this.attendanceTrend = const [],
    this.selectedReportDetail,
    this.isLoadingDetail = false,
    this.activeDownload,
    this.isDownloading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage = '',
    this.successMessage = '',
    this.selectedCircle,
  });

  ReportsState copyWith({
    bool? isLoading,
    int? activeSubTab,
    String? selectedType,
    String? circleName,
    String? selectedCircleId,
    List<String>? availableCircles,
    String? period,
    String? reportContent,
    String? highlights,
    String? challengesFaced,
    String? actionItems,
    double? attendancePercentage,
    String? dealsClosedValue,
    String? totalRevenue,
    String? filterType,
    String? filterStatus,
    List<ReportModel>? submittedReports,
    List<ReportsChartPoint>? attendanceTrend,
    ReportModel? selectedReportDetail,
    bool? isLoadingDetail,
    ReportDownloadModel? activeDownload,
    bool? isDownloading,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    String? successMessage,
    String? selectedCircle,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      activeSubTab: activeSubTab ?? this.activeSubTab,
      selectedType: selectedType ?? this.selectedType,
      circleName: circleName ?? this.circleName,
      selectedCircleId: selectedCircleId ?? this.selectedCircleId,
      availableCircles: availableCircles ?? this.availableCircles,
      period: period ?? this.period,
      reportContent: reportContent ?? this.reportContent,
      highlights: highlights ?? this.highlights,
      challengesFaced: challengesFaced ?? this.challengesFaced,
      actionItems: actionItems ?? this.actionItems,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      dealsClosedValue: dealsClosedValue ?? this.dealsClosedValue,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      filterType: filterType ?? this.filterType,
      filterStatus: filterStatus ?? this.filterStatus,
      submittedReports: submittedReports ?? this.submittedReports,
      attendanceTrend: attendanceTrend ?? this.attendanceTrend,
      selectedReportDetail: selectedReportDetail ?? this.selectedReportDetail,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      activeDownload: activeDownload ?? this.activeDownload,
      isDownloading: isDownloading ?? this.isDownloading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      selectedCircle: selectedCircle ?? this.selectedCircle,
    );
  }
}


