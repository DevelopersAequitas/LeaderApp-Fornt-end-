import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/core/models/leader_permissions.dart';
import 'package:leaderapp/core/theme/app_theme.dart';
import 'package:leaderapp/core/widgets/enterprise_components.dart';
import 'package:leaderapp/features/dashboard/model/dashboard_circle_option.dart';
import 'package:leaderapp/features/dashboard/model/dashboard_metrics_model.dart';
import 'package:leaderapp/features/dashboard/model/impacter_model.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_action_center_card.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_domains_section.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_hero_card.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_performance_section.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_quick_actions.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_recent_activity_section.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_shimmer_skeleton.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_top_impacters.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_upcoming_events_section.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_welcome_header.dart';
import 'package:leaderapp/features/teams/model/teams_model.dart';

void main() {
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  final sampleCircles = <CircleTeamModel>[
    const CircleTeamModel(
      id: '11111111-1111-4111-8111-111111111111',
      name: 'Ahmedabad Titans',
      category: 'Technology',
      location: 'Ahmedabad',
      peersCount: 38,
      healthPercentage: 92,
      revenue: '₹40,000',
      tags: ['Technology'],
      founderName: 'Aarav Patel',
      directorName: 'Rohan Desai',
      chairName: 'Meera Shah',
      status: 'Active',
      meetingFrequency: 'Monthly',
      meetingMode: 'Offline',
      cadence: CircleCadenceModel(
        frequency: 'Monthly',
        mode: 'Offline',
        day: 'Wednesday',
        ordinal: '1st',
        startTime: '09:00',
        endTime: '10:30',
        timeRange: '09:00 AM - 10:30 AM',
        venue: 'Courtyard Marriott, Ahmedabad',
        upcomingDisplay: '1st Wed, Dec 3',
      ),
    ),
    const CircleTeamModel(
      id: '22222222-2222-4222-8222-222222222222',
      name: 'Mumbai FinTech Guild',
      category: 'Financial Services',
      location: 'Mumbai',
      peersCount: 25,
      healthPercentage: 48,
      revenue: '₹25,000',
      tags: ['Finance'],
      founderName: 'Vikram Rao',
      directorName: '',
      chairName: '',
      status: 'Active',
    ),
    const CircleTeamModel(
      id: '44444444-4444-4444-8444-444444444444',
      name: 'Delhi Global Circle',
      category: 'Manufacturing',
      location: 'New Delhi',
      peersCount: 18,
      healthPercentage: 0,
      revenue: '₹10,000',
      tags: ['Manufacturing'],
      founderName: 'Karan Mehta',
      directorName: 'Neha Verma',
      chairName: 'Suresh Iyer',
      status: 'At Risk',
    ),
  ];

  const sampleMetrics = DashboardMetricsModel(
    impact: 6000,
    deals: '₹13L',
    dealsCount: 7,
    p2pMeetings: 35,
    totalPeers: 81,
    totalPeersGrowth: 5,
    referrals: 14,
    testimonials: 4,
    coins: 6400900000000000,
    overallRevenue: '₹75,000',
    pendingRequestsCount: 6,
    requirements: 20,
    visitorRegistrations: 3,
    introducedPeers: 4,
    collaborationAsks: 15,
    referralAsks: 2,
    helpAsks: 6,
    allAsks: 23,
    openAsks: 17,
    inProgressAsks: 6,
    fulfilledAsks: 3,
    coinClaims: 1,
    leadershipInterests: 4,
    partnerInquiries: 2,
    circulars: 5,
    eventRegistrations: 79,
    eventAttendance: 79,
  );

  final sampleImpacters = <ImpacterModel>[
    const ImpacterModel(
      id: '33333333-3333-4333-8333-333333333333',
      rank: 1,
      initials: 'CM',
      name: 'CHIRAG MALI',
      company: 'Peers Global',
      designation: 'Founder',
      location: 'Ahmedabad',
      lives: 420,
      coins: 1200,
      isVerified: true,
    ),
  ];

  Future<void> setSuperAdminSession() async {
    await SessionManager().setAuthSession(
      token: 'sa-token',
      session: const UserSession(
        id: 'sa-1',
        name: 'Chirag Mali',
        email: 'admin@peersglobal.com',
        phone: '+919999999999',
        role: UserRole.superAdmin,
        regionalScope: 'Global',
        managedCircles: [
          'Ahmedabad Titans',
          'Mumbai FinTech Guild',
          'Delhi Global Circle',
        ],
        memberSince: 'Aug 2025',
        capabilitiesCount: 21,
      ),
      permissions: LeaderPermissions.allGranted,
    );
  }

  Future<void> setChairSession() async {
    await SessionManager().setAuthSession(
      token: 'chair-token',
      session: const UserSession(
        id: 'ch-1',
        name: 'Meera Shah',
        email: 'chair@peersglobal.com',
        phone: '+918888888888',
        role: UserRole.chairBusinessGrowth,
        regionalScope: 'Ahmedabad Titans',
        managedCircles: ['Ahmedabad Titans'],
        memberSince: 'Jan 2026',
        capabilitiesCount: 6,
      ),
      permissions: const LeaderPermissions(
        canAccessDashboard: true,
        canViewOverallRevenue: false,
        canAccessPeersTab: true,
        canAccessTeamsTab: false,
        canAccessFinanceTab: false,
        canAccessReportsTab: true,
        canAccessRoleManagement: false,
      ),
    );
  }

  Widget buildCommandCenter({
    required ThemeData theme,
    double textScale = 1.0,
  }) {
    return MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(393, 852),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardWelcomeHeader(
                  circles: sampleCircles,
                  availableCircles: const [
                    DashboardCircleOption(
                      id: '11111111-1111-4111-8111-111111111111',
                      name: 'Ahmedabad Titans',
                      country: 'India',
                      district: 'Ahmedabad',
                      industry: 'Technology',
                      peersCount: 38,
                    ),
                    DashboardCircleOption(
                      id: '22222222-2222-4222-8222-222222222222',
                      name: 'Mumbai FinTech Guild',
                      country: 'India',
                      district: 'Mumbai',
                      industry: 'Financial Services',
                      peersCount: 25,
                    ),
                    DashboardCircleOption(
                      id: '44444444-4444-4444-8444-444444444444',
                      name: 'Dubai Founders Circle',
                      country: 'UAE',
                      district: 'Dubai',
                      industry: 'Manufacturing',
                      peersCount: 18,
                    ),
                  ],
                  industries: const [
                    'Technology',
                    'Financial Services',
                    'Manufacturing',
                  ],
                  selectedCircleId: null,
                  onCircleSelected: (_) {},
                  currentTime: DateTime(2026, 11, 25, 10, 30),
                ),
                const DashboardHeroCard(
                  metrics: sampleMetrics,
                  totalCirclesCount: 3,
                  activeCirclesCount: 2,
                ),
                DashboardActionCenterCard(
                  metrics: sampleMetrics,
                  circles: sampleCircles,
                  selectedCircle: null,
                  onOpenTeamsTab: () {},
                ),
                DashboardDomainsSection(
                  metrics: sampleMetrics,
                  selectedCircle: null,
                  onPeersTap: () {},
                ),
                DashboardPerformanceSection(
                  metrics: sampleMetrics,
                  circles: sampleCircles,
                  selectedCircle: null,
                  onOpenTeamsTab: () {},
                ),
                DashboardQuickActions(
                  metrics: sampleMetrics,
                  selectedCircle: null,
                  onOpenPeersTab: () {},
                  onOpenTeamsTab: () {},
                  onOpenReportsTab: () {},
                ),
                DashboardUpcomingEventsSection(
                  circles: sampleCircles,
                  metrics: sampleMetrics,
                  selectedCircle: null,
                ),
                DashboardTopImpacters(
                  impacters: sampleImpacters,
                  metrics: sampleMetrics,
                ),
                const DashboardRecentActivitySection(
                  metrics: sampleMetrics,
                  selectedCircle: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  group('Super Admin Command Center', () {
    testWidgets(
        'Circle switcher sheet shows All Circles by default with Country, District, Industry dropdowns and Search',
        (tester) async {
      await setSuperAdminSession();
      String? pickedScope;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: DashboardWelcomeHeader(
              circles: sampleCircles,
              availableCircles: const [
                DashboardCircleOption(
                  id: '11111111-1111-4111-8111-111111111111',
                  name: 'Ahmedabad Titans',
                  country: 'India',
                  district: 'Ahmedabad',
                  industry: 'Technology',
                  peersCount: 38,
                ),
                DashboardCircleOption(
                  id: '22222222-2222-4222-8222-222222222222',
                  name: 'Mumbai FinTech Guild',
                  country: 'India',
                  district: 'Mumbai',
                  industry: 'Financial Services',
                  peersCount: 25,
                ),
                DashboardCircleOption(
                  id: '44444444-4444-4444-8444-444444444444',
                  name: 'Dubai Founders Circle',
                  country: 'UAE',
                  district: 'Dubai',
                  industry: 'Manufacturing',
                  peersCount: 18,
                ),
              ],
              industries: const [
                'Technology',
                'Financial Services',
                'Manufacturing',
              ],
              selectedCircleId: null,
              onCircleSelected: (val) => pickedScope = val,
            ),
          ),
        ),
      );

      // Open Circle scope selector
      await tester.tap(find.text('All Circles'));
      await tester.pumpAndSettle();

      // Default shows All Circles + all Circles + Country, District, Industry dropdowns
      expect(find.text('Select Circle Scope'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Industry'), findsOneWidget);
      expect(find.text('Ahmedabad Titans'), findsOneWidget);
      expect(find.text('Dubai Founders Circle'), findsOneWidget);

      // Filter by Country -> UAE
      await tester.tap(find.text('Country'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by Country'), findsOneWidget);
      await tester.tap(find.text('UAE'));
      await tester.pumpAndSettle();

      expect(find.text('Dubai Founders Circle'), findsOneWidget);
      expect(find.text('Ahmedabad Titans'), findsNothing);

      // Reset filters -> back to All Circles
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('Ahmedabad Titans'), findsOneWidget);

      // Filter by City -> Ahmedabad
      await tester.tap(find.text('City'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by City'), findsOneWidget);
      await tester.tap(find.text('Ahmedabad'));
      await tester.pumpAndSettle();
      expect(find.text('Ahmedabad Titans'), findsOneWidget);
      expect(find.text('Dubai Founders Circle'), findsNothing);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Filter by Industry -> Financial Services
      await tester.tap(find.text('Industry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Financial Services'));
      await tester.pumpAndSettle();
      expect(find.text('Mumbai FinTech Guild'), findsOneWidget);
      expect(find.text('Ahmedabad Titans'), findsNothing);

      // Tap Mumbai FinTech Guild
      await tester.tap(find.text('Mumbai FinTech Guild'));
      await tester.pumpAndSettle();
      expect(pickedScope, '22222222-2222-4222-8222-222222222222');
    });

    testWidgets(
        'renders executive KPIs & concise 3-item Action Required above the fold, plus 4-domain drill-downs',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await setSuperAdminSession();
      await tester.pumpWidget(buildCommandCenter(theme: AppTheme.lightTheme));

      // Identity & Scope
      expect(find.textContaining('Good morning'), findsOneWidget);
      expect(find.text('Chirag Mali'), findsWidgets);
      expect(find.text('Super Admin'), findsOneWidget);
      expect(
        find.textContaining(
          'Global · 2/3 Circles · 3 Industries',
        ),
        findsOneWidget,
      );

      // Core Organizational Overview
      expect(find.text('Organizational Overview'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('₹75,000'), findsOneWidget);
      expect(find.text('Business Deals'), findsOneWidget);
      expect(find.text('₹13L'), findsOneWidget);
      expect(find.text('Total Peers'), findsOneWidget);
      expect(find.text('Active Circles'), findsOneWidget);

      // Concise Action Required: only backend-flagged Circle ('Delhi Global Circle'),
      // Pending Approvals, and Director vacancy ('Mumbai FinTech Guild') initially (max 3!),
      // never invented <60% threshold, and ALL 3 fit above the 852dp portrait fold!
      expect(find.text('Action Required'), findsOneWidget);
      expect(
        find.text('Delhi Global Circle requires operational review'),
        findsOneWidget,
      );
      expect(
        find.text('Mumbai FinTech Guild requires operational review'),
        findsNothing,
      );
      expect(find.text('6 Pending Approvals'), findsOneWidget);
      expect(
        find.text('Mumbai FinTech Guild has no assigned Director'),
        findsOneWidget,
      );
      final actionCardBottom =
          tester.getBottomLeft(find.byType(DashboardActionCenterCard)).dy;
      expect(actionCardBottom, lessThan(760));
      // 4th item (Coin Claim) is hidden from initial 3-item card until View All is tapped
      expect(find.text('1 Coin Claim awaiting audit'), findsNothing);

      // Open 'View All' sheet in Action Required
      final actionHeaderViewAll = find.descendant(
        of: find.byType(DashboardActionCenterCard),
        matching: find.text('View All'),
      );
      expect(actionHeaderViewAll, findsOneWidget);
      await tester.tap(actionHeaderViewAll);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('1 Coin Claim awaiting audit'),
        120,
        scrollable: find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('1 Coin Claim awaiting audit'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      // Retained 4-Domain Information Architecture (Activity, Asks, Community, Leadership)
      expect(find.text('Operational Domains'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Leadership'), findsOneWidget);

      await tester.ensureVisible(find.text('Community'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Community'));
      await tester.pumpAndSettle();
      expect(find.text('Community Streams'), findsOneWidget);
      expect(find.text('Timeline Posts'), findsOneWidget);
      expect(find.text('Official Circulars'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      // Performance Lenses switch cleanly & never show invented 'avg health'
      expect(find.text('Organizational Performance'), findsOneWidget);
      expect(find.textContaining('avg health'), findsNothing);
      final perfIndustries = find.descendant(
        of: find.byType(DashboardPerformanceSection),
        matching: find.text('Industries'),
      );
      await tester.ensureVisible(perfIndustries);
      await tester.pumpAndSettle();
      await tester.tap(perfIndustries);
      await tester.pumpAndSettle();
      expect(find.text('Technology'), findsOneWidget);
      expect(find.text('Financial Services'), findsOneWidget);

      // Upcoming Conclaves & Top Impact Leaders (ALL CAPS normalized to Title Case!)
      expect(find.text('Ahmedabad Titans Conclave'), findsOneWidget);
      expect(find.text('CHIRAG MALI'), findsNothing);
      expect(find.text('Impacts'), findsOneWidget);
    });

    testWidgets(
        'renders cleanly on small phone (320px), 1.4x text scale, and dark mode without overflow',
        (tester) async {
      await setSuperAdminSession();
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.4),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    DashboardWelcomeHeader(
                      circles: sampleCircles,
                      availableCircles: const [
                        DashboardCircleOption(
                          id: '11111111-1111-4111-8111-111111111111',
                          name: 'Ahmedabad Titans',
                        ),
                        DashboardCircleOption(
                          id: '22222222-2222-4222-8222-222222222222',
                          name: 'Mumbai FinTech Guild',
                        ),
                      ],
                      industries: const ['Technology', 'Financial Services'],
                      selectedCircleId: null,
                      onCircleSelected: (_) {},
                    ),
                    const DashboardHeroCard(
                      metrics: sampleMetrics,
                      totalCirclesCount: 3,
                      activeCirclesCount: 2,
                    ),
                    DashboardActionCenterCard(
                      metrics: sampleMetrics,
                      circles: sampleCircles,
                      selectedCircle: null,
                      onOpenTeamsTab: () {},
                    ),
                    DashboardDomainsSection(
                      metrics: sampleMetrics,
                      selectedCircle: null,
                      onPeersTap: () {},
                    ),
                    DashboardPerformanceSection(
                      metrics: sampleMetrics,
                      circles: sampleCircles,
                      selectedCircle: null,
                      onOpenTeamsTab: () {},
                    ),
                    DashboardQuickActions(
                      metrics: sampleMetrics,
                      selectedCircle: null,
                      onOpenPeersTab: () {},
                      onOpenTeamsTab: () {},
                      onOpenReportsTab: () {},
                    ),
                    DashboardUpcomingEventsSection(
                      circles: sampleCircles,
                      metrics: sampleMetrics,
                      selectedCircle: null,
                    ),
                    DashboardTopImpacters(
                      impacters: sampleImpacters,
                      metrics: sampleMetrics,
                    ),
                    const DashboardRecentActivitySection(
                      metrics: sampleMetrics,
                      selectedCircle: null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Global · 2/3 Circles · 2 Industries'),
        findsOneWidget,
      );
    });
  });

  group('Role-Aware Adaptation & States', () {
    testWidgets(
        'Circle Chair sees single-scope lock (no switcher), Total Coins (no "Q" unit), and 1-on-1 P2Ps — never Revenue or Role Matrix',
        (tester) async {
      await setChairSession();
      await tester.pumpWidget(buildCommandCenter(theme: AppTheme.lightTheme));

      expect(find.text('Chair - Business Growth'), findsOneWidget);
      expect(find.text('Total Coins'), findsOneWidget);
      expect(find.text('999B+'), findsOneWidget); // Never "6.4Q"
      expect(find.textContaining('6.4Q'), findsNothing);
      expect(find.text('Total Revenue'), findsNothing);
      expect(find.text('Role Matrix'), findsNothing);
      expect(find.text('Approvals'), findsNothing);
      expect(find.text('Referrals'), findsWidgets);
      expect(find.text('1-on-1 P2Ps'), findsWidgets);
      expect(find.text('Open Asks'), findsOneWidget);
    });

    testWidgets('Skeleton and Error Recovery states render cleanly',
        (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: DashboardSkeleton()),
                EnterpriseErrorState(
                  message: 'Service temporarily unreachable.',
                  onRetry: () => retried = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });
}
