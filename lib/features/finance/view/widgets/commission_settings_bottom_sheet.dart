import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/finance_repository.dart';

/// Modal bottom sheet for configuring commission rates (Super Admin).
class CommissionSettingsBottomSheet extends StatefulWidget {
  final VoidCallback onRatesUpdated;
  final ValueChanged<String> onError;

  const CommissionSettingsBottomSheet({
    super.key,
    required this.onRatesUpdated,
    required this.onError,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRatesUpdated,
    required ValueChanged<String> onError,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CommissionSettingsBottomSheet(
        onRatesUpdated: onRatesUpdated,
        onError: onError,
      ),
    );
  }

  @override
  State<CommissionSettingsBottomSheet> createState() =>
      _CommissionSettingsBottomSheetState();
}

class _CommissionSettingsBottomSheetState
    extends State<CommissionSettingsBottomSheet> {
  final _referralCtrl = TextEditingController(text: '7.5');
  final _appJoinCtrl = TextEditingController(text: '3.0');
  bool _isSaving = false;

  @override
  void dispose() {
    _referralCtrl.dispose();
    _appJoinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final refVal = double.tryParse(_referralCtrl.text.trim()) ?? 0.0;
    final appVal = double.tryParse(_appJoinCtrl.text.trim()) ?? 0.0;

    setState(() => _isSaving = true);
    try {
      final res = await FinanceRepositoryImpl().updateCommissionRates([
        {
          'role_id': 'circleFounder',
          'direct_referral_cut_percentage': refVal,
          'app_join_cut_percentage': appVal,
        },
      ]);

      if (mounted) Navigator.of(context).pop();

      if (res.success) {
        widget.onRatesUpdated();
      } else {
        widget.onError(res.message ?? 'Failed to update rates');
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      widget.onError('Error updating commission rates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Icon(
                  Icons.percent_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Configure Commission Rates',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _referralCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Direct Referral Cut (%)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.trending_up_outlined, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _appJoinCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'App Join Cut (%)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.handshake_outlined, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Commission Rates',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
