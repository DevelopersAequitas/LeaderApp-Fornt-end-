import 'package:flutter/material.dart';

@immutable
abstract class RoleManagementEvent {
  const RoleManagementEvent();
}

/// Triggers loading of all roles and their mapped permissions.
class LoadRoleManagementData extends RoleManagementEvent {
  const LoadRoleManagementData();
}

/// Triggers toggling of a capability for a target role.
class ToggleCapability extends RoleManagementEvent {
  final String roleId;
  final String capabilityId;

  const ToggleCapability({
    required this.roleId,
    required this.capabilityId,
  });
}

/// Triggers adding a new custom role with default permissions.
class AddRole extends RoleManagementEvent {
  final String label;

  const AddRole({required this.label});
}

/// Triggers editing the name of a custom role.
class EditRole extends RoleManagementEvent {
  final String roleId;
  final String newLabel;

  const EditRole({
    required this.roleId,
    required this.newLabel,
  });
}

/// Triggers deleting a custom role.
class DeleteRole extends RoleManagementEvent {
  final String roleId;

  const DeleteRole({required this.roleId});
}

/// Triggers saving changes to backend/local session simulation.
class SaveChangesRequested extends RoleManagementEvent {
  const SaveChangesRequested();
}
