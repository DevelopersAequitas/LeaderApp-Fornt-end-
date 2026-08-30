import 'package:flutter/material.dart';
import '../model/role_permission_model.dart';

@immutable
class RoleManagementState {
  final bool isLoading;
  final List<AppCapability> capabilities;
  final List<RolePermissionModel> rolesPermissions;
  final bool isSaving;
  final String errorMessage;
  final bool saveSuccess;
  final bool hasUnsavedChanges;
  final String selectedRoleId;
  final String searchQuery;
  final String selectedCategory;

  const RoleManagementState({
    this.isLoading = false,
    this.capabilities = const [],
    this.rolesPermissions = const [],
    this.isSaving = false,
    this.errorMessage = '',
    this.saveSuccess = false,
    this.hasUnsavedChanges = false,
    this.selectedRoleId = '',
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  RoleManagementState copyWith({
    bool? isLoading,
    List<AppCapability>? capabilities,
    List<RolePermissionModel>? rolesPermissions,
    bool? isSaving,
    String? errorMessage,
    bool? saveSuccess,
    bool? hasUnsavedChanges,
    String? selectedRoleId,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return RoleManagementState(
      isLoading: isLoading ?? this.isLoading,
      capabilities: capabilities ?? this.capabilities,
      rolesPermissions: rolesPermissions ?? this.rolesPermissions,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      selectedRoleId: selectedRoleId ?? this.selectedRoleId,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
