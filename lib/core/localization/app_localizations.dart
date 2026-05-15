import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'lib/core/localization/translations/${locale.languageCode}.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      debugPrint('Error loading translations for ${locale.languageCode}: $e');
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  String get appName => translate('app_name');
  String get settings => translate('settings');
  String get editProfile => translate('edit_profile');
  String get phonebook => translate('phonebook');
  String get partnerPreferences => translate('partner_preferences');
  String get safetyAndSecurity => translate('safety_and_security');
  String get astrology => translate('astrology');
  String get helpAndSupport => translate('help_and_support');
  String get clearCache => translate('clear_cache');
  String get logout => translate('logout');
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get upgradeMembership => translate('upgrade_membership');
  String get flatOffer => translate('flat_offer');
  String get locationUnavailable => translate('location_unavailable');
  String get guestUser => translate('guest_user');
  String get english => translate('english');
  String get hindi => translate('hindi');
  String get punjabi => translate('punjabi');
  String get clearCacheTitle => translate('clear_cache_title');
  String get clearCacheMessage => translate('clear_cache_message');
  String get cancel => translate('cancel');
  String get clear => translate('clear');
  String get cacheCleared => translate('cache_cleared');
  String get cacheClearedSuccess => translate('cache_cleared_success');
  String get failedToClearCache => translate('failed_to_clear_cache');
  String get logoutTitle => translate('logout_title');
  String get logoutMessage => translate('logout_message');
  String get areYouSure => translate('are_you_sure');

  String get home => translate('home');
  String get community => translate('community');
  String get welcome => translate('welcome');
  String get personalInfo => translate('personal_info');
  String get location => translate('location');
  String get phone => translate('phone');
  String get memberSince => translate('member_since');
  String get locationNotSet => translate('location_not_set');
  String get notSpecified => translate('not_specified');
  String get chooseLanguage => translate('choose_language');
  String get contactInformation => translate('contact_information');
  String get city => translate('city');
  String get state => translate('state');
  String get about => translate('about');
  String get totalMembers => translate('total_members');
  String get admin => translate('admin');
  String get comingSoon => translate('coming_soon');
  String get messagingFeature => translate('messaging_feature');
  String get notifications => translate('notifications');
  String get noNotificationsYet => translate('no_notifications_yet');
  String get title => translate('title');
  String get description => translate('description');
  String get selectDate => translate('select_date');
  String get required => translate('required');
  String get invalidNumber => translate('invalid_number');
  String get create => translate('create');
  String get creating => translate('creating');
  String get optional => translate('optional');
  String get selectImageSource => translate('select_image_source');
  String get camera => translate('camera');
  String get gallery => translate('gallery');
  String get submit => translate('submit');
  String get error => translate('error');
  String get goodMorning => translate('good_morning');
  String get goodAfternoon => translate('good_afternoon');
  String get goodEvening => translate('good_evening');
  String get welcomeBack => translate('welcome_back');
  String get seeAll => translate('see_all');
  String get retry => translate('retry');
  String get quickAccess => translate('quick_access');
  String get podcasts => translate('podcasts');
  String get refresh => translate('refresh');
  String get allServices => translate('all_services');
  String get podcastsDesc => translate('podcasts_desc');
  String get relatedContent => translate('related_content');
  String get learnMore => translate('learn_more');
  String get frequentlyAskedQuestions =>
      translate('frequently_asked_questions');
  String get call => translate('call');
  String get applyNow => translate('apply_now');
  String get noPodcastsAvailable => translate('no_podcasts_available');
  String get checkBackLater => translate('check_back_later');
  String get popularPodcasts => translate('popular_podcasts');
  String get newReleases => translate('new_releases');
  String get details => translate('details');
  String get genericError => translate('generic_error');
  String get networkError => translate('network_error');
  String get timeoutError => translate('timeout_error');
  String get unknownError => translate('unknown_error');
  String get permissionDenied => translate('permission_denied');
  String get serviceUnavailable => translate('service_unavailable');
  String get ok => translate('ok');
  String get success => translate('success');
  String get warning => translate('warning');
  String get info => translate('info');
  String get somethingWentWrong => translate('something_went_wrong');
  String get invalidDataFormat => translate('invalid_data_format');
  String get userNotFound => translate('user_not_found');
  String get wrongPassword => translate('wrong_password');
  String get emailAlreadyInUse => translate('email_already_in_use');
  String get weakPassword => translate('weak_password');
  String get invalidEmail => translate('invalid_email');
  String get userDisabled => translate('user_disabled');
  String get tooManyRequests => translate('too_many_requests');
  String get operationNotAllowed => translate('operation_not_allowed');
  String get noInternetConnection => translate('no_internet_connection');
  String get nowPlaying => translate('now_playing');
  String get newMemberJoined => translate('new_member_joined');
  String get createNew => translate('create_new');
  String get noDataAvailable => translate('no_data_available');
  String get loading => translate('loading');
  String get unknownUser => translate('unknown_user');
  String get tryAgain => translate('try_again');
  String get verify => translate('verify');
  String get updating => translate('updating');
  String get saveChanges => translate('save_changes');
  String get generate => translate('generate');
  String get clearSelection => translate('clear_selection');
  String get confirmDelete => translate('confirm_delete');
  String get deleteAll => translate('delete_all');
  String get goToHome => translate('go_to_home');
  String get members => translate('members');
  String get close => translate('close');
  String get removeMember => translate('remove_member');
  String get noResultsFound => translate('no_results_found');
  String get share => translate('share');

  String shareProfileMessage(String name) {
    return translate('share_profile_message').replaceAll('{name}', name);
  }

  String shareProfileSubject(String name) {
    return translate('share_profile_subject').replaceAll('{name}', name);
  }

  String get nameRequired => translate('name_required');
  String get companyNameRequired => translate('company_name_required');
  String get aadharNumberRequired => translate('aadhar_number_required');
  String get emailIdRequired => translate('email_id_required');
  String get addressHint => translate('address_hint');
  String get productType => translate('product_type');
  String get typeService => translate('type_service');
  String get typeProduct => translate('type_product');
  String get typeBoth => translate('type_both');
  String get fillAllRequiredFields => translate('fill_all_required_fields');
  String get verificationSimulated => translate('verification_simulated');
  String get accountSavings => translate('account_savings');
  String get accountCurrent => translate('account_current');
  String get accountSalary => translate('account_salary');
  String get paymentTerms => translate('payment_terms');
  String get workDescriptionHint => translate('work_description_hint');
  String get businessPhotos => translate('business_photos');
  String get chooseFile => translate('choose_file');
  String get noFileChosen => translate('no_file_chosen');
  String get addPhotosHint => translate('add_photos_hint');
  String get vendorRegistrationSuccess =>
      translate('vendor_registration_success');
  String get submissionFailed => translate('submission_failed');
  String get priceRange => translate('price_range');
  String get mobileNo => translate('mobile_no');
  String get countryKey => translate('country');

  String get localAddress => translate('local_address');
  String get selectStateHint => translate('select_state_hint');
  String get selectServices => translate('select_services');
  String get mobileNumberHint => translate('mobile_number_hint');

  String get vendorListing => translate('vendor_listing');
  String get bankDetails => translate('bank_details');
  String get accountHolderName => translate('account_holder_name');
  String get accountNumber => translate('account_number');
  String get bankName => translate('bank_name');
  String get ifscCode => translate('ifsc_code');
  String get accountType => translate('account_type');
  String get upiId => translate('upi_id');
  String get linkedMobileNumber => translate('linked_mobile_number');
  String get gstin => translate('gstin');
  String get next => translate('next');
  String get workingDetails => translate('working_details');
  String get workingHours => translate('working_hours');
  String get socialLinks => translate('social_links');
  String get instagramLink => translate('instagram_link');
  String get youtubeLink => translate('youtube_link');
  String get facebookLink => translate('facebook_link');
  String get twitterLink => translate('twitter_link');

  String get login => translate('login');
  String get myServices => translate('my_services');
  String get manageServicesDesc => translate('manage_services_desc');
  String get activeServices => translate('active_services');
  String get addNewService => translate('add_new_service');
  String get editService => translate('edit_service');
  String get deleteService => translate('delete_service');

  String get navVendors => translate('nav_vendors');
  String get navChats => translate('nav_chats');
  String get navHome => translate('nav_home');
  String get navShopping => translate('nav_shopping');
  String get navProfile => translate('nav_profile');

  String get loginTaglinePart1 => translate('login_tagline_part1');
  String get loginTaglinePart2 => translate('login_tagline_part2');
  String get loginTaglinePart3 => translate('login_tagline_part3');
  String get continueWithOtp => translate('continue_with_otp');
  String get continueWithGoogle => translate('continue_with_google');
  String get loginWithUsernamePassword =>
      translate('login_with_username_password');
  String get termsAgreementPart1 => translate('terms_agreement_part1');
  String get termsAndConditions => translate('terms_and_conditions');
  String get and => translate('and');
  String get privacyPolicy => translate('privacy_policy');
  String get termsAgreementPart2 => translate('terms_agreement_part2');
  String get ncprDisclaimer => translate('terms_agreement_part2');

  String get proMembershipViewPhoto => translate('pro_membership_view_photo');
  String get upgradeToView => translate('upgrade_to_view');
  String get goldBadge => translate('gold_badge');
  String get profileManagedBy => translate('profile_managed_by');
  String get membershipPlans => translate('membership_plans');
  String get yetToBeImplemented => translate('yet_to_be_implemented');
  String get activeToday => translate('active_today');
  String get filterNew => translate('filter_new');
  String get filterNearby => translate('filter_nearby');
  String get filterFilters => translate('filter_filters');
  String get asPer => translate('as_per');
  String get myMatches => translate('my_matches');

  String get photoManagerTitle => translate('photo_manager_title');
  String get photosCountLabel => translate('photos_count_label');
  String get addAtLeastOnePhoto => translate('add_at_least_one_photo');
  String get addMorePhotosHint => translate('add_more_photos_hint');
  String get addBtn => translate('add_btn');
  String get noPhotosTitle => translate('no_photos_title');
  String get noPhotosDesc => translate('no_photos_desc');
  String get addPhotosBtn => translate('add_photos_btn');
  String get profileBadge => translate('profile_badge');
  String get failedToLoad => translate('failed_to_load');
  String get photoGuidelinesTitle => translate('photo_guidelines_title');
  String get guidelineClearRecent => translate('guideline_clear_recent');
  String get guidelineFaceVisible => translate('guideline_face_visible');
  String get guidelineNoGroup => translate('guideline_no_group');
  String get guidelineMaxPhotos => translate('guideline_max_photos');
  String get gotIt => translate('got_it');
  String get errorIdentifyPhoto => translate('error_identify_photo');
  String get photoDeletedSuccess => translate('photo_deleted_success');
  String get photoDeleteFailed => translate('photo_delete_failed');
  String get maxPhotosWarning => translate('max_photos_warning');
  String get photosAddedLimit => translate('photos_added_limit');
  String get errorPickingPhotos => translate('error_picking_photos');
  String get profilePhotoUpdatedSuccess =>
      translate('profile_photo_updated_success');
  String get profilePhotoUpdateFailed =>
      translate('profile_photo_update_failed');

  String get productDetailsTitle => translate('product_details_title');
  String get shareComingSoon => translate('share_coming_soon');
  String get soldBy => translate('sold_by');
  String get vendorId => translate('vendor_id');
  String get addedToCartMsg => translate('added_to_cart_msg');
  String get viewCart => translate('view_cart');
  String get cartComingSoon => translate('cart_coming_soon');
  String get addToCart => translate('add_to_cart');

  String get createProfile => translate('create_profile');
  String get additionalDetailsTitle => translate('additional_details_title');
  String get heightLabel => translate('height_label');
  String get selectHeightHint => translate('select_height_hint');
  String get maritalUnmarried => translate('marital_unmarried');
  String get maritalAnnulled => translate('marital_annulled');
  String get disabilityLabel => translate('disability_label');
  String get selectDisabilityHint => translate('select_disability_hint');
  String get disabilityNone => translate('disability_none');
  String get disabilityPhysical => translate('disability_physical');
  String get disabilityMental => translate('disability_mental');
  String get bloodGroupLabel => translate('blood_group_label');
  String get selectBloodGroupHint => translate('select_blood_group_hint');
  String get selectMaritalStatusError =>
      translate('select_marital_status_error');

  String get maritalStatusLabel => translate('marital_status_label');
  String get maritalAwaitingDivorce => translate('marital_awaiting_divorce');
  String get maritalWidow => translate('marital_widow');
  String get maritalDivorced => translate('marital_divorced');

  String get motherTongueLabel => translate('mother_tongue_label');
  String get selectMotherTongueHint => translate('select_mother_tongue_hint');

  String get landAreaLabel => translate('land_area_label');
  String get landTypesLabel => translate('land_types_label');
  String get selectLandTypesHint => translate('select_land_types_hint');
  String get landAgricultural => translate('land_agricultural');
  String get landCommercial => translate('land_commercial');
  String get landResidential => translate('land_residential');
  String get landPlot => translate('land_plot');
  String get landOrchard => translate('land_orchard');
  String get houseTypesLabel => translate('house_types_label');
  String get selectHouseTypesHint => translate('select_house_types_hint');
  String get houseOwn => translate('house_own');
  String get houseRented => translate('house_rented');
  String get houseVilla => translate('house_villa');
  String get houseBungalow => translate('house_bungalow');
  String get propertyAssetsTitle => translate('property_assets_title');
  String get landAreaHint => translate('land_area_hint');
  String get landNone => translate('land_none');
  String get houseApartment => translate('house_apartment');

  String get other => translate('other');
  String get houseFarmhouse => translate('house_farmhouse');
  String get selectLandHouseError => translate('select_land_house_error');

  String get religiousBackground => translate('religious_background');
  String get religionLabel => translate('religion_label');
  String get communityCasteLabel => translate('community_caste_label');
  String get save => translate('save');

  String get selectReligionCommunityError =>
      translate('select_religion_community_error');
  String get profileUpdatedSuccess => translate('profile_updated_success');
  String get profileUpdateFailed => translate('profile_update_failed');

  String get religionHindu => translate('religion_hindu');
  String get religionChristian => translate('religion_christian');
  String get religionMuslim => translate('religion_muslim');
  String get religionJain => translate('religion_jain');
  String get religionBuddhist => translate('religion_buddhist');
  String get religionSikh => translate('religion_sikh');
  String get religionJewish => translate('religion_jewish');
  String get religionOther => translate('religion_other');

  String get communityGeneral => translate('community_general');
  String get communityObc => translate('community_obc');
  String get communitySt => translate('community_st');
  String get communitySc => translate('community_sc');
  String get communityEws => translate('community_ews');
  String get communityOther => translate('community_other');

  String get oneStop => translate('one_stop');
  String get wedding => translate('wedding');
  String get solution => translate('solution');
  String get signUp => translate('sign_up');
  String get agreeToTerms => translate('agree_to_terms');
  String get terms => translate('terms');
  String get privacy => translate('privacy');

  String get aboutMeTab => translate('about_me_tab');
  String get partnerPreferencesTab => translate('partner_preferences_tab');

  String get basicDetailsTitle => translate('basic_details_title');
  String get aboutMeTitle => translate('about_me_title');
  String get locationDetailsTitle => translate('location_details_title');
  String get religiousCulturalTitle => translate('religious_cultural_title');
  String get educationCareerTitle => translate('education_career_title');
  String get educationTitle => translate('education_title');
  String get careerTitle => translate('career_title');
  String get familyTitle => translate('family_title');
  String get astroTitle => translate('astro_title');
  String get lifestyleTitle => translate('lifestyle_title');
  String get assetsTitle => translate('assets_title');

  String get partnerBasicTitle => translate('partner_basic_title');
  String get partnerEducationTitle => translate('partner_education_title');
  String get partnerReligionTitle => translate('partner_religion_title');
  String get partnerLifestyleTitle => translate('partner_lifestyle_title');

  String get noBio => translate('no_bio');
  String get fatherStatusNotSpecified =>
      translate('father_status_not_specified');
  String get motherStatusNotSpecified =>
      translate('mother_status_not_specified');
  String get dietLabel => translate('diet_label');
  String get smokingLabel => translate('smoking_label');
  String get drinkingLabel => translate('drinking_label');
  String get minLabel => translate('min_label');
  String get lpaLabel => translate('lpa_label');
  String get toLabel => translate('to_label');
  String get yearsLabel => translate('years_label');
  String get na => translate('na');
  String get addPhotos => translate('add_photos');
  String get brothers => translate('brothers');
  String get sisters => translate('sisters');
  String get sqFt => translate('sq_ft');
  String get notLoggedIn => translate('not_logged_in');
  String get reviews => translate('reviews');
  String get nameLabel => translate('name_label');
  String get phoneLabel => translate('phone_label');
  String get dateLabel => translate('date_label');
  String get chat => translate('chat');
  String get startConversation => translate('start_conversation');
  String get saving => translate('saving');
  String get completeProfileMessage => translate('complete_profile_message');
  String get manglikLabel => translate('manglik_label');
  String get manglikYes => translate('manglik_yes');
  String get manglikNo => translate('manglik_no');
  String get manglikAnshik => translate('manglik_anshik');
  String get manglikDontKnow => translate('manglik_dont_know');
  String get subCommunityLabel => translate('sub_community_label');
  String get enterSubCommunityHint => translate('enter_sub_community_hint');
  String get pobLabel => translate('pob_label');
  String get enterPobHint => translate('enter_pob_hint');
  String get pickImageError => translate('pick_image_error');
  String get failedCreateProfile => translate('failed_create_profile');
  String get uploadError => translate('upload_error');
  String get usernameLabel => translate('username_label');
  String get aadharNumberLabel => translate('aadhar_number_label');
  String get aadharLabel => translate('aadhar_label');
  String get brothersLabel => translate('brothers_label');
  String get sistersLabel => translate('sisters_label');
  String get collegeNameLabel => translate('college_name_label');
  String get enterCollegeNameHint => translate('enter_college_name_hint');
  String get eduDetailsLabel => translate('edu_details_label');
  String get enterEduDetailsHint => translate('enter_edu_details_hint');
  String get selectOption => translate('select_option');
  String get clearPreferencesTitle => translate('clear_preferences_title');
  String get clearPreferencesConfirm => translate('clear_preferences_confirm');
  String get clearPreferencesBtn => translate('clear_preferences_btn');
  String get preferencesClearedMsg => translate('preferences_cleared_msg');
  String get preferencesClearFailedMsg =>
      translate('preferences_clear_failed_msg');
  String get aadhaarLabel => translate('aadhaar_label');
  String get noBioAdded => translate('no_bio_added');
  String get kundliAstro => translate('kundli_astro');
  String get lifestyleInterests => translate('lifestyle_interests');
  String get education => translate('education');
  String get career => translate('career');
  String get family => translate('family');
  String get selectUnit => translate('select_unit');
  String get aadhaarHint => translate('aadhaar_hint');
  String get dobHint => translate('dob_hint');
  String get maxPhotosAllowed => translate('max_photos_allowed');
  String get deletePhotoTitle => translate('delete_photo_title');
  String get deletePhotoConfirm => translate('delete_photo_confirm');
  String get deleteButton => translate('delete_button');
  String get errorDeletingPhoto => translate('error_deleting_photo');
  String get addMore => translate('add_more');
  String get optionalDetailsHint => translate('optional_details_hint');
  String get failedBlockUser => translate('failed_block_user');
  String get failedReportUser => translate('failed_report_user');
  String get getTheApp => translate('get_the_app');
  String get userDefault => translate('user_default');
  String get noVendorsFound => translate('no_vendors_found');
  String get tryAdjustingSearch => translate('try_adjusting_search');
  String get noVendorsAvailable => translate('no_vendors_available');
  String get failedClearFilters => translate('failed_clear_filters');
  String get unableProcessRequest => translate('unable_process_request');
  String get failedSendConnection => translate('failed_send_connection');
  String get unableProcessRequests => translate('unable_process_requests');
  String get failedSendRequests => translate('failed_send_requests');
  String get unableProcessCancellations =>
      translate('unable_process_cancellations');
  String get failedCancelRequests => translate('failed_cancel_requests');
  String get allRequestsSentSuccess => translate('all_requests_sent_success');
  String get allRequestsCancelledSuccess =>
      translate('all_requests_cancelled_success');
  String get networkErrorCheckConnection =>
      translate('network_error_check_connection');
  String get filesSelected => translate('files_selected');
  String get showingAllProfiles => translate('showing_all_profiles');
  String get showAllProfiles => translate('show_all_profiles');
  String get editPartnerPreferences => translate('edit_partner_preferences');
  String get connectionRequestSent => translate('connection_request_sent');
  String get requestAlreadyPending => translate('request_already_pending');
  String get startChattingVendors => translate('start_chatting_vendors');
  String get browseVendors => translate('browse_vendors');
  String get cancelRequest => translate('cancel_request');
  String get preferencesUpdatedSuccessfully =>
      translate('preferences_updated_successfully');
  String get failedUpdatePreferences => translate('failed_update_preferences');
  String get advancedFilters => translate('advanced_filters');
  String get open => translate('open');
  String get preferencesUpdatedFromFilters =>
      translate('preferences_updated_from_filters');
  String get nA => translate('n_a');
  String get yrs => translate('yrs');
  String get profilePhotoUpdated => translate('profile_photo_updated');
  String get failedUpdateProfilePhoto =>
      translate('failed_update_profile_photo');
  String get unableStartChat => translate('unable_start_chat');
  String get userDataNotLoaded => translate('user_data_not_loaded');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'pa'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
