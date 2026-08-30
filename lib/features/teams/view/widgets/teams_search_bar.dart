import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Renders a compact, sleek search input field for filtering circles.
class TeamsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const TeamsSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF8B9CB4),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(fontSize: 13, color: AppColors.text),
                decoration: const InputDecoration(
                  hintText: 'Search circles by name, founder, city...',
                  hintStyle: TextStyle(
                    color: Color(0xFF8B9CB4),
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF8B9CB4),
                    size: 16,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
