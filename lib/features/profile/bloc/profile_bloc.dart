import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/profile_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Business Logic Component for managing User Profile data and sign out.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfileData>(_onLoadProfileData);
    on<TriggerSignOut>(_onTriggerSignOut);
  }

  void _onLoadProfileData(LoadProfileData event, Emitter<ProfileState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final session = SessionManager().currentSession;
    final permissions = SessionManager().permissions;

    final enabledCaps = <String>[];
    if (permissions.canAccessDashboard) enabledCaps.add('Dashboard Analytics');
    if (permissions.canAccessPeersTab) enabledCaps.add('Peer Directory & Profiles');
    if (permissions.canSendWishes) enabledCaps.add('Peer Wishes & Celebrations');
    if (permissions.canAddEditPeer) enabledCaps.add('Add / Edit Peer Records');
    if (permissions.canAccessTeamsTab) enabledCaps.add('Circles & Teams Management');
    if (permissions.canManageCircles) enabledCaps.add('Circle Leadership Operations');
    if (permissions.canAssignCircleChair) enabledCaps.add('Assign Circle Chairs');
    if (permissions.canAccessFinanceTab) enabledCaps.add('Financial Analytics & Dues');
    if (permissions.canModifyFinanceSettings) enabledCaps.add('Financial Settings Control');
    if (permissions.canIssueCoins) enabledCaps.add('Coin Issuance & Rewards');
    if (permissions.canAccessReportsTab) enabledCaps.add('Reports & Attendance Analytics');
    if (permissions.canSubmitReports) enabledCaps.add('Submit Leadership Reports');
    if (permissions.canExportPeerData || permissions.canExportFinancialData) {
      enabledCaps.add('Export Analytics (PDF/Excel)');
    }
    if (permissions.canAccessRoleManagement) enabledCaps.add('Role & Permission Matrix Control');
    if (permissions.canViewRegionalScope) enabledCaps.add('Regional & National Scope');

    final roleLabel = session.customRoleLabel ?? session.role.label;

    final profile = UserProfileModel(
      id: session.id,
      name: session.name.isNotEmpty ? session.name : 'Leader',
      phone: session.phone.isNotEmpty ? session.phone : 'Not Provided',
      email: session.email.isNotEmpty ? session.email : 'No Email',
      roleLabel: roleLabel,
      regionalScope: session.regionalScope.isNotEmpty ? session.regionalScope : 'Assigned Scope',
      memberSince: session.memberSince.isNotEmpty ? session.memberSince : '2026',
      capabilitiesCount: enabledCaps.isNotEmpty ? enabledCaps.length : session.capabilitiesCount,
      managedCircles: session.managedCircles,
      enabledCapabilityNames: enabledCaps,
      avatarUrl: session.avatarUrl ?? '',
    );

    emit(state.copyWith(isLoading: false, userProfile: profile));
  }

  Future<void> _onTriggerSignOut(
    TriggerSignOut event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      await SessionManager().clearSession();
      emit(state.copyWith(isLoading: false, isSignedOut: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
