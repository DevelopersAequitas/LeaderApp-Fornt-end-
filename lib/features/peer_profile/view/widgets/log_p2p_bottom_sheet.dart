import 'package:flutter/material.dart';
import '../../../peers/model/peer_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/peers_repository.dart';

/// Modal bottom sheet for logging a 1-to-1 P2P Meeting with a peer.
class LogP2PBottomSheet extends StatefulWidget {
  final PeerModel peer;
  final VoidCallback onMeetingLogged;
  final ValueChanged<String> onError;

  const LogP2PBottomSheet({
    super.key,
    required this.peer,
    required this.onMeetingLogged,
    required this.onError,
  });

  static Future<void> show(
    BuildContext context, {
    required PeerModel peer,
    required VoidCallback onMeetingLogged,
    required ValueChanged<String> onError,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LogP2PBottomSheet(
        peer: peer,
        onMeetingLogged: onMeetingLogged,
        onError: onError,
      ),
    );
  }

  @override
  State<LogP2PBottomSheet> createState() => _LogP2PBottomSheetState();
}

class _LogP2PBottomSheetState extends State<LogP2PBottomSheet> {
  final _dateCtrl = TextEditingController(
    text: DateTime.now().toString().split(' ').first,
  );
  final _placeCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _placeCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_placeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter meeting place/venue')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final res = await PeersRepositoryImpl().logP2PMeeting(
        peerId: widget.peer.id,
        meetingDate: _dateCtrl.text.trim(),
        meetingPlace: _placeCtrl.text.trim(),
        remarks: _remarksCtrl.text.trim(),
      );

      if (mounted) Navigator.of(context).pop();

      if (res.success) {
        widget.onMeetingLogged();
      } else {
        widget.onError(res.message ?? 'Failed to log meeting');
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      widget.onError('Error logging meeting: $e');
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
                  Icons.handshake_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Log P2P Meeting · ${widget.peer.name}',
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
              controller: _dateCtrl,
              decoration: InputDecoration(
                labelText: 'Meeting Date (YYYY-MM-DD)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _placeCtrl,
              decoration: InputDecoration(
                labelText: 'Meeting Location / Venue',
                hintText: 'e.g. Starbucks / Google Meet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _remarksCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Discussion Notes & Next Steps',
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
                      'Save P2P Meeting',
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
