import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../model/profile_model.dart';
import '../presenter/profile_presenter.dart';
import 'widgets/edit_profile_bottom_sheet.dart';
import 'widgets/profile_app_version_tile.dart';
import 'widgets/profile_circulars_tile.dart';
import 'widgets/profile_contact_card.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_role_management_tile.dart';
import 'widgets/profile_sign_out_bottom_sheet.dart';

/// The View component of the Profile Screen feature.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> implements ProfileViewContract {
  late final ProfileBloc _bloc;
  late final ProfilePresenter _presenter;

  bool _isLoading = false;
  UserProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _bloc = ProfileBloc();
    _presenter = ProfilePresenter(view: this, bloc: _bloc);
    _presenter.load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- ProfileViewContract Implementations ---

  @override
  void onProfileLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onProfileLoaded() {
    setState(() {
      _isLoading = false;
      _profile = _bloc.state.userProfile;
    });
  }

  @override
  void onProfileError(String error) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void onSignedOut() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _showEditProfileModal(UserProfileModel profile) {
    EditProfileBottomSheet.show(
      context,
      profile: profile,
      onProfileUpdated: () {
        _presenter.load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onError: onProfileError,
    );
  }

  void _showSignOutBottomSheet() {
    ProfileSignOutBottomSheet.show(
      context,
      onConfirm: () => _presenter.signOut(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = SessionManager().currentRole == UserRole.superAdmin;

    return BlocProvider<ProfileBloc>.value(
      value: _bloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: const CustomAppBar(
            title: 'Leader Profile',
            showBackButton: true,
          ),
          body: _isLoading || _profile == null
              ? const CenteredLoadingIndicator(height: 300)
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileHeroCard(profile: _profile!),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileContactCard(
                              profile: _profile!,
                              onEditTap: () => _showEditProfileModal(_profile!),
                              canEdit: true,
                            ),
                            const SizedBox(height: 10),
                            const ProfileCircularsTile(),
                            if (isSuperAdmin) ...[
                              const SizedBox(height: 10),
                              const ProfileRoleManagementTile(),
                            ],
                            const SizedBox(height: 10),
                            const ProfileAppVersionTile(),
                            const SizedBox(height: 20),
                            // Refined Compact Sign Out Button
                            InkWell(
                              onTap: _showSignOutBottomSheet,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.danger.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout_rounded,
                                      size: 16,
                                      color: AppColors.danger,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Sign Out of Account',
                                      style: TextStyle(
                                        color: AppColors.danger,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
