import 'package:flutter/material.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';

/// Form component for leaders to draft and submit weekly/monthly circle reports.
class ReportSubmitSection extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final String circleName;
  final List<String> availableCircles;
  final ValueChanged<String>? onCircleChanged;
  final TextEditingController contentController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const ReportSubmitSection({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.circleName,
    this.availableCircles = const [],
    this.onCircleChanged,
    required this.contentController,
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
        return 'To: Circle Founder, Circle Director & District Leadership';
      case UserRole.circleFounder:
      case UserRole.circleDirector:
        return 'To: Industry Director & District Leadership';
      case UserRole.industryDirector:
        return 'To: District Executive Director & Super Admin';
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

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
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
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${circles.length} Available',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
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
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (ctx, idx) {
                              final item = filtered[idx];
                              final isSelected = item.toLowerCase() ==
                                  circleName.toLowerCase();
                              return ListTile(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onCircleChanged?.call(item);
                                },
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1E3C72)
                                        : const Color(0xFFEBF3FB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.group_work_rounded,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF1E3C72),
                                  ),
                                ),
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected
                                        ? const Color(0xFF1E3C72)
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
          // Content Input Box
          _buildContentInput(),
          const SizedBox(height: 16),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit Leadership Report',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getUpperRecipientLabel(),
                  style: const TextStyle(
                    color: Color(0xFF1E3C72),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onTypeChanged('Weekly'),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selectedType == 'Weekly'
                    ? AppColors.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selectedType == 'Weekly'
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Weekly Report',
                style: TextStyle(
                  color: selectedType == 'Weekly'
                      ? Colors.white
                      : AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () => onTypeChanged('Monthly'),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selectedType == 'Monthly'
                    ? AppColors.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selectedType == 'Monthly'
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Monthly Report',
                style: TextStyle(
                  color: selectedType == 'Monthly'
                      ? Colors.white
                      : AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
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
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            if (availableCircles.length > 1)
              const Text(
                'Tap to change circle',
                style: TextStyle(
                  color: Color(0xFF1E3C72),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
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
                  color: Color(0xFF1E3C72),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    circleName.isNotEmpty ? circleName : 'Select Circle',
                    style: TextStyle(
                      color: circleName.isNotEmpty
                          ? AppColors.text
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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


  Widget _buildContentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REPORT CONTENT',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: contentController,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText:
                'Describe attendance, closed deals, peer updates, concerns, or achievements...',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
            contentPadding: const EdgeInsets.all(14.0),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Submit Report →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
