// ==============================================================================
// File: lib/features/profile/view/profile_view.dart
// Description: Executive Profile Settings, Identity Hub & Account Governance
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Matches Peers Global Unity Profile Screen layout & visual design system.
// Features:
//   - Modern white surface header card with cover banner, overlapping avatar (68px),
//     full name (uppercase), role pill, designation & company, category gradient mask,
//     and regional scope.
//   - Contact & executive bio card with unified border styling.
//   - Assigned circles & territory assignment card.
//   - Role-gated administration tiles: Role Management Matrix and Official Circulars.
//   - Outlined secure sign-out action button.
//   - Note: Edit buttons and role metrics are commented out per user request.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../model/profile_model.dart';
import 'widgets/edit_profile_bottom_sheet.dart';
import 'widgets/profile_assigned_circles_card.dart';
import 'widgets/profile_milestones_card.dart';
import 'widgets/profile_circulars_tile.dart';
import 'widgets/profile_contact_card.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_role_management_tile.dart';
import 'widgets/profile_shimmer_skeleton.dart';
import 'widgets/profile_sign_out_bottom_sheet.dart';

/// The View component of the Profile Screen feature.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc()..add(const LoadProfileData()),
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  // Preserved for future profile editing invocation:
  // ignore: unused_element
  void _showEditProfileModal(BuildContext context, UserProfileModel profile) {
    final bloc = context.read<ProfileBloc>();
    EditProfileBottomSheet.show(
      context,
      profile: profile,
      onProfileUpdated: () {
        bloc.add(const LoadProfileData());
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.danger),
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    ProfileSignOutBottomSheet.show(
      context,
      onConfirm: () {
        bloc.add(const TriggerSignOut());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    final session = SessionManager().currentSession;
    final isSuperAdmin = session.role == UserRole.superAdmin;
    final isCountryDirector = session.role == UserRole.countryDirector;
    final canManageRoles = isSuperAdmin || isCountryDirector;

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
          (prev.errorMessage != curr.errorMessage &&
              curr.errorMessage.isNotEmpty) ||
          (prev.isSignedOut != curr.isSignedOut && curr.isSignedOut),
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        } else if (state.isSignedOut) {
          SessionManager().clearSession();
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final profile = state.userProfile;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const CustomAppBar(
              title: 'My Profile',
              showBackButton: true,
              // =========================================================================
              // Edit button in AppBar - Commented out per user request
              // =========================================================================
              // actions: [
              //   if (profile != null)
              //     IconButton(
              //       icon: const GradientIcon(
              //         icon: Icons.edit_outlined,
              //         size: 20,
              //         gradient: AppColors.brandGradient,
              //       ),
              //       onPressed: () => _showEditProfileModal(context, profile),
              //     ),
              // ],
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && profile == null
                  ? const ProfileSkeleton()
                  : RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(const LoadProfileData());
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (profile != null) ...[
                              // 1. Header Card (Cover banner + Avatar + Info)
                              ProfileHeroCard(profile: profile),
                              const SizedBox(height: 4),

                              // =========================================================================
                              // 2. Role Metrics Section - Commented out per user request
                              // =========================================================================
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16),
                              //   child: ProfileRoleMetricsCard(profile: profile),
                              // ),
                              // const SizedBox(height: 10),

                              // 3. Contact & Executive Bio Card
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: ProfileContactCard(
                                  profile: profile,
                                  onEditTap: () => {},
                                  canEdit: false, // Edit button disabled per user request
                                ),
                              ),
                              const SizedBox(height: 10),

                              // 4. Assigned Circles & Territory Card
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: ProfileAssignedCirclesCard(
                                  profile: profile,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // 5. Leadership Milestones & Performance Rewards (Role-wise)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: ProfileMilestonesCard(
                                  milestones: state.milestones,
                                  isApplicable: state.isApplicableForMilestones,
                                  totalEarnedBonuses: state.totalEarnedBonuses,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),

                            // 5. Governance & Administrative Tiles
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  if (canManageRoles) ...[
                                    const ProfileRoleManagementTile(),
                                    const SizedBox(height: 8),
                                  ],
                                  const ProfileCircularsTile(),
                                  const SizedBox(height: 16),

                                  // Sign Out Button
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _showSignOutDialog(context),
                                      icon: const Icon(
                                        Icons.logout_rounded,
                                        color: AppColors.danger,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Sign Out from Account',
                                        style: TextStyle(
                                          color: AppColors.danger,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppColors.dangerBorder,
                                        ),
                                        backgroundColor: AppColors.dangerBg,
                                        minimumSize: const Size(
                                          double.infinity,
                                          44,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
