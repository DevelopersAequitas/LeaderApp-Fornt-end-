import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/network/api_client.dart';
import '../model/profile_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Business Logic Component for managing User Profile data and sign out.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfileData>(_onLoadProfileData);
    on<TriggerSignOut>(_onTriggerSignOut);
  }

  Future<void> _onLoadProfileData(LoadProfileData event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    // 1. Fetch fresh profile and dynamic permissions from GET /api/v1/leader/profile
    try {
      final response = await ApiClient().get<Map<String, dynamic>>(
        ApiEndpoints.profile,
        fromJsonT: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
      );
      if (response.data != null && response.data!.isNotEmpty) {
        await SessionManager().updateFromAuthProfile(response.data!);
      }
    } catch (_) {}

    final session = SessionManager().currentSession;
    final currentRole = session.role;
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
      firstName: session.firstName,
      lastName: session.lastName,
      phone: session.phone.isNotEmpty ? session.phone : 'Not Provided',
      email: session.email.isNotEmpty ? session.email : 'No Email',
      companyName: session.companyName,
      company: session.company,
      city: session.city,
      location: session.location,
      designation: session.designation,
      businessCategory: session.businessCategory,
      industry: session.industry,
      level4Category: session.level4Category,
      profilePhotoUrl: session.profilePhotoUrl ?? session.avatarUrl ?? '',
      avatarUrl: session.avatarUrl ?? session.profilePhotoUrl ?? '',
      lifeImpact: session.lifeImpact,
      role: session.role.name,
      customRoleLabel: session.customRoleLabel ?? '',
      roleLabel: roleLabel,
      regionalScope: session.regionalScope.isNotEmpty ? session.regionalScope : 'Assigned Scope',
      memberSince: session.memberSince.isNotEmpty ? session.memberSince : '2026',
      capabilitiesCount: enabledCaps.isNotEmpty ? enabledCaps.length : session.capabilitiesCount,
      managedCircles: session.managedCircles,
      enabledCapabilityNames: enabledCaps,
    );

    // Leadership roles (CD, CF, CHAIR, DED, ID, etc.) are applicable for milestones by default,
    // while Super Admin manages milestone policy and has no personal commissions/bonuses.
    final isSuperAdmin = currentRole == UserRole.superAdmin;
    bool isApplicable = !isSuperAdmin;
    List<LeaderMilestoneItemModel> milestonesList = [];
    String totalBonuses = '₹0';

    try {
      final milestoneRes = await ApiClient().get<Map<String, dynamic>>(
        ApiEndpoints.leaderMilestones,
        fromJsonT: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
      );
      if (milestoneRes.data != null) {
        final data = milestoneRes.data!;
        // Super admin decision overrides default eligibility
        if (data.containsKey('is_applicable')) {
          isApplicable = data['is_applicable'] == true;
        }
        totalBonuses = data['total_earned_bonuses']?.toString() ?? '₹0';
        final rawMilestones = (data['milestones'] is Map ? data['milestones']['bonus_rules'] : null) ??
            (data['milestones'] is List ? data['milestones'] : null) ??
            (data['bonus_rules'] is List ? data['bonus_rules'] : null) ??
            (data['awards'] is List ? data['awards'] : null) ??
            (data['catalog'] is List ? data['catalog'] : null);
        if (rawMilestones is List) {
          milestonesList = rawMilestones
              .whereType<Map<String, dynamic>>()
              .map((m) => LeaderMilestoneItemModel.fromJson(m))
              .toList();
        }
      }
    } catch (_) {}

    // Fallback: If role is eligible and milestones list is empty (e.g. backend sync or offline),
    // provide the role-specific active milestones catalog so Circle Directors and other leaders
    // always see their performance goals and rewards.
    if (isApplicable && milestonesList.isEmpty && !isSuperAdmin) {
      milestonesList = _getDefaultMilestonesForRole(currentRole);
    }

    emit(state.copyWith(
      isLoading: false,
      userProfile: profile,
      milestones: milestonesList,
      isApplicableForMilestones: isApplicable,
      totalEarnedBonuses: totalBonuses,
    ));
  }

  /// Default active milestones catalog tailored per leadership role.
  static List<LeaderMilestoneItemModel> _getDefaultMilestonesForRole(UserRole? role) {
    if (role == UserRole.circleDirector) {
      return const [
        LeaderMilestoneItemModel(
          id: 'cd_speed_10m_20d',
          ruleCode: 'SPEED_10M_20D',
          title: '10 new Peers in 20 days',
          description: 'Onboard 10 new paid Peers within 20 days of tenure start.',
          category: 'speed_bonus',
          currentMetricValue: 0,
          targetMetricValue: 10,
          progressPercentage: 0,
          bonusAmountInr: 10000,
          status: 'in_progress',
          isAchieved: false,
          timeframeDays: 20,
        ),
        LeaderMilestoneItemModel(
          id: 'cd_speed_10m_10d',
          ruleCode: 'CD_SPEED_10M_10D',
          title: '10 new Peers in 10 days',
          description: 'Fast-track speed bonus: 10 new paid Peers within 10 days.',
          category: 'speed_bonus',
          currentMetricValue: 0,
          targetMetricValue: 10,
          progressPercentage: 0,
          bonusAmountInr: 25000,
          status: 'in_progress',
          isAchieved: false,
          timeframeDays: 10,
        ),
        LeaderMilestoneItemModel(
          id: 'cd_scale_50m_90d',
          ruleCode: 'CD_SCALE_50M_90D',
          title: '50 Active Circle Members',
          description: 'Reach 50 active paid peers in circle within 90 days.',
          category: 'growth_milestone',
          currentMetricValue: 0,
          targetMetricValue: 50,
          progressPercentage: 0,
          bonusAmountInr: 25000,
          status: 'in_progress',
          isAchieved: false,
          timeframeDays: 90,
        ),
        LeaderMilestoneItemModel(
          id: 'cd_scale_100m_180d',
          ruleCode: 'CD_SCALE_100M_180D',
          title: '100 Active Circle Members',
          description: 'Reach 100 active paid peers in circle within 180-day tenure window.',
          category: 'growth_milestone',
          currentMetricValue: 0,
          targetMetricValue: 100,
          progressPercentage: 0,
          bonusAmountInr: 50000,
          status: 'in_progress',
          isAchieved: false,
          timeframeDays: 180,
        ),
      ];
    } else if (role == UserRole.circleFounder) {
      return const [
        LeaderMilestoneItemModel(
          id: 'cf_speed_10m_20d',
          ruleCode: 'SPEED_10M_20D',
          title: '10 new Peers in 20 days',
          description: 'Bring 10 new paid Peers within 20 days of tenure activation.',
          category: 'speed_bonus',
          currentMetricValue: 0,
          targetMetricValue: 10,
          progressPercentage: 0,
          bonusAmountInr: 10000,
          status: 'in_progress',
          isAchieved: false,
          timeframeDays: 20,
        ),
        LeaderMilestoneItemModel(
          id: 'cf_speed_30m_40d',
          ruleCode: 'CF_SPEED_30M_40D',
          title: '30 members in 40 days',
          description: 'Momentum bonus: 30 paid members within 40 days.',
          category: 'speed_bonus',
          currentMetricValue: 0,
          targetMetricValue: 30,
          progressPercentage: 0,
          bonusAmountInr: 25000,
          status: 'in_progress',
          isAchieved: false,
          timeframeDays: 40,
        ),
        LeaderMilestoneItemModel(
          id: 'cf_speed_50m_75d',
          ruleCode: 'CF_SPEED_50M_75D',
          title: '50 members in 75 days',
          description: 'Founder milestone: 50 paid members within 75 days.',
          category: 'growth_milestone',
          currentMetricValue: 0,
          targetMetricValue: 50,
          progressPercentage: 0,
          bonusAmountInr: 50000,
          rewardPerks: 'Founder Dinner / Retreat',
          status: 'in_progress',
          isAchieved: false,
          timeframeDays: 75,
        ),
      ];
    } else if (role == UserRole.districtExecDirector || role == UserRole.countryDirector) {
      return const [
        LeaderMilestoneItemModel(
          id: 'ded_district_scale_3c',
          ruleCode: 'DED_LAUNCH_3C_90D',
          title: '3 Active Circles Launched',
          description: 'Supervise and activate 3 thriving circles within 90 days.',
          category: 'circle_launch_bonus',
          currentMetricValue: 0,
          targetMetricValue: 3,
          progressPercentage: 0,
          bonusAmountInr: 30000,
          status: 'in_progress',
          isAchieved: false,
          timeframeDays: 90,
        ),
      ];
    } else if (role != null && role.isChair) {
      return const [
        LeaderMilestoneItemModel(
          id: 'chair_growth_25m',
          ruleCode: 'CHAIR_GROWTH_25M_60D',
          title: '25 Committee Attributed Peers',
          description: 'Drive 25 new paid peers through committee activities within 60 days.',
          category: 'growth_milestone',
          currentMetricValue: 0,
          targetMetricValue: 25,
          progressPercentage: 0,
          bonusAmountInr: 15000,
          status: 'in_progress',
          isAchieved: false,
          timeframeDays: 60,
        ),
      ];
    }
    return const [];
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
