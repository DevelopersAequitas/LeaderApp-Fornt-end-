import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

class NotificationEmptyState extends StatelessWidget {
  final String category;
  final VoidCallback onRefresh;

  const NotificationEmptyState({
    super.key,
    required this.category,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColor.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 32,
                color: AppColor.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              category == 'all'
                  ? 'No notifications yet'
                  : 'No ${category.toLowerCase()} updates',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You are all caught up! Organic leader activities and circle updates will appear here in real time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColor.lightTextSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh Feed'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.primaryBlue,
                side: const BorderSide(color: AppColor.lightBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
