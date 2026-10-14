// ==============================================================================
// File: lib/features/reports/view/reports_view.dart
// Description: Leadership Reports Submission, History & Analytics Export Center
// Framework: Flutter | Architecture: MVP View Layer (BLoC + State Management)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import 'widgets/report_history_section.dart';
import 'widgets/report_submit_section.dart';
import 'widgets/reports_export_section.dart';
import 'widgets/reports_tab_selector.dart';

/// The View component of the Reports tab feature.
class ReportsView extends StatelessWidget {
  final String? selectedCircle;

  const ReportsView({super.key, this.selectedCircle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsBloc>(
      key: ValueKey(selectedCircle),
      create: (context) =>
          ReportsBloc()..add(LoadReports(selectedCircle: selectedCircle)),
      child: _ReportsContent(selectedCircle: selectedCircle),
    );
  }
}

class _ReportsContent extends StatefulWidget {
  final String? selectedCircle;

  const _ReportsContent({this.selectedCircle});

  @override
  State<_ReportsContent> createState() => _ReportsContentState();
}

class _ReportsContentState extends State<_ReportsContent> {
  late final TextEditingController _periodController;
  late final TextEditingController _attendanceController;
  late final TextEditingController _dealsClosedController;
  late final TextEditingController _totalRevenueController;
  late final TextEditingController _contentController;
  late final TextEditingController _highlightsController;
  late final TextEditingController _challengesController;
  late final TextEditingController _actionItemsController;

  @override
  void initState() {
    super.initState();
    _periodController = TextEditingController();
    _attendanceController = TextEditingController(text: '95.0');
    _dealsClosedController = TextEditingController();
    _totalRevenueController = TextEditingController();
    _contentController = TextEditingController();
    _highlightsController = TextEditingController();
    _challengesController = TextEditingController();
    _actionItemsController = TextEditingController();
  }

  @override
  void dispose() {
    _periodController.dispose();
    _attendanceController.dispose();
    _dealsClosedController.dispose();
    _totalRevenueController.dispose();
    _contentController.dispose();
    _highlightsController.dispose();
    _challengesController.dispose();
    _actionItemsController.dispose();
    super.dispose();
  }

  void _syncControllersWithState(ReportsState state) {
    if (_periodController.text.isEmpty && state.period.isNotEmpty) {
      _periodController.text = state.period;
    }
  }

  void _clearFormControllers() {
    _contentController.clear();
    _highlightsController.clear();
    _challengesController.clear();
    _actionItemsController.clear();
    _dealsClosedController.clear();
    _totalRevenueController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReportsBloc>();
    final session = SessionManager().currentSession;
    final canExport = session.role == UserRole.superAdmin ||
        session.role == UserRole.countryDirector;

    return BlocListener<ReportsBloc, ReportsState>(
      listenWhen: (prev, curr) =>
          (prev.errorMessage != curr.errorMessage && curr.errorMessage.isNotEmpty) ||
          (prev.isSuccess != curr.isSuccess && curr.isSuccess),
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        } else if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.successMessage.isNotEmpty
                    ? state.successMessage
                    : 'Report submitted successfully and routed to higher leadership.',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          _clearFormControllers();
        }
      },
      child: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          _syncControllersWithState(state);

          if (state.isLoading && state.submittedReports.isEmpty && state.attendanceTrend.isEmpty) {
            return const CenteredLoadingIndicator(height: 300);
          }

          return RefreshIndicator(
            onRefresh: () async {
              bloc.add(LoadReports(selectedCircle: widget.selectedCircle));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReportsTabSelector(
                    activeIndex: state.activeSubTab,
                    firstTabLabel: 'Submit Report',
                    secondTabLabel: 'History & Analytics',
                    secondTabBadge: state.submittedReports.isNotEmpty
                        ? '${state.submittedReports.length}'
                        : null,
                    onTabSelected: (idx) => bloc.add(ToggleReportSubTab(idx)),
                  ),
                  const SizedBox(height: 12),
                  if (state.activeSubTab == 0)
                    ReportSubmitSection(
                      selectedType: state.selectedType,
                      onTypeChanged: (type) => bloc.add(ChangeReportType(type)),
                      circleName: state.circleName,
                      availableCircles: state.availableCircles,
                      onCircleChanged: (circle) =>
                          bloc.add(ChangeSelectedCircle(circle)),
                      periodController: _periodController,
                      attendanceController: _attendanceController,
                      dealsClosedController: _dealsClosedController,
                      totalRevenueController: _totalRevenueController,
                      contentController: _contentController,
                      highlightsController: _highlightsController,
                      challengesController: _challengesController,
                      actionItemsController: _actionItemsController,
                      isSubmitting: state.isSubmitting,
                      onSubmit: () {
                        final attVal = double.tryParse(_attendanceController.text.trim()) ?? 95.0;
                        bloc.add(ReportPeriodChanged(_periodController.text.trim()));
                        bloc.add(ReportAttendanceChanged(attVal));
                        bloc.add(ReportDealsValueChanged(_dealsClosedController.text.trim()));
                        bloc.add(ReportRevenueChanged(_totalRevenueController.text.trim()));
                        bloc.add(ReportContentChanged(_contentController.text.trim()));
                        bloc.add(ReportHighlightsChanged(_highlightsController.text.trim()));
                        bloc.add(ReportChallengesChanged(_challengesController.text.trim()));
                        bloc.add(ReportActionItemsChanged(_actionItemsController.text.trim()));
                        bloc.add(const SubmitReportForm());
                      },
                    )
                  else ...[
                    ReportHistorySection(
                      reports: state.submittedReports,
                      attendanceTrend: state.attendanceTrend,
                      filterType: state.filterType,
                      filterStatus: state.filterStatus,
                      onFilterTypeChanged: (type) =>
                          bloc.add(FilterReportsByType(type)),
                      onFilterStatusChanged: (status) =>
                          bloc.add(FilterReportsByStatus(status)),
                    ),
                    if (canExport) ...[
                      const SizedBox(height: 16),
                      ReportsExportSection(
                        selectedCircle: widget.selectedCircle,
                        attendanceTrend: state.attendanceTrend,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
