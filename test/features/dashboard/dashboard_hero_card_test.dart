import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/features/dashboard/model/dashboard_metrics_model.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_hero_card.dart';

DashboardMetricsModel _metrics(Map<String, dynamic> json) =>
    DashboardMetricsModel.fromJson(json);

Widget _card(DashboardMetricsModel m) => MaterialApp(
      home: Scaffold(body: DashboardHeroCard(metrics: m)),
    );

void main() {
  // SessionManager persists permissions through flutter_secure_storage; stub
  // the platform channel so the test can grant/revoke the revenue capability.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  void grantRevenue(bool allowed) {
    // Default test session role is `circleChair`; the capability list is what
    // decides whether the revenue card is shown (access_finance).
    SessionManager().updateRoleCapabilitiesMatrix(
      'circleChair',
      allowed ? ['access_dashboard', 'access_finance'] : ['access_dashboard'],
    );
  }

  group('Dashboard "Total Revenue" card', () {
    testWidgets('missing revenue shows "Unavailable", never the deal value',
        (tester) async {
      grantRevenue(true);
      await tester.pumpWidget(_card(_metrics({'deals': '₹13L'}))); // no overall_revenue
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
      // The deal value appears exactly once: in its own "Business Deals" card.
      expect(find.text('₹13L'), findsOneWidget);
      expect(find.text('Business Deals'), findsOneWidget);
    });

    testWidgets('blank / "null" revenue is treated as unavailable (not 0)',
        (tester) async {
      grantRevenue(true);
      for (final raw in ['', '   ', 'null']) {
        await tester.pumpWidget(
          _card(_metrics({'overall_revenue': raw, 'deals': '₹13L'})),
        );
        expect(find.text('Unavailable'), findsOneWidget, reason: 'raw="$raw"');
        expect(find.text('₹0'), findsNothing);
        expect(find.text('₹13L'), findsOneWidget);
      }
    });

    testWidgets('a revenue value from the API is shown as received',
        (tester) async {
      grantRevenue(true);
      await tester.pumpWidget(
        _card(_metrics({'overall_revenue': '₹65,000', 'deals': '₹13L'})),
      );
      expect(find.text('₹65,000'), findsOneWidget);
      expect(find.text('Unavailable'), findsNothing);
      expect(find.text('₹13L'), findsOneWidget);
    });

    testWidgets('an explicit zero from the API is a real value, shown as is',
        (tester) async {
      grantRevenue(true);
      await tester.pumpWidget(
        _card(_metrics({'overall_revenue': '₹0', 'deals': '₹13L'})),
      );
      expect(find.text('₹0'), findsOneWidget);
      expect(find.text('Unavailable'), findsNothing);
    });

    testWidgets('roles without the revenue capability still see Total Coins',
        (tester) async {
      grantRevenue(false);
      await tester.pumpWidget(
        _card(_metrics({'overall_revenue': '₹65,000', 'coins': 1500})),
      );
      expect(find.text('Total Coins'), findsOneWidget);
      expect(find.text('Total Revenue'), findsNothing);
      expect(find.text('₹65,000'), findsNothing);
    });
  });
}
