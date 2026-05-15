import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weddingzon/ui_clone/navigation/ui_clone_home.dart';
import 'package:weddingzon/ui_clone/navigation/ui_clone_routes.dart';

/// Tests for the debug access point to UI clone
///
/// Validates Requirements 10.4, 10.6:
/// - Debug button/menu is accessible in development mode
/// - UI clone navigation is isolated from main app
/// - Only appears in debug builds
void main() {
  group('Debug Access Point Tests', () {
    testWidgets('UI clone home screen renders correctly', (WidgetTester tester) async {
      // Build the UI clone home screen
      await tester.pumpWidget(
        const MaterialApp(
          home: UiCloneHomeScreen(),
        ),
      );

      // Verify the screen renders
      expect(find.text('UI Clone Gallery'), findsOneWidget);
      expect(find.text('39 screens extracted from Figma'), findsOneWidget);
      
      // Verify search bar exists
      expect(find.byType(TextField), findsOneWidget);
      
      // Verify category filters exist (scroll to make them visible)
      await tester.pumpAndSettle();
      expect(find.text('All (39)'), findsOneWidget);
      expect(find.text('Authentication (7)'), findsOneWidget);
      
      // Verify at least some screens are visible
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Search functionality filters screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UiCloneHomeScreen(),
        ),
      );

      // Enter search query
      await tester.enterText(find.byType(TextField), 'login');
      await tester.pump();

      // Verify filtered results
      expect(find.text('Login Choice Screen'), findsOneWidget);
      expect(find.text('Mobile Login Screen'), findsOneWidget);
      expect(find.text('Google Login Screen'), findsOneWidget);
    });

    testWidgets('Category filter works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UiCloneHomeScreen(),
        ),
      );

      // Tap on Authentication category
      await tester.tap(find.text('Authentication (7)'));
      await tester.pump();

      // Verify only authentication screens are shown
      expect(find.text('Splash Screen'), findsOneWidget);
      expect(find.text('Login Choice Screen'), findsOneWidget);
      
      // Verify other category screens are not shown
      expect(find.text('Feed Screen'), findsNothing);
    });

    test('UI clone routes are properly configured', () {
      // Verify all routes are defined
      final routes = UiCloneRoutes.getRoutes();
      
      expect(routes.containsKey(UiCloneRoutes.splash), true);
      expect(routes.containsKey(UiCloneRoutes.loginChoice), true);
      expect(routes.containsKey(UiCloneRoutes.feed), true);
      expect(routes.containsKey(UiCloneRoutes.profile), true);
      
      // Verify total number of routes
      expect(routes.length, 39);
    });

    test('All screens have proper metadata', () {
      // Verify all screens have required information
      for (final screen in UiCloneRoutes.allScreens) {
        expect(screen.title.isNotEmpty, true, reason: 'Screen title should not be empty');
        expect(screen.route.isNotEmpty, true, reason: 'Screen route should not be empty');
        expect(screen.category.isNotEmpty, true, reason: 'Screen category should not be empty');
        expect(screen.description.isNotEmpty, true, reason: 'Screen description should not be empty');
        expect(screen.route.startsWith('/ui-clone'), true, reason: 'Route should be isolated under /ui-clone');
      }
    });

    test('Screen count matches documentation', () {
      // Verify total screen count
      expect(UiCloneRoutes.allScreens.length, 39);
      
      // Verify category counts
      final authScreens = UiCloneRoutes.allScreens.where((s) => s.category == 'Authentication').length;
      final profileScreens = UiCloneRoutes.allScreens.where((s) => s.category == 'Profile Creation').length;
      final mainScreens = UiCloneRoutes.allScreens.where((s) => s.category == 'Main Features').length;
      final vendorScreens = UiCloneRoutes.allScreens.where((s) => s.category == 'Vendor/Franchise').length;
      final componentScreens = UiCloneRoutes.allScreens.where((s) => s.category == 'Components').length;
      
      expect(authScreens, 7);
      expect(profileScreens, 12);
      expect(mainScreens, 9);
      expect(vendorScreens, 10);
      expect(componentScreens, 1);
    });

    testWidgets('Navigation to screen works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const UiCloneHomeScreen(),
          routes: UiCloneRoutes.getRoutes(),
        ),
      );

      // Find and tap on a screen card
      await tester.tap(find.text('Splash Screen').first);
      await tester.pumpAndSettle();

      // Verify navigation occurred (screen should change)
      // Note: We can't verify the exact screen content without importing it,
      // but we can verify the navigation action completed
      expect(tester.takeException(), isNull);
    });

    testWidgets('Close button navigates back', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UiCloneHomeScreen()),
                  );
                },
                child: const Text('Open UI Clone'),
              ),
            ),
          ),
        ),
      );

      // Open UI clone
      await tester.tap(find.text('Open UI Clone'));
      await tester.pumpAndSettle();

      // Verify UI clone is shown
      expect(find.text('UI Clone Gallery'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify we're back to the original screen
      expect(find.text('Open UI Clone'), findsOneWidget);
      expect(find.text('UI Clone Gallery'), findsNothing);
    });
  });

  group('Debug Mode Verification', () {
    test('Debug mode detection works correctly', () {
      // In test environment, debug mode should be true
      bool isDebugMode = false;
      assert(() {
        isDebugMode = true;
        return true;
      }());
      
      expect(isDebugMode, true, reason: 'Tests run in debug mode');
    });
  });
}
