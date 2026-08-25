import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/teams_model.dart';

/// Renders the restricted view placeholder and lock card for unauthorized roles.
class TeamsRestrictedPlaceholder extends StatelessWidget {
  final TeamsPermissionModel permission;

  const TeamsRestrictedPlaceholder({super.key, required this.permission});

  @override
  Widget build(BuildContext context) {
    return RestrictedAccessCard(
      title: 'Access Restricted',
      message: '',
      contentOverride: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'As a '),
                TextSpan(
                  text: permission.role,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const TextSpan(
                  text:
                      ', you do not have permissions to access the Teams dashboard. Access is limited to Founder, Director, and Executive levels.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'REQUIRED CAPABILITIES',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: permission.requiredCapabilities
                      .map(
                        (cap) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE1DDF6),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            cap,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: 'Logged in as: '),
                TextSpan(
                  text: permission.role,
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Blurred skeleton placeholder under restricted view.
class TeamsRestrictedBackgroundSkeleton extends StatelessWidget {
  const TeamsRestrictedBackgroundSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 20, width: 150, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
