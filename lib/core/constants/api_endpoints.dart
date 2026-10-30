/// Defines the active server environment for the Leader App.
enum AppEnvironment {
  dev('Development', 'https://dev.peersunity.com/api/v1'),
  local('Localhost', 'http://localhost:8000/api/v1'),
  staging('Staging', 'https://staging-api.peersunity.com/api/v1'),
  prod('Production', 'https://peersunity.com/api/v1');

  final String name;
  final String baseUrl;

  const AppEnvironment(this.name, this.baseUrl);
}

/// Centralized API endpoint registry for all REST APIs.
/// Adheres strictly to the Leader App API Specification and New Endpoints release.
abstract class ApiEndpoints {
  /// Active Environment.
  /// Defaults to Development (dev.peersunity.com) so generated release APKs connect to dev peers.
  /// Can be overridden at build-time using `--dart-define=ENV=prod` or runtime via [setEnvironment].
  static AppEnvironment activeEnvironment = () {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (env.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'staging':
        return AppEnvironment.staging;
      case 'local':
        return AppEnvironment.local;
      case 'dev':
      default:
        return AppEnvironment.dev;
    }
  }();

  /// Gets the current Base URL.
  static String get baseUrl => activeEnvironment.baseUrl;

  /// Allows switching environment dynamically during runtime/QA testing.
  static void setEnvironment(AppEnvironment environment) {
    activeEnvironment = environment;
  }

  // --- 1. Authentication & Profile ---
  static String get sendOtp => '$baseUrl/leader/auth/send-otp';
  static String get verifyOtp => '$baseUrl/leader/auth/verify-otp';
  static String get profile => '$baseUrl/leader/profile';
  static String get updateProfile => '$baseUrl/leader/profile';
  static String get uploadAvatar => '$baseUrl/leader/auth/profile/avatar';

  // --- 2. Dashboard ---
  static String get dashboardMetrics => '$baseUrl/leader/dashboard/metrics';
  static String get dashboardTopImpacters =>
      '$baseUrl/leader/dashboard/top-impacters';
  static String get leaderAsksSummary => '$baseUrl/leader/asks/summary';
  static String leaderAsksGlobal(String flow) =>
      '$baseUrl/leader/asks/$flow/global';
  static String get adminLeadsCounts => '$baseUrl/admin/leads/counts';
  static String adminLeadsByType(String type) => '$baseUrl/admin/leads/$type';
  static String get adminPendingRequests => '$baseUrl/admin/pending-requests';
  static String get adminPendingRequestsSummary =>
      '$baseUrl/admin/pending-requests/summary';
  static String adminApprovePendingRequest(String id, {String? category}) =>
      category != null && category.isNotEmpty && category != 'all'
          ? '$baseUrl/admin/pending-requests/$category/$id/approve'
          : '$baseUrl/admin/pending-requests/$id/approve';
  static String adminRejectPendingRequest(String id, {String? category}) =>
      category != null && category.isNotEmpty && category != 'all'
          ? '$baseUrl/admin/pending-requests/$category/$id/reject'
          : '$baseUrl/admin/pending-requests/$id/reject';
  static String get leaderPendingRequestsSummary =>
      '$baseUrl/leader/pending-requests/summary';
  static String leaderApprovePendingRequest(String id, {String? category}) =>
      category != null && category.isNotEmpty && category != 'all'
          ? '$baseUrl/leader/pending-requests/$category/$id/approve'
          : '$baseUrl/leader/pending-requests/$id/approve';
  static String leaderRejectPendingRequest(String id, {String? category}) =>
      category != null && category.isNotEmpty && category != 'all'
          ? '$baseUrl/leader/pending-requests/$category/$id/reject'
          : '$baseUrl/leader/pending-requests/$id/reject';
  static String get adminPosts => '$baseUrl/admin/posts';
  static String get adminActivitiesStats => '$baseUrl/admin/activities/stats';

  // --- 3. Peers, Meetings, Activities & Celebrations ---
  static String get peers => '$baseUrl/leader/peers';
  static String get membersLimited => '$baseUrl/members/limited';
  static String peerDetails(String id) => '$baseUrl/leader/peers/$id';
  static String get peerCelebrations => '$baseUrl/leader/peers/celebrations';
  static String peerSendWish(String id) =>
      '$baseUrl/leader/peers/$id/send-wish';
  static String peerMeetings(String id) => '$baseUrl/leader/peers/$id/meetings';
  static String peerActivities(String id) =>
      '$baseUrl/leader/peers/$id/activities';
  static String memberProfile(String memberId) =>
      '$baseUrl/leader/members/$memberId';
  static String memberActivities(String memberId) =>
      '$baseUrl/leader/members/$memberId/activities';
  static String memberSpecificActivity(String memberId, String path) =>
      '$baseUrl/leader/members/$memberId/$path';
  static String get impacts => '$baseUrl/leader/impacts';
  static String get p2pMeetings => '$baseUrl/leader/p2p-meetings';
  static String get logP2pMeeting => '$baseUrl/leader/p2p-meetings';
  static String get businessDeals => '$baseUrl/leader/business-deals';
  static String get requirements => '$baseUrl/leader/requirements';
  static String leaderActivitiesByType(String type) =>
      '$baseUrl/leader/activities/$type';

