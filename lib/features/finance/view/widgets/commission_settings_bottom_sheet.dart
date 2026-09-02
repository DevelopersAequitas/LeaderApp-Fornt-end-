import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/finance_repository.dart';
import '../../model/finance_model.dart';

/// Modal bottom sheet for configuring dynamic commission rates for all leadership roles (Super Admin).
class CommissionSettingsBottomSheet extends StatefulWidget {
  final List<CommissionStructureItemModel> currentStructure;
  final VoidCallback onRatesUpdated;
  final ValueChanged<String> onError;

  const CommissionSettingsBottomSheet({
    super.key,
    this.currentStructure = const [],
    required this.onRatesUpdated,
    required this.onError,
  });

  static Future<void> show(
    BuildContext context, {
    List<CommissionStructureItemModel> currentStructure = const [],
    required VoidCallback onRatesUpdated,
    required ValueChanged<String> onError,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommissionSettingsBottomSheet(
        currentStructure: currentStructure,
        onRatesUpdated: onRatesUpdated,
        onError: onError,
      ),
    );
  }

  @override
  State<CommissionSettingsBottomSheet> createState() =>
      _CommissionSettingsBottomSheetState();
}

class _CommissionSettingsBottomSheetState
    extends State<CommissionSettingsBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_RoleRateFormState> _roleForms = [
    _RoleRateFormState(
      roleId: 'circleFounder',
      roleName: 'Circle Founder',
      defaultReferral: 7.5,
      defaultAppJoin: 3.0,
      defaultRenewal: 2.0,
      icon: Icons.star_rounded,
      description: 'Founder overseeing circle inception and growth.',
    ),
    _RoleRateFormState(
      roleId: 'circleChair',
      roleName: 'Circle Chair',
      defaultReferral: 5.0,
      defaultAppJoin: 2.0,
      defaultRenewal: 1.5,
      icon: Icons.chair_rounded,
      description: 'Chair leading weekly meetings and peer engagement.',
    ),
    _RoleRateFormState(
      roleId: 'countryDirector',
      roleName: 'Country Director',
      defaultReferral: 10.0,
      defaultAppJoin: 5.0,
      defaultRenewal: 3.0,
      icon: Icons.business_center_rounded,
      description: 'Director governing national circles and operations.',
    ),
    _RoleRateFormState(
      roleId: 'superAdmin',
      roleName: 'Super Admin',
      defaultReferral: 12.0,
      defaultAppJoin: 6.0,
      defaultRenewal: 3.0,
      icon: Icons.admin_panel_settings_rounded,
      description: 'Global system administrator override.',
    ),
  ];

  int _selectedIndex = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _roleForms.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Prepopulate with existing server data if available
    for (final item in widget.currentStructure) {
      final roleKey = item.roleId ??
          item.role.toLowerCase().replaceAll(' ', '').replaceAll('_', '');

      for (final form in _roleForms) {
        if (form.roleId.toLowerCase() == roleKey.toLowerCase() ||
            form.roleName.toLowerCase() == item.role.toLowerCase()) {
          final refNum = _parsePercentage(item.directReferralCut);
          final appNum = _parsePercentage(item.appJoinCut);
          final renNum = item.renewalCut != null
              ? _parsePercentage(item.renewalCut!)
              : form.defaultRenewal;

          form.referralController.text = refNum.toString();
          form.appJoinController.text = appNum.toString();
          form.renewalController.text = renNum.toString();
        }
      }
    }
  }

  void _handleTabChange() {
    if (_tabController.index != _selectedIndex) {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    }
  }

  double _parsePercentage(String raw) {
    final cleaned = raw.replaceAll('%', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    for (final form in _roleForms) {
      form.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    // 1. Client-side Validation across all roles
    final dtoList = <UpdateCommissionRateDto>[];

    for (final form in _roleForms) {
      final refVal = double.tryParse(form.referralController.text.trim());
      final appVal = double.tryParse(form.appJoinController.text.trim());
      final renVal = form.renewalController.text.trim().isNotEmpty
          ? double.tryParse(form.renewalController.text.trim())
          : null;

      if (refVal == null || refVal < 0.0 || refVal > 100.0) {
        widget.onError(
          'Direct Referral Cut for ${form.roleName} must be between 0.0% and 100.0%.',
        );
        return;
      }

      if (appVal == null || appVal < 0.0 || appVal > 100.0) {
        widget.onError(
          'App Join Cut for ${form.roleName} must be between 0.0% and 100.0%.',
        );
        return;
      }

      if (renVal != null && (renVal < 0.0 || renVal > 100.0)) {
        widget.onError(
          'Renewal Cut for ${form.roleName} must be between 0.0% and 100.0%.',
        );
        return;
      }

      dtoList.add(
        UpdateCommissionRateDto(
          roleId: form.roleId,
          roleName: form.roleName,
          directReferralCutPercentage: refVal,
          appJoinCutPercentage: appVal,
          renewalCutPercentage: renVal,
        ),
      );
    }

    // 2. Submit to PUT /finance/commission-rates
    setState(() => _isSaving = true);
    try {
      final res = await FinanceRepositoryImpl().updateCommissionRates(dtoList);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (res.success) {
        widget.onRatesUpdated();
      } else {
        widget.onError(res.message ?? 'Failed to update commission rates');
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      widget.onError('Error updating commission rates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure Commission Rates',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Super Admin Global Matrix Configuration',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Sleek Role Segmented Pill Bar
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _roleForms.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final form = _roleForms[index];
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        _tabController.animateTo(index);
                        setState(() => _selectedIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              form.icon,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              form.roleName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Form Body per Tab
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _roleForms.map((form) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Card Info Banner
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.border,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  form.icon,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        form.roleName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        form.description,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 1. Direct Referral Cut Field
                          const Text(
                            'Direct Referral Cut (%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Commission earned on every closed peer referral deal.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: form.referralController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                            cursorColor: AppColors.primary,
                            decoration: InputDecoration(
                              hintText: 'e.g. 7.5',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: const Icon(
                                Icons.trending_up_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              suffixText: '%',
                              suffixStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 2. App Join Cut Field
                          const Text(
                            'App Join Cut (%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Commission credited on new peer joining/onboarding fee.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: form.appJoinController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                            cursorColor: AppColors.primary,
                            decoration: InputDecoration(
                              hintText: 'e.g. 3.0',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: const Icon(
                                Icons.handshake_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              suffixText: '%',
                              suffixStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 3. Annual Renewal Cut Field (Optional)
                          const Text(
                            'Annual Renewal Cut (%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Commission credited on annual peer renewal fees.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: form.renewalController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                            cursorColor: AppColors.primary,
                            decoration: InputDecoration(
                              hintText: 'e.g. 2.0',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: const Icon(
                                Icons.autorenew_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              suffixText: '%',
                              suffixStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),

              // Action Buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Save Commission Rates',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleRateFormState {
  final String roleId;
  final String roleName;
  final double defaultReferral;
  final double defaultAppJoin;
  final double defaultRenewal;
  final IconData icon;
  final String description;

  late final TextEditingController referralController;
  late final TextEditingController appJoinController;
  late final TextEditingController renewalController;

  _RoleRateFormState({
    required this.roleId,
    required this.roleName,
    required this.defaultReferral,
    required this.defaultAppJoin,
    required this.defaultRenewal,
    required this.icon,
    required this.description,
  }) {
    referralController =
        TextEditingController(text: defaultReferral.toString());
    appJoinController = TextEditingController(text: defaultAppJoin.toString());
    renewalController = TextEditingController(text: defaultRenewal.toString());
  }

  void dispose() {
    referralController.dispose();
    appJoinController.dispose();
    renewalController.dispose();
  }
}
