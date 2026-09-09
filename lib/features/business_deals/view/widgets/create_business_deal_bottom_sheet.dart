import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';

class CreateBusinessDealBottomSheet extends StatefulWidget {
  final Function({
    required String withPeerId,
    required dynamic amount,
    required String currency,
    required String dealType,
    String? notes,
  }) onSubmit;

  const CreateBusinessDealBottomSheet({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    required Function({
      required String withPeerId,
      required dynamic amount,
      required String currency,
      required String dealType,
      String? notes,
    }) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateBusinessDealBottomSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<CreateBusinessDealBottomSheet> createState() =>
      _CreateBusinessDealBottomSheetState();
}

class _CreateBusinessDealBottomSheetState
    extends State<CreateBusinessDealBottomSheet> {
  final _peerIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _dealType = 'closed';

  @override
  void dispose() {
    _peerIdController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final peerId = _peerIdController.text.trim();
    final amountStr = _amountController.text.trim();
    final notes = _notesController.text.trim();

    final amountNum = double.tryParse(amountStr.replaceAll(',', ''));
    if (peerId.isEmpty || amountNum == null || amountNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid Peer ID and Amount'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    widget.onSubmit(
      withPeerId: peerId,
      amount: amountNum,
      currency: 'INR',
      dealType: _dealType,
      notes: notes.isNotEmpty ? notes : null,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
            const SizedBox(height: 16),
            const Text(
              'Record Business Deal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _peerIdController,
              decoration: InputDecoration(
                labelText: 'Peer User ID *',
                hintText: 'Enter peer UUID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Deal Amount (₹) *',
                hintText: 'e.g. 150000',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _dealType,
              decoration: InputDecoration(
                labelText: 'Deal Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'closed', child: Text('CLOSED / COMPLETED')),
                DropdownMenuItem(value: 'in_progress', child: Text('IN PROGRESS')),
                DropdownMenuItem(value: 'referred', child: Text('REFERRED')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _dealType = val);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Deal Description / Products',
                hintText: 'e.g. Annual enterprise ERP license agreement',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Record Deal',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
