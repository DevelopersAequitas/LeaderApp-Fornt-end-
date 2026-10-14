import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/reports_repository.dart';

/// Consolidated Reports Export section providing authentic PDF and Excel exports.
class ReportsExportSection extends StatefulWidget {
  final String? selectedCircle;

  const ReportsExportSection({
    super.key,
    this.selectedCircle,
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
                    ? 'Export generated! Opening download link...'
                    : 'Report export downloaded successfully.',
              ),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
          if (downloadUrl.isNotEmpty) {
            final uri = Uri.tryParse(downloadUrl);
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (res.message != null && res.message!.isNotEmpty)
                    ? res.message!
                    : 'Export failed',
              ),
              backgroundColor: AppColors.danger,
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
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
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
              icon: Icons.cloud_download_outlined,
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
            'Consolidated summary of circle performance reports.',
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
        ? Icons.picture_as_pdf_outlined
        : Icons.table_chart_outlined;

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: _buildStandardExportCard(),
    );
  }
}
