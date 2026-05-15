import 'package:flutter/material.dart';

import '../screens/splash_screen_ui.dart';
import '../screens/auth_choice_screen_ui.dart';
import '../screens/login_choice_screen_ui.dart';
import '../screens/mobile_login_screen_ui.dart';
import '../screens/google_login_screen_ui.dart';
import '../screens/otp_screen_ui.dart';
import '../screens/login_screen_ui.dart';
import '../screens/role_selection_screen_ui.dart';
import '../screens/profile_basic_details_ui.dart';
import '../screens/profile_location_ui.dart';
import '../screens/profile_education_ui.dart';
import '../screens/profile_family_ui.dart';
import '../screens/profile_additional_details_ui.dart';
import '../screens/profile_religious_background_ui.dart';
import '../screens/profile_lifestyle_ui.dart';
import '../screens/profile_habits_ui.dart';
import '../screens/profile_property_assets_ui.dart';
import '../screens/profile_contact_details_ui.dart';
import '../screens/profile_about_me_ui.dart';
import '../screens/profile_photos_upload_ui.dart';
import '../screens/feed_screen_ui.dart';
import '../screens/explore_screen_ui.dart';
import '../screens/connections_screen_ui.dart';
import '../screens/chat_list_screen_ui.dart';
import '../screens/chat_conversation_screen_ui.dart';
import '../screens/profile_screen_ui.dart';
import '../screens/profile_view_screen_ui.dart';
import '../screens/settings_screen_ui.dart';
import '../screens/photo_manager_screen_ui.dart';
import '../screens/membership_plans_screen_ui.dart';
import '../screens/vendor_browse_screen_ui.dart';
import '../screens/vendor_detail_screen_ui.dart';
import '../screens/vendor_listing_basic_details_ui.dart';
import '../screens/vendor_listing_working_details_ui.dart';
import '../screens/vendor_listing_social_links_ui.dart';
import '../screens/vendor_listing_bank_details_ui.dart';
import '../screens/vendor_services_management_ui.dart';
import '../screens/franchise_dashboard_ui.dart';
import '../screens/franchise_listing_form_ui.dart';
import '../screens/components_demo_screen_ui.dart';
import '../../shared/screens/coming_soon_screen.dart';

class ScreenInfo {
  final String title;
  final String route;
  final String category;
  final String description;

  const ScreenInfo({
    required this.title,
    required this.route,
    required this.category,
    required this.description,
  });
}

class UiCloneRoutes {
  UiCloneRoutes._();

  static const String home = '/ui-clone';
  static const String splash = '/ui-clone/splash';
  static const String authChoice = '/ui-clone/auth-choice';
  static const String loginChoice = '/ui-clone/login-choice';
  static const String mobileLogin = '/ui-clone/mobile-login';
  static const String googleLogin = '/ui-clone/google-login';
  static const String otp = '/ui-clone/otp';
  static const String login = '/ui-clone/login';
  static const String roleSelection = '/ui-clone/role-selection';
  static const String profileBasicDetails = '/ui-clone/profile-basic-details';
  static const String profileLocation = '/ui-clone/profile-location';
  static const String profileEducation = '/ui-clone/profile-education';
  static const String profileFamily = '/ui-clone/profile-family';
  static const String profileAdditionalDetails =
      '/ui-clone/profile-additional-details';
  static const String profileReligiousBackground =
      '/ui-clone/profile-religious-background';
  static const String profileLifestyle = '/ui-clone/profile-lifestyle';
  static const String profileHabits = '/ui-clone/profile-habits';
  static const String profilePropertyAssets =
      '/ui-clone/profile-property-assets';
  static const String profileContactDetails =
      '/ui-clone/profile-contact-details';
  static const String profileAboutMe = '/ui-clone/profile-about-me';
  static const String profilePhotosUpload = '/ui-clone/profile-photos-upload';
  static const String feed = '/ui-clone/feed';
  static const String explore = '/ui-clone/explore';
  static const String connections = '/ui-clone/connections';
  static const String chatList = '/ui-clone/chat-list';
  static const String chatConversation = '/ui-clone/chat-conversation';
  static const String profile = '/ui-clone/profile';
  static const String profileView = '/ui-clone/profile-view';
  static const String settings = '/ui-clone/settings';
  static const String photoManager = '/ui-clone/photo-manager';
  static const String membershipPlans = '/ui-clone/membership-plans';
  static const String vendorBrowse = '/ui-clone/vendor-browse';
  static const String vendorDetail = '/ui-clone/vendor-detail';
  static const String vendorListingBasicDetails =
      '/ui-clone/vendor-listing-basic-details';
  static const String vendorListingWorkingDetails =
      '/ui-clone/vendor-listing-working-details';
  static const String vendorListingSocialLinks =
      '/ui-clone/vendor-listing-social-links';
  static const String vendorListingBankDetails =
      '/ui-clone/vendor-listing-bank-details';
  static const String vendorServicesManagement =
      '/ui-clone/vendor-services-management';
  static const String franchiseDashboard = '/ui-clone/franchise-dashboard';
  static const String franchiseListingForm = '/ui-clone/franchise-listing-form';
  static const String componentsDemo = '/ui-clone/components-demo';
  static const String comingSoonShopping = '/coming-soon-shopping';

