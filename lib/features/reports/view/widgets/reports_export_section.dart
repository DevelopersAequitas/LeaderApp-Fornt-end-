import 'package:flutter/material.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/reports_repository.dart';
import '../../model/report_model.dart';
import 'reports_spline_chart.dart';

/// Renders the consolidated Export tab for Country Directors & Super Admins.
class ReportsExportSection extends StatefulWidget {
  final String? selectedCircle;
  final List<ReportsChartPoint> attendanceTrend;

  const ReportsExportSection({
    super.key,
    this.selectedCircle,
    required this.attendanceTrend,
  });

  @override
  State<ReportsExportSection> createState() => _ReportsExportSectionState();
}

class _ReportsExportSectionState extends State<ReportsExportSection> {
  String _exportFormat = 'pdf';
  bool _isExporting = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      final res = await ReportsRepositoryImpl().exportReports(
        format: _exportFormat,
        circleId: widget.selectedCircle,
      );
      if (mounted) {
        setState(() => _isExporting = false);
        if (res.success) {
          final downloadUrl =
              res.data?['download_url'] ?? res.data?['url'] ?? '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                downloadUrl.isNotEmpty
                    ? 'Export generated! Ready for download.'
                    : 'Report export downloaded successfully.',
              ),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (res.message != null && res.message!.isNotEmpty)
                    ? res.message!
                    : 'Export failed',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate export: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildQuickExportButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generating $label...'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SquareRoundedGradientIcon(
              icon: icon,
              iconSize: 15,
              boxSize: 28,
              showBorder: true,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuperAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickExportButton(
              label: 'Export Peers',
              icon: Icons.description_outlined,
              bgColor: const Color(0xFFEFF6FF),
              textColor: const Color(0xFF2563EB),
            ),
            _buildQuickExportButton(
              label: 'Export Financials',
              icon: Icons.credit_card_rounded,
              bgColor: const Color(0xFFDCFCE7),
              textColor: const Color(0xFF16A34A),
            ),
            _buildQuickExportButton(
              label: 'Global Export',
              icon: Icons.public_rounded,
              bgColor: const Color(0xFFFEE2E2),
              textColor: const Color(0xFFDC2626),
            ),
          ],
        ),
        if (widget.attendanceTrend.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Trend',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Average monthly circle attendance (%)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ReportsSplineChart(
                  points: widget.attendanceTrend,
                  minY: 0.0,
                  maxY: 100.0,
                  yLabels: const [0, 25, 50, 75, 100],
                  lineColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStandardExportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: SquareRoundedGradientIcon(
              icon: Icons.cloud_download_rounded,
              iconSize: 22,
              boxSize: 44,
              showBorder: true,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Export Reports Data',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Consolidated summary of all circle reports in scope.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _exportFormat = 'pdf'),
                  child: _buildExportFormatCard(
                    'PDF Document',
                    _exportFormat == 'pdf',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _exportFormat = 'xlsx'),
                  child: _buildExportFormatCard(
                    'Excel Sheet',
                    _exportFormat == 'xlsx',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Download ${_exportFormat.toUpperCase()} Export',
            isLoading: _isExporting,
            onPressed: _handleExport,
          ),
        ],
      ),
    );
  }

  Widget _buildExportFormatCard(String label, bool isSelected) {
    final iconData = label.contains('PDF')
        ? Icons.picture_as_pdf_rounded
        : Icons.table_chart_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isSelected ? AppColors.brandGradient : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? null : Border.all(color: AppColors.border),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Icon(
            iconData,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = SessionManager().currentRole;
    final isSuperAdmin = role == UserRole.superAdmin;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: isSuperAdmin ? _buildSuperAdminSection() : _buildStandardExportCard(),
    );
  }
}
