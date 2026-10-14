import 'package:flutter/material.dart';

@immutable
abstract class ReportsEvent {
  const ReportsEvent();
}

/// Triggers loading of reports history list and 6-month attendance trend.
class LoadReports extends ReportsEvent {
  final String? selectedCircle;
  final String? reportType;
  final String? status;
  final String? districtId;

  const LoadReports({
    this.selectedCircle,
    this.reportType,
    this.status,
    this.districtId,
  });
}

/// Dispatched when changing type filter in History tab (All, Weekly, Monthly, Quarterly, Annual).
class FilterReportsByType extends ReportsEvent {
  final String reportType;
  const FilterReportsByType(this.reportType);
}

/// Dispatched when changing status filter in History tab (All, Approved, Under Review, Draft).
class FilterReportsByStatus extends ReportsEvent {
  final String status;
  const FilterReportsByStatus(this.status);
}

/// Dispatched when switching segment sub-tabs (0: Submit Report, 1: History list & Analytics).
class ToggleReportSubTab extends ReportsEvent {
  final int index;
  const ToggleReportSubTab(this.index);
}

/// Dispatched when toggling report type to submit ("Weekly", "Monthly", "Quarterly", "Annual").
class ChangeReportType extends ReportsEvent {
  final String type;
  const ChangeReportType(this.type);
}

/// Dispatched when selecting a circle to submit report for.
class ChangeSelectedCircle extends ReportsEvent {
  final String circleName;
  final String? circleId;
  const ChangeSelectedCircle(this.circleName, {this.circleId});
}

/// Form input change events for LeaderSubmitReportRequest
class ReportPeriodChanged extends ReportsEvent {
  final String period;
  const ReportPeriodChanged(this.period);
}

class ReportContentChanged extends ReportsEvent {
  final String content;
  const ReportContentChanged(this.content);
}

class ReportHighlightsChanged extends ReportsEvent {
  final String highlights;
  const ReportHighlightsChanged(this.highlights);
}

class ReportChallengesChanged extends ReportsEvent {
  final String challenges;
  const ReportChallengesChanged(this.challenges);
}

class ReportActionItemsChanged extends ReportsEvent {
  final String actionItems;
  const ReportActionItemsChanged(this.actionItems);
}

class ReportAttendanceChanged extends ReportsEvent {
  final double? attendance;
  const ReportAttendanceChanged(this.attendance);
}

class ReportDealsValueChanged extends ReportsEvent {
  final String dealsValue;
  const ReportDealsValueChanged(this.dealsValue);
}

class ReportRevenueChanged extends ReportsEvent {
  final String revenue;
  const ReportRevenueChanged(this.revenue);
}

/// Dispatched when report form is submitted.
class SubmitReportForm extends ReportsEvent {
  const SubmitReportForm();
}

/// Dispatched when user views full report details with peer breakdown (Endpoint 4).
class FetchReportDetails extends ReportsEvent {
  final String reportId;
  const FetchReportDetails(this.reportId);
}

/// Dispatched when user requests pre-signed PDF download link (Endpoint 5).
class DownloadReportPdf extends ReportsEvent {
  final String reportId;
  const DownloadReportPdf(this.reportId);
}

