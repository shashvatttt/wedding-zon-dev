import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weddingzon/ui_clone/navigation/ui_clone_routes.dart';
import 'package:weddingzon/ui_clone/navigation/ui_clone_home.dart';

void main() {
  group('UI Clone Navigation Tests', () {
    test('All 39 screens should have routes defined', () {
      // Verify we have exactly 39 screens
      expect(UiCloneRoutes.allScreens.length, 39);

      // Verify all screens have valid route names
      for (final screen in UiCloneRoutes.allScreens) {
        expect(screen.route, isNotEmpty);
        expect(screen.route, startsWith('/ui-clone'));
        expect(screen.title, isNotEmpty);
        expect(screen.category, isNotEmpty);
        expect(screen.description, isNotEmpty);
      }
    });

    test('All routes should be unique', () {
      final routes = UiCloneRoutes.allScreens.map((s) => s.route).toList();
      final uniqueRoutes = routes.toSet();
      expect(routes.length, uniqueRoutes.length,
          reason: 'All routes should be unique');
    });

    test('Route map should contain all screen routes', () {
      final routeMap = UiCloneRoutes.getRoutes();
      
      // Should have 39 routes (excluding home route)
      expect(routeMap.length, 39);

      // Verify each screen has a corresponding route in the map
      for (final screen in UiCloneRoutes.allScreens) {
        expect(routeMap.containsKey(screen.route), true,
            reason: 'Route map should contain ${screen.route}');
      }
    });

    test('Screens should be organized into correct categories', () {
      final categoryCount = <String, int>{};
      
      for (final screen in UiCloneRoutes.allScreens) {
        categoryCount[screen.category] = 
            (categoryCount[screen.category] ?? 0) + 1;
      }

      // Verify expected category counts
      expect(categoryCount['Authentication'], 7);
      expect(categoryCount['Profile Creation'], 12);
      expect(categoryCount['Main Features'], 9);
      expect(categoryCount['Vendor/Franchise'], 10);
      expect(categoryCount['Components'], 1);
    });

    testWidgets('UI Clone Home Screen should display all screens',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UiCloneHomeScreen(),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the app bar title
      expect(find.text('UI Clone Gallery'), findsOneWidget);

      // Verify the info banner shows correct count
      expect(find.textContaining('39 screens extracted'), findsOneWidget);

      // Verify search bar exists
      expect(find.byType(TextField), findsOneWidget);

      // Verify the "All" category chip exists with correct count
      expect(find.text('All (39)'), findsOneWidget);
      
      // Verify category chips exist (at least one widget per category)
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('Search functionality should filter screens',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UiCloneHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'login');
      await tester.pumpAndSettle();

      // Should find login-related screens
      expect(find.textContaining('Login'), findsWidgets);
    });

    testWidgets('Category filter should work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UiCloneHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Authentication category
      await tester.tap(find.text('Authentication (7)'));
      await tester.pumpAndSettle();

      // Should only show authentication screens
      // Verify by checking that the category chip is selected
      final authChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Authentication (7)'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(authChip.selected, true);
    });

    test('Navigation isolation - routes should not conflict with main app', () {
      final uiCloneRoutes = UiCloneRoutes.getRoutes();
      
      // All UI clone routes should start with /ui-clone
      for (final route in uiCloneRoutes.keys) {
        expect(route, startsWith('/ui-clone'),
            reason: 'All UI clone routes should be prefixed with /ui-clone');
      }
    });
  });
}

