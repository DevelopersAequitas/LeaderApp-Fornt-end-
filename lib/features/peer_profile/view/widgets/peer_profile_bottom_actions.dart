import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(
                  Icons.handshake_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Log P2P',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
                onPressed: onLogP2PTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.send_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Send Referral',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                onPressed: onSendReferralTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
