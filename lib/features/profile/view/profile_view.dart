import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
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

  Widget _buildAppBar() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2E46), // Translucent dark blue card
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B9CB4),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF253B59),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              SessionManager().currentSession.name
                  .split(' ')
                  .map((n) => n[0])
                  .take(2)
                  .join()
                  .toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
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
                SessionManager().currentSession.role.label.toUpperCase(),
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
                child: _buildHeroStatCard(profile.regionalScope, 'SCOPE'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeroStatCard(
                  '${profile.capabilitiesCount}',
                  'PERMS',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildHeroStatCard(profile.memberSince, 'SINCE')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
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
        _buildAccountDetailRow(
          Icons.person_outline_rounded,
          'Full Name',
          profile.name,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        _buildAccountDetailRow(
          Icons.phone_outlined,
          'Mobile Phone',
          profile.phone,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        _buildAccountDetailRow(
          Icons.mail_outline_rounded,
          'Email Address',
          profile.email,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        _buildAccountDetailRow(
          Icons.map_outlined,
          'Regional Scope',
          profile.regionalScope,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        _buildAccountDetailRow(
          Icons.calendar_today_outlined,
          'Member Since',
          profile.memberSince,
        ),
        Divider(color: Colors.grey.shade100, height: 1),
        _buildAccountDetailRow(
          Icons.lock_outline_rounded,
          'Permissions Status',
          '${profile.capabilitiesCount} capabilities granted',
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
          final initials = circleName
              .split(' ')
              .map((w) => w[0])
              .join()
              .toUpperCase();
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isFounder
                          ? const Color(0xFF1B4D3E)
                          : const Color(0xFF102640),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
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

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _presenter.signOut(),
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
          size: 18,
        ),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: const Color(0xFFF9FAFC),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: _isLoading || _profile == null
                        ? const SizedBox(
                            height: 300,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
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
                                    _buildWarningCard(),
                                    const SizedBox(height: 24),
                                    _buildSignOutButton(),
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
