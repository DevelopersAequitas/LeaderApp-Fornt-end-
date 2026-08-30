import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Clean empty state component when no notifications match active filter.
class NotificationsEmptyView extends StatelessWidget {
  final String selectedFilter;

  const NotificationsEmptyView({super.key, required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.notifications_off_outlined,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            selectedFilter == 'All'
                ? 'No notifications yet'
                : 'No $selectedFilter notifications',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Alerts, referrals, and meeting updates will appear here.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
