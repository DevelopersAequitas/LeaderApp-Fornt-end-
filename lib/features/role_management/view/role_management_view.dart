// ==============================================================================
// File: lib/features/role_management/view/role_management_view.dart
// Description: Dynamic Role Permissions, Security Matrix & Capability Governance
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Interactive role selector (Super Admin, Country Director, Circle Founder, Circle Chair, Area Director)
//   - Capability matrix organized by functional categories (Dashboard, Peers, Finance, Reports, Governance)
//   - Real-time permission toggle switches with unsaved changes detection
//   - Capability search filter and Category pill chips
//   - Custom role creation, role deletion, and bulk permission commit flows
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/role_management_bloc.dart';
import '../bloc/role_management_event.dart';
import '../bloc/role_management_state.dart';
import '../model/role_permission_model.dart';
import 'widgets/add_role_bottom_sheet.dart';
import 'widgets/capability_filter_bar.dart';
import 'widgets/role_category_section.dart';
import 'widgets/role_dialogs.dart';
import 'widgets/role_header_card.dart';
import 'widgets/role_save_bar.dart';
import 'widgets/role_selector_bar.dart';

/// The View component of the Role Management feature for Super Admin.
/// 100% Pure StatelessWidget powered by BLoC state machine.
class RoleManagementView extends StatelessWidget {
  const RoleManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoleManagementBloc>(
      create: (context) =>
          RoleManagementBloc()..add(const LoadRoleManagementData()),
      child: const _RoleManagementContent(),
    );
  }
}

class _RoleManagementContent extends StatelessWidget {
  const _RoleManagementContent();

  void _showAddRoleModal(BuildContext context) {
    final bloc = context.read<RoleManagementBloc>();
    AddRoleBottomSheet.show(
      context,
      onAdd: (name) => bloc.add(AddRole(label: name)),
    );
  }

  void _showEditRoleModal(
    BuildContext context,
    RolePermissionModel rolePermission,
  ) {
    final bloc = context.read<RoleManagementBloc>();
    RoleDialogs.showEditRoleDialog(
      context,
      role: rolePermission.role,
      onSave: (name) => bloc.add(
        EditRole(
          roleId: rolePermission.role.id,
          newLabel: name,
        ),
      ),
    );
  }

  void _showDeleteConfirmModal(
    BuildContext context,
    RolePermissionModel rolePermission,
  ) {
    final bloc = context.read<RoleManagementBloc>();
    RoleDialogs.showDeleteRoleDialog(
      context,
      role: rolePermission.role,
      onDelete: () =>
          bloc.add(DeleteRole(roleId: rolePermission.role.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RoleManagementBloc>();

    return BlocListener<RoleManagementBloc, RoleManagementState>(
      listenWhen: (prev, curr) =>
          (prev.errorMessage != curr.errorMessage &&
              curr.errorMessage.isNotEmpty) ||
          (prev.saveSuccess != curr.saveSuccess && curr.saveSuccess),
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        } else if (state.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissions matrix updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: BlocBuilder<RoleManagementBloc, RoleManagementState>(
        builder: (context, state) {
          if (state.isLoading && state.rolesPermissions.isEmpty) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: CustomAppBar(
                title: 'Role Permissions Matrix',
                subtitle: 'System Capability Governance',
                showBackButton: true,
              ),
              body: const CenteredLoadingIndicator(height: 300),
            );
          }

          final selectedRole = state.rolesPermissions.firstWhere(
            (r) => r.role.id == state.selectedRoleId,
            orElse: () => state.rolesPermissions.isNotEmpty
                ? state.rolesPermissions.first
                : const RolePermissionModel(
                    role: RoleModel(
                      id: '',
                      label: '',
                      isSystemRole: true,
                    ),
                    enabledCapabilityIds: [],
                  ),
          );

          final categories = <String>[
            'All',
            ...state.capabilities.map((c) => c.category).toSet(),
          ];

          final filteredCapabilities = state.capabilities.where((cap) {
            final matchesSearch = state.searchQuery.isEmpty ||
                cap.name
                    .toLowerCase()
                    .contains(state.searchQuery.toLowerCase()) ||
                cap.description
                    .toLowerCase()
                    .contains(state.searchQuery.toLowerCase());
            final matchesCategory = state.selectedCategory == 'All' ||
                cap.category == state.selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();

          final groupedByCategory = <String, List<AppCapability>>{};
          for (final cap in filteredCapabilities) {
            groupedByCategory.putIfAbsent(cap.category, () => []).add(cap);
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Role Permissions Matrix',
              subtitle: 'System Capability Governance',
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.add_moderator_outlined,
                    color: AppColors.text,
                    size: 22,
                  ),
                  tooltip: 'Create new custom role',
                  onPressed: () => _showAddRoleModal(context),
                ),
              ],
            ),
            body: Column(
              children: [
                // Horizontal Role Selector
                RoleSelectorBar(
                  rolesPermissions: state.rolesPermissions,
                  selectedRoleId: state.selectedRoleId,
                  onSelectRole: (id) => bloc.add(SelectRole(id)),
                  onAddRole: () => _showAddRoleModal(context),
                ),

                // Capability Search & Category Filters
                CapabilityFilterBar(
                  searchQuery: state.searchQuery,
                  selectedCategory: state.selectedCategory,
                  categories: categories,
                  onSearchChanged: (q) =>
                      bloc.add(SearchCapabilityQueryChanged(q)),
                  onCategorySelected: (cat) =>
                      bloc.add(SelectCapabilityCategory(cat)),
                ),

                // Role Header Card & Capabilities List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      RoleHeaderCard(
                        rolePermission: selectedRole,
                        totalCapabilities: state.capabilities.length,
                        onEdit: () =>
                            _showEditRoleModal(context, selectedRole),
                        onDelete: () =>
                            _showDeleteConfirmModal(context, selectedRole),
                        onToggleAll: (enable) {
                          bloc.add(
                            BulkToggleAllRoleCapabilities(
                              roleId: selectedRole.role.id,
                              allCapabilityIds:
                                  state.capabilities.map((c) => c.id).toList(),
                              enable: enable,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      if (groupedByCategory.isEmpty)
                        Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                color: AppColors.textSecondary,
                                size: 36,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No capabilities found matching your search query.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...groupedByCategory.entries.map((entry) {
                          return RoleCategorySection(
                            categoryName: entry.key,
                            capabilities: entry.value,
                            enabledCapabilityIds:
                                selectedRole.enabledCapabilityIds,
                            onToggleCapability: (capId) {
                              bloc.add(
                                ToggleCapability(
                                  roleId: selectedRole.role.id,
                                  capabilityId: capId,
                                ),
                              );
                            },
                            onToggleCategoryAll: (enable) {
                              bloc.add(
                                BulkToggleCategoryCapabilities(
                                  roleId: selectedRole.role.id,
                                  capabilityIds:
                                      entry.value.map((c) => c.id).toList(),
                                  enable: enable,
                                ),
                              );
                            },
                          );
                        }),
                    ],
                  ),
                ),

                // Save Bottom Bar
                RoleSaveBar(
                  isSaving: state.isSaving,
                  hasUnsavedChanges: state.hasUnsavedChanges,
                  onSave: () => bloc.add(const SaveChangesRequested()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
