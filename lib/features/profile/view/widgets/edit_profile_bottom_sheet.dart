import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../model/profile_model.dart';

/// Modal bottom sheet for updating the active leader's profile details with proper theme and field styling.
class EditProfileBottomSheet extends StatefulWidget {
  final UserProfileModel profile;
  final VoidCallback onProfileUpdated;
  final ValueChanged<String> onError;

  const EditProfileBottomSheet({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.onError,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfileModel profile,
    required VoidCallback onProfileUpdated,
    required ValueChanged<String> onError,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileBottomSheet(
        profile: profile,
        onProfileUpdated: onProfileUpdated,
        onError: onError,
      ),
    );
  }

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _companyCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _bioCtrl = TextEditingController(text: widget.profile.bio);
    _companyCtrl = TextEditingController(
      text: widget.profile.companyName.isNotEmpty
          ? widget.profile.companyName
          : widget.profile.company,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final res = await AuthRepositoryImpl().updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        companyName: _companyCtrl.text.trim(),
      );

      if (mounted) Navigator.of(context).pop();

      if (res.success) {
        widget.onProfileUpdated();
      } else {
        widget.onError(res.message ?? 'Failed to update profile');
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      widget.onError('Failed to update profile: $e');
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.primary,
        size: 19,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Edit Profile Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full Name Field
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(height: 12),

              // Phone Number Field
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  hintText: '+91 98765 43210',
                ),
              ),
              const SizedBox(height: 12),

              // Company / Organization Field
              TextField(
                controller: _companyCtrl,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Company / Organization',
                  prefixIcon: Icons.business_outlined,
                  hintText: 'Enter company or organization',
                ),
              ),
              const SizedBox(height: 12),

              // Executive Bio Field
              TextField(
                controller: _bioCtrl,
                maxLines: 3,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Executive Bio',
                  prefixIcon: Icons.notes_rounded,
                  hintText: 'Brief summary of your executive background',
                ),
              ),
              const SizedBox(height: 20),

              // Save Changes Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
