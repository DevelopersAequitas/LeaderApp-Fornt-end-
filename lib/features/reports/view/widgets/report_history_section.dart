import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/report_model.dart';
import 'report_history_card.dart';

/// Renders the list of submitted historical reports with search or empty state.
class ReportHistorySection extends StatelessWidget {
  final List<ReportModel> reports;

  const ReportHistorySection({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Text(
            'No reports submitted yet.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: reports.map((r) => ReportHistoryCard(report: r)).toList(),
    );
  }
}
