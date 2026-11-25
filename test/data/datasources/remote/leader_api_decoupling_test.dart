import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/constants/api_endpoints.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/core/network/api_client.dart';
import 'package:leaderapp/core/network/api_response.dart';
import 'package:leaderapp/data/datasources/remote/activities_remote_datasource.dart';
import 'package:leaderapp/data/datasources/remote/dashboard_remote_datasource.dart';

class _RecordingFakeApiClient implements ApiClient {
  final List<String> requestedUrls = [];
  final Map<String, dynamic Function(Map<String, dynamic>? queryParameters)>
  handlers = {};

  @override
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJsonT,
  }) async {
    requestedUrls.add(url);
    final handler = handlers[url];
    if (handler == null) {
      return ApiResponse<T>(
        success: false,
        message: 'Unhandled test URL: $url',
      );
    }

    final raw = handler(queryParameters);
    if (raw is ApiResponse<T>) {
      return raw;
    }
    final parsed = fromJsonT != null ? fromJsonT(raw) : raw as T;
    return ApiResponse<T>(success: true, data: parsed);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('P0 Batch 1: Leader API Decoupling', () {
    late _RecordingFakeApiClient fakeApiClient;
    late DashboardRemoteDataSource dashboardDataSource;
    late ActivitiesRemoteDataSource activitiesDataSource;

    setUp(() {
      fakeApiClient = _RecordingFakeApiClient();
      dashboardDataSource = DashboardRemoteDataSource(apiClient: fakeApiClient);
      activitiesDataSource = ActivitiesRemoteDataSource(
        apiClient: fakeApiClient,
      );
    });

    test(
      'DashboardRemoteDataSource uses /leader/* endpoints and never /admin/* for superAdmin',
      () async {
        await SessionManager().updateFromAuthProfile({
          'id': '00000000-0000-0000-0000-000000000001',
          'name': 'Global Founder',
          'email': 'founder@peersglobal.com',
          'phone': '9999999999',
          'role': 'superAdmin',
          'regional_scope': 'Global',
        });

        fakeApiClient.handlers[ApiEndpoints.dashboardMetrics] = (_) => {
          'total_peers': 12,
          'total_p2p_meetings': 4,
          'total_business_deals': 2,
          'total_referrals': 3,
        };
        fakeApiClient.handlers[ApiEndpoints.leaderLeadsCounts] = (_) => {
          'entrepreneur_certification': 5,
          'leadership_certification': 2,
          'partner_with_us': 1,
          'become_speaker': 3,
          'become_mentor': 4,
          'story_submissions': 6,
        };
        fakeApiClient.handlers[ApiEndpoints.leaderPendingRequestsSummary] =
            (_) => {
              'breakdown': {
                'visitor_registrations': 7,
                'coin_claims': 2,
                'certifications': 7,
                'event_registrations': 9,
              },
            };
        fakeApiClient.handlers[ApiEndpoints.leaderActivitiesByType('posts')] =
            (_) => {'peers': <dynamic>[], 'items': <dynamic>[]};
        fakeApiClient.handlers[ApiEndpoints.leaderActivitiesByType(
          'pending-requests',
        )] = (_) => {'peers': <dynamic>[], 'items': <dynamic>[]};
        fakeApiClient.handlers[ApiEndpoints.leaderActivitiesByType(
          'mentor-applications',
        )] = (_) => {'peers': <dynamic>[], 'items': <dynamic>[]};
        fakeApiClient.handlers[ApiEndpoints.leaderPosts] = (_) => {
          'items': [
            {
              'id': 'p1',
              'post_type': 'creative',
              'media_url': 'https://example.com/a.png',
            },
            {'id': 'p2', 'post_type': 'general'},
          ],
          'pagination': {'total': 11},
        };
        fakeApiClient.handlers[ApiEndpoints.peers] = (_) => [];
        fakeApiClient.handlers[ApiEndpoints.circulars] = (_) => [
          {'id': 'c1'},
        ];
        fakeApiClient.handlers[ApiEndpoints.leaderPendingRequests] = (_) => [
          {'id': 'req1'},
          {'id': 'req2'},
        ];

        final res = await dashboardDataSource.getMetrics();

        expect(res.success, isTrue);
        expect(res.data, isNotNull);
        expect(res.data!.entrepreneurCertifications, 5);
        expect(res.data!.leadershipCertifications, 2);
        expect(res.data!.posts, 11);
        expect(res.data!.creatives, 1);
        expect(res.data!.pendingRequestsCount, 2);
        expect(res.data!.visitorRegistrations, 7);

        expect(
          fakeApiClient.requestedUrls,
          containsAll([
            ApiEndpoints.leaderLeadsCounts,
            ApiEndpoints.leaderPendingRequestsSummary,
            ApiEndpoints.leaderPosts,
            ApiEndpoints.leaderPendingRequests,
          ]),
        );
        expect(
          fakeApiClient.requestedUrls.where((u) => u.contains('/admin/')),
          isEmpty,
        );
      },
    );

    test(
      'DashboardRemoteDataSource uses /leader/* endpoints for scoped circleFounder',
      () async {
        await SessionManager().updateFromAuthProfile({
          'id': '00000000-0000-0000-0000-000000000002',
          'name': 'Circle Founder',
          'email': 'cf@peersglobal.com',
          'phone': '8888888888',
          'role': 'circleFounder',
          'regional_scope': 'Ahmedabad Circle',
          'managed_circles': ['Ahmedabad Circle'],
        });

        fakeApiClient.handlers[ApiEndpoints.dashboardMetrics] = (_) => {
          'total_peers': 8,
        };
        fakeApiClient.handlers[ApiEndpoints.leaderPendingRequestsSummary] =
            (_) => {'total_pending': 3, 'breakdown': {}};

        final res = await dashboardDataSource.getMetrics();

        expect(res.success, isTrue);
        expect(res.data!.pendingRequestsCount, 3);
        expect(
          fakeApiClient.requestedUrls,
          contains(ApiEndpoints.leaderPendingRequestsSummary),
        );
        expect(
          fakeApiClient.requestedUrls.where((u) => u.contains('/admin/')),
          isEmpty,
        );
      },
    );

    test(
      'ActivitiesRemoteDataSource calls /leader/posts, /leader/pending-requests, and /leader/leads/{type} with zero /admin/ calls',
      () async {
        await SessionManager().updateFromAuthProfile({
          'id': '00000000-0000-0000-0000-000000000003',
          'name': 'Country Director',
          'email': 'eed@peersglobal.com',
          'phone': '7777777777',
          'role': 'countryDirector',
          'regional_scope': 'India',
        });

        fakeApiClient.handlers[ApiEndpoints.leaderActivitiesByType('posts')] =
            (_) => {'peers': <dynamic>[], 'items': <dynamic>[]};
        fakeApiClient.handlers[ApiEndpoints.leaderActivitiesByType(
          'pending-requests',
        )] = (_) => {'peers': <dynamic>[], 'items': <dynamic>[]};
        fakeApiClient.handlers[ApiEndpoints.leaderActivitiesByType(
          'mentor-applications',
        )] = (_) => {'peers': <dynamic>[], 'items': <dynamic>[]};
        fakeApiClient.handlers[ApiEndpoints.leaderPosts] = (_) => {
          'items': [
            {
              'id': 'post-1',
              'post_type': 'creative',
              'title': 'Circle Launch',
              'content_text': 'Welcome!',
              'media_url': 'https://example.com/1.png',
              'created_at': '2026-04-01T10:00:00Z',
              'user': {'display_name': 'Aarav Shah', 'company_name': 'Apex'},
            },
          ],
        };
        fakeApiClient.handlers[ApiEndpoints.leaderPendingRequests] = (_) => {
          'data': [
            {
              'id': 'pend-1',
              'applicant_name': 'Riya Patel',
              'company_name': 'Nova Tech',
              'category': 'visitor_registrations',
              'status': 'pending',
              'submitted_at': '2026-04-01T11:00:00Z',
            },
          ],
        };
        fakeApiClient.handlers[ApiEndpoints.leaderLeadsByType('become_mentor')] =
            (_) => {
              'data': [
                {
                  'id': 'lead-1',
                  'full_name': 'Vikram Mehta',
                  'business_name': 'Zenith Co',
                  'status': 'pending',
                  'created_at': '2026-04-01T12:00:00Z',
                },
              ],
            };

        final posts = await activitiesDataSource.getExtendedActivitiesFallback(
          normalizedType: 'posts',
        );
        final pending = await activitiesDataSource.getExtendedActivitiesFallback(
          normalizedType: 'pending-requests',
        );
        final mentors = await activitiesDataSource.getExtendedActivitiesFallback(
          normalizedType: 'mentor-applications',
        );

        expect(posts, hasLength(1));
        expect(posts.first.title, 'Circle Launch');
        expect(pending, hasLength(1));
        expect(pending.first.peerName, 'Riya Patel');
        expect(mentors, hasLength(1));
        expect(mentors.first.peerName, 'Vikram Mehta');

        expect(
          fakeApiClient.requestedUrls,
          containsAll([
            ApiEndpoints.leaderPosts,
            ApiEndpoints.leaderPendingRequests,
            ApiEndpoints.leaderLeadsByType('become_mentor'),
          ]),
        );
        expect(
          fakeApiClient.requestedUrls.where((u) => u.contains('/admin/')),
          isEmpty,
        );
      },
    );

    test(
      'ActivitiesRemoteDataSource fails safely on 403/unsuccessful response without crashing',
      () async {
        await SessionManager().updateFromAuthProfile({
          'id': '00000000-0000-0000-0000-000000000003',
          'name': 'Country Director',
          'email': 'eed@peersglobal.com',
          'phone': '7777777777',
          'role': 'countryDirector',
          'regional_scope': 'India',
        });

        fakeApiClient.handlers[ApiEndpoints.leaderLeadsByType('become_speaker')] =
            (_) => const ApiResponse<List<dynamic>>(
              success: false,
              message: 'Forbidden',
            );

        final speakers = await activitiesDataSource.getExtendedActivitiesFallback(
          normalizedType: 'speaker-applications',
        );

        expect(speakers, isEmpty);
        expect(
          fakeApiClient.requestedUrls.where((u) => u.contains('/admin/')),
          isEmpty,
        );
      },
    );
  });
}
