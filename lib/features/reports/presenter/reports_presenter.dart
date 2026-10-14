import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

/// Contract interface defining Reports view actions.
abstract class ReportsViewContract {
  void onReportsLoading();
  void onReportsLoaded();
  void onReportSubmitting();
  void onReportSubmitSuccess();
  void onReportsError(String error);
  void onSubTabChanged(int index);
}

/// Presenter coordinating visual transitions for Reports feature.
class ReportsPresenter {
  final ReportsViewContract view;
  final ReportsBloc bloc;

  ReportsPresenter({required this.view, required this.bloc});

  void load({String? selectedCircle, String? reportType, String? status}) {
    bloc.add(LoadReports(
      selectedCircle: selectedCircle,
      reportType: reportType,
      status: status,
    ));
  }

  void changeSubTab(int index) {
    bloc.add(ToggleReportSubTab(index));
  }

  void changeReportType(String type) {
    bloc.add(ChangeReportType(type));
  }

  void changeCircle(String circleName, {String? circleId}) {
    bloc.add(ChangeSelectedCircle(circleName, circleId: circleId));
  }

  void onPeriodChanged(String period) {
    bloc.add(ReportPeriodChanged(period));
  }

  void onContentChanged(String content) {
    bloc.add(ReportContentChanged(content));
  }

  void onHighlightsChanged(String highlights) {
    bloc.add(ReportHighlightsChanged(highlights));
  }

  void onChallengesChanged(String challenges) {
    bloc.add(ReportChallengesChanged(challenges));
  }

  void onActionItemsChanged(String actionItems) {
    bloc.add(ReportActionItemsChanged(actionItems));
  }

  void onAttendanceChanged(double attendance) {
    bloc.add(ReportAttendanceChanged(attendance));
  }

  void onDealsValueChanged(String dealsValue) {
    bloc.add(ReportDealsValueChanged(dealsValue));
  }

  void onRevenueChanged(String revenue) {
    bloc.add(ReportRevenueChanged(revenue));
  }

  void filterByType(String reportType) {
    bloc.add(FilterReportsByType(reportType));
  }

  void filterByStatus(String status) {
    bloc.add(FilterReportsByStatus(status));
  }

  void fetchReportDetails(String reportId) {
    bloc.add(FetchReportDetails(reportId));
  }

  void downloadReportPdf(String reportId) {
    bloc.add(DownloadReportPdf(reportId));
  }

  void submit() {
    bloc.add(const SubmitReportForm());
  }

  void handleStateChange(ReportsState state) {
    view.onSubTabChanged(state.activeSubTab);

    if (state.isLoading) {
      view.onReportsLoading();
    } else {
      view.onReportsLoaded();
    }

    if (state.isSubmitting) {
      view.onReportSubmitting();
    }

    if (state.isSuccess) {
      view.onReportSubmitSuccess();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onReportsError(state.errorMessage);
    }
  }
}

