import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/app.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/core/notifications/app_notification_navigator.dart';
import 'package:leaderapp/features/dashboard/view/dashboard_view.dart';
import 'package:leaderapp/features/splash/view/splash_view.dart';

class _MockAssetBundle extends CachingAssetBundle {
  static final Uint8List _png = Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, //
    0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 13, 73, 68, 65, 84, //
    120, 156, 99, 96, 0, 0, 0, 2, 0, 1, 244, 117, 100, 242, 0, 0, 0, 0, 73, 69, //
    78, 68, 174, 66, 96, 130,
  ]);

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.png')) return ByteData.sublistView(_png);
    if (key == 'AssetManifest.bin') {
      return ByteData.sublistView(Uint8List.fromList([13, 0]));
    }
    if (key == 'AssetManifest.json') {
      return ByteData.sublistView(Uint8List.fromList([123, 125]));
    }
    throw FlutterError('Asset not found in mock bundle: $key');
  }
}

void main() {
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  // Real cold start: the notification tap arrives BEFORE the widget tree exists
  // (FirebaseMessaging.getInitialMessage runs inside main()). It must not be
  // lost and must not navigate over the Splash screen; it opens once the Home
  // shell is mounted.
  testWidgets('cold-start notification tap opens after Splash → Home, once',
      (tester) async {
    await SessionManager().setAuthSession(
      token: 'test-token',
      session: const UserSession(
        id: 'u1',
        name: 'Test Leader',
        email: 'leader@example.com',
        phone: '',
        role: UserRole.circleChair,
        regionalScope: 'District',
        managedCircles: [],
        memberSince: '',
        capabilitiesCount: 4,
      ),
    );

    // 1. Tap arrives with no navigator yet.
    AppNotificationNavigator.instance.handle({'screen': 'reports'});
    expect(AppNotificationNavigator.instance.hasPending, isTrue);

    // 2. App starts: Splash is showing, nothing has been opened.
    await tester.pumpWidget(
      DefaultAssetBundle(bundle: _MockAssetBundle(), child: const App()),
    );
    expect(find.byType(SplashView), findsOneWidget);
    expect(find.byType(DashboardView), findsNothing);
    expect(AppNotificationNavigator.instance.hasPending, isTrue);

    // 3. Splash finishes → Home mounts → the pending tap opens the Reports tab.
    for (int i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(AppNotificationNavigator.instance.hasPending, isFalse);
    final tabs = tester
        .widgetList<DashboardView>(find.byType(DashboardView, skipOffstage: false))
        .map((w) => w.initialTab)
        .toList();
    expect(tabs, contains(4), reason: 'the reports notification was not opened');
    expect(tabs.where((t) => t == 4).length, 1, reason: 'opened more than once');
  });
}
