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
    final catName = category == 'all' ? 'notifications' : '$category updates';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primaryBlue.withValues(alpha: 0.12),
                    AppColor.primaryPink.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.primaryBlue.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 34,
                color: AppColor.primaryBlue,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              category == 'all' ? 'All Caught Up!' : 'No $catName',
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: AppColor.lightTextPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No new leader activity or circle broadcasts in this feed. When events are dispatched, you\'ll see them instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColor.lightTextSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            InkWell(
              onTap: onRefresh,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColor.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColor.lightBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: AppColor.primaryBlue,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Refresh Feed',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
