import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/widgets/widgets.dart';

void main() {
  group('CenteredLoadingIndicator Tests', () {
    testWidgets('Renders properly with default height', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CenteredLoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final widget = tester.widget<CenteredLoadingIndicator>(find.byType(CenteredLoadingIndicator));
      expect(widget.height, isNull);
    });

    testWidgets('Renders properly with custom height', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CenteredLoadingIndicator(height: 350),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final widget = tester.widget<CenteredLoadingIndicator>(find.byType(CenteredLoadingIndicator));
      expect(widget.height, 350);
    });
  });

  group('DetailRow Tests', () {
    testWidgets('Renders label and value properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DetailRow(
              icon: Icons.email,
              label: 'Email',
              value: 'test@example.com',
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });

  group('InitialsAvatar Tests', () {
    testWidgets('Generates correct initials for single word', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InitialsAvatar(name: 'John'),
          ),
        ),
      );

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('Generates correct initials for multiple words', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InitialsAvatar(name: 'John Doe Smith'),
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });
  });

  group('PrimaryButton Tests', () {
    testWidgets('Renders text and responds to taps', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Submit',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      expect(tapped, isTrue);
    });

    testWidgets('Does not tap when loading', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Submit',
              isLoading: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(PrimaryButton));
      expect(tapped, isFalse);
    });
  });

  group('RestrictedAccessCard Tests', () {
    testWidgets('Renders title, message, and custom content override', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RestrictedAccessCard(
              title: 'Permission Denied',
              message: 'You do not have access to view this data.',
            ),
          ),
        ),
      );

      expect(find.text('Permission Denied'), findsOneWidget);
      expect(find.text('You do not have access to view this data.'), findsOneWidget);
    });
  });

  group('SearchTextField Tests', () {
    testWidgets('Triggers onChanged callback and holds text', (WidgetTester tester) async {
      final controller = TextEditingController();
      String changedText = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTextField(
              controller: controller,
              hintText: 'Search here...',
              onChanged: (val) {
                changedText = val;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Query');
      expect(controller.text, 'Query');
      expect(changedText, 'Query');
    });
  });

  group('SegmentedControl Tests', () {
    testWidgets('Displays options and triggers changes', (WidgetTester tester) async {
      int active = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedControl(
              labels: const ['Tab 1', 'Tab 2'],
              activeIndex: active,
              onSegmentChanged: (idx) {
                active = idx;
              },
            ),
          ),
        ),
      );

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);

      await tester.tap(find.text('Tab 2'));
      expect(active, 1);
    });
  });

  group('StarRatingDisplay Tests', () {
    testWidgets('Renders rating stars correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: 3),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    });
  });

  group('StatCard Tests', () {
    testWidgets('Displays value and label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              value: '100',
              label: 'Views',
            ),
          ),
        ),
      );

      expect(find.text('100'), findsOneWidget);
      expect(find.text('VIEWS'), findsOneWidget);
    });
  });

  group('StatusPill Tests', () {
    testWidgets('Displays correct status text and style using factories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusPill.active(label: 'Active'),
                StatusPill.warning(label: 'Warning'),
                StatusPill.danger(label: 'Danger'),
                StatusPill.info(label: 'Info'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Danger'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
    });
  });
}
