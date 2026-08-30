import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../model/circular_model.dart';

/// Modal sheet for Super Admin and Directorate to publish role-targeted circulars.
class PublishCircularBottomSheet extends StatefulWidget {
  final ValueChanged<CircularModel> onPublish;

  const PublishCircularBottomSheet({super.key, required this.onPublish});

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<CircularModel> onPublish,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => PublishCircularBottomSheet(onPublish: onPublish),
    );
  }

  @override
  State<PublishCircularBottomSheet> createState() => _PublishCircularBottomSheetState();
}

class _PublishCircularBottomSheetState extends State<PublishCircularBottomSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedPriority = 'General';
  final List<String> _selectedRoles = ['all'];

  static const Map<String, String> _roleNames = {
    'all': 'All Leaders',
    'circleChair': 'Circle Chair',
    'circleFounder': 'Circle Founder',
    'circleDirector': 'Circle Director',
    'industryDirector': 'Industry Director',
    'districtExecDirector': 'District Exec Director',
    'countryDirector': 'Country Director',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handlePublish() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    final circular = CircularModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      targetRoles: List.from(_selectedRoles),
      priority: _selectedPriority,
      publishedAt: 'Just now',
      authorName: 'National Directorate',
      authorRole: 'Super Admin',
    );
    widget.onPublish(circular);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.selectionBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Publish Role-Wise Circular',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
                      ),
                      Text(
                        'Target critical announcements to leader roles',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.border),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Circular Title *',
                hintText: 'e.g. Q3 Leadership Summit Notice',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.secondaryBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 4,
              style: const TextStyle(fontSize: 13, color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Announcement Details *',
                hintText: 'Enter full circular description and instructions...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.secondaryBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Priority Level',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['General', 'Important', 'Urgent'].map((p) {
                final isSel = _selectedPriority == p;
                final activeColor = p == 'Urgent'
                    ? AppColors.danger
                    : (p == 'Important' ? AppColors.warningDark : AppColors.primary);

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedPriority = p),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSel ? activeColor : AppColors.secondaryBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel ? Colors.transparent : AppColors.border,
                          width: 1,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                          color: isSel ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            const Text(
              'Target Leader Roles',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _roleNames.entries.map((entry) {
                final roleKey = entry.key;
                final roleLabel = entry.value;
                final isSel = _selectedRoles.contains(roleKey);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (roleKey == 'all') {
                        _selectedRoles.clear();
                        _selectedRoles.add('all');
                      } else {
                        _selectedRoles.remove('all');
                        if (isSel) {
                          _selectedRoles.remove(roleKey);
                        } else {
                          _selectedRoles.add(roleKey);
                        }
                        if (_selectedRoles.isEmpty) _selectedRoles.add('all');
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : AppColors.secondaryBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? Colors.transparent : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSel) ...[
                          const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          roleLabel,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Broadcast Circular',
              onPressed: _handlePublish,
              leadingIcon: Icons.campaign_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
