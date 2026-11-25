import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Confirmation & reason-entry dialogs for Life Impact moderation.
class ImpactModerationDialogs {
  const ImpactModerationDialogs._();

  static Future<({bool confirmed, String? remarks})> showApproveConfirmation(
    BuildContext context, {
    required String peerName,
    required String impactTitle,
  }) async {
    final remarksController = TextEditingController();
    final result = await showDialog<({bool confirmed, String? remarks})>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                color: AppColor.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Approve Life Impact',
                  style: AppTypography.titleMedium,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm approval for this Life Impact submission:',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 12),
                _SummaryBox(
                  rows: [
                    ('Peer', peerName),
                    ('Life Impact', impactTitle),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: remarksController,
                  maxLines: 2,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Verification Note (optional)',
                    hintText: 'Add audit remarks if needed',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                (confirmed: false, remarks: null),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = remarksController.text.trim();
                Navigator.of(dialogContext).pop(
                  (confirmed: true, remarks: text.isEmpty ? null : text),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Approval'),
            ),
          ],
        );
      },
    );
    remarksController.dispose();
    return result ?? (confirmed: false, remarks: null);
  }

  /// Two-step rejection dialog:
  /// 1. Validates a mandatory rejection reason (>= 3 characters).
  /// 2. Displays explicit confirmation with Peer Name, Impact Title, and Rejection Reason.
  static Future<String?> showRejectDialog(
    BuildContext context, {
    required String peerName,
    required String impactTitle,
  }) async {
    final reasonController = TextEditingController();
    String? errorText;
    var confirming = false;

    final confirmedReason = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    color: AppColor.danger,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      confirming
                          ? 'Confirm Rejection'
                          : 'Reject Life Impact',
                      style: AppTypography.titleMedium,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: confirming
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Please review and confirm rejection details:',
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          _SummaryBox(
                            rows: [
                              ('Peer', peerName),
                              ('Life Impact', impactTitle),
                              ('Rejection Reason', reasonController.text.trim()),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SummaryBox(
                            rows: [
                              ('Peer', peerName),
                              ('Life Impact', impactTitle),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: reasonController,
                            maxLines: 3,
                            maxLength: 500,
                            autofocus: true,
                            onChanged: (_) {
                              if (errorText != null) {
                                setState(() => errorText = null);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Rejection Reason *',
                              hintText:
                                  'Explain why this submission is being rejected',
                              errorText: errorText,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
              ),
              actions: confirming
                  ? [
                      TextButton(
                        onPressed: () => setState(() => confirming = false),
                        child: const Text('Edit Reason'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(
                          reasonController.text.trim(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.danger,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm Rejection'),
                      ),
                    ]
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(null),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final reason = reasonController.text.trim();
                          if (reason.length < 3) {
                            setState(
                              () => errorText =
                                  'Please enter a rejection reason (at least 3 characters).',
                            );
                            return;
                          }
                          setState(() => confirming = true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.danger,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Review & Reject'),
                      ),
                    ],
            );
          },
        );
      },
    );

    reasonController.dispose();
    return confirmedReason;
  }
}

class _SummaryBox extends StatelessWidget {
  final List<(String, String)> rows;

  const _SummaryBox({required this.rows});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurfaceSubtle : AppColor.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isDark ? AppColor.darkBorder : AppColor.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Text(
              rows[i].$1,
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColor.darkTextTertiary
                    : AppColor.lightTextMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              rows[i].$2.isNotEmpty ? rows[i].$2 : '—',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
