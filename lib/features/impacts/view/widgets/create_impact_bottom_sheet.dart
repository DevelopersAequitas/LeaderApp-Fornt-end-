import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';

class CreateImpactBottomSheet extends StatefulWidget {
  final Function({
    required String beneficiaryUserId,
    required String impactType,
    required String title,
    required String description,
  }) onSubmit;

  const CreateImpactBottomSheet({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    required Function({
      required String beneficiaryUserId,
      required String impactType,
      required String title,
      required String description,
    }) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateImpactBottomSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<CreateImpactBottomSheet> createState() => _CreateImpactBottomSheetState();
}

class _CreateImpactBottomSheetState extends State<CreateImpactBottomSheet> {
  final _beneficiaryController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedType = 'mentor';

  final List<String> _types = ['mentor', 'connect', 'guide', 'sponsor', 'other'];

  @override
  void dispose() {
    _beneficiaryController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final beneficiary = _beneficiaryController.text.trim();

    if (title.isEmpty || beneficiary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in required fields'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    widget.onSubmit(
      beneficiaryUserId: beneficiary,
      impactType: _selectedType,
      title: title,
      description: desc,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Record Life Impact',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _beneficiaryController,
              decoration: InputDecoration(
                labelText: 'Beneficiary Peer User ID *',
                hintText: 'Enter peer user UUID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Impact Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _types
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g. Business scaling mentorship',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Brief summary of impact provided...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Submit Impact',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
