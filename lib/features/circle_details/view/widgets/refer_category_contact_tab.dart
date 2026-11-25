import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/formatting/phone_number_helper.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/international_phone_field.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/teams_repository.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_sub_industry_model.dart';

/// Tab 2 of [ReferCategoryBottomSheet]: Refer from saved contacts or enter contact details
/// and submit referral or invite via WhatsApp.
class ReferCategoryContactTab extends StatefulWidget {
  final CircleTeamModel circle;
  final SubIndustryItemModel category;

  const ReferCategoryContactTab({
    super.key,
    required this.circle,
    required this.category,
  });

  @override
  State<ReferCategoryContactTab> createState() =>
      _ReferCategoryContactTabState();
}

class _ReferCategoryContactTabState extends State<ReferCategoryContactTab> {
  final TeamsRepository _teamsRepo = TeamsRepositoryImpl();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;
  late final TextEditingController _cityController;
  late final TextEditingController _notesController;

  List<ReferralContactModel> _savedContacts = const [];
  bool _isLoadingContacts = true;
  bool _isSubmitting = false;
  String? _selectedContactId;
  late Country _selectedCountry;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _selectedCountry = PhoneNumberHelper.resolveCountry();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _companyController = TextEditingController();
    _cityController = TextEditingController(text: widget.circle.location);
    _notesController = TextEditingController();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final res = await _teamsRepo.getContacts();
    if (!mounted) return;
    setState(() {
      _isLoadingContacts = false;
      _savedContacts = res.data ?? const [];
    });
  }

  void _selectContact(ReferralContactModel contact) {
    final split = PhoneNumberHelper.splitStoredPhone(contact.phone);
    setState(() {
      _selectedContactId = contact.id;
      _selectedCountry = split.country;
      _phoneError = null;
      _nameController.text = contact.name;
      _phoneController.text = split.nationalInput;
      if (contact.company.isNotEmpty) {
        _companyController.text = contact.company;
      }
      if (contact.city.isNotEmpty) {
        _cityController.text = contact.city;
      }
    });
  }

  Future<void> _submitContactReferral() async {
    final name = _nameController.text.trim();
    final rawPhone = _phoneController.text.trim();
    if (name.isEmpty || rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter contact name and phone number'),
          backgroundColor: AppColor.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final validation = PhoneNumberHelper.validate(
      rawPhone,
      countryIso: _selectedCountry.countryCode,
      countryName: _selectedCountry.name,
      dialCode: '+${_selectedCountry.phoneCode}',
    );
    if (!validation.isValid || validation.e164 == null) {
      setState(() => _phoneError = validation.errorMessage);
      return;
    }

    setState(() {
      _phoneError = null;
      _isSubmitting = true;
    });
    final res = await _teamsRepo.referCategory(
      widget.circle.id,
      {
        'source_type': 'contact',
        'peer_name': name,
        'peer_phone': validation.e164!,
        'peer_company': _companyController.text.trim(),
        'peer_city': _cityController.text.trim(),
        'category_id': widget.category.id,
        'category_name': widget.category.name,
        'notes': _notesController.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.success
              ? '$name referred for ${widget.category.name}'
              : (res.message ?? 'Could not submit referral'),
        ),
        backgroundColor: res.success ? AppColor.success : AppColor.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (res.success) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _inviteViaWhatsApp() async {
    final name = _nameController.text.trim();
    final validation = PhoneNumberHelper.validate(
      _phoneController.text.trim(),
      countryIso: _selectedCountry.countryCode,
    );
    final rawPhone = (validation.isValid && validation.e164 != null)
        ? validation.e164!.replaceAll(RegExp(r'[^\d]'), '')
        : _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final greeting = name.isNotEmpty ? 'Hi $name,' : 'Hi,';
    final msg =
        '$greeting I would like to refer you for the open "${widget.category.name}" category in ${widget.circle.name} on Peers Global Unity.';
    final encoded = Uri.encodeComponent(msg);
    final uri = rawPhone.isNotEmpty
        ? Uri.parse('https://wa.me/$rawPhone?text=$encoded')
        : Uri.parse('https://wa.me/?text=$encoded');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isLoadingContacts && _savedContacts.isNotEmpty) ...[
            Text(
              'Quick Pick from Saved Contacts',
              style: AppTypography.labelSmall.copyWith(
                fontSize: 11,
                color: AppColor.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _savedContacts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final c = _savedContacts[index];
                  final isSelected = _selectedContactId == c.id;
                  return InkWell(
                    onTap: () => _selectContact(c),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.badgeBlueBg
                            : AppColor.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.primaryBlue
                              : AppColor.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InitialsAvatar(
                            name: c.name.isNotEmpty ? c.name : 'C',
                            radius: 14,
                            backgroundColor: AppColor.primaryBlue,
                            fontSize: 10,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                c.name,
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 11.5,
                                  color: AppColor.lightTextPrimary,
                                ),
                              ),
                              if (c.phone.isNotEmpty)
                                Text(
                                  c.phone,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 10,
                                    color: AppColor.lightTextSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
          ],
          _buildInput(
            controller: _nameController,
            label: 'Contact Full Name *',
            hint: 'Enter full name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 10),
          InternationalPhoneField(
            controller: _phoneController,
            selectedCountry: _selectedCountry,
            label: 'Mobile / WhatsApp Number',
            isRequired: true,
            isDense: true,
            errorText: _phoneError,
            onCountryChanged: (c) => setState(() {
              _selectedCountry = c;
              _phoneError = null;
            }),
            onChanged: (_) {
              if (_phoneError != null) setState(() => _phoneError = null);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  controller: _companyController,
                  label: 'Company / Business',
                  hint: 'Business name',
                  icon: Icons.business_center_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInput(
                  controller: _cityController,
                  label: 'City',
                  hint: 'City',
                  icon: Icons.location_on_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInput(
            controller: _notesController,
            label: 'Referral Note (Optional)',
            hint: 'Why are they a great fit for ${widget.category.name}?',
            icon: Icons.notes_rounded,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _inviteViaWhatsApp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primaryBlue,
                    side: const BorderSide(color: AppColor.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: Text(
                    'WhatsApp Invite',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 12,
                      color: AppColor.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: _isSubmitting ? 'Submitting...' : 'Refer Contact',
                  onPressed: _isSubmitting ? null : _submitContactReferral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 11,
            color: AppColor.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 13,
            color: AppColor.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySmall.copyWith(
              fontSize: 12,
              color: AppColor.lightTextDisabled,
            ),
            prefixIcon: Icon(
              icon,
              size: 16,
              color: AppColor.lightTextSecondary,
            ),
            filled: true,
            fillColor: AppColor.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColor.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColor.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}

