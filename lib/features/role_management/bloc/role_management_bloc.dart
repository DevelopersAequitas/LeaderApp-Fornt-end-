import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/role_permission_model.dart';
import 'role_management_event.dart';
import 'role_management_state.dart';

/// Business Logic Component for managing application roles and permissions matrix.
class RoleManagementBloc extends Bloc<RoleManagementEvent, RoleManagementState> {
  RoleManagementBloc() : super(const RoleManagementState()) {
    on<LoadRoleManagementData>(_onLoadRoleManagementData);
    on<ToggleCapability>(_onToggleCapability);
    on<AddRole>(_onAddRole);
    on<EditRole>(_onEditRole);
    on<DeleteRole>(_onDeleteRole);
    on<SaveChangesRequested>(_onSaveChangesRequested);
  }

  void _onLoadRoleManagementData(
    LoadRoleManagementData event,
    Emitter<RoleManagementState> emit,
  ) {
    emit(state.copyWith(isLoading: true, errorMessage: '', saveSuccess: false));

    // Seed default permissions for system roles (excluding Super Admin).
    final seededPermissions = <RolePermissionModel>[
      const RolePermissionModel(
        role: RoleModel(
          id: 'circleChair',
          label: 'Circle Chair',
          isSystemRole: true,
        ),
        enabledCapabilityIds: [
          'access_dashboard',
          'access_teams',
          'view_peers',
          'request_actions',
        ],
      ),
      const RolePermissionModel(
        role: RoleModel(
          id: 'circleFounder',
          label: 'Circle Founder',
          isSystemRole: true,
        ),
        enabledCapabilityIds: [
          'access_dashboard',
          'access_teams',
          'view_peers',
          'request_actions',
          'view_reports',
        ],
      ),
      const RolePermissionModel(
        role: RoleModel(
          id: 'circleDirector',
          label: 'Circle Director',
          isSystemRole: true,
        ),
        enabledCapabilityIds: [
          'access_dashboard',
          'access_teams',
          'view_peers',
          'request_actions',
          'view_reports',
        ],
      ),
      const RolePermissionModel(
        role: RoleModel(
          id: 'industryDirector',
          label: 'Industry Director',
          isSystemRole: true,
        ),
        enabledCapabilityIds: [
          'access_dashboard',
          'access_teams',
          'view_peers',
          'request_actions',
          'view_reports',
          'regional_data',
        ],
      ),
      const RolePermissionModel(
        role: RoleModel(
          id: 'districtExecDirector',
          label: 'District Exec Director',
          isSystemRole: true,
        ),
        enabledCapabilityIds: [
          'access_dashboard',
          'access_teams',
          'view_peers',
          'request_actions',
          'view_reports',
          'regional_data',
        ],
      ),
      const RolePermissionModel(
        role: RoleModel(
          id: 'countryDirector',
          label: 'Country Director',
          isSystemRole: true,
        ),
        enabledCapabilityIds: [
          'access_dashboard',
          'access_teams',
          'view_peers',
          'request_actions',
          'view_reports',
          'regional_data',
          'access_finance',
        ],
      ),
    ];

    emit(state.copyWith(isLoading: false, rolesPermissions: seededPermissions));
  }

  void _onToggleCapability(
    ToggleCapability event,
    Emitter<RoleManagementState> emit,
  ) {
    final updatedList = state.rolesPermissions.map((rp) {
      if (rp.role.id == event.roleId) {
        final currentCapabilities = List<String>.from(rp.enabledCapabilityIds);
        if (currentCapabilities.contains(event.capabilityId)) {
          currentCapabilities.remove(event.capabilityId);
        } else {
          currentCapabilities.add(event.capabilityId);
        }
        return rp.copyWith(enabledCapabilityIds: currentCapabilities);
      }
      return rp;
    }).toList();

    emit(state.copyWith(rolesPermissions: updatedList, saveSuccess: false));
  }

  void _onAddRole(AddRole event, Emitter<RoleManagementState> emit) {
    final trimLabel = event.label.trim();
    if (trimLabel.isEmpty) return;
    final uniqueId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final newRole = RoleModel(
      id: uniqueId,
      label: trimLabel,
      isSystemRole: true,
    );

    final newPermissionMap = RolePermissionModel(
      role: newRole,
      enabledCapabilityIds: const ['access_dashboard', 'view_peers'], // default rights
    );

    final updatedList = List<RolePermissionModel>.from(state.rolesPermissions)
      ..add(newPermissionMap);

    SessionManager().addDynamicRole(trimLabel);

    emit(state.copyWith(rolesPermissions: updatedList, saveSuccess: false));
  }

  void _onEditRole(EditRole event, Emitter<RoleManagementState> emit) {
    String oldLabel = '';
    for (final rp in state.rolesPermissions) {
      if (rp.role.id == event.roleId) {
        oldLabel = rp.role.label;
        break;
      }
    }

    final trimNewLabel = event.newLabel.trim();
    if (oldLabel.isNotEmpty && trimNewLabel.isNotEmpty) {
      SessionManager().renameDynamicRole(oldLabel, trimNewLabel);
    }

    final updatedList = state.rolesPermissions.map((rp) {
      if (rp.role.id == event.roleId) {
        return rp.copyWith(role: rp.role.copyWith(label: trimNewLabel));
      }
      return rp;
    }).toList();

    emit(state.copyWith(rolesPermissions: updatedList, saveSuccess: false));
  }

  void _onDeleteRole(DeleteRole event, Emitter<RoleManagementState> emit) {
    String label = '';
    for (final rp in state.rolesPermissions) {
      if (rp.role.id == event.roleId) {
        label = rp.role.label;
        break;
      }
    }

    if (label.isNotEmpty) {
      SessionManager().removeDynamicRole(label);
    }

    final updatedList = state.rolesPermissions
        .where((rp) => rp.role.id != event.roleId)
        .toList();

    emit(state.copyWith(rolesPermissions: updatedList, saveSuccess: false));
  }

  Future<void> _onSaveChangesRequested(
    SaveChangesRequested event,
    Emitter<RoleManagementState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, errorMessage: '', saveSuccess: false));
    try {
      // Simulate remote API call to persist settings
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }
}
