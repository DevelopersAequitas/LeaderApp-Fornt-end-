import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/features/reports/bloc/reports_bloc.dart';
import 'package:leaderapp/features/reports/model/report_model.dart';
import 'package:leaderapp/features/reports/view/widgets/report_submit_section.dart';

ReportPeerRosterItem _peer(String id) => ReportPeerRosterItem(
      peerId: id,
      name: 'Peer $id',
      avatarUrl: null,
      company: 'Co',
      designation: '',
      status: 'Active',
      platformMembershipStart: '',
      platformMembershipEnd: '',
      circleJoiningDate: '',
      circleRenewalDate: '',
      attendance: '90%',
      dealsClosed: '₹0',
      p2pCount: 0,
      referralsCount: 0,
    );

Widget _section({
  required String circleName,
  List<ReportPeerRosterItem> peers = const [],
  bool isLoadingPeers = false,
  bool includeBreakdown = true,
}) {
  final c = List.generate(8, (_) => TextEditingController());
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ReportSubmitSection(
          selectedType: 'monthly',
          onTypeChanged: (_) {},
          circleName: circleName,
          periodController: c[0],
          attendanceController: c[1],
          dealsClosedController: c[2],
          totalRevenueController: c[3],
          contentController: c[4],
          highlightsController: c[5],
          challengesController: c[6],
          actionItemsController: c[7],
          isSubmitting: false,
          onSubmit: () {},
          onPeersScopeModeChanged: (_) {},
          availableCirclePeers: peers,
          isLoadingPeers: isLoadingPeers,
          onSelectAllPeers: (_) {},
          onToggleSelectPeer: (_) {},
          onActivitiesScopeModeChanged: (_) {},
          onSelectAllActivities: (_) {},
          onToggleSelectActivity: (_) {},
          includePeerWithActivities: includeBreakdown,
          onToggleIncludePeerWithActivities: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('ReportsBloc.rosterSubmitBlocker (never submit an incomplete roster)', () {
    test('All Circles + roster breakdown + nothing loaded is blocked', () {
      final msg = ReportsBloc.rosterSubmitBlocker(
        isAllCircles: true,
        includeRoster: true,
        rosterCount: 0,
      );
      expect(msg, isNotNull);
      expect(msg, contains('All Circles'));
      expect(msg, contains('not submitted'));
    });

    test('turning the roster breakdown off allows submission', () {
      expect(
        ReportsBloc.rosterSubmitBlocker(
          isAllCircles: true,
          includeRoster: false,
          rosterCount: 0,
        ),
        isNull,
      );
    });

    test('a specific Circle (roster loaded or genuinely empty) is not blocked', () {
      for (final count in [0, 5]) {
        expect(
          ReportsBloc.rosterSubmitBlocker(
            isAllCircles: false,
            includeRoster: true,
            rosterCount: count,
          ),
          isNull,
        );
      }
    });

    test('All Circles with a loaded roster is not blocked', () {
      expect(
        ReportsBloc.rosterSubmitBlocker(
          isAllCircles: true,
          includeRoster: true,
          rosterCount: 12,
        ),
        isNull,
      );
    });
  });

  group('Report form never shows "0 peers" just because no Circle is chosen', () {
    testWidgets('All Circles, nothing loaded: "not loaded", not zero', (tester) async {
      await tester.pumpWidget(_section(circleName: 'All Circles'));
      expect(find.text('Roster not loaded'), findsOneWidget);
      expect(find.text('All Peers'), findsOneWidget);
      expect(find.textContaining('All 0 peers'), findsNothing);
      expect(find.textContaining('All Peers (0)'), findsNothing);
      expect(find.textContaining('attached for 0 peers'), findsNothing);
      expect(find.textContaining('not available yet'), findsOneWidget);
    });

    testWidgets('All Circles with a loaded roster shows the real count',
        (tester) async {
      await tester.pumpWidget(
        _section(circleName: 'All Circles', peers: [_peer('a'), _peer('b')]),
      );
      expect(find.text('All 2 peers'), findsOneWidget);
      expect(find.textContaining('attached for 2 peers'), findsOneWidget);
      expect(find.text('Roster not loaded'), findsNothing);
    });

    testWidgets('a specific Circle with zero Peers keeps the honest zero',
        (tester) async {
      await tester.pumpWidget(_section(circleName: 'Ahmedabad Investors Circle'));
      expect(find.text('All 0 peers'), findsOneWidget);
      expect(find.text('Roster not loaded'), findsNothing);
    });

    testWidgets('while loading, All Circles does not claim "not loaded"',
        (tester) async {
      await tester.pumpWidget(
        _section(circleName: 'All Circles', isLoadingPeers: true),
      );
      expect(find.text('Roster not loaded'), findsNothing);
    });
  });
}
