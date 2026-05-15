import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weddingzon/ui_clone/widgets/wz_navigation.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';

/// Unit Tests for Navigation Components
///
/// Requirements: 4.3, 4.4, 4.6
///
/// These tests verify navigation component rendering,
/// interactions, and responsive behavior.
void main() {
  group('WzAppBar Tests', () {
    testWidgets('should render with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: WzAppBar(title: 'Test Title'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render without title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: WzAppBar(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should render with leading widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: WzAppBar(
              title: 'Test',
              leading: Icon(Icons.menu),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should render with action widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: WzAppBar(
              title: 'Test',
              actions: [
                Icon(Icons.search),
                Icon(Icons.more_vert),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should center title when centerTitle is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: WzAppBar(
              title: 'Test',
              centerTitle: true,
            ),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });

    testWidgets('should use custom background color',
        (WidgetTester tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: WzAppBar(
              title: 'Test',
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(customColor));
    });

    testWidgets('should use white background by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: WzAppBar(title: 'Test'),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(WzColors.white));
    });

    testWidgets('should have elevation of 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: WzAppBar(title: 'Test'),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, equals(0));
    });

    testWidgets('should have preferred size of 56',
        (WidgetTester tester) async {
      const wzAppBar = WzAppBar(title: 'Test');
      expect(wzAppBar.preferredSize.height, equals(56));
    });
  });

  group('WzStatusBar Tests', () {
    testWidgets('should render with default time', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzStatusBar(),
          ),
        ),
      );

      expect(find.text('9:41'), findsOneWidget);
    });

    testWidgets('should render with custom time', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzStatusBar(time: '12:30'),
          ),
        ),
      );

      expect(find.text('12:30'), findsOneWidget);
    });

    testWidgets('should show status icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzStatusBar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.signal_cellular_4_bar), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.battery_full), findsOneWidget);
    });

    testWidgets('should have height of 58', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WzStatusBar(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minHeight, equals(58));
    });
  });

  group('WzBottomNav Tests', () {
    testWidgets('should render with items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzBottomNav(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                WzBottomNavItem(icon: Icons.home, label: 'Home'),
                WzBottomNavItem(icon: Icons.search, label: 'Search'),
                WzBottomNavItem(icon: Icons.person, label: 'Profile'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should highlight selected item', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzBottomNav(
              currentIndex: 1,
              onTap: (_) {},
              items: const [
                WzBottomNavItem(icon: Icons.home, label: 'Home'),
                WzBottomNavItem(icon: Icons.search, label: 'Search'),
                WzBottomNavItem(icon: Icons.person, label: 'Profile'),
              ],
            ),
          ),
        ),
      );

      final searchIcon = tester.widget<Icon>(
        find.descendant(
          of: find.widgetWithText(InkWell, 'Search'),
          matching: find.byType(Icon),
        ),
      );
      expect(searchIcon.color, equals(WzColors.primary));
    });

    testWidgets('should call onTap callback when item tapped',
        (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzBottomNav(
              currentIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
              items: const [
                WzBottomNavItem(icon: Icons.home, label: 'Home'),
                WzBottomNavItem(icon: Icons.search, label: 'Search'),
                WzBottomNavItem(icon: Icons.person, label: 'Profile'),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(tappedIndex, equals(1));
    });

    testWidgets('should have white background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzBottomNav(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                WzBottomNavItem(icon: Icons.home, label: 'Home'),
              ],
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WzBottomNav),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(WzColors.white));
    });

    testWidgets('should have shadow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzBottomNav(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                WzBottomNavItem(icon: Icons.home, label: 'Home'),
              ],
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WzBottomNav),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
    });
  });

  group('WzTabBar Tests', () {
    testWidgets('should render with tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTabBar(
              tabs: const ['Tab 1', 'Tab 2', 'Tab 3'],
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
    });

    testWidgets('should highlight selected tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTabBar(
              tabs: const ['Tab 1', 'Tab 2', 'Tab 3'],
              currentIndex: 1,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final tab2Text = tester.widget<Text>(find.text('Tab 2'));
      expect(tab2Text.style?.color, equals(WzColors.primary));
      expect(tab2Text.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should call onTap callback when tab tapped',
        (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTabBar(
              tabs: const ['Tab 1', 'Tab 2', 'Tab 3'],
              currentIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tab 2'));
      await tester.pump();

      expect(tappedIndex, equals(1));
    });

    testWidgets('should be scrollable when isScrollable is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTabBar(
              tabs: const ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4', 'Tab 5'],
              currentIndex: 0,
              onTap: (_) {},
              isScrollable: true,
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should not be scrollable by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTabBar(
              tabs: const ['Tab 1', 'Tab 2', 'Tab 3'],
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('should have height of 48', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTabBar(
              tabs: const ['Tab 1', 'Tab 2'],
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minHeight, equals(48));
    });

    testWidgets('should have bottom border', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzTabBar(
              tabs: const ['Tab 1', 'Tab 2'],
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });

  group('WzDrawer Tests', () {
    testWidgets('should render with items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzDrawer(
              items: const [
                WzDrawerItem(title: 'Home', icon: Icons.home),
                WzDrawerItem(title: 'Settings', icon: Icons.settings),
                WzDrawerItem(title: 'Logout', icon: Icons.logout),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('should render with header', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzDrawer(
              header: const Text('User Profile'),
              items: const [
                WzDrawerItem(title: 'Home', icon: Icons.home),
              ],
            ),
          ),
        ),
      );

      expect(find.text('User Profile'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('should call onItemTap callback when item tapped',
        (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzDrawer(
              items: const [
                WzDrawerItem(title: 'Home', icon: Icons.home),
                WzDrawerItem(title: 'Settings', icon: Icons.settings),
              ],
              onItemTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(tappedIndex, equals(1));
    });

    testWidgets('should render divider items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzDrawer(
              items: const [
                WzDrawerItem(title: 'Home', icon: Icons.home),
                WzDrawerItem.divider(),
                WzDrawerItem(title: 'Settings', icon: Icons.settings),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('should have white background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzDrawer(
              items: const [
                WzDrawerItem(title: 'Home', icon: Icons.home),
              ],
            ),
          ),
        ),
      );

      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.backgroundColor, equals(WzColors.white));
    });

    testWidgets('should render trailing widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzDrawer(
              items: const [
                WzDrawerItem(
                  title: 'Notifications',
                  icon: Icons.notifications,
                  trailing: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });
  });
}
