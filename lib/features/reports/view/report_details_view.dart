import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../model/report_model.dart';
import 'services/report_export_service.dart';
import 'widgets/report_details_header_section.dart';
import 'widgets/report_details_metrics_section.dart';
import 'widgets/report_details_roster_section.dart';
import 'widgets/report_details_summary_section.dart';

/// Full screen view presenting complete performance report details and live peer roster.
class ReportDetailsView extends StatefulWidget {
  final ReportModel report;

  const ReportDetailsView({super.key, required this.report});

  @override
  State<ReportDetailsView> createState() => _ReportDetailsViewState();
}

class _ReportDetailsViewState extends State<ReportDetailsView> {
  late Future<ReportModel> _reportFuture;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _reportFuture = ReportExportService.loadFullReport(widget.report);
  }

  Future<void> _onDownloadPdf(ReportModel active) async {
    setState(() => _isExporting = true);
    await ReportExportService.downloadPdf(context, active);
    if (mounted) setState(() => _isExporting = false);
  }

  Future<void> _onDownloadExcel(ReportModel active) async {
    setState(() => _isExporting = true);
    await ReportExportService.downloadExcel(context, active);
    if (mounted) setState(() => _isExporting = false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReportModel>(
      future: _reportFuture,
      initialData: widget.report,
      builder: (context, snapshot) {
        final activeReport = snapshot.data ?? widget.report;
        final isPeerLoading = snapshot.connectionState == ConnectionState.waiting &&
            activeReport.peersRoster.isEmpty;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Report Details',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              if (_isExporting)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else ...[
                IconButton(
                  tooltip: 'Download PDF',
                  icon: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () => _onDownloadPdf(activeReport),
                ),
                IconButton(
                  tooltip: 'Export CSV / Excel',
                  icon: const Icon(
                    Icons.table_chart_rounded,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                  onPressed: () => _onDownloadExcel(activeReport),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReportDetailsHeaderSection(report: activeReport),
                const SizedBox(height: 16),
                ReportDetailsMetricsSection(report: activeReport),
                const SizedBox(height: 16),
                ReportDetailsSummarySection(report: activeReport),
                const SizedBox(height: 16),
                ReportDetailsRosterSection(
                  peers: activeReport.peersRoster,
                  circleName: activeReport.circleName,
                  isLoading: isPeerLoading,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
