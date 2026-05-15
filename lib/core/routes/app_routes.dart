import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/ui_clone/screens/home_landing_screen_ui.dart';

import '../../ui_clone/screens/splash_screen_ui.dart';
import '../../ui_clone/screens/auth_choice_screen_ui.dart';
import '../../ui_clone/screens/login_choice_screen_ui.dart';
import '../../ui_clone/screens/google_login_screen_ui.dart';
import '../../ui_clone/screens/username_login_screen_ui.dart';
import '../../ui_clone/screens/mobile_login_screen_ui.dart';
import '../../ui_clone/screens/mobile_signup_screen_ui.dart';
import '../../ui_clone/screens/otp_screen_ui.dart';
import '../../ui_clone/screens/role_selection_screen_ui.dart';
import '../../ui_clone/screens/membership_plans_screen_ui.dart';
import '../../features/onboarding/screens/profile_form_screen.dart';
import '../../ui_clone/screens/profile_basic_details_ui.dart';
import '../../ui_clone/screens/profile_additional_details_ui.dart';
import '../../ui_clone/screens/profile_location_ui.dart';
import '../../ui_clone/screens/profile_family_ui.dart';
import '../../ui_clone/screens/profile_education_ui.dart';
import '../../ui_clone/screens/profile_religious_background_ui.dart';
import '../../ui_clone/screens/profile_lifestyle_ui.dart';
import '../../ui_clone/screens/profile_habits_ui.dart';
import '../../ui_clone/screens/profile_property_assets_ui.dart';
import '../../ui_clone/screens/profile_contact_details_ui.dart';
import '../../ui_clone/screens/profile_about_me_ui.dart';
import '../../ui_clone/screens/profile_photos_upload_ui.dart';
import '../../ui_clone/screens/partner_preferences_edit_ui.dart';
import '../../ui_clone/screens/profile_partner_preferences_onboarding_ui.dart';
import '../../features/shell/screens/main_shell_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/full_profile_screen.dart';
import '../../ui_clone/screens/feed_screen_ui.dart';
import '../../features/feed/models/feed_user.dart';

import '../../features/connections/screens/connections_screen.dart';
import '../../features/connections/screens/my_connections_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_viewers_screen.dart';
import '../../core/models/user_model.dart';
import '../../core/services/api_service.dart';

import '../../features/franchise/screens/franchise_dashboard.dart';
import '../../features/franchise/screens/add_member_screen.dart';
import '../../features/franchise/screens/manage_member_screen.dart';
import '../../features/franchise/screens/member_profile_screen.dart';
import '../../features/franchise/screens/partner_preferences_screen.dart';
import '../../features/franchise/screens/franchise_payment_screen.dart';
import '../../features/franchise/screens/franchise_approval_screen.dart';
import '../../features/franchise/screens/franchise_login_screen.dart';
import '../../features/franchise/providers/franchise_form_provider.dart';

import '../../features/vendor/screens/vendor_dashboard.dart';
import '../../features/vendor/screens/vendor_payment_screen.dart';
import '../../features/vendor/screens/vendor_approval_screen.dart';
import '../../features/vendor/screens/vendor_profile_screen.dart';
import '../../features/vendor/screens/vendor_availability_calendar_screen.dart';
import '../../features/vendor/providers/vendor_provider.dart';

import '../../features/chat/screens/conversations_screen.dart';
import '../../features/chat/screens/chat_screen_new.dart';
import '../../core/models/conversation_model.dart';

import '../../features/shop/screens/shop_screen.dart';
import '../../ui_clone/screens/product_detail_screen_ui.dart';
import '../../features/shop/providers/shop_provider.dart';
import '../../features/vendor/models/product_model.dart';
import '../../features/map/screens/map_screen.dart';

