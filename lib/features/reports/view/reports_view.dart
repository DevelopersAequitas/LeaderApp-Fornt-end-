import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_state.dart';
import '../model/report_model.dart';
import '../presenter/reports_presenter.dart';
import 'widgets/report_history_section.dart';
import 'widgets/report_submit_section.dart';
import 'widgets/reports_export_section.dart';
import 'widgets/reports_tab_selector.dart';

/// The View component of the Reports tab feature.
/// Handles weekly/monthly report submissions, historical reports list, and exports with role-based UI.
class ReportsView extends StatefulWidget {
  final String? selectedCircle;
  const ReportsView({super.key, this.selectedCircle});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView>
    implements ReportsViewContract {
  late final ReportsBloc _bloc;
  late final ReportsPresenter _presenter;
  late final TextEditingController _contentController;

  int _activeSubTab = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _selectedType = 'Monthly';
  String _circleName = '';
  List<String> _availableCircles = const [];
  List<ReportModel> _reports = const [];
  List<ReportsChartPoint> _attendanceTrend = const [];

  @override
  void initState() {
    super.initState();
    _bloc = ReportsBloc();
    _presenter = ReportsPresenter(view: this, bloc: _bloc);
    _contentController = TextEditingController();

    _contentController.addListener(() {
      _presenter.onContentChanged(_contentController.text);
    });

    _presenter.load(selectedCircle: widget.selectedCircle);
  }

  @override
  void didUpdateWidget(covariant ReportsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCircle != oldWidget.selectedCircle) {
      _presenter.load(selectedCircle: widget.selectedCircle);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _bloc.close();
    super.dispose();
  }

  // --- ReportsViewContract Implementations ---

  @override
  void onReportsLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onReportsLoaded() {
    setState(() {
      _isLoading = false;
      _isSubmitting = false;
      _reports = _bloc.state.submittedReports;
      _attendanceTrend = _bloc.state.attendanceTrend;
      _selectedType = _bloc.state.selectedType;
      _circleName = _bloc.state.circleName;
      _availableCircles = _bloc.state.availableCircles;
    });
  }

  @override
  void onReportSubmitting() {
    setState(() => _isSubmitting = true);
  }

  @override
  void onReportSubmitSuccess() {
    setState(() {
      _isSubmitting = false;
      _contentController.clear();
      _reports = _bloc.state.submittedReports;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    _presenter.changeSubTab(1);
  }

  @override
  void onReportsError(String error) {
    setState(() {
      _isLoading = false;
      _isSubmitting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void onSubTabChanged(int index) {
    if (_activeSubTab != index) {
      setState(() => _activeSubTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = SessionManager().currentRole;
    final isSuperAdmin = role == UserRole.superAdmin;

    return BlocProvider<ReportsBloc>.value(
      value: _bloc,
      child: BlocListener<ReportsBloc, ReportsState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: _isLoading && _reports.isEmpty
            ? const CenteredLoadingIndicator(height: 300)
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isSuperAdmin) ...[
                      // Super Admin View: Reports list & Export
                      ReportsTabSelector(
                        activeIndex: _activeSubTab,
                        onTabSelected: (idx) =>
                            setState(() => _activeSubTab = idx),
                        firstTabLabel: 'Reports',
                        secondTabLabel: 'Export',
                        secondTabBadge: _reports.isNotEmpty
                            ? '${_reports.length}'
                            : null,
                      ),
                      const SizedBox(height: 4),
                      if (_activeSubTab == 0)
                        ReportHistorySection(reports: _reports)
                      else
                        ReportsExportSection(
                          selectedCircle: widget.selectedCircle,
                          attendanceTrend: _attendanceTrend,
                        ),
                    ] else ...[
                      // All Leadership Roles (CC, CF, CD, ID, DED): Submit Report & Scoped Reports History
                      ReportsTabSelector(
                        activeIndex: _activeSubTab,
                        onTabSelected: (idx) => _presenter.changeSubTab(idx),
                        firstTabLabel: 'Submit Report',
                        secondTabLabel: 'Reports',
                        secondTabBadge: _reports.isNotEmpty
                            ? '${_reports.length}'
                            : null,
                      ),
                      const SizedBox(height: 4),
                      if (_activeSubTab == 0)
                        ReportSubmitSection(
                          selectedType: _selectedType,
                          onTypeChanged: (type) =>
                              _presenter.changeReportType(type),
                          circleName: _circleName,
                          availableCircles: _availableCircles,
                          onCircleChanged: (circle) =>
                              _presenter.changeCircle(circle),
                          contentController: _contentController,
                          isSubmitting: _isSubmitting,
                          onSubmit: () => _presenter.submit(),
                        )
                      else
                        ReportHistorySection(reports: _reports),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

}
