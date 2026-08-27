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

  final List<String> _availableRoles = [
    'all',
    'circleChair',
    'circleFounder',
    'circleDirector',
    'industryDirector',
    'districtExecDirector',
    'countryDirector',
  ];

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
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Publish Role-Wise Circular',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
            ),
            const SizedBox(height: 4),
            const Text(
              'Target critical announcements directly to specific leader roles.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 13, color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Circular Title',
                filled: true,
                fillColor: AppColors.secondaryBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 4,
              style: const TextStyle(fontSize: 13, color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Announcement Details',
                filled: true,
                fillColor: AppColors.secondaryBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Priority Level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(
              children: ['General', 'Important', 'Urgent'].map((p) {
                final isSel = _selectedPriority == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(p, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.text)),
                    selected: isSel,
                    selectedColor: p == 'Urgent' ? AppColors.danger : AppColors.primary,
                    onSelected: (_) => setState(() => _selectedPriority = p),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Target Leader Roles', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: _availableRoles.map((r) {
                final isSel = _selectedRoles.contains(r);
                return FilterChip(
                  label: Text(r == 'all' ? 'All Roles' : r, style: const TextStyle(fontSize: 10)),
                  selected: isSel,
                  onSelected: (val) {
                    setState(() {
                      if (r == 'all') {
                        _selectedRoles.clear();
                        _selectedRoles.add('all');
                      } else {
                        _selectedRoles.remove('all');
                        if (val) {
                          _selectedRoles.add(r);
                        } else {
                          _selectedRoles.remove(r);
                        }
                        if (_selectedRoles.isEmpty) _selectedRoles.add('all');
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Broadcast Circular', onPressed: _handlePublish, leadingIcon: Icons.campaign_rounded),
          ],
        ),
      ),
    );
  }
}
