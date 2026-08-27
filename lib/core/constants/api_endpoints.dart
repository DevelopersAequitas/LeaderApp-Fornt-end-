import 'package:flutter/foundation.dart';

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
  /// Automatically selects Production (`https://peersglobal.com/api/v1`) for Release builds,
  /// and Development (`https://dev.peersunity.com/api/v1`) during local Debug runs.
  static AppEnvironment activeEnvironment = kReleaseMode ? AppEnvironment.prod : AppEnvironment.dev;

  /// Gets the current Base URL.
  static String get baseUrl => activeEnvironment.baseUrl;

  /// Allows switching environment dynamically during runtime/QA testing.
  static void setEnvironment(AppEnvironment environment) {
    activeEnvironment = environment;
  }

  // --- 1. Authentication & Profile ---
  static String get sendOtp => '$baseUrl/auth/send-otp';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';
  static String get updateProfile => '$baseUrl/auth/profile';
  static String get uploadAvatar => '$baseUrl/auth/profile/avatar';

  // --- 2. Dashboard ---
  static String get dashboardMetrics => '$baseUrl/dashboard/metrics';
  static String get dashboardTopImpacters => '$baseUrl/dashboard/top-impacters';

  // --- 3. Peers, Meetings, Activities & Celebrations ---
  static String get peers => '$baseUrl/peers';
  static String peerDetails(String id) => '$baseUrl/peers/$id';
  static String get peerCelebrations => '$baseUrl/peers/celebrations';
  static String peerSendWish(String id) => '$baseUrl/peers/$id/send-wish';
  static String peerMeetings(String id) => '$baseUrl/peers/$id/meetings';
  static String peerActivities(String id) => '$baseUrl/peers/$id/activities';
  static String get logP2pMeeting => '$baseUrl/peers/p2p-meetings';

  // --- 4. Teams & Circles ---
  static String get teamsSummary => '$baseUrl/teams/summary';
  static String get teamsCircles => '$baseUrl/teams/circles';
  static String get teamsIndustries => '$baseUrl/teams/industries';
  static String circleDetails(String id) => '$baseUrl/teams/circles/$id';
  static String circlePeers(String id) => '$baseUrl/teams/circles/$id/peers';
  static String circleSubIndustries(String id) => '$baseUrl/teams/circles/$id/sub-industries';
  static String circleEvents(String id) => '$baseUrl/teams/circles/$id/events';


  // --- 5. Finance ---
  static String get financeMetrics => '$baseUrl/finance/metrics';
  static String get financeTransactions => '$baseUrl/finance/transactions';
  static String get updateCommissionRates => '$baseUrl/finance/commission-rates';
  static String get recordOfflineTransaction => '$baseUrl/finance/transactions/record-offline';

  // --- 6. Reports & Analytics ---
  static String get reports => '$baseUrl/reports';
  static String get reportsAttendanceTrend => '$baseUrl/reports/attendance-trend';
  static String get reportsExport => '$baseUrl/reports/export';
  static String reportDownload(String id) => '$baseUrl/reports/$id/download';

  // --- 7. Referrals, Testimonials & Coins ---
  static String get referrals => '$baseUrl/referrals';
  static String get testimonials => '$baseUrl/testimonials';
  static String get peersByCoins => '$baseUrl/peers-by-coins';

  // --- 8. Notifications ---
  static String get notifications => '$baseUrl/notifications';
  static String get notificationsMarkRead => '$baseUrl/notifications/mark-read';

  // --- 9. Role Management Matrix ---
  static String get roleMatrix => '$baseUrl/roles/matrix';
  static String get roles => '$baseUrl/roles';
  static String roleById(String id) => '$baseUrl/roles/$id';

  // --- 10. System Configuration & Circulars ---
  static String get appConfig => '$baseUrl/system/app-config';
  static String get circulars => '$baseUrl/circulars';
  static String circularById(String id) => '$baseUrl/circulars/$id';
  static String get circularPublish => '$baseUrl/circulars/publish';
}
