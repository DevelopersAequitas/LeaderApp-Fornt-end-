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
import '../../features/referrals/view/referrals_view.dart';
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
        final peer = settings.arguments as PeerModel;
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
