import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/peer_profile_model.dart';
import '../../presenter/peer_profile_presenter.dart';

/// Founder-level Peer Identity Header answering:
/// Who is this peer, what do they do, and where do they belong?
class PeerProfileHeroCard extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel? details;

  const PeerProfileHeroCard({
    super.key,
    required this.peer,
    this.details,
  });

  EnterpriseStatusTone _toneForStatus(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'active' || s == 'approved') return EnterpriseStatusTone.active;
    if (s == 'at risk' || s == 'expired' || s == 'rejected' || s == 'inactive') {
      return EnterpriseStatusTone.rejected;
    }
    if (s == 'pending' || s == 'needs attention') {
      return EnterpriseStatusTone.pending;
    }
    return EnterpriseStatusTone.inactive;
  }

  Future<void> _launch(BuildContext context, String uriStr) async {
    final uri = Uri.tryParse(uriStr);
    if (uri == null) return;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to launch application.')),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idInfo = details?.identity;
    final fullName =
        (idInfo?.fullName.isNotEmpty == true ? idInfo!.fullName : peer.name)
            .trim();
    final designation = (idInfo?.designation.isNotEmpty == true
            ? idInfo!.designation
            : (peer.designation ?? ''))
        .trim();
    final company = (idInfo?.companyName.isNotEmpty == true
            ? idInfo!.companyName
            : peer.company)
        .trim();
    final primaryCategory = (idInfo?.level4Category.isNotEmpty == true
            ? idInfo!.level4Category
            : (idInfo?.primaryCategory.isNotEmpty == true
                ? idInfo!.primaryCategory
                : (peer.level4Category?.isNotEmpty == true
                    ? peer.level4Category!
                    : (peer.industry ?? ''))))
        .trim();
    final city =
        (idInfo?.city.isNotEmpty == true ? idInfo!.city : peer.location).trim();
    final district = (idInfo?.districtName ?? '').trim();
    final circle = (idInfo?.circleName.isNotEmpty == true
            ? idInfo!.circleName
            : peer.circle)
        .trim();
    final status = (idInfo?.accountStatus.isNotEmpty == true
            ? idInfo!.accountStatus
            : peer.status)
        .trim();
    final leadershipRole = (idInfo?.currentLeadershipRole ?? '').trim();
    final peerCode = (idInfo?.peerCode ?? '').trim();
    final isVerified = idInfo?.isVerified ?? peer.isVerified;

    final subtitleParts = <String>[
      if (designation.isNotEmpty) designation,
      if (company.isNotEmpty) company,
    ];
    final locationParts = <String>[
      if (city.isNotEmpty) city,
      if (district.isNotEmpty && district.toLowerCase() != city.toLowerCase())
        district,
    ];

    final canShowContact = PeerProfilePresenter.canShowContactActions(
      peer,
      details,
      hasPermission: SessionManager().permissions.canViewPeerContactInfo ||
          SessionManager().isSuperAdmin,
    );

    final phone = (idInfo?.phone ?? details?.phone ?? peer.phone ?? '').trim();
    final whatsapp =
        (idInfo?.whatsapp ?? details?.whatsapp ?? peer.whatsapp ?? '').trim();
    final email = (idInfo?.email ?? details?.email ?? peer.email ?? '').trim();
    final linkedin =
        (idInfo?.linkedin ?? details?.linkedin ?? peer.linkedin ?? '').trim();
    final website = (details?.business?.website ?? '').trim();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        8,
        AppSpacing.screenMargin,
        4,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurface : AppColor.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColor.darkBorder : AppColor.outline,
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(
                name: fullName.isNotEmpty ? fullName : 'Peer',
                imageUrl: peer.avatarUrl,
                radius: 30,
                backgroundColor: AppColor.primaryContainer,
                textColor: AppColor.onPrimaryContainer,
                fontSize: 17,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            fullName.isNotEmpty ? fullName : 'Peer',
                            style: AppTypography.titleLarge.copyWith(
                              color: isDark
                                  ? AppColor.darkTextPrimary
                                  : AppColor.lightTextPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColor.primary,
                            size: 17,
                          ),
                        ],
                      ],
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitleParts.join(' · '),
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColor.darkTextSecondary
                              : AppColor.lightTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (peerCode.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Peer ID: $peerCode',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark
                              ? AppColor.darkTextTertiary
                              : AppColor.lightTextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (status.isNotEmpty) ...[
                const SizedBox(width: 8),
                EnterpriseStatusBadge(
                  label: status,
                  tone: _toneForStatus(status),
                  compact: true,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (leadershipRole.isNotEmpty)
                EnterpriseStatusBadge(
                  label: leadershipRole,
                  tone: EnterpriseStatusTone.info,
                  compact: true,
                ),
              if (circle.isNotEmpty)
                _InfoChip(
                  icon: Icons.groups_outlined,
                  label: circle,
                ),
              if (primaryCategory.isNotEmpty)
                _InfoChip(
                  icon: Icons.category_outlined,
                  label: primaryCategory,
                ),
              if (locationParts.isNotEmpty)
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: locationParts.join(', '),
                ),
            ],
          ),
          if (canShowContact) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: isDark ? AppColor.darkDivider : AppColor.divider,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (phone.isNotEmpty && !phone.contains('***'))
                  _ContactPill(
                    icon: Icons.call_outlined,
                    label: 'Call',
                    onTap: () => _launch(context, 'tel:$phone'),
                  ),
                if (whatsapp.isNotEmpty && !whatsapp.contains('***'))
                  _ContactPill(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'WhatsApp',
                    onTap: () {
                      final digits = whatsapp.replaceAll(RegExp(r'[^0-9+]'), '');
                      _launch(context, 'https://wa.me/$digits');
                    },
                  ),
                if (email.isNotEmpty && !email.contains('***'))
                  _ContactPill(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    onTap: () => _launch(context, 'mailto:$email'),
                  ),
                if (linkedin.isNotEmpty)
                  _ContactPill(
                    icon: Icons.link_rounded,
                    label: 'LinkedIn',
                    onTap: () => _launch(
                      context,
                      linkedin.startsWith('http')
                          ? linkedin
                          : 'https://$linkedin',
                    ),
                  ),
                if (website.isNotEmpty)
                  _ContactPill(
                    icon: Icons.language_rounded,
                    label: 'Website',
                    onTap: () => _launch(
                      context,
                      website.startsWith('http') ? website : 'https://$website',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color:
            isDark ? AppColor.darkSurfaceElevated : AppColor.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(
          color: isDark ? AppColor.darkBorder : AppColor.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColor.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColor.darkTextSecondary
                    : AppColor.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColor.darkSurfaceSubtle : AppColor.primaryContainer,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColor.primary),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isDark
                      ? AppColor.darkTextPrimary
                      : AppColor.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
