import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_state.dart';
import '../model/report_model.dart';
import '../presenter/reports_presenter.dart';

/// The View component of the Reports tab feature.
/// Handles weekly/monthly report submissions and lists historical reports.
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
  String _circleName = 'Mumbai Tech Sunrise';
  List<ReportModel> _reports = const [];

  static const List<ReportsChartPoint> _mockAttendanceTrend = [
    ReportsChartPoint(month: 'Feb', value: 72.0),
    ReportsChartPoint(month: 'Mar', value: 78.0),
    ReportsChartPoint(month: 'Apr', value: 74.0),
    ReportsChartPoint(month: 'May', value: 82.0),
    ReportsChartPoint(month: 'Jun', value: 87.0),
    ReportsChartPoint(month: 'Jul', value: 90.0),
  ];

  Widget _buildExportButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporting $label...'),
            backgroundColor: Colors.green,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuperAdminExportTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildExportButton(
                label: 'Export Peers',
                icon: Icons.description_outlined,
                bgColor: AppColors.infoBg,
                textColor: AppColors.info,
              ),
              _buildExportButton(
                label: 'Export Financials',
                icon: Icons.credit_card_rounded,
                bgColor: AppColors.successBg,
                textColor: AppColors.success,
              ),
              _buildExportButton(
                label: 'Global Export',
                icon: Icons.public_rounded,
                bgColor: AppColors.dangerBg,
                textColor: AppColors.danger,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Performance Summary',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Attendance %',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: const ReportsSplineChart(
              points: _mockAttendanceTrend,
              minY: 0.0,
              maxY: 100.0,
              yLabels: [0, 25, 50, 75, 100],
              lineColor: AppColors.chartPrimary,
            ),
          ),
        ],
      ),
    );
  }

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
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void onReportsLoaded() {
    setState(() {
      _isLoading = false;
      _isSubmitting = false;
      _reports = _bloc.state.submittedReports;
      _selectedType = _bloc.state.selectedType;
      _circleName = _bloc.state.circleName;
    });
  }

  @override
  void onReportSubmitting() {
    setState(() {
      _isSubmitting = true;
    });
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
    // Automatically transition to History list tab
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
      setState(() {
        _activeSubTab = index;
      });
    }
  }

  // --- UI Widget Builders ---

  Widget _buildSegmentControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Submit Report Segment
          Expanded(
            child: InkWell(
              onTap: () => _presenter.changeSubTab(0),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeSubTab == 0
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Submit Report',
                  style: TextStyle(
                    color: _activeSubTab == 0
                        ? Colors.white
                        : const Color(0xFF8B9CB4),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          // Reports (X) History Segment
          Expanded(
            child: InkWell(
              onTap: () => _presenter.changeSubTab(1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeSubTab == 1
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Reports (${_reports.length})',
                  style: TextStyle(
                    color: _activeSubTab == 1
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitReportHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Row(
        children: [
          // Orange sheet icon rounded container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.warningBorder, width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit Report',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'To: Circle Director & Leadership',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Row(
        children: [
          // Weekly Report Toggle
          Expanded(
            child: InkWell(
              onTap: () => _presenter.changeReportType('Weekly'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'Weekly'
                      ? AppColors.primary
                      : AppColors.selectionBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Weekly Report',
                  style: TextStyle(
                    color: _selectedType == 'Weekly'
                        ? Colors.white
                        : AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Monthly Report Toggle
          Expanded(
            child: InkWell(
              onTap: () => _presenter.changeReportType('Monthly'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'Monthly'
                      ? AppColors.primary
                      : AppColors.selectionBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Monthly Report',
                  style: TextStyle(
                    color: _selectedType == 'Monthly'
                        ? Colors.white
                        : AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitTab() {
    final isContentEmpty = _contentController.text.trim().isEmpty;
    final btnBgColor = isContentEmpty
        ? AppColors.textSecondary.withOpacity(0.7)
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Circle Name Read-Only Indicator
          Text(
            'CIRCLE',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Text(
              _circleName,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Report Content Multi-Line Input
          Text(
            'REPORT CONTENT',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText:
                  'Describe attendance, deals, peer updates, concerns, or achievements...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                height: 1.4,
              ),
              contentPadding: const EdgeInsets.all(16.0),
              filled: true,
              fillColor: AppColors.secondaryBg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _presenter.submit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBgColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit Report →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReportHistoryCard(ReportModel report) {
    final isActioned = report.status.toLowerCase() == 'actioned';
    final statusBgColor = isActioned
        ? AppColors.successBg
        : AppColors.warningBg;
    final statusTextColor = isActioned
        ? AppColors.success
        : AppColors.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badges and Date row
          Row(
            children: [
              // Type Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.selectionBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.type,
                  style: const TextStyle(
                    color: AppColors.chartPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              // Date
              Text(
                report.date,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Subtitle (Author info)
          Text(
            'By: ${report.author}',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Description paragraph
          Text(
            report.content,
            style: TextStyle(
              color: AppColors.text.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_reports.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Text(
              'No reports submitted yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8B9CB4), fontSize: 14),
            ),
          )
        else
          ..._reports.map((r) => _buildReportHistoryCard(r)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCountryDirectorSegmentControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Reports (X) Segment
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeSubTab = 0),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeSubTab == 0
                      ? const Color(0xFF1E3A60)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Reports (${_reports.length})',
                  style: TextStyle(
                    color: _activeSubTab == 0
                        ? Colors.white
                        : const Color(0xFF8B9CB4),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          // Export Segment
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeSubTab = 1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeSubTab == 1
                      ? const Color(0xFF1E3A60)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Export',
                  style: TextStyle(
                    color: _activeSubTab == 1
                        ? Colors.white
                        : const Color(0xFF8B9CB4),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    if (SessionManager().currentRole == UserRole.superAdmin) {
      return _buildSuperAdminExportTab();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.selectionBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_download_rounded,
                      color: AppColors.chartPrimary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Export Reports Data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Consolidated summary of all circle reports in scope.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildExportFormatCard('PDF Document', true),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildExportFormatCard('Excel Sheet', false),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Downloading export...'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.chartPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Download Export',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportFormatCard(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.selectionBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.chartPrimary : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            label.contains('PDF') ? Icons.picture_as_pdf_rounded : Icons.table_chart_rounded,
            color: AppColors.chartPrimary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = SessionManager().currentRole;
    final isCountryDirector = role == UserRole.countryDirector || role == UserRole.superAdmin;
    final isReviewer =
        role != UserRole.circleChair && role != UserRole.circleFounder && role != UserRole.superAdmin;

    return BlocProvider<ReportsBloc>.value(
      value: _bloc,
      child: BlocListener<ReportsBloc, ReportsState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(64.0),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : isCountryDirector
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCountryDirectorSegmentControls(),
                  _activeSubTab == 0 ? _buildHistoryTab() : _buildExportTab(),
                ],
              )
            : isReviewer
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.chartPrimary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Reports (${_reports.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildHistoryTab(),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSegmentControls(),
                  _buildSubmitReportHeader(),
                  _buildReportTypeSelector(),
                  _activeSubTab == 0 ? _buildSubmitTab() : _buildHistoryTab(),
                ],
              ),
      ),
    );
  }
}

class ReportsChartPoint {
  final String month;
  final double value;

  const ReportsChartPoint({required this.month, required this.value});
}

class ReportsSplineChart extends StatelessWidget {
  final List<ReportsChartPoint> points;
  final double minY;
  final double maxY;
  final List<double> yLabels;
  final Color lineColor;

  const ReportsSplineChart({
    super.key,
    required this.points,
    required this.minY,
    required this.maxY,
    required this.yLabels,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 16, 24, 8),
      child: CustomPaint(
        painter: _ReportsSplineChartPainter(
          points: points,
          minY: minY,
          maxY: maxY,
          yLabels: yLabels,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

class _ReportsSplineChartPainter extends CustomPainter {
  final List<ReportsChartPoint> points;
  final double minY;
  final double maxY;
  final List<double> yLabels;
  final Color lineColor;

  _ReportsSplineChartPainter({
    required this.points,
    required this.minY,
    required this.maxY,
    required this.yLabels,
    required this.lineColor,
  });

  void _drawDashedHorizontalLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double currentX = start.dx;
    while (currentX < end.dx) {
      canvas.drawLine(
        Offset(currentX, start.dy),
        Offset(
          currentX + dashWidth > end.dx ? end.dx : currentX + dashWidth,
          start.dy,
        ),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  void _drawDashedVerticalLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const double dashHeight = 4.0;
    const double dashSpace = 4.0;
    double currentY = start.dy;
    while (currentY < end.dy) {
      canvas.drawLine(
        Offset(start.dx, currentY),
        Offset(
          start.dx,
          currentY + dashHeight > end.dy ? end.dy : currentY + dashHeight,
        ),
        paint,
      );
      currentY += dashHeight + dashSpace;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const double leftPadding = 40.0;
    const double bottomPadding = 30.0;

    final double chartWidth = size.width - leftPadding;
    final double chartHeight = size.height - bottomPadding;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.0;

    final baselinePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5;

    // Draw vertical dashed grid lines for X axis coordinates
    final double xSegment = chartWidth / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final x = leftPadding + (i * xSegment);
      _drawDashedVerticalLine(
        canvas,
        Offset(x, 0),
        Offset(x, chartHeight),
        gridPaint,
      );
    }

    // Draw horizontal dashed grid lines and Y-axis labels
    for (final label in yLabels) {
      final yRatio = (label - minY) / (maxY - minY);
      final yPos = chartHeight - (yRatio * chartHeight);

      _drawDashedHorizontalLine(
        canvas,
        Offset(leftPadding, yPos),
        Offset(size.width, yPos),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: '${label.toInt()}',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftPadding - textPainter.width - 12,
          yPos - textPainter.height / 2,
        ),
      );
    }

    // Draw solid horizontal baseline at the bottom of the chart
    canvas.drawLine(
      Offset(leftPadding, chartHeight),
      Offset(size.width, chartHeight),
      baselinePaint,
    );

    if (points.isEmpty) return;

    final List<Offset> pixelPoints = [];
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = leftPadding + (i * xSegment);
      final yRatio = (p.value - minY) / (maxY - minY);
      final y = chartHeight - (yRatio * chartHeight);
      pixelPoints.add(Offset(x, y));
    }

    // Natural flowing spline tangent calculation
    final int n = pixelPoints.length;
    final List<Offset> controlPoints1 = [];
    final List<Offset> controlPoints2 = [];
    const double factor = 0.20; // Curve smoothing factor

    final List<Offset> tangents = List.filled(n, Offset.zero);
    for (int i = 0; i < n; i++) {
      if (i == 0) {
        tangents[i] = (pixelPoints[1] - pixelPoints[0]) * factor;
      } else if (i == n - 1) {
        tangents[i] = (pixelPoints[n - 1] - pixelPoints[n - 2]) * factor;
      } else {
        tangents[i] = (pixelPoints[i + 1] - pixelPoints[i - 1]) * factor;
      }
    }

    for (int i = 0; i < n - 1; i++) {
      controlPoints1.add(pixelPoints[i] + tangents[i]);
      controlPoints2.add(pixelPoints[i + 1] - tangents[i + 1]);
    }

    // 1. Gradient Fill Path
    final fillPath = Path();
    fillPath.moveTo(pixelPoints[0].dx, chartHeight);
    fillPath.lineTo(pixelPoints[0].dx, pixelPoints[0].dy);

    for (int i = 0; i < n - 1; i++) {
      fillPath.cubicTo(
        controlPoints1[i].dx,
        controlPoints1[i].dy,
        controlPoints2[i].dx,
        controlPoints2[i].dy,
        pixelPoints[i + 1].dx,
        pixelPoints[i + 1].dy,
      );
    }
    fillPath.lineTo(pixelPoints.last.dx, chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.12),
          lineColor.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(leftPadding, 0, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // 2. Line Path
    final linePath = Path();
    linePath.moveTo(pixelPoints[0].dx, pixelPoints[0].dy);

    for (int i = 0; i < n - 1; i++) {
      linePath.cubicTo(
        controlPoints1[i].dx,
        controlPoints1[i].dy,
        controlPoints2[i].dx,
        controlPoints2[i].dy,
        pixelPoints[i + 1].dx,
        pixelPoints[i + 1].dy,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // 3. Dots & X labels
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final pt = pixelPoints[i];

      canvas.drawCircle(pt, 5.0, dotBorderPaint);
      canvas.drawCircle(pt, 3.5, dotPaint);

      textPainter.text = TextSpan(
        text: points[i].month,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pt.dx - textPainter.width / 2, chartHeight + 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ReportsSplineChartPainter oldDelegate) => true;
}
