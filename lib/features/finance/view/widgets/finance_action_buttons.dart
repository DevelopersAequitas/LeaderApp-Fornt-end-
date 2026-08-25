import 'package:flutter/material.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders the top action buttons on the Finance screen (Record Payment, Commission Setup).
class FinanceActionButtons extends StatelessWidget {
  final VoidCallback onRecordPaymentTap;
  final VoidCallback onCommissionSetupTap;

  const FinanceActionButtons({
    super.key,
    required this.onRecordPaymentTap,
    required this.onCommissionSetupTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = SessionManager().currentRole == UserRole.superAdmin;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              icon: const Icon(
                Icons.add_card_rounded,
                size: 15,
                color: AppColors.primary,
              ),
              label: const Text(
                'Record Payment',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
              onPressed: onRecordPaymentTap,
            ),
          ),
          if (isSuperAdmin) ...[
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 15,
                  color: Colors.white,
                ),
                label: const Text(
                  'Commission Setup',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                ),
                onPressed: onCommissionSetupTap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
