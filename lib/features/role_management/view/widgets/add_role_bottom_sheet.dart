import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

/// Modal bottom sheet allowing Super Admin to add a new custom role cleanly.
class AddRoleBottomSheet extends StatefulWidget {
  final ValueChanged<String> onAdd;

  const AddRoleBottomSheet({super.key, required this.onAdd});

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddRoleBottomSheet(onAdd: onAdd),
    );
  }

  @override
  State<AddRoleBottomSheet> createState() => _AddRoleBottomSheetState();
}

class _AddRoleBottomSheetState extends State<AddRoleBottomSheet> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Please enter a valid role name');
      return;
    }
    widget.onAdd(text);
    Navigator.of(context).pop();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.selectionBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Custom Role',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Create a role and assign permissions.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Text Input
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            style: const TextStyle(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Role Title',
              hintText: 'e.g., Regional Coordinator, Event Lead',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              errorText: _errorText,
              prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.secondaryBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Actions
          PrimaryButton(
            label: 'Create Role',
            onPressed: _handleSubmit,
            leadingIcon: Icons.add_circle_outline_rounded,
          ),
        ],
      ),
    );
  }
}
