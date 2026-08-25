import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/referrals_repository.dart';
import '../../../peers/model/peer_model.dart';

/// Modal bottom sheet for creating and sending a referral lead to a peer.
class SendReferralBottomSheet extends StatefulWidget {
  final PeerModel peer;
  final VoidCallback onReferralSent;
  final ValueChanged<String> onError;

  const SendReferralBottomSheet({
    super.key,
    required this.peer,
    required this.onReferralSent,
    required this.onError,
  });

  static Future<void> show(
    BuildContext context, {
    required PeerModel peer,
    required VoidCallback onReferralSent,
    required ValueChanged<String> onError,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SendReferralBottomSheet(
        peer: peer,
        onReferralSent: onReferralSent,
        onError: onError,
      ),
    );
  }

  @override
  State<SendReferralBottomSheet> createState() =>
      _SendReferralBottomSheetState();
}

class _SendReferralBottomSheetState extends State<SendReferralBottomSheet> {
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _valueCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter prospect name')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final res = await ReferralsRepositoryImpl().createReferralLead(
        toPeerId: widget.peer.id,
        prospectName: _nameCtrl.text.trim(),
        prospectCompany: _companyCtrl.text.trim(),
        prospectPhone: _phoneCtrl.text.trim(),
        prospectEmail: _emailCtrl.text.trim(),
        estimatedDealValue: _valueCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );

      if (mounted) Navigator.of(context).pop();

      if (res.success) {
        widget.onReferralSent();
      } else {
        widget.onError(res.message ?? 'Failed to send referral');
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      widget.onError('Error sending referral: $e');
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
              children: [
                const Icon(
                  Icons.share_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Send Referral · ${widget.peer.name}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Prospect Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _companyCtrl,
              decoration: InputDecoration(
                labelText: 'Prospect Company',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.business_outlined, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Prospect Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Prospect Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _valueCtrl,
              decoration: InputDecoration(
                labelText: 'Estimated Deal Value (e.g. ₹15.0L)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(
                  Icons.currency_rupee_outlined,
                  size: 20,
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Requirement / Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.notes_outlined, size: 20),
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
                      'Send Referral',
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
