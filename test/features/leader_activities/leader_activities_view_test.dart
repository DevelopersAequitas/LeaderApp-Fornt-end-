import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/core/models/leader_permissions.dart';
import 'package:leaderapp/core/network/api_response.dart';
import 'package:leaderapp/core/theme/app_theme.dart';
import 'package:leaderapp/data/repositories/activities_repository.dart';
import 'package:leaderapp/data/repositories/peers_repository.dart';
import 'package:leaderapp/features/impacts/model/life_impact_detail_model.dart';
import 'package:leaderapp/features/leader_activities/bloc/leader_activities_bloc.dart';
import 'package:leaderapp/features/leader_activities/bloc/leader_activities_event.dart';
import 'package:leaderapp/features/leader_activities/model/leader_activity_item_model.dart';
import 'package:leaderapp/features/leader_activities/view/leader_activities_view.dart';
import 'package:leaderapp/features/peers/model/peer_model.dart';

class _FakeActivitiesRepository implements ActivitiesRepository {
  final Map<String, LeaderActivitiesPayload> payloads;
  final List<LeaderActivityItemModel> fallbackItems;
  String? lastApprovedId;
  String? lastApprovedCategory;
  String? lastApprovedImpactId;
  String? lastRejectedImpactId;
  String? lastRejectReason;

  _FakeActivitiesRepository({
    this.payloads = const {},
    this.fallbackItems = const [],
  });

