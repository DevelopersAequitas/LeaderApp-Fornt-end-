import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/core/widgets/primary_button.dart';
import 'package:leaderapp/features/finance/view/widgets/finance_action_buttons.dart';
import 'package:leaderapp/features/peer_profile/view/widgets/peer_profile_bottom_actions.dart';
import 'package:leaderapp/features/profile/view/widgets/profile_sign_out_bottom_sheet.dart';
import 'package:leaderapp/features/role_management/view/widgets/role_save_bar.dart';

/// Every side-by-side button layout in the app, at the widths and font scales
/// the product must support. Pumps with the real font; fails on any overflow.
Future<List<String>> _pump(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required double scale,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final reports = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (d) => reports.add(d.toDiagnosticsNode().toStringDeep());
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(fontFamily: 'LibreFranklin'),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(body: Align(alignment: Alignment.bottomCenter, child: child)),
      ),
    ),
  );
  await tester.pump();
  FlutterError.onError = previous; // restore BEFORE any expect()
  return reports;
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('LibreFranklin')
      ..addFont(rootBundle.load(
          'assets/fonts/Libre_Franklin/static/LibreFranklin-SemiBold.ttf'));
    await loader.load();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
    // Super Admin so the second Finance button (Commission Setup) is shown.
    await SessionManager().setAuthSession(
      token: 't',
      session: const UserSession(
        id: 'u',
        name: 'Admin',
        email: 'a@example.com',
        phone: '',
        role: UserRole.superAdmin,
        regionalScope: 'Global',
        managedCircles: [],
        memberSince: '',
        capabilitiesCount: 12,
      ),
    );
  });

  const sizes = [Size(320, 640), Size(360, 800), Size(384, 853)];
  const scales = [1.0, 1.15, 1.3];

  for (final size in sizes) {
    for (final scale in scales) {
      final tag = '${size.width.toInt()}dp, scale $scale';

      testWidgets('Log P2P / Send Referral pair: $tag', (tester) async {
        final errors = await _pump(
          tester,
          PeerProfileBottomActions(onLogP2PTap: () {}, onSendReferralTap: () {}),
          size: size,
          scale: scale,
        );
        expect(errors, isEmpty, reason: errors.join('\n---\n'));

        final left = tester.getRect(find.text('Log P2P'));
        final right = tester.getRect(find.text('Send Referral'));
        expect(left, isNot(equals(right)));

        final buttons = find.byType(PrimaryButton);
        final a = tester.getRect(buttons.at(0));
        final b = tester.getRect(buttons.at(1));
        // Both actions preserved, same height, side by side, touch targets >= 44.
        expect(a.height, closeTo(b.height, 0.5));
        expect(a.height, greaterThanOrEqualTo(44.0));
        expect(a.right, lessThan(b.left));
        // Labels stay inside their buttons.
        expect(left.right, lessThanOrEqualTo(a.right));
        expect(right.right, lessThanOrEqualTo(b.right));
      });

      testWidgets('Finance Record Payment / Commission Setup: $tag', (tester) async {
        final errors = await _pump(
          tester,
          FinanceActionButtons(
            onRecordPaymentTap: () {},
            onCommissionSetupTap: () {},
          ),
          size: size,
          scale: scale,
        );
        expect(errors, isEmpty, reason: errors.join('\n---\n'));
        expect(find.text('Record Payment'), findsOneWidget);
        expect(find.text('Commission Setup'), findsOneWidget);
      });

      testWidgets('Role save bar (status pill + save): $tag', (tester) async {
        final errors = await _pump(
          tester,
          RoleSaveBar(isSaving: false, hasUnsavedChanges: true, onSave: () {}),
          size: size,
          scale: scale,
        );
        expect(errors, isEmpty, reason: errors.join('\n---\n'));
        expect(find.text('Save Matrix Settings'), findsOneWidget);
        expect(find.text('Unsaved'), findsOneWidget);
      });

      testWidgets('Sign-out sheet Cancel / Yes, Sign Out: $tag', (tester) async {
        final errors = await _pump(
          tester,
          ProfileSignOutBottomSheet(onConfirm: () {}),
          size: size,
          scale: scale,
        );
        expect(errors, isEmpty, reason: errors.join('\n---\n'));
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Yes, Sign Out'), findsOneWidget);
      });
    }
  }

  testWidgets('pair: disabled-style states still tappable where enabled', (tester) async {
    var p2p = 0, ref = 0;
    await _pump(
      tester,
      PeerProfileBottomActions(onLogP2PTap: () => p2p++, onSendReferralTap: () => ref++),
      size: const Size(320, 640),
      scale: 1.3,
    );
    await tester.tap(find.text('Log P2P'));
    await tester.tap(find.text('Send Referral'));
    expect(p2p, 1);
    expect(ref, 1);
  });
}
