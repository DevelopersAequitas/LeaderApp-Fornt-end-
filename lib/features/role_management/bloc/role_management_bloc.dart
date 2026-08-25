import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/role_matrix_repository.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/role_permission_model.dart';
import 'role_management_event.dart';
import 'role_management_state.dart';

/// Business Logic Component for managing application roles and permissions matrix via Clean Architecture.
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
    on<SaveChangesRequested>(_onSaveChangesRequested);
  }

  Future<void> _onLoadRoleManagementData(
    LoadRoleManagementData event,
    Emitter<RoleManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', saveSuccess: false));

    try {
      final response = await _roleMatrixRepository.getRoleMatrix();
      emit(
        state.copyWith(
          isLoading: false,
          rolesPermissions: response.data?.roles ?? const [],
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
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
        emit(state.copyWith(rolesPermissions: updatedList, saveSuccess: false));
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

      emit(state.copyWith(rolesPermissions: updatedList, saveSuccess: false));
    } catch (_) {}
  }

  Future<void> _onDeleteRole(DeleteRole event, Emitter<RoleManagementState> emit) async {
    try {
      await _roleMatrixRepository.deleteRole(event.roleId);
      final updatedList = state.rolesPermissions
          .where((rp) => rp.role.id != event.roleId)
          .toList();

      emit(state.copyWith(rolesPermissions: updatedList, saveSuccess: false));
    } catch (_) {}
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
      }
      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }
}
