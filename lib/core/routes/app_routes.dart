import 'package:flutter/material.dart';
import '../../features/splash/view/splash_view.dart';
import '../../features/login/view/login_view.dart';
import '../../features/otp/view/otp_view.dart';
import '../../features/dashboard/view/dashboard_view.dart';
import '../../features/profile/view/profile_view.dart';
import '../../features/peers/model/peer_model.dart';
import '../../features/peer_profile/view/peer_profile_view.dart';
import '../../features/notifications/view/notifications_view.dart';
import '../../features/testimonials/model/testimonial_model.dart';
import '../../features/testimonials/view/testimonials_view.dart';
import '../../features/referrals/model/referral_model.dart';
import '../../features/referrals/view/referrals_view.dart';
import '../../features/peers_by_coins/model/coin_balance_model.dart';
import '../../features/peers_by_coins/view/peers_by_coins_view.dart';
import '../../features/impacts/model/impact_model.dart';
import '../../features/impacts/view/impacts_view.dart';
import '../../features/p2p_meetings/model/p2p_meeting_model.dart';
import '../../features/p2p_meetings/view/p2p_meetings_view.dart';
import '../../features/business_deals/model/business_deal_model.dart';
import '../../features/business_deals/view/business_deals_view.dart';
import '../../features/requirements/model/requirement_model.dart';
import '../../features/requirements/view/requirements_view.dart';
import '../../features/teams/model/teams_model.dart';
import '../../features/circle_details/view/circle_details_view.dart';
import '../../features/role_management/view/role_management_view.dart';
import '../../features/circulars/view/circulars_view.dart';
import '../../features/maintenance/view/maintenance_view.dart';
import '../../features/peers/view/peers_view.dart';

/// Centralized routing configuration for the Leader App.
abstract class AppRoutes {
  /// Splash screen route
  static const String splash = '/';

  /// Login screen route
  static const String login = '/login';

  /// Home screen route
  static const String home = '/home';

  /// Peers list route
  static const String peers = '/peers';

  /// OTP verification route
  static const String otp = '/otp';

  /// Profile screen route
  static const String profile = '/profile';

  /// Peer Profile route
  static const String peerProfile = '/peer-profile';

  /// Notifications route
  static const String notifications = '/notifications';

  /// Testimonials route
  static const String testimonials = '/testimonials';

  /// Referrals route
  static const String referrals = '/referrals';

  /// Peers by Coins route
  static const String peersByCoins = '/peers-by-coins';

  /// Impacts route
  static const String impacts = '/impacts';

  /// P2P Meetings route
  static const String p2pMeetings = '/p2p-meetings';

  /// Business Deals route
  static const String businessDeals = '/business-deals';

  /// Requirements route
  static const String requirements = '/requirements';

  /// Circle Details route
  static const String circleDetails = '/circle-details';

  /// Role Management route
  static const String roleManagement = '/role-management';

  /// Official Circulars route
  static const String circulars = '/circulars';

  /// Maintenance mode route
  static const String maintenance = '/maintenance';

  /// Route generator to handle app navigation transitions.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashView(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginView(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const DashboardView(),
          settings: settings,
        );
      case peers:
        String? sort;
        String? circle;
        if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          sort = map['sort']?.toString();
          circle = map['circle']?.toString();
        } else if (settings.arguments is String) {
          sort = settings.arguments as String;
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text(
                sort != null ? 'Peers · $sort' : 'Peers Directory',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              backgroundColor: const Color(0xFF102640),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: PeersView(
              selectedCircle: circle,
              initialSort: sort,
            ),
          ),
          settings: settings,
        );
      case otp:
        final emailOrPhone = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => OtpView(emailOrPhone: emailOrPhone),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileView(),
          settings: settings,
        );
      case peerProfile:
        PeerModel peer;
        if (settings.arguments is PeerModel) {
          peer = settings.arguments as PeerModel;
        } else if (settings.arguments is ImpactModel) {
          peer = (settings.arguments as ImpactModel).toPeerModel();
        } else if (settings.arguments is P2PMeetingModel) {
          peer = (settings.arguments as P2PMeetingModel).toPeerModel();
        } else if (settings.arguments is BusinessDealModel) {
          peer = (settings.arguments as BusinessDealModel).toPeerModel();
        } else if (settings.arguments is RequirementModel) {
          peer = (settings.arguments as RequirementModel).toPeerModel();
        } else if (settings.arguments is ReferralModel) {
          peer = (settings.arguments as ReferralModel).toPeerModel();
        } else if (settings.arguments is CoinBalanceModel) {
          peer = (settings.arguments as CoinBalanceModel).toPeerModel();
        } else if (settings.arguments is TestimonialModel) {
          peer = (settings.arguments as TestimonialModel).toPeerModel();
        } else if (settings.arguments is Map<String, dynamic>) {
          peer = PeerModel.fromJson(settings.arguments as Map<String, dynamic>);
        } else if (settings.arguments is String) {
          final str = settings.arguments as String;
          peer = PeerModel(
            id: str,
            initials: 'PR',
            name: 'Peer Details',
            company: '',
            circle: '',
            location: '',
            tags: '',
            impactCount: 0,
            dealsFormatted: '₹0',
            coins: 0,
            attendance: '90%',
            status: 'Active',
          );
        } else {
          peer = const PeerModel(
            id: '',
            initials: 'PR',
            name: 'Peer Details',
            company: '',
            circle: '',
            location: '',
            tags: '',
            impactCount: 0,
            dealsFormatted: '₹0',
            coins: 0,
            attendance: '90%',
            status: 'Active',
          );
        }
        return MaterialPageRoute(
          builder: (_) => PeerProfileView(peer: peer),
          settings: settings,
        );
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsView(),
          settings: settings,
        );
      case testimonials:
        return MaterialPageRoute(
          builder: (_) => const TestimonialsView(),
          settings: settings,
        );
      case referrals:
        return MaterialPageRoute(
          builder: (_) => const ReferralsView(),
          settings: settings,
        );
      case peersByCoins:
        return MaterialPageRoute(
          builder: (_) => const PeersByCoinsView(),
          settings: settings,
        );
      case impacts:
        final circleId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ImpactsView(circleId: circleId),
          settings: settings,
        );
      case p2pMeetings:
        final circleId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => P2PMeetingsView(circleId: circleId),
          settings: settings,
        );
      case businessDeals:
        final circleId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => BusinessDealsView(circleId: circleId),
          settings: settings,
        );
      case requirements:
        final circleId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => RequirementsView(circleId: circleId),
          settings: settings,
        );
      case circleDetails:
        final circle = settings.arguments as CircleTeamModel;
        return MaterialPageRoute(
          builder: (_) => CircleDetailsView(circle: circle),
          settings: settings,
        );
      case roleManagement:
        return MaterialPageRoute(
          builder: (_) => const RoleManagementView(),
          settings: settings,
        );
      case circulars:
        return MaterialPageRoute(
          builder: (_) => const CircularsView(),
          settings: settings,
        );
      case maintenance:
        return MaterialPageRoute(
          builder: (_) => const MaintenanceView(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
