// ==============================================================================
// File: lib/features/reports/view/reports_view.dart
// Description: Leadership Reports Submission, History & Analytics Export Center
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Segmented sub-tab switcher between Report Submission and Submitted History
//   - Structured report submission forms with recipient hierarchy previews
//   - Real-time submission state feedback driven by `ReportsBloc`
//   - Export section for Super Admins and Country Directors
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
/// 100% Pure StatelessWidget powered by BLoC state machine.
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

class _ReportsContent extends StatelessWidget {
  final String? selectedCircle;
  final TextEditingController _contentController = TextEditingController();

  _ReportsContent({this.selectedCircle});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReportsBloc>();
    final session = SessionManager().currentSession;
    final canExport = session.role == UserRole.superAdmin ||
        session.role == UserRole.countryDirector;

    return BlocListener<ReportsBloc, ReportsState>(
      listenWhen: (prev, curr) =>
          (prev.errorMessage != curr.errorMessage &&
              curr.errorMessage.isNotEmpty) ||
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
            const SnackBar(
              content: Text('Report submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          _contentController.clear();
        }
      },
      child: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state.isLoading && state.submittedReports.isEmpty) {
            return const CenteredLoadingIndicator(height: 300);
          }

          return RefreshIndicator(
            onRefresh: () async {
              bloc.add(LoadReports(selectedCircle: selectedCircle));
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
                    secondTabLabel: 'History',
                    secondTabBadge: state.submittedReports.isNotEmpty
                        ? '${state.submittedReports.length}'
                        : null,
                    onTabSelected: (idx) =>
                        bloc.add(ToggleReportSubTab(idx)),
                  ),
                  const SizedBox(height: 12),
                  if (state.activeSubTab == 0)
                    ReportSubmitSection(
                      selectedType: state.selectedType,
                      onTypeChanged: (type) =>
                          bloc.add(ChangeReportType(type)),
                      circleName: state.circleName,
                      availableCircles: state.availableCircles,
                      onCircleChanged: (circle) =>
                          bloc.add(ChangeSelectedCircle(circle)),
                      contentController: _contentController,
                      isSubmitting: state.isSubmitting,
                      onSubmit: () {
                        bloc.add(
                          ReportContentChanged(_contentController.text),
                        );
                        bloc.add(const SubmitReportForm());
                      },
                    )
                  else ...[
                    ReportHistorySection(reports: state.submittedReports),
                    if (canExport) ...[
                      const SizedBox(height: 16),
                      ReportsExportSection(
                        selectedCircle: selectedCircle,
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