  @override
  Future<ApiResponse<LifeImpactDetailModel>> getImpactDetail(String id) async {
    return ApiResponse<LifeImpactDetailModel>(
      success: true,
      data: LifeImpactDetailModel(id: id, title: 'Life Impact', status: 'pending'),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> approveImpact({
    required String id,
    String? remarks,
  }) async {
    lastApprovedImpactId = id;
    return const ApiResponse<Map<String, dynamic>>(
      success: true,
      message: 'Approved',
      data: {},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> rejectImpact({
    required String id,
    required String reason,
  }) async {
    lastRejectedImpactId = id;
    lastRejectReason = reason;
    return const ApiResponse<Map<String, dynamic>>(
      success: true,
      message: 'Rejected',
      data: {},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> approvePendingRequest({
    required String id,
    String? category,
    String? notes,
  }) async {
    lastApprovedId = id;
    lastApprovedCategory = category;
    return const ApiResponse<Map<String, dynamic>>(
      success: true,
      message: 'Approved',
      data: {},
    );
  }

  @override
  Future<ApiResponse<LeaderActivitiesPayload>> getActivitiesPayloadByType({
    required String type,
    String? circleId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final p = payloads[type];
    if (p != null) {
      return ApiResponse<LeaderActivitiesPayload>(success: true, data: p);
    }
    return const ApiResponse<LeaderActivitiesPayload>(
      success: true,
      data: LeaderActivitiesPayload(peers: [], items: []),
    );
  }

  @override
  Future<List<LeaderActivityItemModel>> getExtendedActivitiesFallback({
    required String normalizedType,
    String? circleId,
  }) async =>
      fallbackItems;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Future<dynamic>.value(null);
}

class _FakePeersRepository implements PeersRepository {
  final List<PeerModel> peers;
  _FakePeersRepository(this.peers);

  @override
  Future<ApiResponse<List<PeerModel>>> getPeers({
    String? circleId,
    String? status,
    String? search,
    int? page,
    int? perPage,
    bool global = false,
  }) async {
    return ApiResponse<List<PeerModel>>(success: true, data: peers);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Future<dynamic>.value(null);
}

void main() {
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  const samplePeers = <PeerModel>[
    PeerModel(
      id: 'p-1',
      initials: 'HC',
      name: 'HARSH CHAUHAN',
      company: 'Aequitas Infotech',
      circle: 'Ahmedabad Titans',
      location: 'Ahmedabad',
      tags: 'FinTech SaaS',
      impactCount: 1895,
      dealsFormatted: '₹10L',
      coins: 1200,
      attendance: '96%',
      status: 'Active',
      designation: 'Developer',
      isVerified: true,
    ),
    PeerModel(
      id: 'p-2',
      initials: 'RP',
      name: 'sandeep pandya',
      company: 'IT Ventures',
      circle: 'Ahmedabad Titans',
      location: 'Mumbai',
      tags: 'Enterprise Cloud',
      impactCount: 2702,
      dealsFormatted: '₹5L',
      coins: 900,
      attendance: '92%',
      status: 'Active',
      designation: 'Founder & CEO',
      isVerified: true,
    ),
  ];

  Future<void> setSuperAdmin() async {
    await SessionManager().setAuthSession(
      token: 'sa-token',
      session: const UserSession(
        id: 'sa-1',
        name: 'Chirag Mali',
        email: 'admin@peersglobal.com',
        phone: '+919999999999',
        role: UserRole.superAdmin,
        regionalScope: 'Global',
        managedCircles: ['Ahmedabad Titans'],
        memberSince: 'Aug 2025',
        capabilitiesCount: 21,
      ),
      permissions: LeaderPermissions.allGranted,
    );
  }

  Widget wrapView(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: child,
    );
  }

  group('LeaderActivitiesView — Direct Peer List, Top Contributors Tab & Filters',
      () {
    for (final activityType in const [
      'p2p-meetings',
      'referrals',
      'business-deals',
      'impacts',
      'coins',
      'open-asks',
      'visitor-registrations',
      'event-registrations',
    ]) {
      final config = LeaderActivityCategoryConfig.fromType(activityType);

      testWidgets(
          '$activityType main Peers list shows direct Peers without duplicate counts and respects Top Contributors tab gating',
          (tester) async {
        await setSuperAdmin();

        final bloc = LeaderActivitiesBloc(
          activitiesRepository: _FakeActivitiesRepository(
            payloads: {
              activityType: LeaderActivitiesPayload(
                peers: [
                  LeaderRankedPeerModel(
                    rank: 1,
                    peer: samplePeers[0],
                    metricCount: 36,
                    metricLabel: config.unitLabel,
                    metricDisplay: '36',
                  ),
                  LeaderRankedPeerModel(
                    rank: 2,
                    peer: samplePeers[1],
                    metricCount: 12,
                    metricLabel: config.unitLabel,
                    metricDisplay: '12',
                  ),
                ],
                items: [
                  LeaderActivityItemModel(
                    id: 'item-1',
                    type: activityType,
                    title: 'Activity Entry',
                    subtitle: 'Sub',
                    description: 'Desc',
                    status: 'Active',
                    date: '2026-11-24',
                    peerId: 'p-1',
                    peerName: 'HARSH CHAUHAN',
                    city: 'Ahmedabad',
                    designation: 'Developer',
                    company: 'Aequitas Infotech',
                    category: 'FinTech SaaS',
                    circleName: 'Ahmedabad Titans',
                  ),
                ],
                totalActivities: 36,
                totalPeers: 2,
                total: 1,
                unitLabel: config.unitLabel,
              ),
            },
          ),
          peersRepository: _FakePeersRepository(samplePeers),
        )..add(LoadLeaderActivities(type: activityType));

        await tester.pumpWidget(
          wrapView(
            LeaderActivitiesView(
              activityType: activityType,
              bloc: bloc,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(config.title), findsOneWidget);
        // Both uppercase and lowercase names are normalized cleanly to Title Case
        expect(find.text('Harsh Chauhan'), findsOneWidget);
        expect(find.text('Sandeep Pandya'), findsOneWidget);
        expect(find.text('HARSH CHAUHAN'), findsNothing);
        expect(find.text('sandeep pandya'), findsNothing);
        expect(find.textContaining('Activity Records'), findsNothing);

        // Main Peers list omits counts & rank badges
        expect(find.text('36'), findsNothing);
        expect(find.text('12'), findsNothing);
        expect(find.text('#1'), findsNothing);

        if (config.supportsTopContributorsTab) {
          expect(find.text('Peers'), findsOneWidget);
          expect(find.text('Top Contributors'), findsOneWidget);

          // Switching to Top Contributors tab reveals contributor rankings
          await tester.tap(find.text('Top Contributors'));
          await tester.pumpAndSettle();

          expect(find.text('#1'), findsOneWidget);
          expect(find.text('36 ${config.unitLabel}'), findsOneWidget);
        } else {
          expect(find.text('Top Contributors'), findsNothing);
        }
      });
    }

    testWidgets(
        'Recent sort and Type filter chips filter p2p-meetings main Peer list accurately',
        (tester) async {
      await setSuperAdmin();

      final bloc = LeaderActivitiesBloc(
        activitiesRepository: _FakeActivitiesRepository(
          payloads: {
            'p2p-meetings': LeaderActivitiesPayload(
              peers: [
                LeaderRankedPeerModel(
                  rank: 1,
                  peer: samplePeers[0], // Harsh — older Online meeting
                  metricCount: 15,
                  metricLabel: 'Meetings',
                  metricDisplay: '15',
                ),
                LeaderRankedPeerModel(
                  rank: 2,
                  peer: samplePeers[1], // Sandeep — newest In-Person meeting
                  metricCount: 4,
                  metricLabel: 'Meetings',
                  metricDisplay: '4',
                ),
              ],
              items: const [
                LeaderActivityItemModel(
                  id: 'm-1',
                  type: 'p2p-meetings',
                  title: 'Online Discovery Call',
                  subtitle: 'online',
                  description: 'Discussed roadmap',
                  status: 'Completed',
                  date: '2026-11-20T10:00:00Z',
                  peerId: 'p-1',
                  peerName: 'HARSH CHAUHAN',
                  city: 'Ahmedabad',
                  designation: 'Developer',
                  company: 'Aequitas Infotech',
                  category: 'FinTech SaaS',
                  circleName: 'Ahmedabad Titans',
                ),
                LeaderActivityItemModel(
                  id: 'm-2',
                  type: 'p2p-meetings',
                  title: 'Coffee Conclave Sync',
                  subtitle: 'offline',
                  description: 'Met in person',
                  status: 'Completed',
                  date: '2026-11-25T09:00:00Z',
                  peerId: 'p-2',
                  peerName: 'sandeep pandya',
                  city: 'Mumbai',
                  designation: 'Founder & CEO',
                  company: 'IT Ventures',
                  category: 'Enterprise Cloud',
                  circleName: 'Ahmedabad Titans',
                ),
              ],
            ),
          },
        ),
        peersRepository: _FakePeersRepository(samplePeers),
      )..add(const LoadLeaderActivities(type: 'p2p-meetings'));

      await tester.pumpWidget(
        wrapView(
          LeaderActivitiesView(
            activityType: 'p2p-meetings',
            bloc: bloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default order follows rank: Harsh above Sandeep
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('In-Person'), findsOneWidget);

      final harshInitialY = tester.getTopLeft(find.text('Harsh Chauhan')).dy;
      final sandeepInitialY =
          tester.getTopLeft(find.text('Sandeep Pandya')).dy;
      expect(harshInitialY, lessThan(sandeepInitialY));

      // Tap Recent -> Sandeep (2026-11-25) rises above Harsh (2026-11-20)
      await tester.tap(find.text('Recent'));
      await tester.pumpAndSettle();

      final sandeepRecentY =
          tester.getTopLeft(find.text('Sandeep Pandya')).dy;
      final harshRecentY = tester.getTopLeft(find.text('Harsh Chauhan')).dy;
      expect(sandeepRecentY, lessThan(harshRecentY));

      // Tap In-Person -> only Sandeep remains visible
      await tester.tap(find.text('In-Person'));
      await tester.pumpAndSettle();

      expect(find.text('Sandeep Pandya'), findsOneWidget);
      expect(find.text('Harsh Chauhan'), findsNothing);

      // Tap All -> restores both Peers
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('Sandeep Pandya'), findsOneWidget);
      expect(find.text('Harsh Chauhan'), findsOneWidget);
    });

    testWidgets(
        'falls back to activity items when server returns no pre-ranked peers and supports type filters on open-asks',
        (tester) async {
      await setSuperAdmin();

      final bloc = LeaderActivitiesBloc(
        activitiesRepository: _FakeActivitiesRepository(
          fallbackItems: const [
            LeaderActivityItemModel(
              id: 'ask-1',
              type: 'collaboration-asks',
              title: 'Joint SaaS Expansion',
              subtitle: 'COLLABORATION',
              description: 'Looking for partner',
              status: 'Open',
              date: '2026-11-24',
              peerId: 'p-1',
              peerName: 'HARSH CHAUHAN',
              city: 'Ahmedabad',
              designation: 'Developer',
              company: 'Aequitas Infotech',
              category: 'FinTech SaaS',
              circleName: 'Ahmedabad Titans',
            ),
            LeaderActivityItemModel(
              id: 'ask-2',
              type: 'referral-asks',
              title: 'Enterprise Intro Needed',
              subtitle: 'REFERRAL',
              description: 'Need intro to CFO',
              status: 'Open',
              date: '2026-11-25',
              peerId: 'p-2',
              peerName: 'sandeep pandya',
              city: 'Mumbai',
              designation: 'Founder & CEO',
              company: 'IT Ventures',
              category: 'Enterprise Cloud',
              circleName: 'Ahmedabad Titans',
            ),
          ],
        ),
        peersRepository: _FakePeersRepository(samplePeers),
      )..add(const LoadLeaderActivities(type: 'open-asks'));

      await tester.pumpWidget(
        wrapView(
          LeaderActivitiesView(
            activityType: 'open-asks',
            bloc: bloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open Asks'), findsOneWidget);
      expect(find.text('Top Contributors'), findsNothing);
      expect(find.text('Collaboration'), findsOneWidget);
      expect(find.text('Referral'), findsOneWidget);

      await tester.tap(find.text('Referral'));
      await tester.pumpAndSettle();

      expect(find.text('Sandeep Pandya'), findsOneWidget);
      expect(find.text('Harsh Chauhan'), findsNothing);
    });

    testWidgets(
        'pending-requests preserves Accept/Reject actions and filters by category & recent',
        (tester) async {
      await setSuperAdmin();

      final bloc = LeaderActivitiesBloc(
        activitiesRepository: _FakeActivitiesRepository(
          payloads: {
            'pending-requests': const LeaderActivitiesPayload(
              peers: [],
              items: [
                LeaderActivityItemModel(
                  id: 'req-1',
                  type: 'pending-requests',
                  title: 'Coin Claim Audit',
                  subtitle: 'Ahmedabad Titans',
                  description: 'Submitted P2P proof.',
                  status: 'pending',
                  date: '2026-11-20',
                  requestCategory: 'coin_claims',
                  peerId: 'p-1',
                  peerName: 'HARSH CHAUHAN',
                  city: 'Ahmedabad',
                  designation: 'Developer',
                  company: 'Aequitas Infotech',
                  category: 'FinTech SaaS',
                  circleName: 'Ahmedabad Titans',
                ),
                LeaderActivityItemModel(
                  id: 'req-2',
                  type: 'pending-requests',
                  title: 'Visitor Pass Approval',
                  subtitle: 'Ahmedabad Titans',
                  description: 'Invited guest for conclave.',
                  status: 'pending',
                  date: '2026-11-25',
                  requestCategory: 'visitor_registrations',
                  peerId: 'p-2',
                  peerName: 'sandeep pandya',
                  city: 'Mumbai',
                  designation: 'Founder & CEO',
                  company: 'IT Ventures',
                  category: 'Enterprise Cloud',
                  circleName: 'Ahmedabad Titans',
                ),
              ],
              totalActivities: 2,
              totalPeers: 2,
              total: 2,
              unitLabel: 'Requests',
            ),
          },
        ),
        peersRepository: _FakePeersRepository(samplePeers),
      )..add(const LoadLeaderActivities(type: 'pending-requests'));

      await tester.pumpWidget(
        wrapView(
          LeaderActivitiesView(
            activityType: 'pending-requests',
            bloc: bloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pending Approvals'), findsOneWidget);
      expect(find.text('Top Contributors'), findsNothing);
      expect(find.text('Coin Claims'), findsOneWidget);
      expect(find.text('Visitors'), findsOneWidget);
      expect(find.text('Accept'), findsNWidgets(2));

      await tester.tap(find.text('Coin Claims'));
      await tester.pumpAndSettle();

      expect(find.text('Harsh Chauhan'), findsOneWidget);
      expect(find.text('Sandeep Pandya'), findsNothing);
    });

    testWidgets(
        'renders full tabbed & filtered screen + Top Contributors row cleanly in dark mode at 320px width and 1.4x text scale without overflow',
        (tester) async {
      await setSuperAdmin();
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final bloc = LeaderActivitiesBloc(
        activitiesRepository: _FakeActivitiesRepository(
          payloads: {
            'p2p-meetings': LeaderActivitiesPayload(
              peers: [
                LeaderRankedPeerModel(
                  rank: 1,
                  peer: samplePeers[0],
                  metricCount: 36,
                  metricLabel: 'Meetings',
                  metricDisplay: '36',
                  latestActivityAt: DateTime(2026, 11, 25, 12),
                  activityTags: const ['Online'],
                ),
                LeaderRankedPeerModel(
                  rank: 2,
                  peer: samplePeers[1],
                  metricCount: 12,
                  metricLabel: 'Meetings',
                  metricDisplay: '12',
                  latestActivityAt: DateTime(2026, 11, 24, 12),
                  activityTags: const ['In-Person'],
                ),
              ],
              items: const [],
            ),
          },
        ),
        peersRepository: _FakePeersRepository(samplePeers),
      )..add(const LoadLeaderActivities(type: 'p2p-meetings'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.4),
            ),
            child: LeaderActivitiesView(
              activityType: 'p2p-meetings',
              bloc: bloc,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Peers'), findsOneWidget);
      expect(find.text('Top Contributors'), findsOneWidget);

      await tester.tap(find.text('Top Contributors'));
      await tester.pumpAndSettle();

      expect(find.text('#1'), findsOneWidget);
      expect(find.text('36 Meetings'), findsOneWidget);
    });

    testWidgets(
        'impacts Pending filter shows pending Life Impact items with Accept/Reject buttons and approves via pending_impacts',
        (tester) async {
      await setSuperAdmin();
      final repo = _FakeActivitiesRepository(
        payloads: {
          'impacts': LeaderActivitiesPayload(
            peers: [
              LeaderRankedPeerModel(
                rank: 1,
                peer: samplePeers[0],
                metricCount: 5,
                metricLabel: 'Impacts',
                metricDisplay: '5',
              ),
            ],
            items: const [
              LeaderActivityItemModel(
                id: 'imp-approved',
                type: 'impacts',
                title: 'Mentored Peer Startup',
                subtitle: 'mentor',
                description: 'Helped launch product.',
                status: 'Approved',
                date: '2026-11-20',
                badgeLabel: 'mentor',
                peerId: 'p-1',
                peerName: 'HARSH CHAUHAN',
                city: 'Ahmedabad',
                designation: 'Developer',
                company: 'Aequitas Infotech',
                category: 'FinTech SaaS',
                circleName: 'Ahmedabad Titans',
              ),
              LeaderActivityItemModel(
                id: 'imp-pending',
                type: 'impacts',
                title: 'Supported Peer Hiring',
                subtitle: 'mentor',
                description: 'Referred 3 senior engineers.',
                status: 'pending',
                date: '2026-11-25',
                badgeLabel: 'mentor',
                peerId: 'p-2',
                peerName: 'sandeep pandya',
                city: 'Mumbai',
                designation: 'Founder & CEO',
                company: 'IT Ventures',
                category: 'Enterprise Cloud',
                circleName: 'Ahmedabad Titans',
                requestCategory: 'pending_impacts',
              ),
            ],
            totalActivities: 2,
            totalPeers: 1,
            total: 2,
            unitLabel: 'Impacts',
          ),
        },
      );

      final bloc = LeaderActivitiesBloc(
        activitiesRepository: repo,
        peersRepository: _FakePeersRepository(samplePeers),
      )..add(const LoadLeaderActivities(type: 'impacts'));

      await tester.pumpWidget(
        wrapView(
          LeaderActivitiesView(
            activityType: 'impacts',
            bloc: bloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Life Impacts'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);

      // Default view shows Peers list without moderation buttons
      expect(find.text('Accept'), findsNothing);

      // Tap Pending filter -> switches to actionable moderation cards
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();

      expect(find.text('Supported Peer Hiring'), findsOneWidget);
      expect(find.text('Mentored Peer Startup'), findsNothing);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      // Confirmation dialog opens before approving
      expect(find.text('Approve Life Impact'), findsOneWidget);
      await tester.tap(find.text('Confirm Approval'));
      await tester.pumpAndSettle();

      expect(repo.lastApprovedImpactId, 'imp-pending');
    });

    testWidgets(
        'impacts Pending filter hides Accept/Reject for non-reviewer roles (Circle Chair) and allows DED',
        (tester) async {
      await SessionManager().setAuthSession(
        token: 'chair-token',
        session: const UserSession(
          id: 'chair-1',
          name: 'Chair User',
          email: 'chair@peersglobal.com',
          phone: '+919999999998',
          role: UserRole.circleChair,
          regionalScope: 'Ahmedabad Titans',
          managedCircles: ['Ahmedabad Titans'],
          memberSince: 'Jan 2025',
          capabilitiesCount: 5,
        ),
        permissions: LeaderPermissions.allGranted,
      );

      final repo = _FakeActivitiesRepository(
        payloads: {
          'impacts': LeaderActivitiesPayload(
            peers: const [],
            items: const [
              LeaderActivityItemModel(
                id: 'imp-pending-chair',
                type: 'impacts',
                title: 'Supported Peer Hiring',
                subtitle: 'mentor',
                description: 'Referred 3 senior engineers.',
                status: 'pending',
                date: '2026-11-25',
                peerId: 'p-2',
                peerName: 'sandeep pandya',
                city: 'Mumbai',
                designation: 'Founder & CEO',
                company: 'IT Ventures',
                category: 'Enterprise Cloud',
                circleName: 'Ahmedabad Titans',
                requestCategory: 'pending_impacts',
              ),
            ],
            totalActivities: 1,
            totalPeers: 0,
            total: 1,
            unitLabel: 'Impacts',
          ),
        },
      );

      final bloc = LeaderActivitiesBloc(
        activitiesRepository: repo,
        peersRepository: _FakePeersRepository(samplePeers),
      )..add(const LoadLeaderActivities(type: 'impacts'));

      await tester.pumpWidget(
        wrapView(
          LeaderActivitiesView(
            activityType: 'impacts',
            bloc: bloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();

      expect(find.text('Supported Peer Hiring'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });
  });
}
