import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/celebration_model.dart';

/// Renders an individual birthday or anniversary celebration card.
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
    final isBirthday = celebration.type == 'birthday';
    final cardBgColor =
        isBirthday ? AppColors.dangerBg : AppColors.successBg;
    final cardIconColor =
        isBirthday ? AppColors.danger : AppColors.success;
    final btnBgColor =
        isBirthday ? AppColors.dangerBg : AppColors.successBg;
    final btnTextColor =
        isBirthday ? AppColors.danger : AppColors.success;
    final btnLabel = isBirthday ? 'Wish 🎂' : 'Wish 🤝';

    final subDetails = [
      if (celebration.date.isNotEmpty) celebration.date,
      if (celebration.company.isNotEmpty) celebration.company,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cardBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isBirthday ? Icons.cake_rounded : Icons.star_rounded,
              color: cardIconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  celebration.peerName,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subDetails.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subDetails,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onWishTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: btnBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                btnLabel,
                style: TextStyle(
                  color: btnTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
