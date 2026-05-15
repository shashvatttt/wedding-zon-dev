import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weddingzon/ui_clone/widgets/wz_cards.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';

/// Unit Tests for Card Components
///
/// Requirements: 4.3, 4.4, 4.6
///
/// These tests verify card rendering with different content,
/// responsive behavior, and interaction callbacks.
void main() {
  group('WzProfileCard Tests', () {
    testWidgets('should render with full name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should render with age', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              age: 28,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('28'), findsOneWidget);
    });

    testWidgets('should render with location', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              location: 'New York',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('New York'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('should render with occupation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              occupation: 'Software Engineer',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Software Engineer'), findsOneWidget);
      expect(find.byIcon(Icons.work), findsOneWidget);
    });

    testWidgets('should render with religion', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              religion: 'Christian',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Christian'), findsOneWidget);
      expect(find.byIcon(Icons.church), findsOneWidget);
    });

    testWidgets('should render with about me', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              aboutMe: 'I love traveling and photography',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('I love traveling and photography'), findsOneWidget);
    });

    testWidgets('should show placeholder when no photos',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              photoUrls: [],
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should show share button when onShare provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              photoUrls: ['https://example.com/photo.jpg'],
              onShare: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('should call onTap callback when card tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              onTap: () {
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

    testWidgets('should call onShare callback when share button tapped',
        (WidgetTester tester) async {
      bool shared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              photoUrls: ['https://example.com/photo.jpg'],
              onShare: () {
                shared = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      expect(shared, isTrue);
    });

    testWidgets('should have elevation of 4', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              onTap: () {},
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(4));
    });

    testWidgets('should have border radius of 16',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzProfileCard(
              fullName: 'John Doe',
              onTap: () {},
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      final borderRadius = shape.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, equals(16));
    });
  });

  group('WzUserCard Tests', () {
    testWidgets('should render with full name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzUserCard(
              fullName: 'Jane Smith',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should render with age and location',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzUserCard(
              fullName: 'Jane Smith',
              age: 25,
              location: 'Los Angeles',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('25 years'), findsOneWidget);
      expect(find.text('Los Angeles'), findsOneWidget);
      expect(find.byIcon(Icons.cake), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('should render with about me', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzUserCard(
              fullName: 'Jane Smith',
              aboutMe: 'Passionate about art and music',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Passionate about art and music'), findsOneWidget);
    });

    testWidgets('should show chevron by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzUserCard(
              fullName: 'Jane Smith',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should hide chevron when showChevron is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzUserCard(
              fullName: 'Jane Smith',
              showChevron: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('should call onTap callback when card tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzUserCard(
              fullName: 'Jane Smith',
              onTap: () {
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

    testWidgets('should show avatar with first letter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzUserCard(
              fullName: 'Jane Smith',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('J'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });

  group('WzNotificationCard Tests', () {
    testWidgets('should render with name, action, and type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzNotificationCard(
              name: 'John Doe',
              action: 'accepted your',
              typeText: 'connection request',
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the RichText widget inside the notification card
      final richTextFinder = find.descendant(
        of: find.byType(WzNotificationCard),
        matching: find.byType(RichText),
      );
      expect(richTextFinder, findsWidgets);
      
      // Check that the text content is present
      final richText = tester.widgetList<RichText>(richTextFinder).firstWhere(
        (widget) {
          final textSpan = widget.text as TextSpan;
          final fullText = textSpan.toPlainText();
          return fullText.contains('John Doe');
        },
      );
      final textSpan = richText.text as TextSpan;
      final fullText = textSpan.toPlainText();
      expect(fullText.contains('John Doe'), isTrue);
      expect(fullText.contains('accepted your'), isTrue);
      expect(fullText.contains('connection request'), isTrue);
    });

    testWidgets('should show arrow icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzNotificationCard(
              name: 'John Doe',
              action: 'accepted your',
              typeText: 'connection request',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('should call onTap callback when card tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzNotificationCard(
              name: 'John Doe',
              action: 'accepted your',
              typeText: 'connection request',
              onTap: () {
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

    testWidgets('should have border but no elevation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzNotificationCard(
              name: 'John Doe',
              action: 'accepted your',
              typeText: 'connection request',
              onTap: () {},
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(0));

      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.side.color, equals(WzColors.border));
    });
  });

  group('WzRequestCard Tests', () {
    testWidgets('should render with display name and occupation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzRequestCard(
              displayName: 'Alice Johnson',
              occupation: 'Doctor',
              requestType: 'connection',
              onAccept: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      expect(find.text('Alice Johnson'), findsOneWidget);
      expect(find.text('Doctor'), findsOneWidget);
    });

    testWidgets('should show connection badge for connection type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzRequestCard(
              displayName: 'Alice Johnson',
              occupation: 'Doctor',
              requestType: 'connection',
              onAccept: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      expect(find.text('Connection'), findsOneWidget);
    });

    testWidgets('should show photo access badge for photo type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzRequestCard(
              displayName: 'Alice Johnson',
              occupation: 'Doctor',
              requestType: 'photo',
              onAccept: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      expect(find.text('Photo Access'), findsOneWidget);
    });

    testWidgets('should show accept and reject buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzRequestCard(
              displayName: 'Alice Johnson',
              occupation: 'Doctor',
              requestType: 'connection',
              onAccept: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should call onAccept callback when accept button tapped',
        (WidgetTester tester) async {
      bool accepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzRequestCard(
              displayName: 'Alice Johnson',
              occupation: 'Doctor',
              requestType: 'connection',
              onAccept: () {
                accepted = true;
              },
              onReject: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Accept'));
      await tester.pump();

      expect(accepted, isTrue);
    });

    testWidgets('should call onReject callback when reject button tapped',
        (WidgetTester tester) async {
      bool rejected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzRequestCard(
              displayName: 'Alice Johnson',
              occupation: 'Doctor',
              requestType: 'connection',
              onAccept: () {},
              onReject: () {
                rejected = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reject'));
      await tester.pump();

      expect(rejected, isTrue);
    });

    testWidgets('should disable buttons when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzRequestCard(
              displayName: 'Alice Johnson',
              occupation: 'Doctor',
              requestType: 'connection',
              isLoading: true,
              onAccept: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      final acceptButton =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final rejectButton =
          tester.widget<OutlinedButton>(find.byType(OutlinedButton));

      expect(acceptButton.onPressed, isNull);
      expect(rejectButton.onPressed, isNull);
    });
  });

  group('WzConversationTile Tests', () {
    testWidgets('should render with display name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzConversationTile(
              displayName: 'Bob Wilson',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Bob Wilson'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should render with last message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzConversationTile(
              displayName: 'Bob Wilson',
              lastMessage: 'Hey, how are you?',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Hey, how are you?'), findsOneWidget);
    });

    testWidgets('should show unread badge when unreadCount > 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzConversationTile(
              displayName: 'Bob Wilson',
              unreadCount: 5,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should show 99+ for unread count > 99',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzConversationTile(
              displayName: 'Bob Wilson',
              unreadCount: 150,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('should not show unread badge when unreadCount is 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzConversationTile(
              displayName: 'Bob Wilson',
              unreadCount: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      final badgeContainer = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == WzColors.primary,
      );
      expect(badgeContainer, findsNothing);
    });

    testWidgets('should call onTap callback when tile tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzConversationTile(
              displayName: 'Bob Wilson',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should format timestamp correctly',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 14, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WzConversationTile(
              displayName: 'Bob Wilson',
              timestamp: today,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('14:30'), findsOneWidget);
    });
  });
}
