import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../peers/model/peer_model.dart';

/// Modal bottom sheet allowing Super Admin and authorized leaders to edit peer profile details.
class EditPeerBottomSheet extends StatefulWidget {
  final PeerModel peer;
  final ValueChanged<PeerModel> onUpdated;

  const EditPeerBottomSheet({
    super.key,
    required this.peer,
    required this.onUpdated,
  });

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.peer.name);
    _companyController = TextEditingController(text: widget.peer.company);
    _designationController =
        TextEditingController(text: widget.peer.designation ?? '');
    _phoneController = TextEditingController(text: widget.peer.phone ?? '');
    _emailController = TextEditingController(text: widget.peer.email ?? '');
    _videoUrlController =
        TextEditingController(text: widget.peer.introVideoUrl ?? '');
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
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a full name'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final updated = widget.peer.copyWith(
      name: trimmedName,
      company: _companyController.text.trim(),
      designation: _designationController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      introVideoUrl: _videoUrlController.text.trim(),
    );

    try {
      if (widget.peer.id.isNotEmpty) {
        await ApiClient().put(
          ApiEndpoints.peerDetails(widget.peer.id),
          body: updated.toJson(),
        );
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Drag Handle Pill
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header Row: Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Peer Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Update member details & contact info',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),

              // Form Fields
              _buildField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter full name',
                icon: Icons.person_outline_rounded,
                isRequired: true,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _companyController,
                label: 'Company Name',
                hint: 'Enter company name',
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _designationController,
                label: 'Designation / Role',
                hint: 'e.g. Founder & CEO',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'e.g. +91 98765 43210',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'e.g. peer@company.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _videoUrlController,
                label: 'Intro Video URL',
                hint: 'e.g. https://youtu.be/...',
                icon: Icons.play_circle_outline_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // Save Action Button
              PrimaryButton(
                label: _isSaving ? 'Saving Changes...' : 'Save Peer Details',
                onPressed: _isSaving ? null : _handleSave,
                isLoading: _isSaving,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
                letterSpacing: 0.1,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
