import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../peers/model/peer_model.dart';

/// Modal bottom sheet allowing Super Admin and authorized leaders to edit peer profile and privacy flags.
class EditPeerBottomSheet extends StatefulWidget {
  final PeerModel peer;
  final ValueChanged<PeerModel> onUpdated;

  const EditPeerBottomSheet({super.key, required this.peer, required this.onUpdated});

  static Future<void> show(
    BuildContext context, {
    required PeerModel peer,
    required ValueChanged<PeerModel> onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditPeerBottomSheet(peer: peer, onUpdated: onUpdated),
    );
  }

  @override
  State<EditPeerBottomSheet> createState() => _EditPeerBottomSheetState();
}

class _EditPeerBottomSheetState extends State<EditPeerBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _designationController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _videoUrlController;
  late bool _hidePhone;
  late bool _hideEmail;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.peer.name);
    _companyController = TextEditingController(text: widget.peer.company);
    _designationController = TextEditingController(text: widget.peer.designation ?? '');
    _phoneController = TextEditingController(text: widget.peer.phone ?? '');
    _emailController = TextEditingController(text: widget.peer.email ?? '');
    _videoUrlController = TextEditingController(text: widget.peer.introVideoUrl ?? '');
    _hidePhone = widget.peer.hidePhone;
    _hideEmail = widget.peer.hideEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final updated = widget.peer.copyWith(
      name: _nameController.text.trim(),
      company: _companyController.text.trim(),
      designation: _designationController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      introVideoUrl: _videoUrlController.text.trim(),
      hidePhone: _hidePhone,
      hideEmail: _hideEmail,
    );

    try {
      if (widget.peer.id.isNotEmpty) {
        await ApiClient().put(ApiEndpoints.peerDetails(widget.peer.id), body: updated.toJson());
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isSaving = false);
      widget.onUpdated(updated);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Edit Peer Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            _buildField(_nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 10),
            _buildField(_companyController, 'Company Name', Icons.business_outlined),
            const SizedBox(height: 10),
            _buildField(_designationController, 'Designation', Icons.badge_outlined),
            const SizedBox(height: 10),
            _buildField(_phoneController, 'Phone Number', Icons.phone_outlined),
            _buildPrivacyRow('Hide Phone from other Peers', _hidePhone, (v) => setState(() => _hidePhone = v)),
            const SizedBox(height: 6),
            _buildField(_emailController, 'Email Address', Icons.mail_outline),
            _buildPrivacyRow('Hide Email from other Peers', _hideEmail, (v) => setState(() => _hideEmail = v)),
            const SizedBox(height: 10),
            _buildField(_videoUrlController, 'Intro Video URL', Icons.play_circle_outline),
            const SizedBox(height: 20),
            PrimaryButton(
              label: _isSaving ? 'Saving Changes...' : 'Save Peer Details',
              onPressed: _isSaving ? null : _handleSave,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 13, color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.secondaryBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPrivacyRow(String title, bool val, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: val,
              activeThumbColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
