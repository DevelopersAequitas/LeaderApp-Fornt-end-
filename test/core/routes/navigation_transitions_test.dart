import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/core/routes/app_page_route.dart';
import 'package:leaderapp/core/routes/app_routes.dart';
import 'package:leaderapp/core/theme/app_motion.dart';
import 'package:leaderapp/features/dashboard/view/widgets/dashboard_bottom_nav_bar.dart';

void main() {
  group('AppPageRoute & AppRoutes transition semantics', () {
    test(
      'AppPageRoute extends MaterialPageRoute with crisp 220ms/180ms timing',
      () {
        final pushRoute = AppPageRoute<void>(
          builder: (_) => const SizedBox.shrink(),
        );
        expect(pushRoute, isA<MaterialPageRoute<void>>());
        expect(pushRoute.transitionStyle, AppRouteTransitionStyle.platformPush);
        expect(pushRoute.transitionDuration, AppMotion.pageForward);
        expect(pushRoute.reverseTransitionDuration, AppMotion.pageReverse);

        final rootRoute = AppPageRoute<void>(
          builder: (_) => const SizedBox.shrink(),
          transitionStyle: AppRouteTransitionStyle.rootFade,
        );
        expect(rootRoute.transitionDuration, AppMotion.rootFade);
        expect(rootRoute.reverseTransitionDuration, AppMotion.rootFade);
      },
    );

    test(
      'root routes use rootFade while drill-down routes use platformPush',
      () {
        for (final name in [
          AppRoutes.splash,
          AppRoutes.login,
          AppRoutes.home,
          AppRoutes.maintenance,
        ]) {
          final route = AppRoutes.onGenerateRoute(RouteSettings(name: name));
          expect(route, isA<AppPageRoute<dynamic>>());
          expect(
            (route as AppPageRoute<dynamic>).transitionStyle,
            AppRouteTransitionStyle.rootFade,
            reason: '$name should use rootFade',
          );
        }

        for (final name in [
          AppRoutes.profile,
          AppRoutes.notifications,
          AppRoutes.roleManagement,
          AppRoutes.circulars,
        ]) {
          final route = AppRoutes.onGenerateRoute(RouteSettings(name: name));
          expect(route, isA<AppPageRoute<dynamic>>());
          expect(
            (route as AppPageRoute<dynamic>).transitionStyle,
            AppRouteTransitionStyle.platformPush,
            reason: '$name should use platformPush',
          );
        }
      },
    );

    testWidgets('respects reduced motion (disableAnimations: true)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            theme: ThemeData(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: SmoothPageTransitionsBuilder(),
                },
              ),
            ),
            home: Builder(
              builder: (context) {
                expect(AppMotion.reduceMotion(context), isTrue);
                expect(
                  AppMotion.duration(context, AppMotion.pageForward),
                  Duration.zero,
                );
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        AppPageRoute<void>(
                          builder: (_) =>
                              const Scaffold(body: Text('Destination')),
                        ),
                      );
                    },
                    child: const Text('Go'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.text('Destination'), findsOneWidget);
    });
  });

  group('DashboardBottomNavBar tactile navigation', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
            (call) async => null,
          );
    });

    testWidgets('renders permitted tabs and fires onTabSelected cleanly', (
      tester,
    ) async {
      await SessionManager().setAuthSession(
        token: 'test-token',
        session: const UserSession(
          id: 'u-nav',
          name: 'Test Admin',
          email: 'admin@example.com',
          phone: '',
          role: UserRole.superAdmin,
          regionalScope: 'Global',
          managedCircles: [],
          memberSince: '',
          capabilitiesCount: 13,
        ),
      );
      int selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: DashboardBottomNavBar(
                  activeTab: selected,
                  onTabSelected: (idx) => setState(() => selected = idx),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Peers'), findsOneWidget);
      expect(find.text('Teams'), findsOneWidget);
      expect(find.text('Finance'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      expect(selected, 4);

      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(selected, 0);
    });
  });
}
