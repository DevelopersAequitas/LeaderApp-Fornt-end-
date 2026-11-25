import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/network/api_response.dart';
import 'package:leaderapp/data/repositories/reports_repository.dart';
import 'package:leaderapp/data/repositories/teams_repository.dart';
import 'package:leaderapp/features/reports/bloc/reports_bloc.dart';
import 'package:leaderapp/features/reports/bloc/reports_event.dart';
import 'package:leaderapp/features/reports/model/report_model.dart';
import 'package:leaderapp/features/reports/view/widgets/report_history_section.dart';
import 'package:leaderapp/features/reports/view/widgets/reports_trend_card.dart';
import 'package:leaderapp/features/teams/model/teams_model.dart';

class _FakeReportsRepository implements ReportsRepository {
  int getReportsCalls = 0;
  int getAttendanceTrendCalls = 0;

  final List<ReportModel> reports;

  _FakeReportsRepository({this.reports = const []});

  @override
  Future<ApiResponse<List<ReportModel>>> getReports({
    String? circleId,
    String? reportType,
    String? status,
    String? districtId,
    int? page,
    int? perPage,
  }) async {
    getReportsCalls++;
    return ApiResponse(success: true, data: reports);
  }

  @override
  Future<ApiResponse<List<ReportsChartPoint>>> getAttendanceTrend({
    String? circleId,
  }) async {
    getAttendanceTrendCalls++;
    return const ApiResponse(success: true, data: []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in test');
}

class _FakeTeamsRepository implements TeamsRepository {
  @override
  Future<ApiResponse<List<CircleTeamModel>>> getCircles({
    String? industry,
    String? status,
    String? search,
  }) async {
    return const ApiResponse(success: true, data: []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in test');
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  group('Attendance Trend API cleanup', () {
    test(
      'LoadReports does not call getAttendanceTrend and does not fabricate fallback points',
      () async {
        final fakeReports = _FakeReportsRepository(
          reports: const [
            ReportModel(
              id: 'rep-1',
              type: 'Monthly',
              status: 'submitted',
              date: '2026-10-01',
              period: 'October 2026',
              circleName: 'Alpha Circle',
              content: 'Summary',
              author: 'Leader',
              attendancePercentage: 92.5,
            ),
            ReportModel(
              id: 'rep-2',
              type: 'Monthly',
              status: 'submitted',
              date: '2026-11-01',
              period: 'November 2026',
              circleName: 'Alpha Circle',
              content: 'Summary 2',
              author: 'Leader',
              attendancePercentage: 88.0,
            ),
          ],
        );
        final bloc = ReportsBloc(
          reportsRepository: fakeReports,
          teamsRepository: _FakeTeamsRepository(),
        );
        addTearDown(bloc.close);

        bloc.add(const LoadReports());
        await _settle();

        expect(fakeReports.getReportsCalls, 1);
        expect(fakeReports.getAttendanceTrendCalls, 0);
        expect(bloc.state.submittedReports.length, 2);
        expect(bloc.state.attendanceTrend, isEmpty);
      },
    );

    testWidgets(
      'ReportsTrendCard remains preserved while not mounted in ReportHistorySection',
      (tester) async {
        const samplePoints = [
          ReportsChartPoint(month: 'Sep', value: 84.0),
          ReportsChartPoint(month: 'Oct', value: 91.5),
        ];

        // History section does not mount ReportsTrendCard yet.
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ReportHistorySection(
                  reports: [],
                  attendanceTrend: samplePoints,
                ),
              ),
            ),
          ),
        );
        expect(find.byType(ReportsTrendCard), findsNothing);

        // ReportsTrendCard itself remains intact for future re-mounting.
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReportsTrendCard(attendanceTrend: samplePoints),
            ),
          ),
        );
        expect(find.text('6-Month Attendance Trend'), findsOneWidget);
        expect(find.text('Latest: 91.5%'), findsOneWidget);
      },
    );
  });
}
