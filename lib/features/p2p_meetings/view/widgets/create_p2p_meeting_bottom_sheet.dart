import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';

class CreateP2PMeetingBottomSheet extends StatefulWidget {
  final Function({
    required String peerUserId,
    required String scheduledAt,
    required String mode,
    required String location,
    String? notes,
  }) onSubmit;

  const CreateP2PMeetingBottomSheet({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    required Function({
      required String peerUserId,
      required String scheduledAt,
      required String mode,
      required String location,
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
      builder: (_) => CreateP2PMeetingBottomSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<CreateP2PMeetingBottomSheet> createState() => _CreateP2PMeetingBottomSheetState();
}

class _CreateP2PMeetingBottomSheetState extends State<CreateP2PMeetingBottomSheet> {
  final _peerIdController = TextEditingController();
  final _scheduledAtController = TextEditingController();
  final _locationController = TextEditingController(text: 'Google Meet');
  final _notesController = TextEditingController();
  String _mode = 'online';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().add(const Duration(days: 1));
    _scheduledAtController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 15:30:00';
  }

  @override
  void dispose() {
    _peerIdController.dispose();
    _scheduledAtController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final peerId = _peerIdController.text.trim();
    final schedule = _scheduledAtController.text.trim();
    final location = _locationController.text.trim();
    final notes = _notesController.text.trim();

    if (peerId.isEmpty || schedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in required fields'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    widget.onSubmit(
      peerUserId: peerId,
      scheduledAt: schedule,
      mode: _mode,
      location: location.isNotEmpty ? location : (_mode == 'online' ? 'Google Meet' : 'In Person'),
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
              'Schedule P2P 1-on-1 Meeting',
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
              controller: _scheduledAtController,
              decoration: InputDecoration(
                labelText: 'Scheduled Time (YYYY-MM-DD HH:MM:SS) *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Online')),
                    selected: _mode == 'online',
                    onSelected: (s) {
                      if (s) {
                        setState(() {
                          _mode = 'online';
                          if (_locationController.text.isEmpty ||
                              _locationController.text == 'Starbucks') {
                            _locationController.text = 'Google Meet';
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('In Person')),
                    selected: _mode == 'in_person',
                    onSelected: (s) {
                      if (s) {
                        setState(() {
                          _mode = 'in_person';
                          if (_locationController.text == 'Google Meet') {
                            _locationController.text = 'Starbucks';
                          }
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location / Platform',
                hintText: _mode == 'online' ? 'Google Meet / Zoom' : 'Coffee shop / Office',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Meeting Notes / Agenda',
                hintText: 'e.g. Cross-collaboration discussion',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Schedule Meeting',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
