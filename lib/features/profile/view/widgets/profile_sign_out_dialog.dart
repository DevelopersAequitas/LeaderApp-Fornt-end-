import 'package:flutter/material.dart';

/// Modal dialog confirming user sign out.
class ProfileSignOutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ProfileSignOutDialog({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, {required VoidCallback onConfirm}) {
    return showDialog(
      context: context,
      builder: (_) => ProfileSignOutDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: const [
          Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
          SizedBox(width: 8),
          Text(
            'Sign Out',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
      content: const Text(
        'Are you sure you want to sign out of your Leader Account?',
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
            'Sign Out',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
