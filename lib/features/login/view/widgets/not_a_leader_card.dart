import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';

/// Persistent inline card displayed when a non-leader peer or unregistered user
/// attempts to sign in to Peers Leaders.
/// Provides a direct, permanent deep link to the "Become a Leader" (`LeadershipRoleScreen`)
/// screen inside the Peers Global Unity app.
class NotALeaderCard extends StatelessWidget {
  final bool isAccountUnregistered;
  final VoidCallback? onDismiss;

  const NotALeaderCard({
    super.key,
    this.isAccountUnregistered = false,
    this.onDismiss,
  });

  static const String _becomeLeaderSchemeUrl = 'peersunity://become_leader';
  static const String _leadershipRoleSchemeUrl = 'peersunity://leadership_role';

  static String get _universalFallbackUrl {
    final isDev =
        kDebugMode || ApiEndpoints.activeEnvironment == AppEnvironment.dev;
    final domain = isDev ? 'dev.peersunity.com' : 'peersunity.com';
    return 'https://$domain/share?type=become_leader';
  }

  /// Opens the Become a Leader screen directly inside the Peers Global Unity app.
  /// Falls back to the universal link if the custom scheme is not handled.
  static Future<void> openBecomeLeaderInPeersGlobal(
    BuildContext context,
  ) async {
    final primarySchemeUri = Uri.parse(_becomeLeaderSchemeUrl);
    final secondarySchemeUri = Uri.parse(_leadershipRoleSchemeUrl);
    final universalUri = Uri.parse(_universalFallbackUrl);

    try {
      final launchedPrimary = await launchUrl(
        primarySchemeUri,
        mode: LaunchMode.externalApplication,
      );
      if (launchedPrimary) return;
    } catch (_) {}

    try {
      final launchedSecondary = await launchUrl(
        secondarySchemeUri,
        mode: LaunchMode.externalApplication,
      );
      if (launchedSecondary) return;
    } catch (_) {}

    try {
      await launchUrl(universalUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please open the Peers Global app to apply for a leadership role.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColor.darkSurface : AppColor.lightSurface;
    final primaryTextColor = isDark
        ? AppColor.darkTextPrimary
        : AppColor.lightTextPrimary;
    final secondaryTextColor = isDark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;

    final title = isAccountUnregistered
        ? 'No Leader Account Found'
        : 'You are not a Leader yet';
    final description = isAccountUnregistered
        ? 'We couldn\'t find a Peers Leader account with these details. Open Peers Global and apply to become a leader to access Peers Leaders.'
        : 'This app is exclusively for Peers Global leaders. Your account is active, but you don\'t have a leadership role yet. Apply to become a leader in the Peers Global app to get started.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primaryBlue.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryBlue.withValues(alpha: 0.12),
                      AppColor.primaryPink.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.military_tech_outlined,
                  color: AppColor.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: primaryTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onDismiss != null)
                InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: secondaryTextColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColor.transparent,
            child: InkWell(
              onTap: () => openBecomeLeaderInPeersGlobal(context),
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColor.brandGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Become a Leader in Peers Global',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColor.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.open_in_new_rounded,
                      color: AppColor.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // const SizedBox(height: 12),
          // Center(
          //   child: InkWell(
          //     onTap: () => openBecomeLeaderInPeersGlobal(context),
          //     borderRadius: BorderRadius.circular(8),
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           const Icon(
          //             Icons.link_rounded,
          //             size: 15,
          //             color: AppColor.primaryBlue,
          //           ),
          //           const SizedBox(width: 6),
          //           Flexible(
          //             child: Text(
          //               'Open Leadership Roles screen in Peers Global',
          //               style: AppTypography.bodySmall.copyWith(
          //                 color: AppColor.primaryBlue,
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.w500,
          //                 decoration: TextDecoration.underline,
          //                 decorationColor: AppColor.primaryBlue,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
