import 'package:flutter/material.dart';

/// Data model representing a user role for auto-fill functionality on the sign-in screen.
class RoleModel {
  /// The user-facing name of the role (e.g. Circle Chair).
  final String title;

  /// Brief description of the role's permissions/responsibilities.
  final String description;

  /// The email address associated with the role for auto-fill.
  final String email;

  /// Icon representing this role visually.
  final IconData icon;

  /// Color background for the icon.
  final Color iconBgColor;

  /// Color for the icon itself.
  final Color iconColor;

  const RoleModel({
    required this.title,
    required this.description,
    required this.email,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}
