import 'package:flutter/material.dart';
import 'app_page_route.dart';
import '../widgets/custom_app_bar.dart';
import '../../features/splash/view/splash_view.dart';
import '../../features/login/view/login_view.dart';
import '../../features/otp/view/otp_view.dart';
import '../../features/dashboard/view/dashboard_view.dart';
import '../../features/profile/view/profile_view.dart';
import '../../features/peers/model/peer_model.dart';
import '../../features/peer_profile/view/peer_profile_view.dart';
import '../../features/peer_profile/view/peer_collaboration_screen.dart';
import '../../features/peer_profile/model/peer_profile_model.dart';
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
import '../../features/leader_activities/model/leader_activity_item_model.dart';
import '../../features/leader_activities/view/leader_activities_view.dart';
import '../../features/teams/model/teams_model.dart';
import '../../features/circle_details/view/circle_details_view.dart';
import '../../features/circle_details/view/circle_events_screen.dart';
import '../../features/circle_details/view/circle_overview_screen.dart';
import '../../features/circle_details/view/circle_peers_screen.dart';
import '../../features/circle_details/view/circle_sub_industries_screen.dart';
import '../../features/role_management/view/role_management_view.dart';
import '../../features/circulars/view/circulars_view.dart';
import '../../features/maintenance/view/maintenance_view.dart';
import '../../features/peers/view/peers_view.dart';
import '../../features/reports/model/report_model.dart';
import '../../features/reports/view/report_details_view.dart';

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

  /// Peer Collaboration route
  static const String peerCollaboration = '/peer-collaboration';

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

  /// Unified Leader User-Input Activities route
  static const String leaderActivities = '/leader-activities';

  /// Circle Details route
  static const String circleDetails = '/circle-details';

  /// Circle Peers route
  static const String circlePeers = '/circle-peers';

  /// Circle Sub-Industries route
  static const String circleSubIndustries = '/circle-sub-industries';

  /// Circle Events route
  static const String circleEvents = '/circle-events';

  /// Circle Overview route
  static const String circleOverview = '/circle-overview';

  /// Role Management route
  static const String roleManagement = '/role-management';

  /// Official Circulars route
  static const String circulars = '/circulars';

  /// Maintenance mode route
  static const String maintenance = '/maintenance';

  /// Report Details screen route
  static const String reportDetails = '/report-details';

  /// Route generator to handle app navigation transitions.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return AppPageRoute(
          builder: (_) => const SplashView(),
          settings: settings,
        );
      case login:
        return AppPageRoute(
          builder: (_) => const LoginView(),
          settings: settings,
        );
      case home:
        return AppPageRoute(
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
        return AppPageRoute(
          builder: (_) => _PeersRouteScreen(
            selectedCircle: circle,
            initialSort: sort,
          ),
          settings: settings,
        );
      case otp:
        String emailOrPhone = '';
        String channel = 'email';
        int otpExpirySeconds = 300;
        if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          emailOrPhone =
              (map['emailOrPhone'] ?? map['email_or_phone'] ?? '').toString();
          channel = (map['channel'] ?? 'email').toString();
          otpExpirySeconds =
              int.tryParse(map['otpExpirySeconds']?.toString() ?? '') ?? 300;
        } else if (settings.arguments is String) {
          emailOrPhone = settings.arguments as String;
        }
        return AppPageRoute(
          builder: (_) => OtpView(
            emailOrPhone: emailOrPhone,
            channel: channel,
            otpExpirySeconds: otpExpirySeconds,
          ),
          settings: settings,
        );
      case profile:
        return AppPageRoute(
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
        } else if (settings.arguments is LeaderActivityItemModel) {
          peer = (settings.arguments as LeaderActivityItemModel).toPeerModel();
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
        return AppPageRoute(
          builder: (_) => PeerProfileView(peer: peer),
          settings: settings,
        );
      case testimonials:
        return AppPageRoute(
          builder: (_) => const TestimonialsView(),
          settings: settings,
        );
      case referrals:
        return AppPageRoute(
          builder: (_) => const ReferralsView(),
          settings: settings,
        );
      case peersByCoins:
        return AppPageRoute(
          builder: (_) => const PeersByCoinsView(),
          settings: settings,
        );
      case impacts:
        final circleId = settings.arguments as String?;
        return AppPageRoute(
          builder: (_) => ImpactsView(circleId: circleId),
          settings: settings,
        );
      case p2pMeetings:
        final circleId = settings.arguments as String?;
        return AppPageRoute(
          builder: (_) => P2PMeetingsView(circleId: circleId),
          settings: settings,
        );
      case businessDeals:
        final circleId = settings.arguments as String?;
        return AppPageRoute(
          builder: (_) => BusinessDealsView(circleId: circleId),
          settings: settings,
        );
      case requirements:
        final circleId = settings.arguments as String?;
        return AppPageRoute(
          builder: (_) => RequirementsView(circleId: circleId),
          settings: settings,
        );
      case leaderActivities:
        String activityType = 'visitor-registrations';
        String? circleId;
        if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          activityType =
              (map['type'] ?? map['activityType'] ?? 'visitor-registrations')
                  .toString();
          circleId = map['circleId']?.toString() ?? map['circle_id']?.toString();
        } else if (settings.arguments is String) {
          activityType = settings.arguments as String;
        }
        return AppPageRoute(
          builder: (_) => LeaderActivitiesView(
            activityType: activityType,
            circleId: circleId,
          ),
          settings: settings,
        );
      case circleDetails:
        final circle = settings.arguments as CircleTeamModel;
        return AppPageRoute(
          builder: (_) => CircleDetailsView(circle: circle),
          settings: settings,
        );
      case circlePeers:
        final circle = settings.arguments as CircleTeamModel;
        return AppPageRoute(
          builder: (_) => CirclePeersScreen(circle: circle),
          settings: settings,
        );
      case circleSubIndustries:
        CircleTeamModel circle;
        int initialTabIndex = 0;
        if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          circle = map['circle'] as CircleTeamModel;
          initialTabIndex =
              int.tryParse(map['initialTabIndex']?.toString() ?? '0') ?? 0;
        } else {
          circle = settings.arguments as CircleTeamModel;
        }
        return AppPageRoute(
          builder: (_) => CircleSubIndustriesScreen(
            circle: circle,
            initialTabIndex: initialTabIndex,
          ),
          settings: settings,
        );
      case circleEvents:
        final circle = settings.arguments as CircleTeamModel;
        return AppPageRoute(
          builder: (_) => CircleEventsScreen(circle: circle),
          settings: settings,
        );
      case circleOverview:
        final circle = settings.arguments as CircleTeamModel;
        return AppPageRoute(
          builder: (_) => CircleOverviewScreen(circle: circle),
          settings: settings,
        );
      case roleManagement:
        return AppPageRoute(
          builder: (_) => const RoleManagementView(),
          settings: settings,
        );
      case circulars:
        return AppPageRoute(
          builder: (_) => const CircularsView(),
          settings: settings,
        );
      case maintenance:
        return AppPageRoute(
          builder: (_) => const MaintenanceView(),
          settings: settings,
        );
      case peerCollaboration:
        PeerModel peerModel;
        PeerProfileDetailModel? detailModel;
        if (settings.arguments is PeerModel) {
          peerModel = settings.arguments as PeerModel;
        } else if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          peerModel =
              map['peer'] as PeerModel? ??
              const PeerModel(
                initials: '',
                name: 'Peer',
                company: '',
                circle: '',
                location: '',
                tags: '',
                impactCount: 0,
                dealsFormatted: '',
                coins: 0,
                attendance: '',
                status: 'Active',
              );
          detailModel = map['details'] as PeerProfileDetailModel?;
        } else {
          peerModel = const PeerModel(
            initials: '',
            name: 'Peer',
            company: '',
            circle: '',
            location: '',
            tags: '',
            impactCount: 0,
            dealsFormatted: '',
            coins: 0,
            attendance: '',
            status: 'Active',
          );
        }
        return AppPageRoute(
          builder: (_) =>
              PeerCollaborationScreen(peer: peerModel, details: detailModel),
          settings: settings,
        );
      case reportDetails:
        final report = settings.arguments as ReportModel;
        return AppPageRoute(
          builder: (_) => ReportDetailsView(report: report),
          settings: settings,
        );
      default:
        return AppPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

class _PeersRouteScreen extends StatefulWidget {
  final String? selectedCircle;
  final String? initialSort;

  const _PeersRouteScreen({
    this.selectedCircle,
    this.initialSort,
  });

  @override
  State<_PeersRouteScreen> createState() => _PeersRouteScreenState();
}

class _PeersRouteScreenState extends State<_PeersRouteScreen> {
  late final TextEditingController _searchController;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Peers',
        showBackButton: true,
        showSearch: true,
        isSearching: _isSearching,
        searchController: _searchController,
        searchHint: 'Search by name, company, circle...',
        onSearchTap: () => setState(() => _isSearching = true),
        onSearchChanged: (val) => setState(() => _searchQuery = val),
        onSearchClose: () {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
            _isSearching = false;
          });
        },
      ),
      body: PeersView(
        selectedCircle: widget.selectedCircle,
        initialSort: widget.initialSort,
        externalSearchQuery: _searchQuery,
      ),
    );
  }
}
