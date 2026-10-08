import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/primary_button.dart';

/// Renders the bottom action bar with Log P2P and Send Referral buttons.
class PeerProfileBottomActions extends StatelessWidget {
  final VoidCallback onLogP2PTap;
  final VoidCallback onSendReferralTap;

  const PeerProfileBottomActions({
    super.key,
    required this.onLogP2PTap,
    required this.onSendReferralTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Log P2P',
                leadingIcon: Icons.handshake_outlined,
                isOutlined: true,
                height: 44,
                onPressed: onLogP2PTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: 'Send Referral',
                leadingIcon: Icons.send_rounded,
                height: 44,
                onPressed: onSendReferralTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