import '../../ui_clone/navigation/ui_clone_home.dart';
import '../../ui_clone/screens/chat_conversation_screen_ui.dart';
import '../../ui_clone/screens/user_profile_view_ui.dart';
import '../../ui_clone/screens/feed_filters_screen_ui.dart';
import '../../ui_clone/screens/connections_screen_ui.dart';
import '../../ui_clone/screens/vendor_listing_basic_details_ui.dart';
import '../../features/franchise/screens/franchise_registration_screen.dart';
import '../../ui_clone/screens/photo_manager_screen_ui.dart';
import '../../ui_clone/screens/vendor_categories_screen_ui.dart';
import '../../ui_clone/screens/vendor_browse_screen_ui.dart';
import '../../features/franchise/screens/franchise_admin_phone_screen.dart';
import '../../features/franchise/screens/franchise_admin_otp_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String landing = '/landing';
  static const String guestHome = '/landing-home';
  static const String signInChoice = '/auth/login-choice';
  static const String loginChoice = '/login-choice';
  static const String franchiseLogin = '/franchise/login';
  static const String franchiseAdminLogin = '/franchise/admin/login';
  static const String franchiseAdminOtp = '/franchise/admin/otp';
  static const String usernameLogin = '/auth/username-login';
  static const String signUpChoice = '/auth/signup-choice';
  static const String signupChoice = '/signup-choice';
  static const String googleLogin = '/auth/google-login';
  static const String googleSignup = '/auth/google-signup';
  static const String mobileLogin = '/auth/mobile-login';
  static const String mobileSignup = '/auth/mobile-signup';
  static const String loginOtp = '/auth/login-otp';
  static const String signupOtp = '/auth/signup-otp';
  static const String roleSelection = '/onboarding/role';
  static const String profileForm = '/onboarding/profile';
  static const String home = '/shell';
  static const String feed = '/feed';
  static const String vendors = '/vendors';

  static const String profileBasicDetails = '/onboarding/basic-details';
  static const String profileAdditionalDetails =
      '/onboarding/additional-details';
  static const String profileLocation = '/onboarding/location';
  static const String profileFamily = '/onboarding/family';
  static const String profileEducation = '/onboarding/education';
  static const String profileReligious = '/onboarding/religious';
  static const String profileLifestyle = '/onboarding/lifestyle';
  static const String profileHabits = '/onboarding/habits';
  static const String profileProperty = '/onboarding/property';
  static const String profileContact = '/onboarding/contact';
  static const String profileAbout = '/onboarding/about-me';
  static const String profilePhotos = '/onboarding/photos-upload';
  static const String profilePartnerPreferences =
      '/onboarding/partner-preferences';

  static const String editBasicDetails = '/profile/edit/basic-details';
  static const String editAdditionalDetails =
      '/profile/edit/additional-details';
  static const String editLocation = '/profile/edit/location';
  static const String editFamily = '/profile/edit/family';
  static const String editEducation = '/profile/edit/education';
  static const String editReligious = '/profile/edit/religious';
  static const String editLifestyle = '/profile/edit/lifestyle';
  static const String editHabits = '/profile/edit/habits';
  static const String editProperty = '/profile/edit/property';
  static const String editContact = '/profile/edit/contact';
  static const String editAbout = '/profile/edit/about-me';
  static const String explore = '/explore';
  static const String chatTab = '/chat-tab';
  static const String profileTab = '/profile-tab';
  static const String editProfile = '/profile/edit';
  static const String fullProfile = '/profile/full';
  static const String photoManager = '/profile/photos';
  static const String userProfile = '/profile/user';
  static const String userProfileView = '/profile/view';
  static const String userPartnerPreferences = '/profile/preferences';
  static const String profileViewers = '/profile/viewers';

  static const String connections = '/connections';
  static const String myConnections = '/connections/my';
  static const String notifications = '/notifications';

  static const String franchiseDashboard = '/franchise/dashboard';
  static const String franchiseProfileForm = '/franchise/profile-form';
  static const String franchiseAddMember = '/franchise/add-member';
  static const String manageMember = '/franchise/manage-member';
  static const String memberProfile = '/franchise/member-profile';
  static const String partnerPreferences = '/franchise/partner-preferences';
  static const String franchisePayment = '/franchise/payment';
  static const String franchiseApproval = '/franchise/approval';
  static const String viewAsFeed = '/feed/view-as';

  static const String shop = '/shop';
  static const String productDetail = '/shop/product-detail';
  static const String nearby = '/map/nearby';

  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorRegistration = '/vendor/registration';
  static const String vendorPayment = '/vendor/payment';
  static const String vendorApproval = '/vendor/approval';
  static const String vendorProfile = '/vendor/profile';
  static const String vendorAvailabilityCalendar =
      '/vendor/availability-calendar';
  static const String vendorCategories = '/vendor/categories';
  static const String conversations = '/conversations';
  static const String chat = '/chat';

  static const String uiCloneDemo = '/ui-clone/demo';
  static const String uiChatConversation = '/ui-clone/chat-conversation';
  static const String uiMembershipPlans = '/ui-clone/membership-plans';
  static const String uiConnections = '/ui-clone/connections';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreenUI(),
    guestHome: (_) => const HomeLandingScreenUI(),
    landing: (_) => const AuthChoiceScreenUI(),
    signInChoice: (_) => const LoginChoiceScreenUI(),
    loginChoice: (_) => const LoginChoiceScreenUI(),
    franchiseLogin: (_) => const FranchiseLoginScreen(),
    franchiseAdminLogin: (_) => const FranchiseAdminPhoneScreen(),
    franchiseAdminOtp: (context) {
      final phone =
          ModalRoute.of(context)?.settings.arguments as String? ?? '';
      return FranchiseAdminOtpScreen(phoneNumber: phone);
    },
    usernameLogin: (_) => const UsernameLoginScreenUI(),
    signUpChoice: (_) => const AuthChoiceScreenUI(),
    signupChoice: (_) => const AuthChoiceScreenUI(),
    googleLogin: (_) => const GoogleLoginScreenUI(isSignup: false),
    googleSignup: (_) => const GoogleLoginScreenUI(isSignup: true),
    mobileLogin: (_) => const MobileLoginScreenUI(),
    mobileSignup: (_) => const MobileSignupScreenUI(),
    loginOtp: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      return OTPScreenUI(phoneNumber: args ?? '', isSignup: false);
    },
    signupOtp: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      return OTPScreenUI(phoneNumber: args ?? '', isSignup: true);
    },
    roleSelection: (_) => const RoleSelectionScreenUI(),
    profileForm: (_) => const ProfileFormScreen(),
    home: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        return MainShellScreen(initialFilters: args);
      } else if (args is int) {
        return MainShellScreen(initialIndex: args);
      }
      return const MainShellScreen();
    },
    profileBasicDetails: (_) => const ProfileBasicDetailsUI(),
    profileAdditionalDetails: (_) => const ProfileAdditionalDetailsUI(),
    profileLocation: (_) => const ProfileLocationUI(),
    profileFamily: (_) => const ProfileFamilyUI(),
    profileEducation: (_) => const ProfileEducationUI(),
    profileReligious: (_) => const ProfileReligiousBackgroundScreenUI(),
    profileLifestyle: (_) => const ProfileLifestyleScreenUI(),
    profileHabits: (_) => const ProfileHabitsScreenUI(),
    profileProperty: (_) => const ProfilePropertyAssetsUI(),
    profileContact: (_) => const ProfileContactDetailsUI(),
    profileAbout: (_) => const ProfileAboutMeUI(),
    profilePhotos: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final isOnboarding = args?['isOnboarding'] ?? false;
      return ProfilePhotosUploadUI(isOnboarding: isOnboarding);
    },
    profilePartnerPreferences: (_) =>
        const ProfilePartnerPreferencesOnboardingUI(),

    editBasicDetails: (_) => const ProfileBasicDetailsUI(isEditMode: true),
    editAdditionalDetails: (_) =>
        const ProfileAdditionalDetailsUI(isEditMode: true),
    editLocation: (_) => const ProfileLocationUI(isEditMode: true),
    editFamily: (_) => const ProfileFamilyUI(isEditMode: true),
    editEducation: (_) => const ProfileEducationUI(isEditMode: true),
    editReligious: (_) =>
        const ProfileReligiousBackgroundScreenUI(isEditMode: true),
    editLifestyle: (_) => const ProfileLifestyleScreenUI(isEditMode: true),
    editHabits: (_) => const ProfileHabitsScreenUI(isEditMode: true),
    editProperty: (_) => const ProfilePropertyAssetsUI(isEditMode: true),
    editContact: (_) => const ProfileContactDetailsUI(isEditMode: true),
    editAbout: (_) => const ProfileAboutMeUI(isEditMode: true),

    feed: (_) => const MainShellScreen(initialIndex: 2),
    vendors: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final initialCategory = args?['initialCategory'] as String?;
      if (initialCategory != null) {
        return VendorBrowseScreenUI(
          showNavBar: true,
          initialCategory: initialCategory,
        );
      }
      return const MainShellScreen(initialIndex: 0);
    },
    chatTab: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final chatTabIndex = args?['chatTabIndex'] as int?;
      return MainShellScreen(initialIndex: 1, chatTabIndex: chatTabIndex);
    },
    profileTab: (_) => const MainShellScreen(initialIndex: 4),
    connections: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ConnectionsScreen(initialIndex: args?['initialTab'] ?? 0);
    },
    myConnections: (_) => const MyConnectionsScreen(),
    notifications: (_) => const NotificationsScreen(),
    editProfile: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return EditProfileScreen(initialTab: args?['initialTab']);
    },
    fullProfile: (_) => const FullProfileScreen(),
    photoManager: (_) => const PhotoManagerScreenUI(),
    userProfile: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('[AppRoutes] userProfile route handler called');
      debugPrint('[AppRoutes] args type: ${args.runtimeType}');
      debugPrint('[AppRoutes] args value: $args');

      if (args is String) {
        debugPrint('[AppRoutes] ✅ String argument detected');
        debugPrint('[AppRoutes] username: $args');
        debugPrint('═══════════════════════════════════════════════════════');
        return UserProfileViewUI(username: args);
      } else if (args is FeedUser) {
        debugPrint('[AppRoutes] ✅ FeedUser argument detected');
        debugPrint('[AppRoutes] username: ${args.username}');
        debugPrint('═══════════════════════════════════════════════════════');
        return UserProfileViewUI(username: args.username);
      } else if (args is Map<String, dynamic>) {
        final username = args['username'] as String?;
        debugPrint('[AppRoutes] ✅ Map argument detected');
        debugPrint('[AppRoutes] username: $username');
        debugPrint('═══════════════════════════════════════════════════════');
        if (username != null) {
          return UserProfileViewUI(username: username);
        }
      }
      debugPrint('[AppRoutes] ❌ ERROR: Invalid arguments');
      debugPrint('═══════════════════════════════════════════════════════');
      throw ArgumentError('Username required for userProfile route');
    },
    userProfileView: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        return UserProfileViewUI(username: args);
      } else if (args is Map<String, dynamic>) {
        final username = args['username'] as String?;
        if (username != null) {
          return UserProfileViewUI(username: username);
        }
      }
      throw ArgumentError('Username required for userProfileView route');
    },
    profileViewers: (_) => const ProfileViewersScreen(),

    franchiseDashboard: (_) => const FranchiseDashboard(),
    franchiseProfileForm: (_) => const FranchiseRegistrationScreen(),
    franchiseAddMember: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return ChangeNotifierProvider(
        create: (_) {
          final provider = FranchiseFormProvider();
          if (args is User) {
            provider.prepopulateFromUser(args);
          }
          return provider;
        },
        child: args is User
            ? AddMemberScreen(editUser: args)
            : const AddMemberScreen(),
      );
    },
    manageMember: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is User) {
        return ManageMemberScreen(member: args);
      }
      throw ArgumentError('User object required for manageMember route');
    },
    memberProfile: (_) => const MemberProfileScreen(),
    partnerPreferences: (_) => const PartnerPreferencesScreen(),

    franchisePayment: (_) => const FranchisePaymentScreen(),
    franchiseApproval: (_) => const FranchiseApprovalScreen(),
    viewAsFeed: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final viewAs = args?['viewAs'] as String?;
      final viewAsName = args?['viewAsName'] as String?;
      if (viewAs != null) {
        return FeedScreenUI(
          viewAsUserId: viewAs,
          viewAsUserName: viewAsName,
          showNavBar: false,
        );
      }
      throw ArgumentError('viewAs argument required');
    },

    vendorDashboard: (context) {
      final apiService = context.read<ApiService>();
      return ChangeNotifierProvider(
        create: (_) => VendorProvider(apiService),
        child: const VendorDashboard(),
      );
    },
    vendorRegistration: (_) => const VendorListingBasicDetailsScreenUI(),
    vendorPayment: (_) => const VendorPaymentScreen(),
    vendorApproval: (_) => const VendorApprovalScreen(),
    vendorProfile: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        return VendorProfileScreen(username: args);
      } else if (args is Map<String, dynamic>) {
        final username = args['username'] as String?;
        if (username != null) {
          return VendorProfileScreen(username: username);
        }
      }
      throw ArgumentError('Username required for vendorProfile route');
    },
    vendorAvailabilityCalendar: (_) => const VendorAvailabilityCalendarScreen(),
    vendorCategories: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final categories = args['categories'] as List<Map<String, String>>;
        final selectedCategory = args['selectedCategory'] as String;
        return VendorCategoriesScreenUI(
          categories: categories,
          selectedCategory: selectedCategory,
        );
      }
      throw ArgumentError(
        'Categories and selectedCategory required for vendorCategories route',
      );
    },

    conversations: (context) {
      return const ConversationsScreen();
    },
    chat: (context) {
      final conversation =
          ModalRoute.of(context)?.settings.arguments as Conversation?;
      if (conversation == null) {
        throw ArgumentError('Conversation argument required');
      }
      return ChatScreenNew(conversation: conversation);
    },

    shop: (context) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF7F9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF2F55).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Color(0xFFEF2F55),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Coming Soon!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'re working on something exciting — a curated wedding shopping experience just for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '✨ Bridal Wear • Jewellery • Decor • Gifts',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFEF2F55).withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF2F55),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    },
    productDetail: (context) {
      final product = ModalRoute.of(context)?.settings.arguments as Product?;
      if (product != null) {
        return ProductDetailScreenUI(product: product);
      }
      throw ArgumentError('Product argument required for productDetail route');
    },

    uiCloneDemo: (_) => const UiCloneHomeScreen(),
    uiChatConversation: (_) => const ChatConversationScreenUI(),
    uiMembershipPlans: (_) => const MembershipPlansScreenUI(),
    uiConnections: (_) => const ConnectionsScreenUI(),
    userPartnerPreferences: (_) => const PartnerPreferencesEditUI(),
    '/ui-clone/filters': (_) => const FeedFiltersScreenUI(),
    nearby: (_) => const MapScreen(),
  };
}
