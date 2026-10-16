import 'package:flutter/material.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';

/// Form component for leaders to draft and submit weekly/monthly/quarterly circle reports.
class ReportSubmitSection extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final String circleName;
  final List<String> availableCircles;
  final ValueChanged<String>? onCircleChanged;
  final TextEditingController periodController;
  final TextEditingController attendanceController;
  final TextEditingController dealsClosedController;
  final TextEditingController totalRevenueController;
  final TextEditingController contentController;
  final TextEditingController highlightsController;
  final TextEditingController challengesController;
  final TextEditingController actionItemsController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const ReportSubmitSection({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.circleName,
    this.availableCircles = const [],
    this.onCircleChanged,
    required this.periodController,
    required this.attendanceController,
    required this.dealsClosedController,
    required this.totalRevenueController,
    required this.contentController,
    required this.highlightsController,
    required this.challengesController,
    required this.actionItemsController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  String _getUpperRecipientLabel() {
    final role = SessionManager().currentRole;
    switch (role) {
      case UserRole.chairBusinessGrowth:
      case UserRole.chairMembership:
      case UserRole.chairEvents:
      case UserRole.circleChair:
        return 'To: Circle Founder ➔ Circle Director ➔ District Leadership';
      case UserRole.circleFounder:
      case UserRole.circleDirector:
        return 'To: Industry Director ➔ District Executive Director';
      case UserRole.industryDirector:
        return 'To: District Executive Director ➔ Super Admin';
      case UserRole.districtExecDirector:
        return 'To: Super Admin & National Leadership';
      case UserRole.countryDirector:
      case UserRole.superAdmin:
        return 'To: Central Audit & Global Records';
    }
  }

  void _showCirclePicker(BuildContext context) {
    if (availableCircles.isEmpty && circleName.isEmpty) return;

    final circles = availableCircles.isNotEmpty
        ? availableCircles
        : (circleName.isNotEmpty ? [circleName] : <String>[]);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = circles
                .where((c) => c.toLowerCase().contains(query.toLowerCase()))
                .toList();

            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            'Select Circle for Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${circles.length} Available',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (val) => setSheetState(() => query = val),
                        decoration: InputDecoration(
                          hintText: 'Search circle name...',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No matching circles found.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (ctx, idx) {
                                final item = filtered[idx];
                                final isSelected =
                                    item.toLowerCase() ==
                                    circleName.toLowerCase();
                                return ListTile(
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    onCircleChanged?.call(item);
                                  },
                                  leading: const SquareRoundedGradientIcon(
                                    icon: Icons.group_work_rounded,
                                    iconSize: 18,
                                    boxSize: 36,
                                    showBorder: true,
                                  ),
                                  title: Text(
                                    item,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                      fontSize: 13,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.text,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF16A34A),
                                          size: 20,
                                        )
                                      : const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.textSecondary,
                                          size: 20,
                                        ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          _buildHeader(),
          const SizedBox(height: 12),
          // Type Selector Pills
          _buildTypeSelector(),
          const SizedBox(height: 14),
          // Circle Name Display with Interactive Picker
          _buildCircleField(context),
          const SizedBox(height: 14),
          // Period & Attendance Row
          _buildPeriodAndAttendanceRow(),
          const SizedBox(height: 14),
          // Deals & Revenue Row
          _buildFinancialsRow(),
          const SizedBox(height: 14),
          // Executive Summary Text (Required)
          _buildField(
            title: 'EXECUTIVE SUMMARY & NOTES *',
            controller: contentController,
            maxLines: 4,
          ),
          const SizedBox(height: 14),
          // Key Highlights
          _buildField(
            title: 'KEY HIGHLIGHTS & WINS',
            controller: highlightsController,
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          // Challenges Faced
          _buildField(
            title: 'CHALLENGES FACED & ROADBLOCKS',
            controller: challengesController,
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          // Action Items
          _buildField(
            title: 'ACTION ITEMS & NEXT STEPS',
            controller: actionItemsController,
            maxLines: 2,
          ),
          const SizedBox(height: 18),
          // Submit Button
          _buildSubmitButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SquareRoundedGradientIcon(
            icon: Icons.description_outlined,
            iconSize: 20,
            boxSize: 40,
            showBorder: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit Performance Report',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getUpperRecipientLabel(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    const types = ['Weekly', 'Monthly', 'Quarterly', 'Annual'];

    return Row(
      children: types.map((type) {
        final isSelected = selectedType.toLowerCase() == type.toLowerCase();
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: InkWell(
              onTap: () => onTypeChanged(type),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.brandGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected ? null : Border.all(color: AppColors.border),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCircleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'TARGET CIRCLE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            if (availableCircles.length > 1)
              const Text(
                'Tap to change circle',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showCirclePicker(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.group_work_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    circleName.isNotEmpty ? circleName : 'Select Target Circle',
                    style: TextStyle(
                      color: circleName.isNotEmpty
                          ? AppColors.text
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodAndAttendanceRow() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REPORT PERIOD',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: periodController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ATTENDANCE %',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: attendanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixIcon: const GradientIcon(
                    icon: Icons.how_to_reg_rounded,
                    size: 16,
                  ),
                  suffixText: '%',
                  suffixStyle: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialsRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DEALS CLOSED VALUE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: dealsClosedController,
                decoration: InputDecoration(
                  prefixIcon: const GradientIcon(
                    icon: Icons.currency_rupee_rounded,
                    size: 16,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL REVENUE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: totalRevenueController,
                decoration: InputDecoration(
                  prefixIcon: const GradientIcon(
                    icon: Icons.trending_up_rounded,
                    size: 16,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String title,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12.0),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return PrimaryButton(
      label: 'Submit Report for Leadership Review →',
      isLoading: isSubmitting,
      height: 48,
      onPressed: onSubmit,
    );
  }
}
