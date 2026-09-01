import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/login_bloc.dart';
import '../../bloc/login_event.dart';
import '../../bloc/login_state.dart';

/// Clean Sign In form section with auto-detecting country code picker and Send OTP action.
class LoginFormSection extends StatefulWidget {
  final TextEditingController inputController;
  final VoidCallback onSubmit;

  const LoginFormSection({
    super.key,
    required this.inputController,
    required this.onSubmit,
  });

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  bool _hasText = false;
  Country _selectedCountry = Country.parse('IN'); // Default India (+91)

  @override
  void initState() {
    super.initState();
    _hasText = widget.inputController.text.isNotEmpty;
    widget.inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    widget.inputController.removeListener(_onInputChanged);
    super.dispose();
  }

  bool _isNumericPhoneInput(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return false;
    final hasLetterOrAt = RegExp(r'[a-zA-Z@]').hasMatch(clean);
    final hasDigits = RegExp(r'[0-9]').hasMatch(clean);
    return !hasLetterOrAt && hasDigits;
  }

  void _syncWithBloc() {
    final raw = widget.inputController.text.trim();
    final bloc = context.read<LoginBloc>();

    if (raw.isEmpty) {
      bloc.add(const EmailOrPhoneChanged(''));
      return;
    }

    if (_isNumericPhoneInput(raw)) {
      if (raw.startsWith('+')) {
        bloc.add(EmailOrPhoneChanged(raw));
      } else {
        bloc.add(EmailOrPhoneChanged('+${_selectedCountry.phoneCode}$raw'));
      }
    } else {
      bloc.add(EmailOrPhoneChanged(raw));
    }
  }

  void _onInputChanged() {
    final hasText = widget.inputController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    _syncWithBloc();
  }

  void _openCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _CountryPickerBottomSheet(
          selectedCountry: _selectedCountry,
          onCountrySelected: (Country country) {
            setState(() {
              _selectedCountry = country;
            });
            _syncWithBloc();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = _isNumericPhoneInput(widget.inputController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your email address or phone number to continue.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: widget.inputController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onSubmit(),
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            prefixIcon: isPhone
                ? InkWell(
                    onTap: () => _openCountryPicker(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountry.flagEmoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${_selectedCountry.phoneCode}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          Container(
                            height: 22,
                            width: 1,
                            color: const Color(0xFFE2E8F0),
                            margin: const EdgeInsets.only(left: 4, right: 6),
                          ),
                        ],
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () => _openCountryPicker(context),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      child: Icon(
                        Icons.alternate_email_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
            suffixIcon: _hasText
                ? IconButton(
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                    onPressed: () {
                      widget.inputController.clear();
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            hintText: isPhone ? '98765 43210' : 'name@example.com or phone',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
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
          ),
        ),
        const SizedBox(height: 24),
        BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final isEnabled = state.isFormValid && !state.isLoading;

            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isEnabled ? widget.onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  elevation: isEnabled ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Send OTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Custom Bottom Sheet with high-contrast, perfectly aligned rows and instant search.
class _CountryPickerBottomSheet extends StatefulWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  const _CountryPickerBottomSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<_CountryPickerBottomSheet> createState() =>
      _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState
    extends State<_CountryPickerBottomSheet> {
  late final List<Country> _allCountries;
  List<Country> _filteredCountries = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allCountries = CountryService().getAll();
    _filteredCountries = _allCountries;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries.where((c) {
          final nameMatch = c.name.toLowerCase().contains(query);
          final codeMatch = c.phoneCode.contains(query);
          final isoMatch = c.countryCode.toLowerCase().contains(query);
          return nameMatch || codeMatch || isoMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle Bar
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header Title & Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -0.2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel_rounded,
                            color: Color(0xFF94A3B8),
                            size: 18,
                          ),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  hintText: 'Search country or dialing code...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
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
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Country List
            Expanded(
              child: _filteredCountries.isEmpty
                  ? Center(
                      child: Text(
                        'No countries found',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: _filteredCountries.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 56,
                        color: Color(0xFFF8FAFC),
                      ),
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        final isSelected = country.countryCode ==
                            widget.selectedCountry.countryCode;

                        return InkWell(
                          onTap: () {
                            widget.onCountrySelected(country);
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 13.0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF1F5F9)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Flag
                                Text(
                                  country.flagEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 14),

                                // Dialing Code Badge
                                Container(
                                  constraints: const BoxConstraints(minWidth: 54),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF3F8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${country.phoneCode}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Country Name
                                Expanded(
                                  child: Text(
                                    country.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.text,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Selected Checkmark
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
