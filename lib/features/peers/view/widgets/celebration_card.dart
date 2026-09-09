import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/celebration_model.dart';

/// Renders a unified celebration card adhering to the standard Leader App Peer Card design.
/// Prominently displays:
/// 1. Peer Profile Avatar & Uppercase Name
/// 2. Designation & Company Name
/// 3. Celebration / Milestone Banner with Date
/// 4. Circle Name badge
/// 5. Wish action trigger button
/// 6. Tap to open full PeerProfileView
class CelebrationCard extends StatelessWidget {
  final CelebrationModel celebration;
  final VoidCallback onWishTap;

  const CelebrationCard({
    super.key,
    required this.celebration,
    required this.onWishTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBirthday = celebration.type.toLowerCase().contains('birth');

    // 1. Designation & Company subtitle
    final displayDesignation = celebration.designation != null &&
            celebration.designation!.trim().isNotEmpty
        ? celebration.designation!.trim()
        : '';
    final displayCompany = celebration.company.trim();

    String subtitle = '';
    if (displayDesignation.isNotEmpty && displayCompany.isNotEmpty) {
      subtitle = '$displayDesignation · $displayCompany';
    } else if (displayDesignation.isNotEmpty) {
      subtitle = displayDesignation;
    } else {
      subtitle = displayCompany;
    }

    // 2. Celebration Tag Formatting
    final celebrationLabel = isBirthday
        ? (celebration.isToday ? '🎂 Birthday: Today' : '🎂 Birthday: ${celebration.date}')
        : (celebration.milestone != null && celebration.milestone!.isNotEmpty
            ? '🤝 ${celebration.milestone} · ${celebration.date}'
            : '🤝 Anniversary: ${celebration.date}');

    final celebrationBg = isBirthday
        ? (celebration.isToday ? const Color(0xFFFEF3C7) : const Color(0xFFFFF1F2))
        : (celebration.isToday ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF));

    final celebrationTextCol = isBirthday
        ? (celebration.isToday ? const Color(0xFFB45309) : const Color(0xFFE11D48))
        : (celebration.isToday ? const Color(0xFF1D4ED8) : const Color(0xFF7C3AED));

    final celebrationBorderCol = isBirthday
        ? (celebration.isToday ? const Color(0xFFFDE68A) : const Color(0xFFFFE4E6))
        : (celebration.isToday ? const Color(0xFFBFDBFE) : const Color(0xFFDDD6FE));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.peerProfile,
              arguments: celebration.toPeerModel(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Avatar + Name/Company + Wish Button + Chevron
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Peer Avatar
                    InitialsAvatar(
                      name: celebration.peerName.toUpperCase(),
                      imageUrl: celebration.profilePhotoUrl,
                      radius: 22,
                      backgroundColor: isBirthday
                          ? const Color(0xFFBE185D)
                          : const Color(0xFF1E40AF),
                      fontSize: 13,
                    ),
                    const SizedBox(width: 10),

                    // 2. Name & Designation/Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            celebration.peerName.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 3. Wish Button / Wished Status
                    if (celebration.wished)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF86EFAC),
                            width: 0.8,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 12,
                              color: Color(0xFF16A34A),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Wished',
                              style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      InkWell(
                        onTap: onWishTap,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isBirthday
                                ? const Color(0xFFFFF1F2)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isBirthday
                                  ? const Color(0xFFFECDD3)
                                  : const Color(0xFFBFDBFE),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isBirthday ? 'Wish 🎂' : 'Wish 🤝',
                                style: TextStyle(
                                  color: isBirthday
                                      ? const Color(0xFFE11D48)
                                      : const Color(0xFF2563EB),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),

                // Bottom Badges Row: Celebration Date Pill + Circle Name
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // 1. Celebration Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: celebrationBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: celebrationBorderCol,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        celebrationLabel,
                        style: TextStyle(
                          color: celebrationTextCol,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // 2. Circle Name Badge
                    if (celebration.circleName != null &&
                        celebration.circleName!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.group_work_outlined,
                              size: 11,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 160),
                              child: Text(
                                celebration.circleName!,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
