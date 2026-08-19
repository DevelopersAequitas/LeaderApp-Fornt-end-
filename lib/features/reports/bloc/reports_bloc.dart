import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/report_model.dart';
import 'reports_event.dart';
import 'reports_state.dart';

/// Business Logic Component for managing leadership report creations and history.
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc() : super(const ReportsState()) {
    on<LoadReports>(_onLoadReports);
    on<ToggleReportSubTab>(_onToggleReportSubTab);
    on<ChangeReportType>(_onChangeReportType);
    on<ReportContentChanged>(_onReportContentChanged);
    on<SubmitReportForm>(_onSubmitReportForm);
  }

  // Pre-load with mock reports as shown in the mockup
  static const List<ReportModel> _mockReportsHistory = [
    ReportModel(
      type: 'Monthly',
      status: 'Actioned',
      date: 'Jul 1, 2026',
      author: 'Arjun Patel · Mumbai Tech Sunrise',
      content:
          'Monthly summary: 56 active peers, 88% avg attendance, 11 referrals, 7 deals worth ₹1.34Cr. Recommend recognizing Priya Sharma as peer of the month.',
    ),
    ReportModel(
      type: 'Monthly',
      status: 'Submitted',
      date: 'Jul 27, 2026',
      author: 'Sneha Joshi · Pune Manufacturing Hub',
      content:
          'Pune circle had 82% attendance. New peer Rohan joined. Manufacturing sector discussions positive. Need support for venue booking next month.',
    ),
  ];

  static const List<ReportModel> _mockHealthcareReports = [
    ReportModel(
      type: 'Monthly',
      status: 'Actioned',
      date: 'Jul 5, 2026',
      author: 'Karthik Raja · Mumbai Health Circle',
      content:
          'Monthly summary: 34 active peers, 85% avg attendance, 5 referrals. Healthcare discussions centered on telemedicine apps.',
    ),
    ReportModel(
      type: 'Monthly',
      status: 'Submitted',
      date: 'Jul 25, 2026',
      author: 'Ramesh Kumar · Bangalore Wellness Node',
      content:
          'Bangalore wellness node had 90% attendance. Held a health checkup drive for 40 local peers.',
    ),
  ];

  static const List<ReportModel> _mockStartupsReports = [
    ReportModel(
      type: 'Monthly',
      status: 'Actioned',
      date: 'Jul 10, 2026',
      author: 'Rohan Gupta · Mumbai Startup Club',
      content:
          'Startup circle had 90% attendance. Pitch night was a success with 4 angel investors present.',
    ),
    ReportModel(
      type: 'Monthly',
      status: 'Submitted',
      date: 'Jul 20, 2026',
      author: 'Priya Sen · Delhi Fintech Node',
      content:
          'Monthly summary: 20 active peers, 85% attendance, 4 referrals. FinTech discussions positive. Preparing for incubator pitch next month.',
    ),
  ];

  void _onLoadReports(LoadReports event, Emitter<ReportsState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final session = SessionManager().currentSession;
    final role = session.role;

    final activeCircle =
        event.selectedCircle ?? state.selectedCircle ?? 'Technology';

    final List<ReportModel> scopeReports;
    if (activeCircle == 'Healthcare') {
      scopeReports = _mockHealthcareReports;
    } else if (activeCircle == 'Startups') {
      scopeReports = _mockStartupsReports;
    } else {
      scopeReports = _mockReportsHistory;
    }

    final List<ReportModel> visibleReports;
    if (role == UserRole.circleChair || role == UserRole.circleFounder) {
      visibleReports = scopeReports
          .where((r) => r.author.startsWith(session.name))
          .toList();
    } else {
      visibleReports = scopeReports;
    }

    emit(
      state.copyWith(
        isLoading: false,
        submittedReports: visibleReports,
        selectedCircle: activeCircle,
      ),
    );
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
      // Simulate remote API delay (800ms)
      await Future.delayed(const Duration(milliseconds: 800));

      final session = SessionManager().currentSession;
      final newReport = ReportModel(
        type: state.selectedType,
        status: 'Submitted',
        date: 'Aug 11, 2026', // Mock active submission date
        content: state.reportContent,
        author: '${session.name} · ${state.circleName}',
      );

      final updatedList = [newReport, ...state.submittedReports];

      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          submittedReports: updatedList,
          reportContent: '', // reset field
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
