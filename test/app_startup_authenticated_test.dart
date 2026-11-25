import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/app.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/features/dashboard/view/dashboard_view.dart';
import 'package:leaderapp/features/login/view/login_view.dart';
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
  // The real startup rule (splash_view.dart): after the splash, an app that
  // already holds a session token goes to /home, otherwise to /login.
  // This file runs in its own isolate, so the SessionManager singleton here is
  // independent of app_smoke_test.dart (which covers the no-session path).
  setUpAll(() {
    // flutter_secure_storage is a platform plugin; stub it so the session can
    // be "persisted" in a test.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  testWidgets('cold start WITH a persisted session: Splash then Home (not Login)',
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
    expect(SessionManager().isAuthenticated, isTrue);

    await tester.pumpWidget(
      DefaultAssetBundle(bundle: _MockAssetBundle(), child: const App()),
    );

    expect(find.byType(SplashView), findsOneWidget);

    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(find.byType(DashboardView), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);
    expect(find.byType(SplashView), findsNothing);
  });
}
