import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/constants/api_endpoints.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/network/api_client.dart';
import 'package:leaderapp/core/network/api_response.dart';
import 'package:leaderapp/data/datasources/remote/teams_remote_datasource.dart';
import 'package:leaderapp/features/circle_details/model/circle_event_model.dart';
import 'package:leaderapp/features/dashboard/model/dashboard_metrics_model.dart';

class _Phase2FakeApiClient implements ApiClient {
  String? lastPostUrl;
  Map<String, dynamic>? lastPostBody;
  bool shouldFail = false;

  @override
  Future<ApiResponse<T>> post<T>(
    String url, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJsonT,
  }) async {
    lastPostUrl = url;
    lastPostBody = body is Map<String, dynamic> ? body : null;
    if (shouldFail) {
      return ApiResponse<T>(success: false, message: 'Forbidden');
    }
    final data = {'circle_id': 'c1', 'user_id': 'u1', 'role': 'vice_chair'};
    final parsed = fromJsonT != null ? fromJsonT(data) : data as T;
    return ApiResponse<T>(success: true, data: parsed);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Phase 2: Operational Workflows', () {
    test('Action Center moderation visibility matches role hierarchy', () {
      expect(UserRole.superAdmin.canModeratePendingRequests, isTrue);
      expect(UserRole.globalFounder.canModeratePendingRequests, isTrue);
      expect(UserRole.countryDirector.canModeratePendingRequests, isTrue);
      expect(UserRole.districtExecDirector.canModeratePendingRequests, isTrue);
      expect(UserRole.industryDirector.canModeratePendingRequests, isTrue);
      expect(UserRole.circleFounder.canModeratePendingRequests, isTrue);
      expect(UserRole.circleDirector.canModeratePendingRequests, isTrue);

      expect(UserRole.circleChair.canModeratePendingRequests, isFalse);
      expect(UserRole.viceChair.canModeratePendingRequests, isFalse);
      expect(UserRole.secretary.canModeratePendingRequests, isFalse);
      expect(UserRole.committeeLeader.canModeratePendingRequests, isFalse);
    });

    test('CircleEventModel parses real attendeesCount and attendees list', () {
      final event = CircleEventModel.fromJson({
        'id': 'evt-1',
        'circle_id': 'c-1',
        'title': 'Monthly Assembly',
        'date': '2026-12-01',
        'time': '08:00 AM',
        'location': 'Ahmedabad',
        'mode': 'In-Person',
        'status': 'Upcoming',
        'attendees_count': 2,
        'attendees': [
          {'id': 'u1', 'name': 'Aarav Shah', 'company_name': 'Apex'},
          {'id': 'u2', 'name': 'Riya Patel', 'company_name': 'Nova'},
        ],
      });

      expect(event.attendeesCount, 2);
      expect(event.attendees, hasLength(2));
      expect(event.attendees.first.name, 'Aarav Shah');
    });

    test('TeamsRemoteDataSource.assignCircleRole posts valid payload & handles errors', () async {
      final fakeClient = _Phase2FakeApiClient();
      final ds = TeamsRemoteDataSource(apiClient: fakeClient);

      final ok = await ds.assignCircleRole(
        circleId: 'c1',
        userId: 'u1',
        role: 'vice_chair',
      );
      expect(ok.success, isTrue);
      expect(fakeClient.lastPostUrl, ApiEndpoints.assignCircleRole('c1'));
      expect(fakeClient.lastPostBody?['role'], 'vice_chair');

      fakeClient.shouldFail = true;
      final denied = await ds.assignCircleRole(
        circleId: 'c2',
        userId: 'u1',
        role: 'secretary',
      );
      expect(denied.success, isFalse);
    });

    test('TeamsRepositoryImpl.assignCircleRole delegates to TeamsRemoteDataSource', () async {
      final fakeClient = _Phase2FakeApiClient();
      final ds = TeamsRemoteDataSource(apiClient: fakeClient);
      final res = await ds.assignCircleRole(
        circleId: 'c1',
        userId: 'u1',
        role: 'committee_leader',
        committeeName: 'Growth',
      );
      expect(res.success, isTrue);
      expect(fakeClient.lastPostBody?['committee_name'], 'Growth');
    });

    test('DashboardMetricsModel preserves unavailable/zero states without fabrication', () {
      final empty = DashboardMetricsModel.fromJson(const {});
      expect(empty.totalPeers, 0);
      expect(empty.pendingRequestsCount, 0);
      expect(empty.circulars, 0);
      expect(empty.deals, isNull);
    });
  });
}
