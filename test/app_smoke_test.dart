import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/app.dart';
import 'package:leaderapp/features/login/view/login_view.dart';
import 'package:leaderapp/features/splash/view/splash_view.dart';

/// Minimal asset bundle: serves a 1x1 PNG for every PNG asset and empty
/// manifests, so `App` can be built without the real asset pipeline.
class MockAssetBundle extends CachingAssetBundle {
  static final Uint8List _onePixelPng = Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, //
    0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 13, 73, 68, 65, 84, //
    120, 156, 99, 96, 0, 0, 0, 2, 0, 1, 244, 117, 100, 242, 0, 0, 0, 0, 73, 69, //
    78, 68, 174, 66, 96, 130,
  ]);

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.png')) {
      return ByteData.sublistView(_onePixelPng);
    }
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
  // The real startup flow (lib/features/splash/view/splash_view.dart):
  //   Splash (min ~2.7 s, Lottie logo) -> fetch app-config (failures are
  //   swallowed) -> if a persisted session exists go to /home, else /login.
  // Tests run with no persisted session, so the app must end on the Login
  // screen. Real network calls are impossible in tests (HTTP 400), which also
  // exercises the "app-config unavailable -> continue" path.
  testWidgets('cold start with no session: Splash then Login', (tester) async {
    await tester.pumpWidget(
      DefaultAssetBundle(bundle: MockAssetBundle(), child: const App()),
    );

    // 1. The app opens on the Splash screen, not on Login.
    expect(find.byType(SplashView), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);

    // 2. Splash holds for its minimum duration; Login must not appear early.
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byType(SplashView), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);

    // 3. After the splash timers complete (2.7 s bloc + 2.8 s safety timer)
    //    and the route transition (240 ms) finishes, Login is shown.
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(SplashView), findsNothing);

    // 4. The Login screen offers the OTP flow (email channel by default).
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });
}
