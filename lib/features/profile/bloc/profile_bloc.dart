import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
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
    final mockProfile = UserProfileModel(
      name: session.name,
      phone: session.phone,
      email: session.email,
      regionalScope: session.regionalScope,
      memberSince: session.memberSince,
      capabilitiesCount: session.capabilitiesCount,
      managedCircleName: session.managedCircles.join(' & '),
      managedCirclePeers: session.role == UserRole.circleFounder ? 112 : 56,
      managedCircleStatus: 'Active',
    );

    emit(state.copyWith(isLoading: false, userProfile: mockProfile));
  }

  Future<void> _onTriggerSignOut(
    TriggerSignOut event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      // Simulate remote API call to clear session
      await Future.delayed(const Duration(milliseconds: 800));
      SessionManager().clearSession();
      emit(state.copyWith(isLoading: false, isSignedOut: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
