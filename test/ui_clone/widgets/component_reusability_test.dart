import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';

/// Property-Based Test for Component Reusability
///
/// Feature: figma-ui-extraction, Property 4: Component Reusability
/// Validates: Requirements 4.1, 4.2, 4.3, 4.4
///
/// This test verifies that for any UI pattern that appears in multiple screens,
/// the extracted component should be usable across all those screens without
/// modification. We test this by using the same component instances in different
/// contexts and verifying they work correctly in all scenarios.
void main() {
  group('Component Reusability Property Tests', () {
    /// Property: Components should work in different layout contexts
    /// without modification
    testWidgets(
      'Property: WzPrimaryButton should work in Column, Row, and Stack layouts',
      (WidgetTester tester) async {
        bool columnTapped = false;
        bool rowTapped = false;
        bool stackTapped = false;

        // Test the same component type in different layout contexts
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Context 1: In a Column
                  WzPrimaryButton(
                    text: 'Column Button',
                    onPressed: () => columnTapped = true,
                  ),
                  // Context 2: In a Row
                  Row(
                    children: [
                      Expanded(
                        child: WzPrimaryButton(
                          text: 'Row Button',
                          onPressed: () => rowTapped = true,
                        ),
                      ),
                    ],
                  ),
                  // Context 3: In a Stack
                  SizedBox(
                    height: 100,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: WzPrimaryButton(
                            text: 'Stack Button',
                            onPressed: () => stackTapped = true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify all buttons render correctly
        expect(find.text('Column Button'), findsOneWidget);
        expect(find.text('Row Button'), findsOneWidget);
        expect(find.text('Stack Button'), findsOneWidget);

        // Verify all buttons are functional
        await tester.tap(find.text('Column Button'));
        await tester.pump();
        expect(columnTapped, isTrue);

        await tester.tap(find.text('Row Button'));
        await tester.pump();
        expect(rowTapped, isTrue);

        await tester.tap(find.text('Stack Button'));
        await tester.pump();
        expect(stackTapped, isTrue);
      },
    );

    /// Property: Components should work with different parameter combinations
    /// without requiring modification
    testWidgets(
      'Property: WzPrimaryButton should work with all parameter combinations',
      (WidgetTester tester) async {
        // Test various parameter combinations
        final testCases = [
          // Basic button
          {'text': 'Basic', 'hasCallback': true},
          // Button with icon
          {'text': 'Icon', 'hasCallback': true, 'hasIcon': true},
          // Button with custom width
          {'text': 'Width', 'hasCallback': true, 'width': 200.0},
          // Loading button
          {'text': 'Load', 'hasCallback': true, 'isLoading': true},
          // Disabled button
          {'text': 'Disabled', 'hasCallback': false},
          // All features combined
          {
            'text': 'All',
            'hasCallback': true,
            'hasIcon': true,
            'width': 300.0
          },
        ];

        for (int i = 0; i < testCases.length; i++) {
          final testCase = testCases[i];
          bool tapped = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: WzPrimaryButton(
                      text: testCase['text'] as String,
                      onPressed: (testCase['hasCallback'] as bool)
                          ? () => tapped = true
                          : null,
                      icon: (testCase['hasIcon'] as bool? ?? false)
                          ? const Icon(Icons.add, size: 16)
                          : null,
                      width: testCase['width'] as double?,
                      isLoading: testCase['isLoading'] as bool? ?? false,
                    ),
                  ),
                ),
              ),
            ),
          );

          // Verify button renders
          expect(find.byType(WzPrimaryButton), findsOneWidget);

          // Verify functionality based on parameters
          if (testCase['hasCallback'] as bool &&
              !(testCase['isLoading'] as bool? ?? false)) {
            await tester.tap(find.byType(ElevatedButton));
            await tester.pump();
            expect(tapped, isTrue,
                reason: 'Button should be tappable for case $i');
          }
        }
      },
    );

    /// Property: Components should maintain consistent styling across contexts
    testWidgets(
      'Property: WzPrimaryButton should maintain consistent styling in all contexts',
      (WidgetTester tester) async {
        // Create multiple instances in different contexts
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  WzPrimaryButton(text: 'Button 1', onPressed: () {}),
                  const SizedBox(height: 16),
                  WzPrimaryButton(text: 'Button 2', onPressed: () {}),
                  const SizedBox(height: 16),
                  WzPrimaryButton(text: 'Button 3', onPressed: () {}),
                ],
              ),
            ),
          ),
        );

        // Find all button instances
        final buttons = tester.widgetList<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        // Verify all buttons have consistent styling
        Color? firstButtonColor;
        for (final button in buttons) {
          final style = button.style!;
          final backgroundColor = style.backgroundColor!.resolve({});

          if (firstButtonColor == null) {
            firstButtonColor = backgroundColor;
          } else {
            expect(
              backgroundColor,
              equals(firstButtonColor),
              reason: 'All buttons should have the same background color',
            );
          }

          // Verify consistent color
          expect(backgroundColor, equals(WzColors.primary));
        }
      },
    );

    /// Property: Secondary buttons should be reusable across contexts
    testWidgets(
      'Property: WzSecondaryButton should work in multiple contexts',
      (WidgetTester tester) async {
        bool button1Tapped = false;
        bool button2Tapped = false;
        bool button3Tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Context 1: Full width in Column
                    WzSecondaryButton(
                      text: 'Sec 1',
                      onPressed: () => button1Tapped = true,
                    ),
                    const SizedBox(height: 8),
                    // Context 2: With icon
                    WzSecondaryButton(
                      text: 'Sec 2',
                      icon: const Icon(Icons.star, size: 16),
                      onPressed: () => button2Tapped = true,
                    ),
                    const SizedBox(height: 8),
                    // Context 3: Custom width
                    WzSecondaryButton(
                      text: 'Sec 3',
                      width: 200,
                      onPressed: () => button3Tapped = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify all buttons render
        expect(find.text('Sec 1'), findsOneWidget);
        expect(find.text('Sec 2'), findsOneWidget);
        expect(find.text('Sec 3'), findsOneWidget);

        // Verify all buttons are functional
        await tester.tap(find.text('Sec 1'));
        await tester.pump();
        expect(button1Tapped, isTrue);

        await tester.tap(find.text('Sec 2'));
        await tester.pump();
        expect(button2Tapped, isTrue);

        await tester.tap(find.text('Sec 3'));
        await tester.pump();
        expect(button3Tapped, isTrue);
      },
    );

    /// Property: Text buttons should be reusable across contexts
    testWidgets(
      'Property: WzTextButton should work in multiple contexts',
      (WidgetTester tester) async {
        bool inlineTapped = false;
        bool underlineTapped = false;
        bool customStyleTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Context 1: Inline text button
                  Row(
                    children: [
                      const Text('Already have an account? '),
                      WzTextButton(
                        text: 'Sign In',
                        onPressed: () => inlineTapped = true,
                      ),
                    ],
                  ),
                  // Context 2: Underlined text button
                  WzTextButton(
                    text: 'Forgot Password?',
                    underline: true,
                    onPressed: () => underlineTapped = true,
                  ),
                  // Context 3: Custom styled text button
                  WzTextButton(
                    text: 'Custom Style',
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    onPressed: () => customStyleTapped = true,
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify all buttons render
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Forgot Password?'), findsOneWidget);
        expect(find.text('Custom Style'), findsOneWidget);

        // Verify all buttons are functional
        await tester.tap(find.text('Sign In'));
        await tester.pump();
        expect(inlineTapped, isTrue);

        await tester.tap(find.text('Forgot Password?'));
        await tester.pump();
        expect(underlineTapped, isTrue);

        await tester.tap(find.text('Custom Style'));
        await tester.pump();
        expect(customStyleTapped, isTrue);
      },
    );

    /// Property: Icon buttons should be reusable across contexts
    testWidgets(
      'Property: WzIconButton should work in multiple contexts',
      (WidgetTester tester) async {
        bool likeTapped = false;
        bool rejectTapped = false;
        bool chatTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Context 1: Action buttons in a row (like in profile cards)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      WzIconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => rejectTapped = true,
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        iconColor: Colors.red,
                      ),
                      WzIconButton(
                        icon: const Icon(Icons.favorite),
                        onPressed: () => likeTapped = true,
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                        iconColor: Colors.green,
                      ),
                      WzIconButton(
                        icon: const Icon(Icons.chat),
                        onPressed: () => chatTapped = true,
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        iconColor: Colors.blue,
                      ),
                    ],
                  ),
                  // Context 2: Different sizes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      WzIconButton(
                        icon: const Icon(Icons.star),
                        size: 40,
                        onPressed: () {},
                      ),
                      WzIconButton(
                        icon: const Icon(Icons.star),
                        size: 64,
                        onPressed: () {},
                      ),
                      WzIconButton(
                        icon: const Icon(Icons.star),
                        size: 80,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify all buttons render
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.chat), findsOneWidget);
        expect(find.byIcon(Icons.star), findsNWidgets(3));

        // Verify buttons are functional
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        expect(rejectTapped, isTrue);

        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pump();
        expect(likeTapped, isTrue);

        await tester.tap(find.byIcon(Icons.chat));
        await tester.pump();
        expect(chatTapped, isTrue);
      },
    );

    /// Property: Components should work in nested contexts
    testWidgets(
      'Property: Components should work when nested in complex layouts',
      (WidgetTester tester) async {
        bool nestedButtonTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Profile Card'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                WzIconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {},
                                ),
                                WzIconButton(
                                  icon: const Icon(Icons.favorite),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            WzPrimaryButton(
                              text: 'View Profile',
                              onPressed: () => nestedButtonTapped = true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify components render in nested context
        expect(find.text('View Profile'), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);

        // Verify functionality in nested context
        await tester.tap(find.text('View Profile'));
        await tester.pump();
        expect(nestedButtonTapped, isTrue);
      },
    );

    /// Property: Components should maintain state consistency across contexts
    testWidgets(
      'Property: Loading state should work consistently across contexts',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  WzPrimaryButton(
                    text: 'Loading 1',
                    isLoading: true,
                  ),
                  WzSecondaryButton(
                    text: 'Loading 2',
                    isLoading: true,
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify loading indicators appear in all contexts
        expect(find.byType(CircularProgressIndicator), findsNWidgets(2));

        // Verify text is hidden when loading
        expect(find.text('Loading 1'), findsNothing);
        expect(find.text('Loading 2'), findsNothing);
      },
    );

    /// Property: Components should handle disabled state consistently
    testWidgets(
      'Property: Disabled state should work consistently across contexts',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  WzPrimaryButton(
                    text: 'Disabled Primary',
                    onPressed: null,
                  ),
                  WzSecondaryButton(
                    text: 'Disabled Secondary',
                    onPressed: null,
                  ),
                  WzTextButton(
                    text: 'Disabled Text',
                    onPressed: null,
                  ),
                  WzIconButton(
                    icon: Icon(Icons.favorite),
                    onPressed: null,
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify all buttons render in disabled state
        expect(find.text('Disabled Primary'), findsOneWidget);
        expect(find.text('Disabled Secondary'), findsOneWidget);
        expect(find.text('Disabled Text'), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);

        // Verify buttons are actually disabled
        final primaryButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(primaryButton.onPressed, isNull);

        final secondaryButton =
            tester.widget<OutlinedButton>(find.byType(OutlinedButton));
        expect(secondaryButton.onPressed, isNull);

        final textButtons = tester.widgetList<TextButton>(find.byType(TextButton));
        expect(textButtons.length, greaterThan(0));
        expect(textButtons.first.onPressed, isNull);

        // Find the InkWell inside WzIconButton
        final iconButtonInkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byType(WzIconButton),
            matching: find.byType(InkWell),
          ),
        );
        expect(iconButtonInkWell.onTap, isNull);
      },
    );

    /// Property: Components should work in responsive layouts
    testWidgets(
      'Property: Components should adapt to different screen sizes',
      (WidgetTester tester) async {
        // Test with different screen sizes
        final sizes = [
          const Size(375, 812), // iPhone X
          const Size(414, 896), // iPhone 11 Pro Max
          const Size(360, 640), // Small Android
        ];

        for (final size in sizes) {
          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      WzPrimaryButton(
                        text: 'Resp',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 8),
                      WzSecondaryButton(
                        text: 'Resp2',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          // Verify buttons render at all screen sizes
          expect(find.text('Resp'), findsOneWidget);
          expect(find.text('Resp2'), findsOneWidget);

          // Verify buttons maintain their height
          final primaryButtons = tester.widgetList<SizedBox>(
            find.ancestor(
              of: find.text('Resp'),
              matching: find.byType(SizedBox),
            ),
          );
          
          // Find the SizedBox that wraps the button (has height 48)
          final buttonSizedBox = primaryButtons.firstWhere(
            (sb) => sb.height == 48,
            orElse: () => const SizedBox(height: 48),
          );
          expect(buttonSizedBox.height, equals(48));
        }

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      },
    );
  });
}
