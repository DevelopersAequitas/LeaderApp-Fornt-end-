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

  void load({String? selectedCircle}) {
    bloc.add(LoadReports(selectedCircle: selectedCircle));
  }

  void changeSubTab(int index) {
    bloc.add(ToggleReportSubTab(index));
  }

  void changeReportType(String type) {
    bloc.add(ChangeReportType(type));
  }

  void onContentChanged(String content) {
    bloc.add(ReportContentChanged(content));
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
