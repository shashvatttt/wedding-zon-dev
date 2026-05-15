import 'package:flutter/material.dart';
import '../widgets/wz_buttons.dart';
import '../widgets/wz_inputs.dart';
import '../widgets/wz_cards.dart';
import '../widgets/wz_navigation.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import '../../core/theme/wz_spacing.dart';
import '../../shared/widgets/wz_toast.dart';
import 'splash_screen_ui.dart';
import 'login_choice_screen_ui.dart';
import 'mobile_login_screen_ui.dart';
import 'google_login_screen_ui.dart';
import 'otp_screen_ui.dart';
import 'role_selection_screen_ui.dart';
import 'profile_basic_details_ui.dart';
import 'profile_location_ui.dart';
import 'profile_education_ui.dart';
import 'profile_family_ui.dart';
import 'feed_screen_ui.dart';
import 'explore_screen_ui.dart';
import 'chat_list_screen_ui.dart';

class ComponentsDemoScreenUI extends StatefulWidget {
  const ComponentsDemoScreenUI({super.key});

  @override
  State<ComponentsDemoScreenUI> createState() => _ComponentsDemoScreenUIState();
}

class _ComponentsDemoScreenUIState extends State<ComponentsDemoScreenUI> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WzAppBar(title: 'UI Components Demo', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WzSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Extracted Screens'),
            const SizedBox(height: WzSpacing.space16),
            _buildScreensSection(),
            const SizedBox(height: WzSpacing.space32),

            _buildSectionTitle('Buttons'),
            const SizedBox(height: WzSpacing.space16),
            _buildButtonsSection(),
            const SizedBox(height: WzSpacing.space32),

            _buildSectionTitle('Input Fields'),
            const SizedBox(height: WzSpacing.space16),
            _buildInputsSection(),
            const SizedBox(height: WzSpacing.space32),

            _buildSectionTitle('Cards'),
            const SizedBox(height: WzSpacing.space16),
            _buildCardsSection(),
            const SizedBox(height: WzSpacing.space32),

            _buildSectionTitle('Navigation'),
            const SizedBox(height: WzSpacing.space16),
            _buildNavigationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: WzTextStyles.heading2);
  }

  Widget _buildScreensSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildScreenButton('Splash Screen', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SplashScreenUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Login Choice Screen', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginChoiceScreenUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Mobile Login Screen', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MobileLoginScreenUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Google Login Screen', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GoogleLoginScreenUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('OTP Screen', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OTPScreenUI(phoneNumber: '+919876543210'),
            ),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Role Selection Screen', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreenUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Profile Basic Details', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileBasicDetailsUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Profile Location', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileLocationUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Profile Education', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileEducationUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Profile Family', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileFamilyUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Feed Screen', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedScreenUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Explore Screen', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExploreScreenUI()),
          );
        }),
        const SizedBox(height: WzSpacing.space8),
        _buildScreenButton('Chat List Screen', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatListScreenUI()),
          );
        }),
      ],
    );
  }

  Widget _buildScreenButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: WzColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WzPrimaryButton(
          text: 'Primary Button',
          onPressed: () {
            WzToast.show(
              context,
              message: 'Primary button pressed',
              type: WzToastType.success,
            );
          },
        ),
        const SizedBox(height: WzSpacing.space12),
        WzSecondaryButton(
          text: 'Secondary Button',
          onPressed: () {
            WzToast.show(
              context,
              message: 'Secondary button pressed',
              type: WzToastType.normal,
            );
          },
        ),
        const SizedBox(height: WzSpacing.space12),
        WzTextButton(
          text: 'Text Button',
          onPressed: () {
            WzToast.show(
              context,
              message: 'Text button pressed',
              type: WzToastType.normal,
            );
          },
        ),
        const SizedBox(height: WzSpacing.space12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            WzIconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                WzToast.show(
                  context,
                  message: 'Like pressed',
                  type: WzToastType.success,
                );
              },
            ),
            WzIconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                WzToast.show(
                  context,
                  message: 'Reject pressed',
                  type: WzToastType.error,
                );
              },
            ),
            WzIconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                WzToast.show(
                  context,
                  message: 'Chat pressed',
                  type: WzToastType.normal,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputsSection() {
    return Column(
      children: [
        const WzTextField(label: 'Full Name', hint: 'Enter your full name'),
        const SizedBox(height: WzSpacing.space16),
        const WzPasswordField(label: 'Password', hint: 'Enter your password'),
        const SizedBox(height: WzSpacing.space16),
        WzDropdown(
          label: 'Gender',
          hint: 'Select gender',
          items: const ['Male', 'Female', 'Other'],
          onChanged: (value) {
            WzToast.show(
              context,
              message: 'Selected: $value',
              type: WzToastType.normal,
            );
          },
        ),
        const SizedBox(height: WzSpacing.space16),
        WzDatePicker(
          label: 'Date of Birth',
          hint: 'Select date',
          onDateSelected: (date) {
            WzToast.show(
              context,
              message: 'Selected: ${date.toString().split(' ')[0]}',
              type: WzToastType.normal,
            );
          },
        ),
        const SizedBox(height: WzSpacing.space16),
        WzSearchBar(
          hint: 'Search...',
          controller: _searchController,
          onChanged: (value) {},
          onClear: () {
            _searchController.clear();
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return Column(
      children: [
        WzUserCard(
          fullName: 'John Doe',
          age: 28,
          location: 'Mumbai, India',
          aboutMe:
              'Software Engineer passionate about technology and innovation.',
          onTap: () {
            WzToast.show(
              context,
              message: 'User card tapped',
              type: WzToastType.normal,
            );
          },
        ),
        const SizedBox(height: WzSpacing.space16),
        WzNotificationCard(
          name: 'Jane Smith',
          action: 'sent you a',
          typeText: 'connection request',
          onTap: () {
            WzToast.show(
              context,
              message: 'Notification tapped',
              type: WzToastType.normal,
            );
          },
        ),
        const SizedBox(height: WzSpacing.space16),
        WzRequestCard(
          displayName: 'Mike Johnson',
          occupation: 'Business Analyst',
          requestType: 'connection',
          onAccept: () {
            WzToast.show(
              context,
              message: 'Request accepted',
              type: WzToastType.success,
            );
          },
          onReject: () {
            WzToast.show(
              context,
              message: 'Request rejected',
              type: WzToastType.error,
            );
          },
        ),
        const SizedBox(height: WzSpacing.space16),
        WzConversationTile(
          displayName: 'Sarah Williams',
          lastMessage: 'Hey! How are you doing?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 3,
          onTap: () {
            WzToast.show(
              context,
              message: 'Conversation tapped',
              type: WzToastType.normal,
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavigationSection() {
    return Column(
      children: [
        const WzStatusBar(time: '9:41'),
        const SizedBox(height: WzSpacing.space16),
        WzTabBar(
          tabs: const ['Tab 1', 'Tab 2', 'Tab 3'],
          currentIndex: _selectedTab,
          onTap: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
        ),
        const SizedBox(height: WzSpacing.space16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: WzColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: WzBottomNav(
            currentIndex: 0,
            onTap: (index) {
              WzToast.show(
                context,
                message: 'Nav item $index tapped',
                type: WzToastType.normal,
              );
            },
            items: const [
              WzBottomNavItem(icon: Icons.home, label: 'Home'),
              WzBottomNavItem(icon: Icons.explore, label: 'Explore'),
              WzBottomNavItem(icon: Icons.people, label: 'Connect'),
              WzBottomNavItem(icon: Icons.chat, label: 'Chat'),
              WzBottomNavItem(icon: Icons.person, label: 'Profile'),
            ],
          ),
        ),
      ],
    );
  }
}
