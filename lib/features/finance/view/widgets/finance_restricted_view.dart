import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/finance_model.dart';

/// Renders the blurred background skeleton with restricted access overlay.
class FinanceRestrictedView extends StatelessWidget {
  final FinancePermissionModel permission;

  const FinanceRestrictedView({super.key, required this.permission});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 580,
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: _buildPlaceholder(),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(color: Colors.white.withValues(alpha: 0.3)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: _buildRestrictedCard(permission),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 16, width: 100, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictedCard(FinancePermissionModel permission) {
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
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
                      ', you do not have permissions to access the Finance dashboard. Access is limited to Founder, Director, and Executive levels.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'REQUIRED CAPABILITIES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: permission.requiredCapabilities
                      .map(
                        (cap) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            cap,
                            style: const TextStyle(
                              color: Color(0xFF1E3C72),
                              fontSize: 10,
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
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: 'Logged in as: '),
                TextSpan(
                  text: permission.role,
                  style: const TextStyle(
                    color: Color(0xFF1E3C72),
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
