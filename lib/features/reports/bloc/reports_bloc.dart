import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../../data/repositories/teams_repository.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/report_model.dart';
import 'reports_event.dart';
import 'reports_state.dart';

/// Business Logic Component for managing leadership report creations and history via Clean Architecture.
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _reportsRepository;
  final TeamsRepository _teamsRepository;

  ReportsBloc({
    ReportsRepository? reportsRepository,
    TeamsRepository? teamsRepository,
  })  : _reportsRepository = reportsRepository ?? ReportsRepositoryImpl(),
        _teamsRepository = teamsRepository ?? TeamsRepositoryImpl(),
        super(const ReportsState()) {
    on<LoadReports>(_onLoadReports);
    on<ToggleReportSubTab>(_onToggleReportSubTab);
    on<ChangeReportType>(_onChangeReportType);
    on<ChangeSelectedCircle>(_onChangeSelectedCircle);
    on<ReportContentChanged>(_onReportContentChanged);
    on<SubmitReportForm>(_onSubmitReportForm);
  }

  Future<void> _onLoadReports(LoadReports event, Emitter<ReportsState> emit) async {
    if (state.submittedReports.isEmpty) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    final activeCircle = event.selectedCircle ?? state.selectedCircle ?? '';

    // Retrieve available circles for this user's scope
    List<String> circlesList = List<String>.from(state.availableCircles);
    try {
      final circlesRes = await _teamsRepository.getCircles();
      if (circlesRes.success && circlesRes.data != null && circlesRes.data!.isNotEmpty) {
        circlesList = circlesRes.data!.map((c) => c.name).where((n) => n.isNotEmpty).toList();
      }
    } catch (_) {}

    if (circlesList.isEmpty) {
      final sessionCircles = SessionManager().currentSession.managedCircles;
      if (sessionCircles.isNotEmpty) {
        circlesList = List<String>.from(sessionCircles);
      }
    }

    final resolvedCircleName = state.circleName.isNotEmpty
        ? state.circleName
        : (activeCircle.isNotEmpty
            ? activeCircle
            : (circlesList.isNotEmpty ? circlesList.first : ''));

    try {
      final reportsResponse = await _reportsRepository.getReports(circleId: activeCircle);
      final trendResponse = await _reportsRepository.getAttendanceTrend(circleId: activeCircle);

      emit(
        state.copyWith(
          isLoading: false,
          submittedReports: reportsResponse.data ?? const [],
          attendanceTrend: trendResponse.data ?? const [],
          selectedCircle: activeCircle,
          availableCircles: circlesList,
          circleName: resolvedCircleName,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          availableCircles: circlesList,
          circleName: resolvedCircleName,
        ),
      );
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

  void _onChangeSelectedCircle(
    ChangeSelectedCircle event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(circleName: event.circleName));
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
          circleName: state.circleName,
          content: state.reportContent,
          author: '${session.name} · ${state.circleName}',
          authorRole: session.role.label,
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

