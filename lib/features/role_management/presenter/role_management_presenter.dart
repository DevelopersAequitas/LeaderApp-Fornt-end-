import '../bloc/role_management_bloc.dart';
import '../bloc/role_management_event.dart';
import '../bloc/role_management_state.dart';

/// Contract interface defining role management view actions.
abstract class RoleManagementViewContract {
  /// Invoked when loading role-permissions list.
  void onRoleManagementLoading();

  /// Invoked when role-permissions list is loaded.
  void onRoleManagementLoaded();

  /// Invoked when saving or loading throws an error.
  void onRoleManagementError(String error);

  /// Invoked when save is in progress.
  void onRoleManagementSaving();

  /// Invoked when save finishes successfully.
  void onRoleManagementSaved();
}

/// Presenter coordinating presentation logic for Role Management screen.
class RoleManagementPresenter {
  /// View contract reference.
  final RoleManagementViewContract view;

  /// BLoC reference.
  final RoleManagementBloc bloc;

  RoleManagementPresenter({required this.view, required this.bloc});

  /// Relays data fetch trigger.
  void load() {
    bloc.add(const LoadRoleManagementData());
  }

  /// Relays capability toggle trigger.
  void toggleCapability(String roleId, String capabilityId) {
    bloc.add(ToggleCapability(roleId: roleId, capabilityId: capabilityId));
  }

  /// Relays add custom role trigger.
  void addRole(String label) {
    bloc.add(AddRole(label: label));
  }

  /// Relays edit custom role label trigger.
  void editRole(String roleId, String newLabel) {
    bloc.add(EditRole(roleId: roleId, newLabel: newLabel));
  }

  /// Relays delete custom role trigger.
  void deleteRole(String roleId) {
    bloc.add(DeleteRole(roleId: roleId));
  }

  /// Relays save changes trigger.
  void saveChanges() {
    bloc.add(const SaveChangesRequested());
  }

  /// Maps BLoC state changes back to view contract triggers.
  void handleStateChange(RoleManagementState state) {
    if (state.isLoading) {
      view.onRoleManagementLoading();
    } else {
      view.onRoleManagementLoaded();
    }

    if (state.isSaving) {
      view.onRoleManagementSaving();
    } else if (state.saveSuccess) {
      view.onRoleManagementSaved();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onRoleManagementError(state.errorMessage);
    }
  }
}
