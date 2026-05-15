import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';

/// Unit Tests for Button Components
///
/// Requirements: 4.1, 4.6
///
/// These tests verify button rendering with different parameters,
/// loading state behavior, disabled state behavior, and tap callbacks.
void main() {
  group('WzPrimaryButton Tests', () {
    testWidgets('should render with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzPrimaryButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render with custom width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WzPrimaryButton(
                text: 'Button',
                width: 300,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(300));
      expect(sizedBox.height, equals(48));
    });

    testWidgets('should render with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzPrimaryButton(
              text: 'Test Button',
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzPrimaryButton(
              text: 'Test Button',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('should be disabled when isLoading is true',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzPrimaryButton(
              text: 'Test Button',
              isLoading: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('should be disabled when onPressed is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzPrimaryButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should call onPressed callback when tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzPrimaryButton(
              text: 'Test Button',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should use primary color from design system',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzPrimaryButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;
      final backgroundColor = style.backgroundColor!.resolve({});

      expect(backgroundColor, equals(WzColors.primary));
    });

    testWidgets('should use muted color when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzPrimaryButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;
      final disabledBackgroundColor =
          style.backgroundColor!.resolve({WidgetState.disabled});

      expect(disabledBackgroundColor, equals(WzColors.muted));
    });
  });

  group('WzSecondaryButton Tests', () {
    testWidgets('should render with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzSecondaryButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should render with custom width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WzSecondaryButton(
                text: 'Button',
                width: 300,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(300));
      expect(sizedBox.height, equals(48));
    });

    testWidgets('should render with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzSecondaryButton(
              text: 'Test Button',
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzSecondaryButton(
              text: 'Test Button',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('should be disabled when isLoading is true',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzSecondaryButton(
              text: 'Test Button',
              isLoading: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('should call onPressed callback when tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzSecondaryButton(
              text: 'Test Button',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should have primary color border',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzSecondaryButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final style = button.style!;
      final side = style.side!.resolve({});

      expect(side?.color, equals(WzColors.primary));
      expect(side?.width, equals(1));
    });
  });

  group('WzTextButton Tests', () {
    testWidgets('should render with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTextButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should render with underline when specified',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTextButton(
              text: 'Test Button',
              underline: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test Button'));
      expect(textWidget.style?.decoration, equals(TextDecoration.underline));
    });

    testWidgets('should render without underline by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTextButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test Button'));
      expect(textWidget.style?.decoration, isNull);
    });

    testWidgets('should use custom text style when provided',
        (WidgetTester tester) async {
      const customStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTextButton(
              text: 'Test Button',
              textStyle: customStyle,
              onPressed: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test Button'));
      expect(textWidget.style?.fontSize, equals(20));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should call onPressed callback when tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTextButton(
              text: 'Test Button',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should be disabled when onPressed is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzTextButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });
  });

  group('WzIconButton Tests', () {
    testWidgets('should render with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzIconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should render with custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzIconButton(
              icon: const Icon(Icons.favorite),
              size: 80,
              onPressed: () {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(80));
      expect(sizedBox.height, equals(80));
    });

    testWidgets('should use default size of 64', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzIconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(64));
      expect(sizedBox.height, equals(64));
    });

    testWidgets('should render with custom background color',
        (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzIconButton(
              icon: const Icon(Icons.favorite),
              backgroundColor: customColor,
              onPressed: () {},
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(WzIconButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, equals(customColor));
    });

    testWidgets('should render with custom icon color',
        (WidgetTester tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzIconButton(
              icon: const Icon(Icons.favorite),
              iconColor: customColor,
              onPressed: () {},
            ),
          ),
        ),
      );

      final iconTheme = tester.widget<IconTheme>(
        find.descendant(
          of: find.byType(WzIconButton),
          matching: find.byType(IconTheme),
        ),
      );
      expect(iconTheme.data.color, equals(customColor));
    });

    testWidgets('should call onPressed callback when tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzIconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should be disabled when onPressed is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzIconButton(
              icon: Icon(Icons.favorite),
              onPressed: null,
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });

    testWidgets('should have circular shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzIconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {},
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(WzIconButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.shape, isA<CircleBorder>());
    });
  });
}
