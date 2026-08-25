import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/report_model.dart';
import 'reports_event.dart';
import 'reports_state.dart';

/// Business Logic Component for managing leadership report creations and history via Clean Architecture.
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _reportsRepository;

  ReportsBloc({ReportsRepository? reportsRepository})
      : _reportsRepository = reportsRepository ?? ReportsRepositoryImpl(),
        super(const ReportsState()) {
    on<LoadReports>(_onLoadReports);
    on<ToggleReportSubTab>(_onToggleReportSubTab);
    on<ChangeReportType>(_onChangeReportType);
    on<ReportContentChanged>(_onReportContentChanged);
    on<SubmitReportForm>(_onSubmitReportForm);
  }

  Future<void> _onLoadReports(LoadReports event, Emitter<ReportsState> emit) async {
    if (state.submittedReports.isEmpty) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    final activeCircle = event.selectedCircle ?? state.selectedCircle ?? '';

    try {
      final reportsResponse = await _reportsRepository.getReports(circleId: activeCircle);
      final trendResponse = await _reportsRepository.getAttendanceTrend(circleId: activeCircle);

      emit(
        state.copyWith(
          isLoading: false,
          submittedReports: reportsResponse.data ?? const [],
          attendanceTrend: trendResponse.data ?? const [],
          selectedCircle: activeCircle,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onToggleReportSubTab(
    ToggleReportSubTab event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(activeSubTab: event.index, isSuccess: false));
  }

  void _onChangeReportType(ChangeReportType event, Emitter<ReportsState> emit) {
    emit(state.copyWith(selectedType: event.type));
  }

  void _onReportContentChanged(
    ReportContentChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(reportContent: event.content, errorMessage: ''));
  }

  Future<void> _onSubmitReportForm(
    SubmitReportForm event,
    Emitter<ReportsState> emit,
  ) async {
    if (state.reportContent.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Report content cannot be empty.'));
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, errorMessage: '', isSuccess: false),
    );

    try {
      final session = SessionManager().currentSession;
      final response = await _reportsRepository.submitReport(
        circleId: state.circleName,
        type: state.selectedType,
        period: 'Aug 2026',
        content: state.reportContent,
      );

      if (response.success) {
        final newReport = ReportModel(
          type: state.selectedType,
          status: 'Submitted',
          date: 'Aug 25, 2026',
          content: state.reportContent,
          author: '${session.name} · ${state.circleName}',
        );

        final updatedList = [newReport, ...state.submittedReports];

        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            submittedReports: updatedList,
            reportContent: '',
          ),
        );
      } else {
        emit(state.copyWith(isSubmitting: false, errorMessage: response.message ?? 'Submission failed.'));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
