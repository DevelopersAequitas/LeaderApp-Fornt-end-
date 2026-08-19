import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/app.dart';

class MockAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'assets/icons/whitelogo.png' ||
        key == 'assets/icons/AppIcon.png') {
      final bytes = Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        31,
        21,
        196,
        137,
        0,
        0,
        0,
        13,
        73,
        68,
        65,
        84,
        120,
        156,
        99,
        96,
        0,
        0,
        0,
        2,
        0,
        1,
        244,
        117,
        100,
        242,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130,
      ]);
      return ByteData.sublistView(bytes);
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
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app wrapping with the MockAssetBundle so it resolves AssetImage.
    await tester.pumpWidget(
      DefaultAssetBundle(bundle: MockAssetBundle(), child: const App()),
    );

    // 1. Verify Splash Screen loads
    expect(find.byType(Image), findsOneWidget);

    // 2. Advance clock past Splash transition timeout (4.5 seconds) -> navigates to Login
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 3. Verify Login Screen loaded
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Leadership Portal'), findsOneWidget);

    // 4. Tap the 'Circle Chair' auto-fill role card (scroll into view first)
    final chairCard = find.text('Circle Chair');
    await tester.ensureVisible(chairCard);
    await tester.tap(chairCard);
    await tester.pumpAndSettle();

    // 5. Verify email is auto-filled in the text field controller
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, 'arjun@peersglobal.in');

    // 6. Tap 'Send OTP' button to trigger simulated loading and navigation to OTP (scroll into view first)
    final sendOtpBtn = find.text('Send OTP');
    await tester.ensureVisible(sendOtpBtn);
    await tester.tap(sendOtpBtn);
    await tester.pump(); // Start loading state

    // Advance clock past the simulated API delay (1.5 seconds) and navigation transition to OTP Screen
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 7. Verify we are on the OTP screen
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Sent to arjun@peersglobal.in'), findsOneWidget);

    // 8. Fill in the 4 OTP fields (1-2-3-4)
    final otpFields = find.byType(TextField);
    expect(otpFields, findsNWidgets(4));

    await tester.enterText(otpFields.at(0), '1');
    await tester.enterText(otpFields.at(1), '2');
    await tester.enterText(otpFields.at(2), '3');
    await tester.enterText(otpFields.at(3), '4');
    await tester.pump(); // Start verification loader state

    // Advance clock past simulated OTP verification delay (1.0 second) and navigation transition to Home Screen
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 9. Verify we are on the Home/Dashboard screen
    expect(find.text('PEERS Global'), findsOneWidget);
    expect(find.text('Key Metrics'), findsOneWidget);
    expect(find.text('Top 5 Impacters'), findsOneWidget);

    // 9a. Tap 'Peers' bottom navigation bar tab (using direct InkWell onTap)
    final peersTabFinder = find.ancestor(
      of: find.text('Peers'),
      matching: find.byType(InkWell),
    );
    final peersInkWell = tester.widget<InkWell>(peersTabFinder);
    peersInkWell.onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();



    // 9b. Verify we are on the Peers tab and segment control is visible
    expect(find.text('Peers (8)'), findsOneWidget);
    expect(find.text('Celebrations'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // 9c. Verify mock peers list matches specifications (e.g. Priya Sharma is visible)
    expect(find.text('Priya Sharma'), findsOneWidget);
    expect(find.text('38 lives'), findsOneWidget);

    // 9d. Tap on the 'Deals' metric chip to check sorting and badge update (using direct InkWell onTap)
    final dealsChipFinder = find.ancestor(
      of: find.text('Deals'),
      matching: find.byType(InkWell),
    );
    final dealsInkWell = tester.widget<InkWell>(dealsChipFinder);
    dealsInkWell.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('₹1.10Cr'), findsOneWidget); // Priya's deals badge is visible

    // 9e. Search for James
    await tester.enterText(find.byType(TextField), 'James');
    await tester.pumpAndSettle();
    expect(find.text('James O\'Brien'), findsOneWidget);
    expect(find.text('Priya Sharma'), findsNothing);

    // 9f. Clear search
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Priya Sharma'), findsOneWidget);

    // 9f-1. Tap 'Priya Sharma' card to navigate to Peer Profile Screen
    final priyaCardFinder = find.text('Priya Sharma');
    await tester.tap(priyaCardFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    // 9f-2. Verify Peer Profile view loads with Priya's stats
    expect(find.text('Peer Profile'), findsOneWidget);
    expect(find.text('Priya Sharma'), findsOneWidget);
    expect(find.text('TechVentures'), findsOneWidget);
    expect(find.textContaining('Lives Impacted'), findsOneWidget);
    expect(find.text('PERFORMANCE STATS'), findsOneWidget);
    expect(find.text('Deals Closed'), findsOneWidget);
    expect(find.text('₹32k'), findsOneWidget);
    expect(find.text('Referrals Given'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);

    // 9f-3. Switch profile subtab to 'Activity'
    final activityTabFinder = find.ancestor(
      of: find.text('Activity'),
      matching: find.byType(InkWell),
    );
    final activityInkWell = tester.widget<InkWell>(activityTabFinder);
    activityInkWell.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('RECENT ACTIVITY'), findsOneWidget);
    expect(find.text('Completed P2P meeting'), findsOneWidget);
    expect(find.text('14 sessions total this quarter'), findsOneWidget);
    expect(find.text('Gave 8 referrals'), findsOneWidget);
    expect(find.text('Earned Champion badge'), findsOneWidget);
    expect(find.text('Closed ₹32k in deals'), findsOneWidget);

    // 9f-3b. Switch profile subtab to 'Testimonials (2)'
    final testimonialsTabFinder = find.ancestor(
      of: find.text('Testimonials (2)'),
      matching: find.byType(InkWell),
    );
    final testimonialsInkWell = tester.widget<InkWell>(testimonialsTabFinder);
    testimonialsInkWell.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Ananya Patel'), findsOneWidget);
    expect(find.textContaining('Ananya connected me with three healthcare clients'), findsOneWidget);
    expect(find.text('James O\'Brien'), findsOneWidget);
    expect(find.textContaining('Priya\'s introduction led to a ₹28k deal'), findsOneWidget);

    // 9f-4. Tap back button to return to Peers Tab list
    final backBtnFinder = find.byIcon(Icons.chevron_left);
    await tester.tap(backBtnFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify we are back on the Peers list
    expect(find.text('Peers (8)'), findsOneWidget);

    // 9g. Tap 'Celebrations' segment to switch tab (using direct InkWell onTap)
    final celebrationsSegmentFinder = find.ancestor(
      of: find.text('Celebrations'),
      matching: find.byType(InkWell),
    );
    final celebrationsInkWell = tester.widget<InkWell>(celebrationsSegmentFinder);
    celebrationsInkWell.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    // 9h. Verify Celebrations view loads (birthdays, anniversaries)
    expect(find.text('Birthdays This Month'), findsOneWidget);
    expect(find.text('Business Anniversaries This Month'), findsOneWidget);
    expect(find.text('Ananya Patel'), findsOneWidget);
    expect(find.text('Marcus Lee'), findsOneWidget);
    expect(find.text('Wish 🎂'), findsOneWidget);
    expect(find.text('Wish 🤝'), findsOneWidget);

    // 9i. Tap Wish button (using direct InkWell onTap)
    final wishButtonFinder = find.ancestor(
      of: find.text('Wish 🎂').first,
      matching: find.byType(InkWell),
    );
    final wishInkWell = tester.widget<InkWell>(wishButtonFinder);
    wishInkWell.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    // 9j. Return to Dashboard tab (using direct InkWell onTap)
    final dashboardTabFinder = find.ancestor(
      of: find.text('Dashboard'),
      matching: find.byType(InkWell),
    );
    final dashboardInkWell = tester.widget<InkWell>(dashboardTabFinder);
    dashboardInkWell.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    // 9k. Tap 'Teams' bottom navigation bar tab (using direct InkWell onTap)
    final teamsTabFinder = find.ancestor(
      of: find.text('Teams'),
      matching: find.byType(InkWell),
    );
    final teamsInkWell = tester.widget<InkWell>(teamsTabFinder);
    teamsInkWell.onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // 9l. Verify lock screen card text is visible
    expect(find.text('Access Restricted'), findsOneWidget);
    expect(find.text('view industry data'), findsOneWidget);
    expect(find.text('view district data'), findsOneWidget);
    expect(find.textContaining('Logged in as:'), findsOneWidget);

    // 9m. Return to Dashboard tab (using direct InkWell onTap)
    final dashboardTabFinder2 = find.ancestor(
      of: find.text('Dashboard'),
      matching: find.byType(InkWell),
    );
    final dashboardInkWell2 = tester.widget<InkWell>(dashboardTabFinder2);
    dashboardInkWell2.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    // 9n. Tap 'Finance' bottom navigation bar tab (using direct InkWell onTap)
    final financeTabFinder = find.ancestor(
      of: find.text('Finance'),
      matching: find.byType(InkWell),
    );
    final financeInkWell = tester.widget<InkWell>(financeTabFinder);
    financeInkWell.onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // 9o. Verify lock screen card text is visible on the Finance screen
    expect(find.text('Access Restricted'), findsOneWidget);
    expect(find.text('view transaction logs'), findsOneWidget);
    expect(find.text('view payment summaries'), findsOneWidget);
    expect(find.textContaining('Logged in as:'), findsOneWidget);

    // 9p. Return to Dashboard tab (using direct InkWell onTap)
    final dashboardTabFinder3 = find.ancestor(
      of: find.text('Dashboard'),
      matching: find.byType(InkWell),
    );
    final dashboardInkWell3 = tester.widget<InkWell>(dashboardTabFinder3);
    dashboardInkWell3.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    // 9q. Tap 'Report' bottom navigation bar tab (using direct InkWell onTap)
    final reportTabFinder = find.ancestor(
      of: find.text('Report'),
      matching: find.byType(InkWell),
    );
    final reportInkWell = tester.widget<InkWell>(reportTabFinder);
    reportInkWell.onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // 9r. Verify we are on the Submit Report tab
    expect(find.text('Submit Report'), findsNWidgets(2)); // AppBar/Segment + card header
    expect(find.text('Mumbai Tech Sunrise'), findsNWidgets(2)); // AppBar + Read-only Circle
    expect(find.text('Weekly Report'), findsOneWidget);
    expect(find.text('Monthly Report'), findsOneWidget);

    // 9s. Type report content
    final contentField = find.byType(TextField);
    await tester.enterText(contentField, 'Weekly summary: all active members attended the meeting. Discussed tech sunrise operations.');
    await tester.pumpAndSettle();

    // 9t. Tap 'Weekly Report' selector pill (using direct InkWell onTap)
    final weeklyPillFinder = find.ancestor(
      of: find.text('Weekly Report'),
      matching: find.byType(InkWell),
    );
    final weeklyInkWell = tester.widget<InkWell>(weeklyPillFinder);
    weeklyInkWell.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    // 9u. Tap 'Submit Report →' button (using direct ElevatedButton onPressed)
    final submitReportBtnFinder = find.byType(ElevatedButton);
    final submitReportBtn = tester.widget<ElevatedButton>(submitReportBtnFinder);
    submitReportBtn.onPressed!();
    await tester.pump(); // Start submission delay

    // Advance clock past simulated delay (800ms)
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // 9v. Verify view transitioned to Reports History and the new weekly report is listed
    expect(find.text('Reports (2)'), findsOneWidget);
    expect(find.text('Weekly summary: all active members attended the meeting. Discussed tech sunrise operations.'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget); // Status of the newly submitted report

    // 9w. Return to Dashboard tab (using direct InkWell onTap)
    final dashboardTabFinder4 = find.ancestor(
      of: find.text('Dashboard'),
      matching: find.byType(InkWell),
    );
    final dashboardInkWell4 = tester.widget<InkWell>(dashboardTabFinder4);
    dashboardInkWell4.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    // 9x. Tap Notification Bell icon in top AppBar (using icon notifications_none_rounded)
    final bellFinder = find.byIcon(Icons.notifications_none_rounded);
    await tester.tap(bellFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    // 9y. Verify Notifications screen loads with 5 items and 3 unread alerts
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('5 notifications'), findsOneWidget);
    expect(find.text('3 unread alerts'), findsOneWidget);
    expect(find.text('New referral submitted'), findsOneWidget);
    expect(find.text('Business deal closed'), findsOneWidget);
    expect(find.text('Peer at risk'), findsOneWidget);

    // 9z. Tap 'Mark all read' (using text finder)
    final markAllReadFinder = find.text('Mark all read');
    await tester.tap(markAllReadFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify unread alert counter text disappeared
    expect(find.text('3 unread alerts'), findsNothing);

    // 9aa. Tap 'Clear all' (using text finder)
    final clearAllFinder = find.text('Clear all');
    await tester.tap(clearAllFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify no notifications remain
    expect(find.text('No notifications found.'), findsOneWidget);
    expect(find.text('0 notifications'), findsOneWidget);

    // 9ab. Tap back button to return to Dashboard
    final backBtnFinder2 = find.byIcon(Icons.chevron_left);
    await tester.tap(backBtnFinder2);
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify we are back on the Dashboard tab
    expect(find.text('PEERS Global'), findsOneWidget);

    // 10. Tap initials avatar 'AP' in the top app bar to navigate to Profile Screen
    final avatarGestureFinder = find.ancestor(
      of: find.text('AP').first,
      matching: find.byType(GestureDetector),
    );
    final gestureDetector = tester.widget<GestureDetector>(avatarGestureFinder);
    gestureDetector.onTap!();
    await tester.pump();
    await tester.pumpAndSettle();

    // 11. Verify Profile Screen loads
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Arjun Patel'), findsNWidgets(2));
    expect(find.text('ACCOUNT DETAILS'), findsOneWidget);

    // 12. Tap 'Sign Out' to return to Login Screen
    final signOutBtnFinder = find.byType(OutlinedButton);
    final signOutButton = tester.widget<OutlinedButton>(signOutBtnFinder);
    signOutButton.onPressed!();
    await tester.pump(); // Start signout loader

    // Advance clock past simulated API delay (800ms)
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // 13. Verify we are back on the Sign In / Login screen
    expect(find.text('Sign in'), findsOneWidget);
  });
}
