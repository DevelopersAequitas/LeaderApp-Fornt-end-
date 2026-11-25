import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/life_impact_detail_bloc.dart';
import '../bloc/life_impact_detail_event.dart';
import '../bloc/life_impact_detail_state.dart';
import '../model/life_impact_detail_model.dart';
import '../presenter/life_impact_detail_presenter.dart';
import 'widgets/impact_moderation_dialogs.dart';

class LifeImpactDetailView extends StatelessWidget {
  final String impactId;
  final LifeImpactDetailModel? initialDetail;
  final LifeImpactDetailBloc? bloc;

  const LifeImpactDetailView({
    super.key,
    required this.impactId,
    this.initialDetail,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<LifeImpactDetailBloc>.value(
        value: bloc!,
        child: _LifeImpactDetailContent(impactId: impactId),
      );
    }
    return BlocProvider<LifeImpactDetailBloc>(
      create: (_) => LifeImpactDetailBloc()
        ..add(
          LoadLifeImpactDetail(
            impactId: impactId,
            initialData: initialDetail,
          ),
        ),
      child: _LifeImpactDetailContent(impactId: impactId),
    );
  }
}

class _LifeImpactDetailContent extends StatelessWidget {
  final String impactId;
  static const LifeImpactDetailPresenter _presenter = LifeImpactDetailPresenter();

  const _LifeImpactDetailContent({required this.impactId});

  EnterpriseStatusTone _toneForStatus(String status) {
    final s = status.toLowerCase();
    if (s == 'approved') return EnterpriseStatusTone.active;
    if (s == 'rejected') return EnterpriseStatusTone.rejected;
    return EnterpriseStatusTone.pending;
  }

