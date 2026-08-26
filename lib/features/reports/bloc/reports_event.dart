import 'package:flutter/material.dart';

@immutable
abstract class ReportsEvent {
  const ReportsEvent();
}

/// Triggers loading of reports history list.
class LoadReports extends ReportsEvent {
  final String? selectedCircle;
  const LoadReports({this.selectedCircle});
}

/// Dispatched when switching segment sub-tabs (0: Submit Report, 1: History list).
class ToggleReportSubTab extends ReportsEvent {
  final int index;
  const ToggleReportSubTab(this.index);
}

/// Dispatched when toggling between Weekly and Monthly report types.
class ChangeReportType extends ReportsEvent {
  final String type; // "Weekly" or "Monthly"
  const ChangeReportType(this.type);
}

/// Dispatched when report text field updates.
class ReportContentChanged extends ReportsEvent {
  final String content;
  const ReportContentChanged(this.content);
}

/// Dispatched when selecting a circle to submit report for.
class ChangeSelectedCircle extends ReportsEvent {
  final String circleName;
  const ChangeSelectedCircle(this.circleName);
}

/// Dispatched when report form is submitted.
class SubmitReportForm extends ReportsEvent {
  const SubmitReportForm();
}

