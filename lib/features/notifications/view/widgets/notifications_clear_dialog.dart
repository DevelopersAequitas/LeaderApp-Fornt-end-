import 'package:flutter/material.dart';

/// Confirmation dialog for clearing all notifications.
class NotificationsClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const NotificationsClearDialog({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, {required VoidCallback onConfirm}) {
    return showDialog(
      context: context,
      builder: (_) => NotificationsClearDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: const [
          Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
          SizedBox(width: 8),
          Text(
            'Clear All Notifications',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
      content: const Text(
        'Are you sure you want to clear your notification history? This action cannot be undone.',
        style: TextStyle(color: Color(0xFF5A6E85), fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF8B9CB4), fontWeight: FontWeight.w700),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text(
            'Clear All',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