  // --- 4. Teams & Circles ---
  static String get teamsSummary => '$baseUrl/leader/teams/summary';
  static String get teamsCircles => '$baseUrl/leader/teams/circles';
  static String get teamsIndustries => '$baseUrl/leader/teams/industries';
  static String circleDetails(String id) => '$baseUrl/leader/teams/circles/$id';
  static String circlePeers(String id) =>
      '$baseUrl/leader/teams/circles/$id/peers';
  static String circleSubIndustries(String id) =>
      '$baseUrl/leader/teams/circles/$id/sub-industries';
  static String circleReferCategory(String id) =>
      '$baseUrl/leader/teams/circles/$id/refer-category';
  static String circleEvents(String id) =>
      '$baseUrl/leader/teams/circles/$id/events';
  static String get leaderContacts => '$baseUrl/leader/contacts';
  static String get contactPosts => '$baseUrl/contact-posts';
  static String get recommendPeerForm => '$baseUrl/forms/recommend-peer';

  // --- 4b. Member 360° Events, Passes & Attendance ---
  static String memberEvents(String memberId) =>
      '$baseUrl/leader/members/$memberId/events';
  static String memberEventRegistrations(String memberId) =>
      '$baseUrl/leader/members/$memberId/event-registrations';
  static String memberAttendance(String memberId) =>
      '$baseUrl/leader/members/$memberId/attendance';

  // --- 5. Finance ---
  static String get financeMetrics => '$baseUrl/leader/finance/metrics';
  static String get financeTransactions =>
      '$baseUrl/leader/finance/transactions';
  static String get updateCommissionRates =>
      '$baseUrl/leader/finance/commission-rates';
  static String get recordOfflineTransaction =>
      '$baseUrl/leader/finance/transactions/record-offline';

  // --- 6. Reports & Analytics ---
  static String get reports => '$baseUrl/leader/reports';
  static String reportById(String id) => '$baseUrl/leader/reports/$id';
  static String get reportsAttendanceTrend =>
      '$baseUrl/leader/reports/attendance-trend';
  static String get reportsExport => '$baseUrl/leader/reports/export';
  static String reportDownload(String id) =>
      '$baseUrl/leader/reports/$id/download';

  // --- 7. Referrals, Testimonials & Coins ---
  static String get referrals => '$baseUrl/leader/referrals';
  static String get testimonials => '$baseUrl/leader/testimonials';
  static String get leaderTestimonials => '$baseUrl/leader/testimonials';
  static String memberTestimonials(String memberId) =>
      '$baseUrl/leader/members/$memberId/testimonials';
  static String get peersByCoins => '$baseUrl/leader/peers-by-coins';
  static String get leaderPeersByCoins => '$baseUrl/leader/peers-by-coins';
  static String memberCoins(String memberId) =>
      '$baseUrl/leader/members/$memberId/coins';

  // --- 7b. Leader Business Deals & Referrals ---
  static String get leaderBusinessDeals => '$baseUrl/leader/business-deals';
  static String memberBusinessDeals(String memberId) =>
      '$baseUrl/leader/members/$memberId/business-deals';
  static String get leaderReferrals => '$baseUrl/leader/referrals';
  static String memberReferrals(String memberId) =>
      '$baseUrl/leader/members/$memberId/referrals';
  static String memberPosts(String memberId) =>
      '$baseUrl/leader/members/$memberId/posts';
  static String memberPost(String memberId, String postId) =>
      '$baseUrl/leader/members/$memberId/posts/$postId';
  static String memberCreatives(String memberId) =>
      '$baseUrl/leader/members/$memberId/creatives';
  static String memberCreative(String memberId, String creativeId) =>
      '$baseUrl/leader/members/$memberId/creatives/$creativeId';

  // --- 7c. Leader Collaboration Asks ---
  static String get leaderCollaborationMy =>
      '$baseUrl/leader/asks/collaboration/my';
  static String leaderCollaborationUser(String userId) =>
      '$baseUrl/leader/asks/collaboration/user/$userId';

  // --- 7d. Leader Referral Asks ---
  static String get leaderReferralAsksMy => '$baseUrl/leader/asks/referral/my';
  static String leaderReferralAsksUser(String userId) =>
      '$baseUrl/leader/asks/referral/user/$userId';

  // --- 7e. Leader Help Asks ---
  static String get leaderHelpAsksMy => '$baseUrl/leader/asks/help/my';
  static String leaderHelpAsksUser(String userId) =>
      '$baseUrl/leader/asks/help/user/$userId';

  // --- 8. Role Management Matrix ---
  static String get roleMatrix => '$baseUrl/leader/roles/matrix';
  static String get roles => '$baseUrl/leader/roles';
  static String roleById(String id) => '$baseUrl/leader/roles/$id';

  // --- 10. System Configuration & Circulars ---
  static String get appConfig => '$baseUrl/leader/system/app-config';
  static String get circulars => '$baseUrl/circulars';
  static String circularById(String id) => '$baseUrl/circulars/$id';
  static String get circularPublish => '$baseUrl/circulars/publish';
}
