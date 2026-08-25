import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../model/profile_model.dart';
import '../presenter/profile_presenter.dart';

/// The View component of the Profile Screen feature.
/// Renders user details, managed circles list, warning banners, and session controls.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    implements ProfileViewContract {
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
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void onSignedOut() {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully signed out.'),
        backgroundColor: Colors.green,
      ),
    );
    // Pop all routes and push login screen
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  // --- UI Widget Helpers ---

  Widget _buildHeroSection(UserProfileModel profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF102640),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          // SM Initials Badge
          InitialsAvatar(
            name: SessionManager().currentSession.name,
            radius: 40,
            backgroundColor: const Color(0xFF253B59),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
            fontSize: 28,
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          // Role & Email Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (SessionManager().currentSession.customRoleLabel ??
                        SessionManager().currentSession.role.label)
                    .toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF4CAF50), // Design match green
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                profile.email,
                style: const TextStyle(
                  color: Color(0xFF8B9CB4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Quick Stats cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: profile.regionalScope,
                  label: 'SCOPE',
                  backgroundColor: const Color(0xFF1B2E46),
                  valueFontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  value: '${profile.capabilitiesCount}',
                  label: 'PERMS',
                  backgroundColor: const Color(0xFF1B2E46),
                  valueFontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  value: profile.memberSince,
                  label: 'SINCE',
                  backgroundColor: const Color(0xFF1B2E46),
                  valueFontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails(UserProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ACCOUNT DETAILS',
          style: TextStyle(
            color: Color(0xFF8B9CB4),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        DetailRow(
          icon: Icons.person_outline_rounded,
          label: 'Full Name',
          value: profile.name,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        DetailRow(
          icon: Icons.phone_outlined,
          label: 'Mobile Phone',
          value: profile.phone,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        DetailRow(
          icon: Icons.mail_outline_rounded,
          label: 'Email Address',
          value: profile.email,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        DetailRow(
          icon: Icons.map_outlined,
          label: 'Regional Scope',
          value: profile.regionalScope,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        DetailRow(
          icon: Icons.calendar_today_outlined,
          label: 'Member Since',
          value: profile.memberSince,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        DetailRow(
          icon: Icons.lock_outline_rounded,
          label: 'Permissions Status',
          value: '${profile.capabilitiesCount} capabilities granted',
        ),
      ],
    );
  }

  Widget _buildCirclesManaged(UserProfileModel profile) {
    final circles = SessionManager().currentSession.managedCircles;
    final isFounder = SessionManager().currentRole == UserRole.circleFounder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Circles Managed',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...circles.map((circleName) {
          final String location = circleName.contains('Mumbai')
              ? 'Mumbai'
              : 'Bengaluru';
          final int peersCount = circleName.contains('Mumbai') ? 56 : 56;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDEFF3)),
              ),
              child: Row(
                children: [
                  InitialsAvatar(
                    name: circleName,
                    radius: 22,
                    backgroundColor: isFounder
                        ? const Color(0xFF1B4D3E)
                        : const Color(0xFF102640),
                    borderRadius: BorderRadius.circular(12),
                    fontSize: 13,
                  ),
                  const SizedBox(width: 12),
                  // Circle Metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          circleName,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$location · $peersCount peers',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Active status pill
                  StatusPill.active(label: 'Active'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAssignedIndustriesSection() {
    final industries = const ['Technology', 'Healthcare', 'Startups'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Assigned Industries',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: industries.map((ind) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF2FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ind,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Profile details are read-only. Contact your coordinator to modify platform settings.',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleManagementTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.roleManagement),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role Management Matrix',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Control capabilities & permissions across all roles',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>.value(
      value: _bloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          body: Column(
            children: [
              const CustomAppBar(
                title: 'Profile',
                showBackButton: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: const Color(0xFFF9FAFC),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: _isLoading || _profile == null
                        ? const CenteredLoadingIndicator(height: 300)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeroSection(_profile!),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildAccountDetails(_profile!),
                                    const SizedBox(height: 28),
                                    if (SessionManager().currentRole ==
                                        UserRole.industryDirector)
                                      _buildAssignedIndustriesSection()
                                    else
                                      _buildCirclesManaged(_profile!),
                                    const SizedBox(height: 28),
                                    if (SessionManager().currentRole ==
                                        UserRole.superAdmin)
                                      _buildRoleManagementTile(),
                                    _buildWarningCard(),
                                    const SizedBox(height: 24),
                                    PrimaryButton(
                                      label: 'Sign Out',
                                      onPressed: () => _presenter.signOut(),
                                      isOutlined: true,
                                      color: Colors.redAccent,
                                      leadingIcon: Icons.logout_rounded,
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
