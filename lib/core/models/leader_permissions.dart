/// Data model encapsulating the 21-flag frontend permission matrix
/// automatically resolved by the backend Dynamic RBAC engine.
class LeaderPermissions {
  final bool canAccessDashboard;
  final bool canViewOverallRevenue;
  final bool canReviewPendingPeers;
  final bool canAccessPeersTab;
  final bool canAddEditPeer;
  final bool canSendWishes;
  final bool canViewPeerProfile;
  final bool canViewPeerContactInfo;
  final bool canAccessTeamsTab;
  final bool canManageCircles;
  final bool canAssignCircleChair;
  final bool canAccessFinanceTab;
  final bool canModifyFinanceSettings;
  final bool canIssueCoins;
  final bool canAccessReportsTab;
  final bool canSubmitReports;
  final bool canExportPeerData;
  final bool canExportFinancialData;
  final bool canExportGlobalData;
  final bool canAccessRoleManagement;
  final bool canViewRegionalScope;

  const LeaderPermissions({
    this.canAccessDashboard = true,
    this.canViewOverallRevenue = false,
    this.canReviewPendingPeers = true,
    this.canAccessPeersTab = true,
    this.canAddEditPeer = false,
    this.canSendWishes = true,
    this.canViewPeerProfile = true,
    this.canViewPeerContactInfo = true,
    this.canAccessTeamsTab = false,
    this.canManageCircles = false,
    this.canAssignCircleChair = false,
    this.canAccessFinanceTab = false,
    this.canModifyFinanceSettings = false,
    this.canIssueCoins = false,
    this.canAccessReportsTab = true,
    this.canSubmitReports = true,
    this.canExportPeerData = false,
    this.canExportFinancialData = false,
    this.canExportGlobalData = false,
    this.canAccessRoleManagement = false,
    this.canViewRegionalScope = false,
  });

  factory LeaderPermissions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LeaderPermissions();
    return LeaderPermissions(
      canAccessDashboard: json['can_access_dashboard'] as bool? ?? true,
      canViewOverallRevenue: json['can_view_overall_revenue'] as bool? ?? false,
      canReviewPendingPeers: json['can_review_pending_peers'] as bool? ?? true,
      canAccessPeersTab: json['can_access_peers_tab'] as bool? ?? true,
      canAddEditPeer: json['can_add_edit_peer'] as bool? ?? false,
      canSendWishes: json['can_send_wishes'] as bool? ?? true,
      canViewPeerProfile: json['can_view_peer_profile'] as bool? ?? true,
      canViewPeerContactInfo: json['can_view_peer_contact_info'] as bool? ?? true,
      canAccessTeamsTab: json['can_access_teams_tab'] as bool? ?? false,
      canManageCircles: json['can_manage_circles'] as bool? ?? false,
      canAssignCircleChair: json['can_assign_circle_chair'] as bool? ?? false,
      canAccessFinanceTab: json['can_access_finance_tab'] as bool? ?? false,
      canModifyFinanceSettings: json['can_modify_finance_settings'] as bool? ?? false,
      canIssueCoins: json['can_issue_coins'] as bool? ?? false,
      canAccessReportsTab: json['can_access_reports_tab'] as bool? ?? true,
      canSubmitReports: json['can_submit_reports'] as bool? ?? true,
      canExportPeerData: json['can_export_peer_data'] as bool? ?? false,
      canExportFinancialData: json['can_export_financial_data'] as bool? ?? false,
      canExportGlobalData: json['can_export_global_data'] as bool? ?? false,
      canAccessRoleManagement: json['can_access_role_management'] as bool? ?? false,
      canViewRegionalScope: json['can_view_regional_scope'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'can_access_dashboard': canAccessDashboard,
        'can_view_overall_revenue': canViewOverallRevenue,
        'can_review_pending_peers': canReviewPendingPeers,
        'can_access_peers_tab': canAccessPeersTab,
        'can_add_edit_peer': canAddEditPeer,
        'can_send_wishes': canSendWishes,
        'can_view_peer_profile': canViewPeerProfile,
        'can_view_peer_contact_info': canViewPeerContactInfo,
        'can_access_teams_tab': canAccessTeamsTab,
        'can_manage_circles': canManageCircles,
        'can_assign_circle_chair': canAssignCircleChair,
        'can_access_finance_tab': canAccessFinanceTab,
        'can_modify_finance_settings': canModifyFinanceSettings,
        'can_issue_coins': canIssueCoins,
        'can_access_reports_tab': canAccessReportsTab,
        'can_submit_reports': canSubmitReports,
        'can_export_peer_data': canExportPeerData,
        'can_export_financial_data': canExportFinancialData,
        'can_export_global_data': canExportGlobalData,
        'can_access_role_management': canAccessRoleManagement,
        'can_view_regional_scope': canViewRegionalScope,
      };
}
