import 'package:flutter/material.dart';
import '../../features/splash/view/splash_view.dart';
import '../../features/login/view/login_view.dart';
import '../../features/otp/view/otp_view.dart';
import '../../features/dashboard/view/dashboard_view.dart';
import '../../features/profile/view/profile_view.dart';
import '../../features/peers/model/peer_model.dart';
import '../../features/peer_profile/view/peer_profile_view.dart';
import '../../features/notifications/view/notifications_view.dart';
import '../../features/testimonials/view/testimonials_view.dart';
import '../../features/referrals/model/referral_model.dart';
import '../../features/referrals/view/referrals_view.dart';
import '../../features/peers_by_coins/model/coin_balance_model.dart';
import '../../features/peers_by_coins/view/peers_by_coins_view.dart';
import '../../features/teams/model/teams_model.dart';
import '../../features/circle_details/view/circle_details_view.dart';
import '../../features/role_management/view/role_management_view.dart';

/// Centralized routing configuration for the Leader App.
abstract class AppRoutes {
  /// Splash screen route
  static const String splash = '/';

  /// Login screen route
  static const String login = '/login';

  /// Home screen route
  static const String home = '/home';

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

  /// Circle Details route
  static const String circleDetails = '/circle-details';

  /// Role Management route
  static const String roleManagement = '/role-management';

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
        } else if (settings.arguments is ReferralModel) {
          final r = settings.arguments as ReferralModel;
          peer = PeerModel(
            id: r.id,
            initials: r.initials,
            name: r.name,
            company: r.company,
            circle: '',
            location: '',
            tags: r.category,
            impactCount: r.referralCount,
            dealsFormatted: r.dealsCount,
            coins: r.coinsCount,
            attendance: r.attendanceRate,
            status: r.status,
          );
        } else if (settings.arguments is CoinBalanceModel) {
          final c = settings.arguments as CoinBalanceModel;
          peer = PeerModel(
            id: c.id,
            initials: c.initials,
            name: c.name,
            company: c.company,
            circle: '',
            location: '',
            tags: c.category,
            impactCount: c.referralsCount,
            dealsFormatted: c.dealsCount,
            coins: c.coins,
            attendance: c.attendanceRate,
            status: c.status,
          );
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
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
