import 'package:flutter/material.dart';
import '../model/role_permission_model.dart';

@immutable
class RoleManagementState {
  final bool isLoading;
  final List<RolePermissionModel> rolesPermissions;
  final bool isSaving;
  final String errorMessage;
  final bool saveSuccess;

  const RoleManagementState({
    this.isLoading = false,
    this.rolesPermissions = const [],
    this.isSaving = false,
    this.errorMessage = '',
    this.saveSuccess = false,
  });

  RoleManagementState copyWith({
    bool? isLoading,
    List<RolePermissionModel>? rolesPermissions,
    bool? isSaving,
    String? errorMessage,
    bool? saveSuccess,
  }) {
    return RoleManagementState(
      isLoading: isLoading ?? this.isLoading,
      rolesPermissions: rolesPermissions ?? this.rolesPermissions,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}
