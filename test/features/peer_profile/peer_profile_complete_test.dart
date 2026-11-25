import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/core/models/leader_permissions.dart';
import 'package:leaderapp/core/network/api_response.dart';
import 'package:leaderapp/core/routes/app_routes.dart';
import 'package:leaderapp/core/theme/app_theme.dart';
import 'package:leaderapp/data/repositories/peers_repository.dart';
import 'package:leaderapp/features/peer_profile/bloc/peer_profile_bloc.dart';
import 'package:leaderapp/features/peer_profile/bloc/peer_profile_event.dart';
import 'package:leaderapp/features/peer_profile/model/peer_profile_model.dart';
import 'package:leaderapp/features/peer_profile/presenter/peer_profile_presenter.dart';
import 'package:leaderapp/features/peer_profile/view/peer_profile_view.dart';
import 'package:leaderapp/features/peers/model/peer_model.dart';

class _FakePeersProfileRepository implements PeersRepository {
  final PeerProfileDetailModel detail;
  bool shouldFail = false;

  _FakePeersProfileRepository(this.detail);

  @override
  Future<ApiResponse<PeerProfileDetailModel>> getPeerProfileDetail(
    String id,
  ) async {
    if (shouldFail) {
      return const ApiResponse<PeerProfileDetailModel>(
        success: false,
        message: 'Forbidden',
      );
    }
    return ApiResponse<PeerProfileDetailModel>(
      success: true,
      data: detail,
    );
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

  const sampleUuid = '11111111-2222-3333-4444-555555555555';
  const basePeer = PeerModel(
    id: sampleUuid,
    initials: 'RP',
    name: 'Rohan Patel',
    company: 'Apex Fintech',
    circle: 'Ahmedabad Titans',
    location: 'Ahmedabad',
    tags: '',
    impactCount: 0,
    dealsFormatted: '',
    coins: 0,
    attendance: '',
    status: 'Active',
  );

  Map<String, dynamic> fullJson({
    bool includeLeadership = true,
    bool includeCompliance = true,
    bool contactAuthorized = true,
  }) {
    return {
      'id': sampleUuid,
      'full_name': 'Rohan Patel',
      'company_name': 'Apex Fintech',
      'circle_name': 'Ahmedabad Titans',
      'bio': 'Building compliant fintech infrastructure for MSMEs.',
      'deals_closed': '₹18.5L',
      'deals_given': '₹10L',
      'deals_received': '₹8.5L',
      'coins': 420,
      'identity': {
        'id': sampleUuid,
        'peer_code': 'PG-105',
        'full_name': 'Rohan Patel',
        'designation': 'Managing Director',
        'company_name': 'Apex Fintech',
        'primary_category': 'Technology',
        'sub_category': 'FinTech',
        'level4_category': 'Payment Infrastructure',
        'city': 'Ahmedabad',
        'district_name': 'Ahmedabad District',
        'circle_name': 'Ahmedabad Titans',
        'account_status': 'Active',
        'is_verified': true,
        'current_leadership_role': includeLeadership ? 'Circle Chair' : null,
        'contact_authorized': contactAuthorized,
        'contact': contactAuthorized
            ? {
                'phone': '+919876543210',
                'email': 'rohan@apexfintech.in',
              }
            : {},
      },
      'business': {
        'company_name': 'Apex Fintech',
        'company_type': 'Private Limited',
        'designation': 'Managing Director',
        'short_bio': 'Building compliant fintech infrastructure for MSMEs.',
        'industry': 'Technology',
        'sub_industry': 'FinTech',
        'level4_category': 'Payment Infrastructure',
        'years_in_business': 8,
        'website': 'https://apexfintech.in',
        'skills': ['Payments', 'Compliance'],
        'i_can_help_with': ['API Integrations'],
        'i_am_looking_for': ['Enterprise CFOs'],
        'completeness_percent': 90,
      },
      'organization': {
        'country': 'India',
        'state': 'Gujarat',
        'district_name': 'Ahmedabad District',
        'city': 'Ahmedabad',
        'membership_type': 'Circle Membership',
        'membership_status': 'Active',
        'joining_date': '2024-03-10',
        'primary_circle': {
          'id': 'c-1',
          'name': 'Ahmedabad Titans',
          'stage': 'Established',
        },
        'circles': [
          {
            'circle_id': 'c-1',
            'circle_name': 'Ahmedabad Titans',
            'role': includeLeadership ? 'Circle Chair' : 'member',
            'status': 'Active',
          },
        ],
      },
      'leadership': {
        'has_leadership_history': includeLeadership,
        'current_positions': includeLeadership
            ? [
                {
                  'role_key': 'circle_chair',
                  'role_label': 'Circle Chair',
                  'scope_type': 'circle',
                  'circle_id': 'c-1',
                  'circle_name': 'Ahmedabad Titans',
                  'started_at': '2026-01-01',
                  'is_current': true,
                },
              ]
            : [],
        'historical_positions': [],
        'reports_submitted_count': includeLeadership ? 4 : 0,
        'recent_reports': [],
      },
      'collaborations': {
        'deals_logged_count': 3,
        'deals_given_count': 2,
        'deals_received_count': 1,
        'deals_given_value_formatted': '₹10L',
        'deals_received_value_formatted': '₹8.5L',
        'deals_total_value_formatted': '₹18.5L',
        'cross_circle_deals_count': 1,
        'referrals_given_count': 5,
        'referrals_received_count': 3,
        'collaboration_asks_count': 2,
        'referral_asks_count': 1,
        'help_asks_count': 1,
        'introduced_peers_count': 2,
        'recent_deals': [
          {
            'id': 'd-1',
            'direction': 'given',
            'counterpart_name': 'Meera Shah',
            'amount_formatted': '₹10L',
            'business_type': 'Enterprise SaaS',
          },
        ],
        'recent_asks': [
          {
            'id': 'ask-1',
            'flow_name': 'Collaboration Ask',
            'title': 'Need NBFC Compliance Partner',
            'status': 'open',
          },
        ],
      },
      'life_impact': {
        'counts': {
          'total': 2,
          'pending': 1,
          'approved': 1,
          'rejected': 0,
          'total_lives_impacted': 5,
        },
        'can_moderate_impacts': true,
        'categories_breakdown': [
          {'category': 'Mentorship', 'count': 2},
        ],
        'submissions': [
          {
            'id': 'li-pending',
            'title': 'Guided MSME Export Launch',
            'impact_category': 'Mentorship',
            'description': 'Helped onboard export documentation.',
            'lives_impacted': 4,
            'status': 'pending',
            'status_label': 'Pending',
            'can_approve': true,
            'can_reject': true,
          },
          {
            'id': 'li-approved',
            'title': 'Connected Seed Investor',
            'impact_category': 'Mentorship',
            'description': 'Facilitated warm investor intro.',
            'lives_impacted': 1,
            'status': 'approved',
            'status_label': 'Approved',
          },
        ],
      },
      'performance': {
        'circle_attendance': {
          'attended': 11,
          'absent': 1,
          'late': 0,
          'excused': 0,
          'total_recorded': 12,
          'attendance_rate_percent': 91.7,
        },
        'events': {'registered_count': 4, 'attended_count': 3},
        'p2p_meetings_count': 14,
        'testimonials_given_count': 2,
        'testimonials_received_count': 3,
        'posts_count': 2,
        'creatives_count': 1,
        'reports_submitted_count': 4,
        'coin_milestone_title': 'Catalyst 500',
      },
      'compliance': includeCompliance
          ? {
              'is_visible': true,
              'account_status': 'Active',
              'approval_status': 'Approved',
              'membership_status': 'Active',
              'renewal_status': 'Current',
              'expires_at': '2027-03-10',
              'days_remaining': 105,
              'subscription_summary': {
                'plan_name': 'Annual Peer Plan',
                'price': '₹36,000',
              },
            }
          : {'is_visible': false},
      'timeline': [
        {
          'id': 'tl-1',
          'event_type': 'life_impact',
          'title': 'Submitted Life Impact: Guided MSME Export Launch',
          'subtitle': '4 lives impacted',
          'status': 'pending',
          'date': '2026-11-24T10:00:00Z',
          'reference_type': 'life_impact',
          'reference_id': 'li-pending',
        },
      ],
    };
  }

  Future<void> setSuperAdmin() async {
    await SessionManager().setAuthSession(
      token: 'sa-token',
      session: const UserSession(
        id: 'sa-1',
        name: 'Founder Admin',
        email: 'founder@peersglobal.com',
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

  group('PeerProfile section visibility & zero-fake-data rules', () {
    test('PeerProfileDetailModel leaves empty optional fields blank rather than fabricating',
        () {
      final minimal = PeerProfileDetailModel.fromJson(const {
        'id': sampleUuid,
        'full_name': 'Minimal Peer',
      });
      expect(minimal.dealsClosed, isEmpty);
      expect(minimal.dealsGiven, isEmpty);
      expect(minimal.dealsReceived, isEmpty);
      expect(minimal.attendanceRate, isEmpty);
      expect(minimal.joinedDate, isEmpty);
      expect(minimal.bio, isEmpty);
      expect(minimal.leadership?.hasAnyData ?? false, isFalse);
    });

    test('resolveVisibleSections hides Leadership & empty sections for minimal Peer',
        () {
      final ordinaryModel = PeerProfileDetailModel.fromJson(
        fullJson(includeLeadership: false, includeCompliance: false),
      );
      final sections = PeerProfilePresenter.resolveVisibleSections(
        basePeer,
        ordinaryModel,
      );
      expect(sections.contains(PeerProfileSection.overview), isTrue);
      expect(sections.contains(PeerProfileSection.leadership), isFalse);
    });

    test('canShowContactActions blocks contact actions when unauthorized', () {
      final unauth = PeerProfileDetailModel.fromJson(
        fullJson(contactAuthorized: false),
      );
      expect(
        PeerProfilePresenter.canShowContactActions(
          basePeer,
          unauth,
          hasPermission: true,
        ),
        isFalse,
      );
    });
  });

  group('PeerProfileView section navigation & compliance gating', () {
    testWidgets(
        'renders all sections cleanly, shows compliance when authorized, and filters Life Impact tab',
        (tester) async {
      await setSuperAdmin();
      final detail = PeerProfileDetailModel.fromJson(fullJson());
      final bloc = PeerProfileBloc(
        peersRepository: _FakePeersProfileRepository(detail),
      )..add(const LoadPeerProfile(basePeer));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: PeerProfileView(peer: basePeer, bloc: bloc),
        ),
      );
      await tester.pumpAndSettle();

      // Overview renders pending callout + compliance card
      expect(find.text('1 Pending Life Impact Submission'), findsOneWidget);
      expect(find.text('ACCOUNT & COMPLIANCE'), findsOneWidget);
      expect(find.text('Annual Peer Plan (₹36,000)'), findsOneWidget);

      // Navigate via Business chip
      await tester.tap(find.text('Business').first);
      await tester.pumpAndSettle();
      expect(find.text('COMPANY & INDUSTRY OVERVIEW'), findsOneWidget);
      expect(find.text('https://apexfintech.in'), findsOneWidget);

      // Navigate to Leadership section
      await tester.tap(find.text('Leadership').first);
      await tester.pumpAndSettle();
      expect(find.text('CURRENT LEADERSHIP ASSIGNMENTS'), findsOneWidget);

      // Navigate to Collaborations section (Deals separated from Asks)
      await tester.tap(find.text('Collaborations').first);
      await tester.pumpAndSettle();
      expect(find.text('BUSINESS DEALS (CLOSED VALUE)'), findsOneWidget);
      expect(find.text('BUSINESS ASKS & SUPPORT REQUESTS'), findsOneWidget);

      // Navigate to Life Impact section and filter Pending
      await tester.ensureVisible(find.text('Life Impact').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Life Impact').first);
      await tester.pumpAndSettle();
      expect(find.text('Guided MSME Export Launch'), findsOneWidget);
      expect(find.text('Connected Seed Investor'), findsOneWidget);

      await tester.tap(find.text('Pending (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Guided MSME Export Launch'), findsOneWidget);
      expect(find.text('Connected Seed Investor'), findsNothing);
    });

    testWidgets(
        'hides Compliance card when compliance.isVisible is false & renders on 320px dark screen without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await setSuperAdmin();
      final detail = PeerProfileDetailModel.fromJson(
        fullJson(includeLeadership: false, includeCompliance: false),
      );
      final bloc = PeerProfileBloc(
        peersRepository: _FakePeersProfileRepository(detail),
      )..add(const LoadPeerProfile(basePeer));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PeerProfileView(peer: basePeer, bloc: bloc),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ACCOUNT & COMPLIANCE'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  test('AppRoutes.onGenerateRoute resolves lifeImpactDetail route', () {
    final route = AppRoutes.onGenerateRoute(
      const RouteSettings(
        name: AppRoutes.lifeImpactDetail,
        arguments: {'id': 'impact-77'},
      ),
    );
    expect(route, isNotNull);
  });
}
