import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/finance_repository.dart';

/// Modal bottom sheet for recording offline / dues payments.
class RecordPaymentBottomSheet extends StatefulWidget {
  final String? selectedCircle;
  final VoidCallback onPaymentRecorded;
  final ValueChanged<String> onError;

  const RecordPaymentBottomSheet({
    super.key,
    this.selectedCircle,
    required this.onPaymentRecorded,
    required this.onError,
  });

  static Future<void> show(
    BuildContext context, {
    String? selectedCircle,
    required VoidCallback onPaymentRecorded,
    required ValueChanged<String> onError,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RecordPaymentBottomSheet(
        selectedCircle: selectedCircle,
        onPaymentRecorded: onPaymentRecorded,
        onError: onError,
      ),
    );
  }

  @override
  State<RecordPaymentBottomSheet> createState() =>
      _RecordPaymentBottomSheetState();
}

class _RecordPaymentBottomSheetState extends State<RecordPaymentBottomSheet> {
  final _peerIdCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _modeCtrl = TextEditingController(text: 'Bank Transfer');
  final _refCtrl = TextEditingController();
  final _typeCtrl = TextEditingController(text: 'Annual Membership Fee');
  bool _isSaving = false;

  @override
  void dispose() {
    _peerIdCtrl.dispose();
    _amountCtrl.dispose();
    _modeCtrl.dispose();
    _refCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_amountCtrl.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final res = await FinanceRepositoryImpl().recordOfflinePayment(
        peerId: _peerIdCtrl.text.trim().isEmpty
            ? 'peer_manual'
            : _peerIdCtrl.text.trim(),
        circleId: widget.selectedCircle ?? 'circle_current',
        amount: amt,
        paymentMode: _modeCtrl.text.trim(),
        referenceNumber: _refCtrl.text.trim(),
        paymentDate: DateTime.now().toString().split(' ').first,
        type: _typeCtrl.text.trim(),
      );

      if (mounted) Navigator.of(context).pop();

      if (res.success) {
        widget.onPaymentRecorded();
      } else {
        widget.onError(res.message ?? 'Failed to record payment');
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      widget.onError('Error recording payment: $e');
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
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Record Offline / Dues Payment',
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
              controller: _peerIdCtrl,
              decoration: InputDecoration(
                labelText: 'Peer ID / Member Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.currency_rupee_outlined, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _modeCtrl,
              decoration: InputDecoration(
                labelText: 'Payment Mode (Cheque / Cash / Bank Transfer)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.payment_outlined, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _refCtrl,
              decoration: InputDecoration(
                labelText: 'Reference Number / Cheque No.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.numbers_outlined, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _typeCtrl,
              decoration: InputDecoration(
                labelText: 'Payment Type / Purpose',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.label_outline, size: 20),
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
                      'Record Payment',
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