  Future<void> _openAttachment(
    BuildContext context,
    ImpactAttachmentModel attachment,
  ) async {
    if (attachment.isImage) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      attachment.title,
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    attachment.url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(attachment.url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid attachment link.'),
          backgroundColor: AppColor.danger,
        ),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open attachment on this device.'),
          backgroundColor: AppColor.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final textMuted =
        isDark ? AppColor.darkTextTertiary : AppColor.lightTextMuted;

    return BlocConsumer<LifeImpactDetailBloc, LifeImpactDetailState>(
      listenWhen: (prev, curr) =>
          (prev.errorMessage != curr.errorMessage && curr.errorMessage.isNotEmpty) ||
          (prev.actionMessage != curr.actionMessage && curr.actionMessage.isNotEmpty),
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColor.danger,
            ),
          );
        } else if (state.actionMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage),
              backgroundColor: AppColor.success,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<LifeImpactDetailBloc>();
        final detail = state.detail;
        final session = SessionManager().currentSession;
        final canReview = detail != null &&
            _presenter.canShowReviewActions(detail, session);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              Navigator.of(context).pop(state.didMutate);
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: 'Life Impact Review',
              subtitle: detail?.circleName.isNotEmpty == true
                  ? detail!.circleName
                  : null,
              showBackButton: true,
              onBackTap: () => Navigator.of(context).pop(state.didMutate),
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && detail == null
                  ? const ListShimmerSkeleton()
                  : detail == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: EnterpriseEmptyState(
                              icon: Icons.volunteer_activism_outlined,
                              title: 'Life Impact Unavailable',
                              description: state.errorMessage.isNotEmpty
                                  ? state.errorMessage
                                  : 'Unable to load this Life Impact submission.',
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColor.primary,
                          onRefresh: () async {
                            bloc.add(LoadLifeImpactDetail(impactId: impactId));
                          },
                          child: ListView(
                            padding: const EdgeInsets.all(AppSpacing.screenMargin),
                            children: [
                              // 1. Status & Core Identity Header
                              EnterpriseSurfaceCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            detail.title,
                                            style: AppTypography.titleMedium
                                                .copyWith(color: textPrimary),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        EnterpriseStatusBadge(
                                          label: detail.statusLabel,
                                          tone: _toneForStatus(detail.status),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        EnterpriseStatusBadge(
                                          label:
                                              '${detail.livesImpacted} ${detail.livesImpacted == 1 ? 'Life' : 'Lives'} Impacted',
                                          tone: EnterpriseStatusTone.info,
                                          compact: true,
                                        ),
                                        if (detail.impactCategory.isNotEmpty &&
                                            detail.impactCategory != detail.title)
                                          EnterpriseStatusBadge(
                                            label: detail.impactCategory,
                                            tone: EnterpriseStatusTone.info,
                                            compact: true,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (detail.description.isNotEmpty) ...[
                                      Text(
                                        'IMPACT STORY & DETAILS',
                                        style: AppTypography.labelSmall
                                            .copyWith(color: textMuted),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        detail.description,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: textSecondary,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                    if (detail.additionalRemarks.isNotEmpty &&
                                        detail.additionalRemarks !=
                                            detail.description) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        'ADDITIONAL REMARKS',
                                        style: AppTypography.labelSmall
                                            .copyWith(color: textMuted),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        detail.additionalRemarks,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 2. Peer Summary & Link to Full Peer Profile
                              EnterpriseSurfaceCard(
                                onTap: detail.submittedBy.id.isNotEmpty
                                    ? () {
                                        Navigator.of(context).pushNamed(
                                          AppRoutes.peerProfile,
                                          arguments:
                                              detail.submittedBy.toPeerModel(),
                                        );
                                      }
                                    : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SUBMITTED BY PEER',
                                      style: AppTypography.labelSmall
                                          .copyWith(color: textMuted),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        InitialsAvatar(
                                          name: detail.submittedBy.name.isNotEmpty
                                              ? detail.submittedBy.name
                                              : 'Peer',
                                          imageUrl: detail.submittedBy.avatarUrl,
                                          radius: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                detail.submittedBy.name
                                                        .isNotEmpty
                                                    ? detail.submittedBy.name
                                                    : 'Peer',
                                                style: AppTypography.titleSmall
                                                    .copyWith(
                                                  color: textPrimary,
                                                ),
                                              ),
                                              if (detail.submittedBy.designation
                                                      .isNotEmpty ||
                                                  detail.organizationName
                                                      .isNotEmpty)
                                                Text(
                                                  [
                                                    if (detail.submittedBy
                                                        .designation.isNotEmpty)
                                                      detail.submittedBy
                                                          .designation,
                                                    if (detail.organizationName
                                                        .isNotEmpty)
                                                      detail.organizationName,
                                                  ].join(' · '),
                                                  style: AppTypography.bodySmall
                                                      .copyWith(
                                                    color: textSecondary,
                                                  ),
                                                ),
                                              if (detail.peerCode.isNotEmpty)
                                                Text(
                                                  'Peer ID: ${detail.peerCode}',
                                                  style: AppTypography.labelSmall
                                                      .copyWith(
                                                    color: textMuted,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (detail.submittedBy.id.isNotEmpty)
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                AppRoutes.peerProfile,
                                                arguments: detail.submittedBy
                                                    .toPeerModel(),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.person_outline_rounded,
                                              size: 16,
                                            ),
                                            label: const Text('Profile'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 3. Beneficiary, Context & Dates
                              EnterpriseSurfaceCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SUBMISSION METADATA',
                                      style: AppTypography.labelSmall
                                          .copyWith(color: textMuted),
                                    ),
                                    const SizedBox(height: 10),
                                    if (detail.beneficiary != null)
                                      _MetaRow(
                                        icon: Icons.handshake_outlined,
                                        label: 'Beneficiary',
                                        value: [
                                          if (detail
                                              .beneficiary!.name.isNotEmpty)
                                            detail.beneficiary!.name,
                                          if (detail.beneficiary!.companyName
                                              .isNotEmpty)
                                            '(${detail.beneficiary!.companyName})',
                                        ].join(' '),
                                      ),
                                    if (detail.location.isNotEmpty)
                                      _MetaRow(
                                        icon: Icons.location_on_outlined,
                                        label: 'Location',
                                        value: detail.location,
                                      ),
                                    if (detail.circleName.isNotEmpty)
                                      _MetaRow(
                                        icon: Icons.groups_outlined,
                                        label: 'Circle',
                                        value: detail.circleName,
                                      ),
                                    if (detail.districtName.isNotEmpty)
                                      _MetaRow(
                                        icon: Icons.map_outlined,
                                        label: 'District',
                                        value: detail.districtName,
                                      ),
                                    if (detail.impactDate.isNotEmpty)
                                      _MetaRow(
                                        icon: Icons.event_outlined,
                                        label: 'Impact Date',
                                        value: DateTimeUtils.formatDate(
                                          detail.impactDate,
                                        ),
                                      ),
                                    if (detail.submittedAt.isNotEmpty)
                                      _MetaRow(
                                        icon: Icons.schedule_rounded,
                                        label: 'Submitted At',
                                        value: DateTimeUtils.formatDateTime(
                                          detail.submittedAt,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 4. Evidence & Attachments
                              if (detail.attachments.isNotEmpty) ...[
                                EnterpriseSurfaceCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'EVIDENCE & ATTACHMENTS',
                                        style: AppTypography.labelSmall
                                            .copyWith(color: textMuted),
                                      ),
                                      const SizedBox(height: 10),
                                      for (final att in detail.attachments)
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(
                                            att.isImage
                                                ? Icons.image_outlined
                                                : Icons.attach_file_rounded,
                                            color: AppColor.primary,
                                          ),
                                          title: Text(
                                            att.title,
                                            style: AppTypography.bodyMedium
                                                .copyWith(color: textPrimary),
                                          ),
                                          trailing: const Icon(
                                            Icons.open_in_new_rounded,
                                            size: 18,
                                          ),
                                          onTap: () =>
                                              _openAttachment(context, att),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // 5. Verification Status & Reviewer Remarks
                              if (detail.reviewRemarks != null &&
                                  detail.reviewRemarks!.isNotEmpty) ...[
                                EnterpriseSurfaceCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.isRejected
                                            ? 'REJECTION REASON'
                                            : 'REVIEW REMARKS',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                          color: detail.isRejected
                                              ? AppColor.danger
                                              : textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        detail.reviewRemarks!,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: textPrimary,
                                        ),
                                      ),
                                      if ((detail.approvedByName ??
                                              detail.rejectedByName) !=
                                          null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Reviewed by ${detail.approvedByName ?? detail.rejectedByName}',
                                          style: AppTypography.labelSmall
                                              .copyWith(color: textSecondary),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // 6. Verification & Submission History
                              if (detail.verificationHistory.isNotEmpty)
                                EnterpriseSurfaceCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SUBMISSION & VERIFICATION HISTORY',
                                        style: AppTypography.labelSmall
                                            .copyWith(color: textMuted),
                                      ),
                                      const SizedBox(height: 10),
                                      for (final ev
                                          in detail.verificationHistory)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                ev.status == 'rejected'
                                                    ? Icons.cancel_rounded
                                                    : ev.status == 'approved'
                                                        ? Icons
                                                            .check_circle_rounded
                                                        : Icons
                                                            .radio_button_checked,
                                                size: 16,
                                                color: ev.status == 'rejected'
                                                    ? AppColor.danger
                                                    : ev.status == 'approved'
                                                        ? AppColor.success
                                                        : AppColor.primary,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      ev.label,
                                                      style: AppTypography
                                                          .labelLarge
                                                          .copyWith(
                                                        color: textPrimary,
                                                      ),
                                                    ),
                                                    if (ev.actorName.isNotEmpty ||
                                                        ev.timestamp.isNotEmpty)
                                                      Text(
                                                        [
                                                          if (ev.actorName
                                                              .isNotEmpty)
                                                            ev.actorName,
                                                          if (ev.timestamp
                                                              .isNotEmpty)
                                                            DateTimeUtils
                                                                .formatDateTime(
                                                              ev.timestamp,
                                                            ),
                                                        ].join(' · '),
                                                        style: AppTypography
                                                            .labelSmall
                                                            .copyWith(
                                                          color: textMuted,
                                                        ),
                                                      ),
                                                    if (ev.remarks != null &&
                                                        ev.remarks!.isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                          top: 3,
                                                        ),
                                                        child: Text(
                                                          ev.remarks!,
                                                          style: AppTypography
                                                              .bodySmall
                                                              .copyWith(
                                                            color: textSecondary,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
            ),
            bottomNavigationBar: canReview
                ? SafeArea(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColor.darkSurface
                            : AppColor.lightSurface,
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? AppColor.darkBorder
                                : AppColor.outline,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed: state.isSubmitting
                                    ? null
                                    : () async {
                                        final reason =
                                            await ImpactModerationDialogs
                                                .showRejectDialog(
                                          context,
                                          peerName: detail.submittedBy.name,
                                          impactTitle: detail.title,
                                        );
                                        if (reason != null && context.mounted) {
                                          bloc.add(
                                            RejectLifeImpact(reason: reason),
                                          );
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColor.danger,
                                  side: const BorderSide(
                                    color: AppColor.rejectedBorder,
                                  ),
                                  backgroundColor: AppColor.rejectedBg,
                                ),
                                icon: const Icon(Icons.close_rounded, size: 18),
                                label: const Text('Reject'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: state.isSubmitting
                                    ? null
                                    : () async {
                                        final decision =
                                            await ImpactModerationDialogs
                                                .showApproveConfirmation(
                                          context,
                                          peerName: detail.submittedBy.name,
                                          impactTitle: detail.title,
                                        );
                                        if (decision.confirmed &&
                                            context.mounted) {
                                          bloc.add(
                                            ApproveLifeImpact(
                                              remarks: decision.remarks,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
                                  foregroundColor: Colors.white,
                                ),
                                icon: state.isSubmitting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded, size: 18),
                                label: const Text('Accept'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColor.primary),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColor.darkTextSecondary
                      : AppColor.lightTextSecondary,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: isDark
                          ? AppColor.darkTextPrimary
                          : AppColor.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
