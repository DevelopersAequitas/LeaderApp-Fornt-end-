import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/widgets/primary_button.dart';

const _longLabel = 'Submit Report for Leadership Review →';

Widget _app(Widget child, {required double textScale}) {
  return MaterialApp(
    theme: ThemeData(fontFamily: 'LibreFranklin'),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

/// Pumps [child] and returns every Flutter error reported while laying it out
/// (restores the handler BEFORE returning, otherwise flutter_test hangs).
Future<List<String>> _pumpCapturing(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required double textScale,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final reports = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (d) => reports.add(d.toDiagnosticsNode().toStringDeep());
  await tester.pumpWidget(_app(child, textScale: textScale));
  await tester.pump();
  FlutterError.onError = previous;
  return reports;
}

void main() {
  // flutter_test's default Ahem font exaggerates text widths; use the real
  // font (the widest weight the button uses) for realistic measurements.
  setUpAll(() async {
    final loader = FontLoader('LibreFranklin')
      ..addFont(rootBundle.load(
          'assets/fonts/Libre_Franklin/static/LibreFranklin-SemiBold.ttf'));
    await loader.load();
  });

  const sizes = [Size(320, 640), Size(360, 800), Size(384, 853)];
  const scales = [1.0, 1.15, 1.3];

  group('long label (the Reports submit button)', () {
    for (final size in sizes) {
      for (final scale in scales) {
        testWidgets(
          '${size.width.toInt()}dp, scale $scale: no overflow, nothing clipped',
          (tester) async {
            final errors = await _pumpCapturing(
              tester,
              PrimaryButton(
                label: _longLabel,
                leadingIcon: Icons.send_rounded,
                onPressed: () {},
              ),
              size: size,
              textScale: scale,
            );
            expect(errors, isEmpty, reason: errors.join('\n---\n'));

            // Full label still present as a single Text.
            expect(find.text(_longLabel), findsOneWidget);
            expect(find.byIcon(Icons.send_rounded), findsOneWidget);

            // Touch target never smaller than the 52 px design minimum, and
            // the text box sits fully inside the button (nothing clipped).
            final button = tester.getRect(find.byType(PrimaryButton));
            final text = tester.getRect(find.text(_longLabel));
            expect(button.height, greaterThanOrEqualTo(52.0));
            expect(button.width, size.width - 32);
            expect(text.left, greaterThanOrEqualTo(button.left));
            expect(text.right, lessThanOrEqualTo(button.right));
            expect(text.top, greaterThanOrEqualTo(button.top));
            expect(text.bottom, lessThanOrEqualTo(button.bottom));

            // Icon stays vertically centred against the text block.
            final icon = tester.getRect(find.byIcon(Icons.send_rounded));
            expect((icon.center.dy - text.center.dy).abs(), lessThan(1.5));
          },
        );
      }
    }
  });

  group('short labels keep their exact design height (no blind wrapping)', () {
    for (final h in const [52.0, 48.0, 44.0]) {
      for (final scale in scales) {
        testWidgets('height $h, scale $scale', (tester) async {
          final errors = await _pumpCapturing(
            tester,
            PrimaryButton(label: 'Send OTP', height: h, onPressed: () {}),
            size: const Size(360, 800),
            textScale: scale,
          );
          expect(errors, isEmpty, reason: errors.join('\n---\n'));
          expect(tester.getSize(find.byType(PrimaryButton)).height, h);
        });
      }
    }

    testWidgets('outlined and icon variants also keep their height',
        (tester) async {
      final errors = await _pumpCapturing(
        tester,
        Column(
          children: [
            PrimaryButton(
              label: 'Log P2P',
              leadingIcon: Icons.handshake_outlined,
              isOutlined: true,
              height: 44,
              onPressed: () {},
            ),
            PrimaryButton(
              label: 'Send OTP',
              trailingIcon: Icons.arrow_forward_rounded,
              height: 48,
              borderRadius: 24,
              onPressed: () {},
            ),
          ],
        ),
        size: const Size(360, 800),
        textScale: 1.0,
      );
      expect(errors, isEmpty, reason: errors.join('\n---\n'));
      expect(tester.getSize(find.byType(PrimaryButton).at(0)).height, 44);
      expect(tester.getSize(find.byType(PrimaryButton).at(1)).height, 48);
    });
  });

  group('compact 34 px "Review" button in an 84 px slot (dashboard card)', () {
    for (final scale in scales) {
      testWidgets('scale $scale: no overflow, height >= 34', (tester) async {
        final errors = await _pumpCapturing(
          tester,
          Row(
            children: [
              const Spacer(),
              SizedBox(
                width: 84,
                child: PrimaryButton(
                  label: 'Review',
                  height: 34,
                  borderRadius: 8,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          size: const Size(360, 800),
          textScale: scale,
        );
        expect(errors, isEmpty, reason: errors.join('\n---\n'));
        final h = tester.getSize(find.byType(PrimaryButton)).height;
        expect(h, greaterThanOrEqualTo(34.0));
        if (scale == 1.0) expect(h, 34.0); // unchanged at default scale
      });
    }
  });

  group('two half-width buttons (peer profile bottom actions)', () {
    for (final size in sizes) {
      for (final scale in scales) {
        testWidgets('${size.width.toInt()}dp, scale $scale', (tester) async {
          final errors = await _pumpCapturing(
            tester,
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Log P2P',
                    leadingIcon: Icons.handshake_outlined,
                    isOutlined: true,
                    height: 44,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: 'Send Referral',
                    leadingIcon: Icons.send_rounded,
                    height: 44,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            size: size,
            textScale: scale,
          );
          expect(errors, isEmpty, reason: errors.join('\n---\n'));
          expect(find.text('Log P2P'), findsOneWidget);
          expect(find.text('Send Referral'), findsOneWidget);
        });
      }
    }
  });

  group('states', () {
    testWidgets('disabled: grey, not tappable, same height', (tester) async {
      var taps = 0;
      final errors = await _pumpCapturing(
        tester,
        const PrimaryButton(label: _longLabel, onPressed: null),
        size: const Size(360, 800),
        textScale: 1.0,
      );
      expect(errors, isEmpty, reason: errors.join('\n---\n'));
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      expect(taps, 0);
      expect(tester.getSize(find.byType(PrimaryButton)).height,
          greaterThanOrEqualTo(52.0));
    });

    testWidgets('loading: spinner replaces the label, tap ignored, min height',
        (tester) async {
      var taps = 0;
      final errors = await _pumpCapturing(
        tester,
        PrimaryButton(
          label: _longLabel,
          isLoading: true,
          onPressed: () => taps++,
        ),
        size: const Size(320, 640),
        textScale: 1.3,
      );
      expect(errors, isEmpty, reason: errors.join('\n---\n'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(_longLabel), findsNothing);
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      expect(taps, 0);
      expect(tester.getSize(find.byType(PrimaryButton)).height, 52.0);
    });

    testWidgets('enabled long-label button still receives taps', (tester) async {
      var taps = 0;
      await _pumpCapturing(
        tester,
        PrimaryButton(label: _longLabel, onPressed: () => taps++),
        size: const Size(320, 640),
        textScale: 1.3,
      );
      await tester.tap(find.byType(PrimaryButton));
      expect(taps, 1);
    });
  });
}
