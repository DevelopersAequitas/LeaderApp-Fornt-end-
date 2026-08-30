import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../data/repositories/role_matrix_repository.dart';
import '../model/role_permission_model.dart';
import 'role_management_event.dart';
import 'role_management_state.dart';

/// Business Logic Component for managing application roles and permissions matrix from API.
class RoleManagementBloc extends Bloc<RoleManagementEvent, RoleManagementState> {
  final RoleMatrixRepository _roleMatrixRepository;

  RoleManagementBloc({RoleMatrixRepository? roleMatrixRepository})
      : _roleMatrixRepository = roleMatrixRepository ?? RoleMatrixRepositoryImpl(),
        super(const RoleManagementState()) {
    on<LoadRoleManagementData>(_onLoadRoleManagementData);
    on<ToggleCapability>(_onToggleCapability);
    on<AddRole>(_onAddRole);
    on<EditRole>(_onEditRole);
    on<DeleteRole>(_onDeleteRole);
    on<BulkToggleCategoryCapabilities>(_onBulkToggleCategoryCapabilities);
    on<BulkToggleAllRoleCapabilities>(_onBulkToggleAllRoleCapabilities);
    on<SaveChangesRequested>(_onSaveChangesRequested);
    on<SelectRole>(_onSelectRole);
    on<SearchCapabilityQueryChanged>(_onSearchCapabilityQueryChanged);
    on<SelectCapabilityCategory>(_onSelectCapabilityCategory);
  }

  Future<void> _onLoadRoleManagementData(
    LoadRoleManagementData event,
    Emitter<RoleManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', saveSuccess: false, hasUnsavedChanges: false));

    try {
      final response = await _roleMatrixRepository.getRoleMatrix();
      final roles = response.data?.roles ?? const [];
      final capabilities = response.data?.capabilities ?? const [];

      for (final rp in roles) {
        SessionManager().updateRoleCapabilitiesMatrix(
          rp.role.id,
          rp.enabledCapabilityIds,
        );
        SessionManager().updateRoleCapabilitiesMatrix(
          rp.role.label,
          rp.enabledCapabilityIds,
        );
        if (rp.role.roleKey != null && rp.role.roleKey!.isNotEmpty) {
          SessionManager().updateRoleCapabilitiesMatrix(
            rp.role.roleKey!,
            rp.enabledCapabilityIds,
          );
        }
      }
      emit(
        state.copyWith(
          isLoading: false,
          capabilities: capabilities,
          rolesPermissions: roles,
          selectedRoleId: roles.isNotEmpty ? roles.first.role.id : '',
          hasUnsavedChanges: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onSelectRole(
    SelectRole event,
    Emitter<RoleManagementState> emit,
  ) {
    emit(state.copyWith(selectedRoleId: event.roleId));
  }

  void _onSearchCapabilityQueryChanged(
    SearchCapabilityQueryChanged event,
    Emitter<RoleManagementState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSelectCapabilityCategory(
    SelectCapabilityCategory event,
    Emitter<RoleManagementState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
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

    emit(state.copyWith(
      rolesPermissions: updatedList,
      saveSuccess: false,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onAddRole(AddRole event, Emitter<RoleManagementState> emit) async {
    final trimLabel = event.label.trim();
    if (trimLabel.isEmpty) return;

    try {
      final response = await _roleMatrixRepository.createRole(
        label: trimLabel,
        enabledCapabilities: const ['access_dashboard', 'view_peers'],
      );

      if (response.data != null) {
        final updatedList = List<RolePermissionModel>.from(state.rolesPermissions)
          ..add(response.data!);
        SessionManager().addDynamicRole(trimLabel);
        emit(state.copyWith(
          rolesPermissions: updatedList,
          selectedRoleId: response.data!.role.id,
          saveSuccess: false,
          hasUnsavedChanges: true,
        ));
      }
    } catch (_) {}
  }

  Future<void> _onEditRole(EditRole event, Emitter<RoleManagementState> emit) async {
    final trimNewLabel = event.newLabel.trim();
    if (trimNewLabel.isEmpty) return;

    try {
      await _roleMatrixRepository.updateRole(event.roleId, label: trimNewLabel);
      final updatedList = state.rolesPermissions.map((rp) {
        if (rp.role.id == event.roleId) {
          return rp.copyWith(role: rp.role.copyWith(label: trimNewLabel));
        }
        return rp;
      }).toList();

      emit(state.copyWith(
        rolesPermissions: updatedList,
        saveSuccess: false,
        hasUnsavedChanges: true,
      ));
    } catch (_) {}
  }

  Future<void> _onDeleteRole(DeleteRole event, Emitter<RoleManagementState> emit) async {
    try {
      await _roleMatrixRepository.deleteRole(event.roleId);
      final updatedList = state.rolesPermissions
          .where((rp) => rp.role.id != event.roleId)
          .toList();

      final newSelectedId = state.selectedRoleId == event.roleId
          ? (updatedList.isNotEmpty ? updatedList.first.role.id : '')
          : state.selectedRoleId;

      emit(state.copyWith(
        rolesPermissions: updatedList,
        selectedRoleId: newSelectedId,
        saveSuccess: false,
        hasUnsavedChanges: true,
      ));
    } catch (_) {}
  }

  void _onBulkToggleCategoryCapabilities(
    BulkToggleCategoryCapabilities event,
    Emitter<RoleManagementState> emit,
  ) {
    final updatedList = state.rolesPermissions.map((rp) {
      if (rp.role.id == event.roleId) {
        final currentCapabilities = Set<String>.from(rp.enabledCapabilityIds);
        if (event.enable) {
          currentCapabilities.addAll(event.capabilityIds);
        } else {
          currentCapabilities.removeAll(event.capabilityIds);
        }
        return rp.copyWith(enabledCapabilityIds: currentCapabilities.toList());
      }
      return rp;
    }).toList();

    emit(state.copyWith(
      rolesPermissions: updatedList,
      saveSuccess: false,
      hasUnsavedChanges: true,
    ));
  }

  void _onBulkToggleAllRoleCapabilities(
    BulkToggleAllRoleCapabilities event,
    Emitter<RoleManagementState> emit,
  ) {
    final updatedList = state.rolesPermissions.map((rp) {
      if (rp.role.id == event.roleId) {
        final newCapabilities = event.enable ? List<String>.from(event.allCapabilityIds) : <String>[];
        return rp.copyWith(enabledCapabilityIds: newCapabilities);
      }
      return rp;
    }).toList();

    emit(state.copyWith(
      rolesPermissions: updatedList,
      saveSuccess: false,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onSaveChangesRequested(
    SaveChangesRequested event,
    Emitter<RoleManagementState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, errorMessage: '', saveSuccess: false));
    try {
      for (final rp in state.rolesPermissions) {
        await _roleMatrixRepository.updateRoleCapabilities(
          roleId: rp.role.id,
          enabledCapabilities: rp.enabledCapabilityIds,
        );
        SessionManager().updateRoleCapabilitiesMatrix(
          rp.role.id,
          rp.enabledCapabilityIds,
        );
        SessionManager().updateRoleCapabilitiesMatrix(
          rp.role.label,
          rp.enabledCapabilityIds,
        );
        if (rp.role.roleKey != null && rp.role.roleKey!.isNotEmpty) {
          SessionManager().updateRoleCapabilitiesMatrix(
            rp.role.roleKey!,
            rp.enabledCapabilityIds,
          );
        }
      }
      emit(state.copyWith(isSaving: false, saveSuccess: true, hasUnsavedChanges: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }
}
