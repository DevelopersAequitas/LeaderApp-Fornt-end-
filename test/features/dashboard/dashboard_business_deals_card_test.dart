import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/features/dashboard/model/dashboard_metrics_model.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_hero_card.dart';

DashboardMetricsModel _metrics(Map<String, dynamic> json) =>
    DashboardMetricsModel.fromJson(json);

Widget _card(DashboardMetricsModel m) =>
    MaterialApp(home: Scaffold(body: DashboardHeroCard(metrics: m)));

void main() {
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
    SessionManager().updateRoleCapabilitiesMatrix(
      'circleChair',
      ['access_dashboard', 'access_finance'],
    );
  });

  group('model: missing is not zero', () {
    test('a missing "deals" stays null (no fabricated ₹0)', () {
      expect(_metrics(const {}).deals, isNull);
    });

    test('an explicit zero and a positive value are kept as received', () {
      expect(_metrics(const {'deals': '₹0'}).deals, '₹0');
      expect(_metrics(const {'deals': '₹1.34Cr'}).deals, '₹1.34Cr');
    });

    test('toJson/fromJson round-trip keeps null as null', () {
      final m = _metrics(const {});
      expect(DashboardMetricsModel.fromJson(m.toJson()).deals, isNull);
    });
  });

  group('Business Deals card', () {
    testWidgets('API value missing: "Unavailable"', (tester) async {
      await tester.pumpWidget(_card(_metrics({'overall_revenue': '₹65,000'})));
      expect(find.text('Business Deals'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget); // only the deals card
      expect(find.text('₹0'), findsNothing);
      expect(find.text('₹65,000'), findsOneWidget); // revenue untouched
    });

    testWidgets('blank / "null" is also unavailable', (tester) async {
      for (final raw in ['', '  ', 'null']) {
        await tester.pumpWidget(
          _card(_metrics({'deals': raw, 'overall_revenue': '₹65,000'})),
        );
        expect(find.text('Unavailable'), findsOneWidget, reason: 'raw="$raw"');
      }
    });

    testWidgets('API value explicitly zero: shows the zero', (tester) async {
      await tester.pumpWidget(
        _card(_metrics({'deals': '₹0', 'overall_revenue': '₹65,000'})),
      );
      expect(find.text('₹0'), findsOneWidget);
      expect(find.text('Unavailable'), findsNothing);
    });

    testWidgets('API value positive: shows the formatted value', (tester) async {
      await tester.pumpWidget(
        _card(_metrics({'deals': '₹13L', 'overall_revenue': '₹65,000'})),
      );
      expect(find.text('₹13L'), findsOneWidget);
      expect(find.text('Unavailable'), findsNothing);
    });

    testWidgets('revenue and deal value stay distinct metrics', (tester) async {
      // Both missing: two separate "Unavailable" states, never one standing in
      // for the other.
      await tester.pumpWidget(_card(_metrics(const {})));
      expect(find.text('Unavailable'), findsNWidgets(2));
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('Business Deals'), findsOneWidget);

      // Revenue present, deals missing: the revenue figure is NOT shown as deals.
      await tester.pumpWidget(_card(_metrics({'overall_revenue': '₹72,000'})));
      expect(find.text('₹72,000'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);

      // Deals present, revenue missing: deals is NOT shown as revenue.
      await tester.pumpWidget(_card(_metrics({'deals': '₹13L'})));
      expect(find.text('₹13L'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
    });
  });
}