  static final List<ScreenInfo> allScreens = [
    const ScreenInfo(
      title: 'Splash Screen',
      route: splash,
      category: 'Authentication',
      description: 'Initial app loading screen with branding',
    ),
    const ScreenInfo(
      title: 'Auth Choice Screen',
      route: authChoice,
      category: 'Authentication',
      description: 'Choose between Login and Sign Up',
    ),
    const ScreenInfo(
      title: 'Login Choice Screen',
      route: loginChoice,
      category: 'Authentication',
      description: 'Main login screen with OTP and Google login options',
    ),
    const ScreenInfo(
      title: 'Mobile Login Screen',
      route: mobileLogin,
      category: 'Authentication',
      description: 'Enter mobile number for OTP verification',
    ),
    const ScreenInfo(
      title: 'Google Login Screen',
      route: googleLogin,
      category: 'Authentication',
      description: 'Google authentication flow',
    ),
    const ScreenInfo(
      title: 'OTP Screen',
      route: otp,
      category: 'Authentication',
      description: 'Enter 6-digit OTP code sent via SMS',
    ),
    const ScreenInfo(
      title: 'Role Selection Screen',
      route: roleSelection,
      category: 'Authentication',
      description:
          'Choose user role (Matrimonial, Vendors, Franchise, Shopping)',
    ),
    const ScreenInfo(
      title: 'Login Screen',
      route: login,
      category: 'Authentication',
      description: 'Generic login screen (consolidated login variant)',
    ),

    const ScreenInfo(
      title: 'Profile Basic Details',
      route: profileBasicDetails,
      category: 'Profile Creation',
      description: 'Collect basic user information (name, DOB, gender)',
    ),
    const ScreenInfo(
      title: 'Profile Additional Details',
      route: profileAdditionalDetails,
      category: 'Profile Creation',
      description:
          'Collect height, marital status, mother tongue, disability, blood group',
    ),
    const ScreenInfo(
      title: 'Profile Education',
      route: profileEducation,
      category: 'Profile Creation',
      description: 'Collect education and employment details',
    ),
    const ScreenInfo(
      title: 'Profile Religious Background',
      route: profileReligiousBackground,
      category: 'Profile Creation',
      description: 'Collect religion and caste information',
    ),
    const ScreenInfo(
      title: 'Profile Lifestyle',
      route: profileLifestyle,
      category: 'Profile Creation',
      description: 'Collect appearance and living status',
    ),
    const ScreenInfo(
      title: 'Profile Habits',
      route: profileHabits,
      category: 'Profile Creation',
      description: 'Collect eating habits, smoking, drinking preferences',
    ),
    const ScreenInfo(
      title: 'Profile Property & Assets',
      route: profilePropertyAssets,
      category: 'Profile Creation',
      description: 'Collect property and asset information',
    ),
    const ScreenInfo(
      title: 'Profile Family',
      route: profileFamily,
      category: 'Profile Creation',
      description: 'Collect family background information',
    ),
    const ScreenInfo(
      title: 'Profile Contact Details',
      route: profileContactDetails,
      category: 'Profile Creation',
      description: 'Collect contact information (phone, email)',
    ),
    const ScreenInfo(
      title: 'Profile About Me',
      route: profileAboutMe,
      category: 'Profile Creation',
      description: 'Write bio/description',
    ),
    const ScreenInfo(
      title: 'Profile Photos Upload',
      route: profilePhotosUpload,
      category: 'Profile Creation',
      description: 'Upload profile and gallery photos',
    ),
    const ScreenInfo(
      title: 'Profile Location',
      route: profileLocation,
      category: 'Profile Creation',
      description: 'Collect location and address details',
    ),

    const ScreenInfo(
      title: 'Feed Screen',
      route: feed,
      category: 'Main Features',
      description: 'Browse matches based on partner preferences',
    ),
    const ScreenInfo(
      title: 'Explore Screen',
      route: explore,
      category: 'Main Features',
      description: 'Explore and discover new matches',
    ),
    const ScreenInfo(
      title: 'Connections Screen',
      route: connections,
      category: 'Main Features',
      description: 'Manage connections and matches',
    ),
    const ScreenInfo(
      title: 'Chat List Screen',
      route: chatList,
      category: 'Main Features',
      description: 'View all conversations',
    ),
    const ScreenInfo(
      title: 'Chat Conversation Screen',
      route: chatConversation,
      category: 'Main Features',
      description: 'One-on-one messaging',
    ),
    const ScreenInfo(
      title: 'Profile View Screen',
      route: profileView,
      category: 'Main Features',
      description: 'View detailed profile of a match',
    ),
    const ScreenInfo(
      title: 'Profile Screen',
      route: profile,
      category: 'Main Features',
      description: 'Main profile viewing and editing screen',
    ),
    const ScreenInfo(
      title: 'Settings Screen',
      route: settings,
      category: 'Main Features',
      description: 'App settings and profile management',
    ),
    const ScreenInfo(
      title: 'Photo Manager Screen',
      route: photoManager,
      category: 'Main Features',
      description: 'Manage profile photos',
    ),

    const ScreenInfo(
      title: 'Vendor Browse Screen',
      route: vendorBrowse,
      category: 'Vendor/Franchise',
      description: 'Browse and search vendors',
    ),
    const ScreenInfo(
      title: 'Vendor Detail Screen',
      route: vendorDetail,
      category: 'Vendor/Franchise',
      description: 'View vendor profile and services',
    ),
    const ScreenInfo(
      title: 'Vendor Listing - Basic Details',
      route: vendorListingBasicDetails,
      category: 'Vendor/Franchise',
      description: 'Vendor registration - basic information',
    ),
    const ScreenInfo(
      title: 'Vendor Listing - Bank Details',
      route: vendorListingBankDetails,
      category: 'Vendor/Franchise',
      description: 'Vendor registration - banking information',
    ),
    const ScreenInfo(
      title: 'Vendor Listing - Social Links',
      route: vendorListingSocialLinks,
      category: 'Vendor/Franchise',
      description: 'Vendor registration - social media and photos',
    ),
    const ScreenInfo(
      title: 'Vendor Listing - Working Details',
      route: vendorListingWorkingDetails,
      category: 'Vendor/Franchise',
      description: 'Vendor registration - working hours and description',
    ),
    const ScreenInfo(
      title: 'Vendor Services Management',
      route: vendorServicesManagement,
      category: 'Vendor/Franchise',
      description: 'Manage vendor services and offerings',
    ),
    const ScreenInfo(
      title: 'Franchise Listing Form',
      route: franchiseListingForm,
      category: 'Vendor/Franchise',
      description: 'Franchise registration - comprehensive form',
    ),
    const ScreenInfo(
      title: 'Franchise Dashboard',
      route: franchiseDashboard,
      category: 'Vendor/Franchise',
      description: 'Dashboard for franchise management',
    ),
    const ScreenInfo(
      title: 'Membership Plans Screen',
      route: membershipPlans,
      category: 'Vendor/Franchise',
      description: 'View and select membership plans',
    ),

    const ScreenInfo(
      title: 'Components Demo Screen',
      route: componentsDemo,
      category: 'Components',
      description: 'Demo and showcase screen for UI components',
    ),
  ];

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreenUI(),
      authChoice: (context) => const AuthChoiceScreenUI(),
      loginChoice: (context) => const LoginChoiceScreenUI(),
      mobileLogin: (context) => const MobileLoginScreenUI(),
      googleLogin: (context) => const GoogleLoginScreenUI(),
      otp: (context) => const OTPScreenUI(phoneNumber: '+919876543210'),
      login: (context) => const LoginScreenUI(),
      roleSelection: (context) => const RoleSelectionScreenUI(),
      profileBasicDetails: (context) => const ProfileBasicDetailsUI(),
      profileLocation: (context) => const ProfileLocationUI(),
      profileEducation: (context) => const ProfileEducationUI(),
      profileFamily: (context) => const ProfileFamilyUI(),
      profileAdditionalDetails: (context) => const ProfileAdditionalDetailsUI(),
      profileReligiousBackground: (context) =>
          const ProfileReligiousBackgroundScreenUI(),
      profileLifestyle: (context) => const ProfileLifestyleScreenUI(),
      profileHabits: (context) => const ProfileHabitsScreenUI(),
      profilePropertyAssets: (context) => const ProfilePropertyAssetsUI(),
      profileContactDetails: (context) => const ProfileContactDetailsUI(),
      profileAboutMe: (context) => const ProfileAboutMeUI(),
      profilePhotosUpload: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final isOnboarding = args?['isOnboarding'] ?? false;
        return ProfilePhotosUploadUI(isOnboarding: isOnboarding);
      },
      feed: (context) => const FeedScreenUI(),
      explore: (context) => const ExploreScreenUI(),
      connections: (context) => const ConnectionsScreenUI(),
      chatList: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final initialTab = args?['initialTab'] as int?;
        return ChatListScreenUI(initialTab: initialTab);
      },
      chatConversation: (context) => const ChatConversationScreenUI(),
      profile: (context) => const ProfileScreenUI(),
      profileView: (context) => const ProfileViewScreenUI(),
      settings: (context) => const SettingsScreenUI(),
      photoManager: (context) => const PhotoManagerScreenUI(),
      membershipPlans: (context) => const MembershipPlansScreenUI(),
      vendorBrowse: (context) => const VendorBrowseScreenUI(),
      vendorDetail: (context) => const VendorDetailScreenUI(),
      vendorListingBasicDetails: (context) =>
          const VendorListingBasicDetailsScreenUI(),
      vendorListingWorkingDetails: (context) =>
          const VendorListingWorkingDetailsScreenUI(),
      vendorListingSocialLinks: (context) =>
          const VendorListingSocialLinksScreenUI(),
      vendorListingBankDetails: (context) =>
          const VendorListingBankDetailsScreenUI(),
      vendorServicesManagement: (context) =>
          const VendorServicesManagementScreenUI(),
      franchiseDashboard: (context) => const FranchiseDashboardScreenUI(),
      franchiseListingForm: (context) => const FranchiseListingFormScreenUI(),
      componentsDemo: (context) => const ComponentsDemoScreenUI(),
      comingSoonShopping: (context) =>
          const ComingSoonScreen(title: 'Shopping', navBarIndex: 3),
    };
  }
}
