import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/features/reports/view/widgets/report_submit_section.dart';

Widget _build({
  required double textScale,
  String peersScopeMode = 'all',
  String activitiesScopeMode = 'all',
}) {
  final c = List.generate(8, (_) => TextEditingController());
  return MaterialApp(
    theme: ThemeData(fontFamily: 'LibreFranklin'),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ReportSubmitSection(
            selectedType: 'monthly',
            onTypeChanged: (_) {},
            circleName: 'All Circles',
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
            peersScopeMode: peersScopeMode,
            onPeersScopeModeChanged: (_) {},
            onSelectAllPeers: (_) {},
            onToggleSelectPeer: (_) {},
            activitiesScopeMode: activitiesScopeMode,
            onActivitiesScopeModeChanged: (_) {},
            onSelectAllActivities: (_) {},
            onToggleSelectActivity: (_) {},
            onToggleIncludePeerWithActivities: (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  // flutter_test renders text with the "Ahem" font (every glyph is a full-size
  // square), which wildly exaggerates widths. Load the app's real font. The
  // SemiBold cut is the widest weight used by these headers, so this is a
  // conservative measurement.
  setUpAll(() async {
    final loader = FontLoader('LibreFranklin')
      ..addFont(rootBundle.load(
          'assets/fonts/Libre_Franklin/static/LibreFranklin-SemiBold.ttf'));
    await loader.load();
  });

  // The Samsung SM-A528B used for the audit is 384 dp wide (1080 px at density
  // 450) with the system font scale at 1.15 - the exact configuration where
  // the 15 px overflow was observed. 360 dp and 320 dp are narrower common
  // Android widths; text scale 1.3 covers "larger font" accessibility settings.
  for (final size in const [Size(384, 853), Size(360, 800), Size(320, 640)]) {
    for (final scale in const [1.0, 1.15, 1.3]) {
      for (final mode in const ['all', 'specific']) {
        testWidgets(
          'no layout overflow at ${size.width.toInt()}dp, text scale $scale, '
          'activities=$mode',
          (tester) async {
            tester.view.devicePixelRatio = 1.0;
            tester.view.physicalSize = size;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            // Capture the full error report (it names the overflowing widget).
            final reports = <String>[];
            final previous = FlutterError.onError;
            FlutterError.onError =
                (d) => reports.add(d.toDiagnosticsNode().toStringDeep());

            await tester.pumpWidget(
              _build(
                textScale: scale,
                peersScopeMode: mode,
                activitiesScopeMode: mode,
              ),
            );
            await tester.pump();
            // Restore BEFORE any expect(), otherwise flutter_test hangs.
            FlutterError.onError = previous;

            // A RenderFlex overflow is reported as a FlutterError. Only
            // overflows located in this widget's own file are asserted here:
            // the shared PrimaryButton (core/widgets) overflows separately with
            // its long submit label on narrow screens and is tracked in the
            // audit as a known, out-of-scope finding.
            final own = reports
                .where((r) => r.contains('report_submit_section.dart'))
                .toList();
            expect(own, isEmpty, reason: own.join('\n---\n'));

            // Both headers keep their title and count badge visible.
            expect(find.text('REPORT ACTIVITY INCLUSION'), findsOneWidget);
            expect(find.text('PEER ROSTER SCOPE'), findsOneWidget);
          },
        );
      }
    }
  }
}
