import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/profile_helpers.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../ui_clone/widgets/wz_bottom_nav_bar.dart';
import '../../../shared/widgets/image_viewer.dart';
import '../../../shared/widgets/wz_loading.dart';
import '../../../shared/widgets/wz_toast.dart';
import '../providers/profile_provider.dart';
import '../models/partner_preference.dart';
import '../../../core/models/photo_model.dart';
import '../../../../core/localization/app_localizations.dart';

class FullProfileScreen extends StatefulWidget {
  final bool showNavBar;

  const FullProfileScreen({super.key, this.showNavBar = true});

  @override
  State<FullProfileScreen> createState() => _FullProfileScreenState();
}

class _FullProfileScreenState extends State<FullProfileScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  int _previousTab = 0;
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;

  late AnimationController _underlineAnimationController;
  late Animation<double> _underlineAnimation;
  final List<GlobalKey> _tabKeys = List.generate(2, (index) => GlobalKey());
  int _fromTabIndex = 0;
  int _toTabIndex = 0;

  @override
  void initState() {
    super.initState();
    debugPrint(
      '📍 [SCREEN] ========== FULL PROFILE SCREEN ========== [ROUTE: ${AppRoutes.fullProfile}]',
    );

    _underlineAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _underlineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _underlineAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadPreferences();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _underlineAnimationController.dispose();
    super.dispose();
  }

  void _animateToTab(int index) {
    if (index == _selectedTab) return;

    _fromTabIndex = _selectedTab;
    _toTabIndex = index;

    setState(() {
      _previousTab = _selectedTab;
      _selectedTab = index;
    });

    _underlineAnimationController.reset();
    _underlineAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      backgroundColor: Colors.white,
      bottomNavigationBar: widget.showNavBar
          ? const WzBottomNavBar(currentIndex: 4)
          : null,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: WzLoading());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await authProvider.refreshUser();
              if (mounted) {
                context.read<ProfileProvider>().loadPreferences();
              }
            },
            color: const Color(0xFFEF2F55),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(user),

                  SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        _buildTabSection(),

                        const SizedBox(height: 24),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                final reverseAnimation = Tween<double>(
                                  begin: 1.0,
                                  end: 0.0,
                                ).animate(animation);

                                final isGoingForward =
                                    _selectedTab > _previousTab;

                                final isIncoming =
                                    child.key == ValueKey(_selectedTab);

                                if (isIncoming) {
                                  final slideInOffset = isGoingForward
                                      ? const Offset(1.0, 0)
                                      : const Offset(-1.0, 0);

                                  return SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: slideInOffset,
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                    child: child,
                                  );
                                } else {
                                  final slideOutOffset = isGoingForward
                                      ? const Offset(-1.0, 0)
                                      : const Offset(1.0, 0);

                                  return SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: Offset.zero,
                                          end: slideOutOffset,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: reverseAnimation,
                                            curve: Curves.easeInCubic,
                                          ),
                                        ),
                                    child: child,
                                  );
                                }
                              },
                          child: _selectedTab == 0
                              ? Container(
                                  key: const ValueKey(0),
                                  child: _buildAboutMeContent(user),
                                )
                              : Container(
                                  key: const ValueKey(1),
                                  child: Consumer<ProfileProvider>(
                                    builder: (context, profileProvider, _) {
                                      return _buildPartnerPreferencesContent(
                                        user,
                                        profileProvider.preferences,
                                      );
                                    },
                                  ),
                                ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    final topPadding = MediaQuery.of(context).padding.top;
    final l10n = AppLocalizations.of(context)!;

    final allPhotos = <String>[];
    if (user.profilePhoto != null && user.profilePhoto!.isNotEmpty) {
      allPhotos.add(user.profilePhoto!);
    }
    if (user.photos != null && user.photos.isNotEmpty) {
      for (var photo in user.photos) {
        if (photo.url != null && photo.url != user.profilePhoto) {
          allPhotos.add(photo.url);
        }
      }
    }

    if (allPhotos.isEmpty) {
      allPhotos.add('');
    }

    return Container(
      height: 378 + topPadding,
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => _openPhotoViewer(user, _currentPhotoIndex),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPhotoIndex = index;
                  });
                },
                itemCount: allPhotos.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<Map<String, String>>(
                    future: _getAuthHeaders(),
                    builder: (context, snapshot) {
                      final headers = snapshot.data ?? {};

                      if (allPhotos[index].isEmpty) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                        );
                      }

                      return CachedNetworkImage(
                        imageUrl: allPhotos[index],
                        httpHeaders: headers,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(child: WzLoading(size: 30)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            if (allPhotos.length > 1)
              Positioned(
                top: 60 + topPadding,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allPhotos.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPhotoIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              top: 311 + topPadding,
              left: 21,
              right: 21,
              child: Text(
                '${user.firstName ?? ''} ${user.lastName ?? ''}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            Positioned(
              top: 11 + topPadding,
              right: 13,
              child: GestureDetector(
                onTap: () => _navigateToPhotoManager(),
                child: Container(
                  width: 142,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    border: Border.all(color: const Color(0xFFFBC3CF)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      l10n.translate('add_photos'),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 11 + topPadding,
              right: 161,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile/viewers');
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    border: Border.all(color: const Color(0xFFFBC3CF)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 11 + topPadding,
              right: 199,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/ui-clone/connections');
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    border: Border.all(color: const Color(0xFFFBC3CF)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 21, top: 21),
      child: Column(
        children: [
          Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      key: _tabKeys[0],
                      onTap: () => _animateToTab(0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.aboutMeTab,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 0
                                  ? const Color(0xFFEF2F55)
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    GestureDetector(
                      key: _tabKeys[1],
                      onTap: () => _animateToTab(1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.partnerPreferencesTab,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 1
                                  ? const Color(0xFFEF2F55)
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  child: AnimatedBuilder(
                    animation: _underlineAnimationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(double.infinity, 2),
                        painter: _ProfileSlidingUnderlinePainter(
                          animationProgress:
                              _underlineAnimationController.isAnimating
                              ? _underlineAnimation.value
                              : 1.0,
                          fromTabIndex: _fromTabIndex,
                          toTabIndex: _toTabIndex,
                          tabKeys: _tabKeys,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAboutMeContent(dynamic user) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        children: [
          _buildSection(
            title: l10n.basicDetailsTitle,
            onEdit: () => _navigateToEdit('basic'),
            children: [
              if (user.firstName != null || user.lastName != null)
                _buildDetailRow(
                  Icons.person,
                  '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                  label: l10n.translate('full_name'),
                ),
              if (user.username != null)
                _buildDetailRow(
                  Icons.alternate_email,
                  user.username!,
                  label: l10n.translate('username'),
                ),
              _buildDetailRow(
                Icons.cake,
                '${_calculateAge(user.dob)} (${_formatDate(user.dob)})',
                label: l10n.translate('age_dob'),
              ),
              if (user.gender != null)
                _buildDetailRow(
                  Icons.wc,
                  user.gender!,
                  label: l10n.translate('gender'),
                ),
              if (user.height != null)
                _buildDetailRow(
                  Icons.height,
                  user.height!,
                  label: l10n.translate('height'),
                ),
              if (user.maritalStatus != null)
                _buildDetailRow(
                  Icons.favorite,
                  user.maritalStatus!,
                  label: l10n.translate('marital_status_label'),
                ),
              if (user.physicalStatus != null)
                _buildDetailRow(
                  Icons.accessibility,
                  user.physicalStatus!,
                  label: l10n.translate('physical_status'),
                ),
              if (user.appearance != null)
                _buildDetailRow(
                  Icons.face,
                  user.appearance!,
                  label: l10n.translate('appearance'),
                ),
              if (user.bloodGroup != null)
                _buildDetailRow(
                  Icons.bloodtype,
                  user.bloodGroup!,
                  label: l10n.translate('blood_group'),
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            title: l10n.aboutMeTitle,
            onEdit: () => _navigateToEdit('about'),
            children: [
              Text(
                user.aboutMe ?? l10n.noBio,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            title: l10n.translate('location_details'),
            onEdit: () => _navigateToEdit('location'),
            children: [
              if (user.city != null)
                _buildDetailRow(
                  Icons.location_city,
                  user.city!,
                  label: l10n.translate('city'),
                ),
              if (user.state != null)
                _buildDetailRow(
                  Icons.map,
                  user.state!,
                  label: l10n.translate('state'),
                ),
              if (user.country != null)
                _buildDetailRow(
                  Icons.flag,
                  user.country!,
                  label: l10n.translate('country'),
                ),
              if (user.placeOfBirth != null)
                _buildDetailRow(
                  Icons.place,
                  user.placeOfBirth!,
                  label: l10n.translate('place_of_birth'),
                ),
              if (user.livingStatus != null)
                _buildDetailRow(
                  Icons.home_work,
                  user.livingStatus!,
                  label: l10n.translate('living_status'),
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            title: l10n.translate('religious_cultural_background'),
            onEdit: () => _navigateToEdit('religious'),
            children: [
              if (user.religion != null)
                _buildDetailRow(
                  Icons.church,
                  user.religion!,
                  label: l10n.translate('religion_label'),
                ),
              if (user.community != null)
                _buildDetailRow(
                  Icons.people,
                  user.community!,
                  label: l10n.translate('community'),
                ),
              if (user.subCommunity != null)
                _buildDetailRow(
                  Icons.group,
                  user.subCommunity!,
                  label: l10n.translate('subcommunity'),
                ),
              if (user.motherTongue != null)
                _buildDetailRow(
                  Icons.language,
                  user.motherTongue!,
                  label: l10n.translate('mother_tongue_label'),
                ),
              if (user.manglikStatus != null)
                _buildDetailRow(
                  Icons.auto_awesome,
                  user.manglikStatus!,
                  label: l10n.translate('manglik_status'),
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            title: l10n.translate('education_career'),
            onEdit: () => _navigateToEdit('education'),
            children: [
              if (user.highestEducation != null)
                _buildDetailRow(
                  Icons.school,
                  user.highestEducation!,
                  label: l10n.translate('highest_education_label'),
                ),
              if (user.educationalDetails != null &&
                  user.educationalDetails!.isNotEmpty)
                _buildDetailRow(
                  Icons.description,
                  user.educationalDetails!,
                  label: l10n.translate('edu_details_label'),
                ),
              if (user.occupation != null)
                _buildDetailRow(
                  Icons.work,
                  user.occupation!,
                  label: l10n.translate('occupation_label'),
                ),
              if (user.employedIn != null && user.employedIn!.isNotEmpty)
                _buildDetailRow(
                  Icons.business,
                  user.employedIn!,
                  label: l10n.translate('employed_in'),
                ),
              if (user.workingSector != null && user.workingSector!.isNotEmpty)
                _buildDetailRow(
                  Icons.category,
                  user.workingSector!,
                  label: l10n.translate('working_sector'),
                ),
              if (user.workingLocation != null &&
                  user.workingLocation!.isNotEmpty)
                _buildDetailRow(
                  Icons.location_on,
                  user.workingLocation!,
                  label: l10n.translate('working_location'),
                ),
              if (user.personalIncome != null)
                _buildDetailRow(
                  Icons.currency_rupee,
                  '₹${user.personalIncome}',
                  label: l10n.translate('personal_income'),
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            title: l10n.familyTitle,
            onEdit: () => _navigateToEdit('family'),
            children: [
              if (user.familyType != null)
                _buildDetailRow(
                  Icons.family_restroom,
                  user.familyType!,
                  label: l10n.translate('family_type'),
                ),
              if (user.familyStatus != null)
                _buildDetailRow(
                  Icons.home,
                  user.familyStatus!,
                  label: l10n.translate('family_status'),
                ),
              if (user.familyValues != null)
                _buildDetailRow(
                  Icons.favorite,
                  user.familyValues!,
                  label: l10n.translate('family_values'),
                ),
              if (user.fatherStatus != null)
                _buildDetailRow(
                  Icons.person,
                  user.fatherStatus!,
                  label: l10n.translate('father'),
                ),
              if (user.motherStatus != null)
                _buildDetailRow(
                  Icons.person,
                  user.motherStatus!,
                  label: l10n.translate('mother'),
                ),
              _buildDetailRow(
                Icons.people,
                '${user.brothers ?? 0} ${l10n.brothers}, ${user.sisters ?? 0} ${l10n.sisters}',
                label: l10n.translate('siblings'),
              ),
              if (user.familyLocation != null &&
                  user.familyLocation!.isNotEmpty)
                _buildDetailRow(
                  Icons.location_city,
                  user.familyLocation!,
                  label: l10n.translate('family_location'),
                ),
              if (user.annualIncome != null)
                _buildDetailRow(
                  Icons.account_balance,
                  '₹${user.annualIncome}',
                  label: l10n.translate('family_income'),
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            title: l10n.lifestyleTitle,
            onEdit: () => _navigateToEdit('lifestyle'),
            children: [
              if (user.eatingHabits != null)
                _buildDetailRow(
                  Icons.restaurant,
                  user.eatingHabits!,
                  label: l10n.translate('diet'),
                ),
              if (user.drinkingHabits != null)
                _buildDetailRow(
                  Icons.local_bar,
                  user.drinkingHabits!,
                  label: l10n.translate('drinking'),
                ),
              if (user.smokingHabits != null)
                _buildDetailRow(
                  Icons.smoking_rooms,
                  user.smokingHabits!,
                  label: l10n.translate('smoking'),
                ),
              if (user.hobbies != null && user.hobbies.isNotEmpty)
                _buildDetailRow(
                  Icons.interests,
                  user.hobbies.join(', '),
                  label: l10n.translate('hobbies'),
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            title: l10n.assetsTitle,
            onEdit: () => _navigateToEdit('assets'),
            children: [
              if (user.propertyType != null && user.propertyType!.isNotEmpty)
                _buildDetailRow(
                  Icons.home,
                  user.propertyType!,
                  label: l10n.translate('property_type'),
                ),
              if (user.propertyPossessionType != null &&
                  user.propertyPossessionType!.isNotEmpty)
                _buildDetailRow(
                  Icons.key,
                  user.propertyPossessionType!,
                  label: l10n.translate('possession'),
                ),
              if (user.landArea != null && user.landArea!.isNotEmpty)
                _buildDetailRow(
                  Icons.square_foot,
                  user.landArea!,
                  label: l10n.translate('land_area'),
                ),
              if (user.landTypes != null && user.landTypes!.isNotEmpty)
                _buildDetailRow(
                  Icons.landscape,
                  user.landTypes!.join(', '),
                  label: l10n.translate('land_types'),
                ),
              if (user.houseTypes != null && user.houseTypes!.isNotEmpty)
                _buildDetailRow(
                  Icons.house,
                  user.houseTypes!.join(', '),
                  label: l10n.translate('house_types'),
                ),
              if (user.businessTypes != null && user.businessTypes!.isNotEmpty)
                _buildDetailRow(
                  Icons.business,
                  user.businessTypes!.join(', '),
                  label: l10n.translate('business_types'),
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            title: l10n.translate('contact_information'),
            onEdit: () => _navigateToEdit('contact'),
            children: [
              if (user.phone != null)
                _buildDetailRow(
                  Icons.phone,
                  user.phone!,
                  label: l10n.translate('phone'),
                ),
              if (user.email != null)
                _buildDetailRow(
                  Icons.email,
                  user.email!,
                  label: l10n.translate('email'),
                ),
              _buildDetailRow(
                Icons.person_outline,
                ProfileHelpers.getManagedByText(user.profileManagedBy),
                label: l10n.translate('profile_managed_by'),
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerPreferencesContent(
    dynamic user,
    PartnerPreference? preferences,
  ) {
    final l10n = AppLocalizations.of(context)!;
    PartnerPreference? prefs = preferences;

    if (prefs == null && user.partnerPreferences != null) {
      if (user.partnerPreferences is PartnerPreference) {
        prefs = user.partnerPreferences;
      } else if (user.partnerPreferences is Map<String, dynamic>) {
        try {
          prefs = PartnerPreference.fromJson(user.partnerPreferences!);
        } catch (e) {
          debugPrint('Error parsing partner preferences: $e');
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        children: [
          _buildSection(
            title: l10n.partnerBasicTitle,
            onEdit: () => Navigator.pushNamed(context, '/profile/preferences'),
            children: [
              _buildDetailRow(
                Icons.cake,
                _formatRange(prefs?.minAge, prefs?.maxAge, l10n.yearsLabel),
                label: l10n.translate('age_range'),
              ),
              _buildDetailRow(
                Icons.height,
                _formatHeightRange(prefs?.heightMin, prefs?.heightMax),
                label: l10n.translate('height'),
              ),
              _buildDetailRow(
                Icons.favorite,
                (prefs?.maritalStatus?.isEmpty ?? true)
                    ? l10n.translate('does_not_matter')
                    : prefs!.maritalStatus!.join(', '),
                label: l10n.translate('marital_status_label'),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: l10n.partnerEducationTitle,
            onEdit: () => Navigator.pushNamed(context, '/profile/preferences'),
            children: [
              _buildDetailRow(
                Icons.school,
                (prefs?.highestEducation?.isEmpty ?? true)
                    ? l10n.translate('does_not_matter')
                    : prefs!.highestEducation!,
                label: l10n.translate('highest_education_label'),
              ),
              _buildDetailRow(
                Icons.work,
                (prefs?.occupation?.isEmpty ?? true)
                    ? l10n.translate('does_not_matter')
                    : prefs!.occupation!,
                label: l10n.translate('occupation_label'),
              ),
              _buildDetailRow(
                Icons.attach_money,
                (prefs?.annualIncome == null || prefs!.annualIncome!.isEmpty)
                    ? l10n.translate('does_not_matter')
                    : '${l10n.minLabel} ${prefs.annualIncome} ${l10n.lpaLabel}',
                label: l10n.translate('annual_income'),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: l10n.partnerReligionTitle,
            onEdit: () => Navigator.pushNamed(context, '/profile/preferences'),
            children: [
              _buildDetailRow(
                Icons.temple_hindu,
                (prefs?.religion?.isEmpty ?? true)
                    ? l10n.translate('does_not_matter')
                    : prefs!.religion!,
                label: l10n.translate('religion_label'),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: l10n.partnerLifestyleTitle,
            onEdit: () => Navigator.pushNamed(context, '/profile/preferences'),
            children: [
              _buildDetailRow(
                Icons.restaurant,
                (prefs?.eatingHabits?.isEmpty ?? true)
                    ? l10n.translate('does_not_matter')
                    : prefs!.eatingHabits!,
                label: l10n.translate('diet'),
              ),
              _buildDetailRow(
                Icons.smoking_rooms,
                (prefs?.smokingHabits?.isEmpty ?? true)
                    ? l10n.translate('does_not_matter')
                    : prefs!.smokingHabits!,
                label: l10n.translate('smoking'),
              ),
              _buildDetailRow(
                Icons.local_bar,
                (prefs?.drinkingHabits?.isEmpty ?? true)
                    ? l10n.translate('does_not_matter')
                    : prefs!.drinkingHabits!,
                label: l10n.translate('drinking'),
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Color(0xFFEF2F55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String value, {
    String? label,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: const Color(0xFFEF2F55)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null)
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    if (label != null) const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }

  String _calculateAge(DateTime? dob) {
    final l10n = AppLocalizations.of(context)!;
    if (dob == null) return l10n.translate('na');
    try {
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return '$age${l10n.translate('years_label')}';
    } catch (e) {
      return l10n.translate('na');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final apiService = context.read<ApiService>();
      final cookieString = await apiService.getCookieString();
      if (cookieString.isNotEmpty) {
        return {'Cookie': cookieString};
      }
    } catch (e) {
      debugPrint('Error getting auth headers: $e');
    }
    return {};
  }

  void _openPhotoViewer(dynamic user, int initialIndex) async {
    if (user.photos == null || user.photos.isEmpty) {
      debugPrint('[PROFILE] No photos to view');
      return;
    }

    final unrestrictedPhotos = user.photos
        .map<Photo>((p) => p.copyWith(restricted: false, isProfile: false))
        .toList();

    debugPrint(
      '[PROFILE] Opening photo viewer with ${unrestrictedPhotos.length} photos at index $initialIndex',
    );

    final headers = await _getAuthHeaders();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          photos: unrestrictedPhotos,
          initialIndex: initialIndex < unrestrictedPhotos.length
              ? initialIndex
              : 0,
          hasAccess: true,
          canSetProfile: true,
          canDelete: true,
          currentProfileImageUrl: user.profilePhoto,
          httpHeaders: headers,
          onSetAsProfile: (index) async {
            if (index >= user.photos.length) return;
            final photo = user.photos[index];
            final photoId = photo.publicId;
            if (photoId != null) {
              final success = await _setAsProfilePhoto(photoId);
              if (success && mounted) {
                Navigator.pop(context);
              }
            } else {
              WzToast.show(
                context,
                message: AppLocalizations.of(
                  context,
                )!.translate('error_identify_photo'),
                type: WzToastType.error,
              );
            }
          },
          onDelete: (index) async {
            if (index >= user.photos.length) return;
            final photo = user.photos[index];
            final photoId = photo.publicId;
            if (photoId != null) {
              final success = await _deletePhoto(photoId);
              if (success && mounted) {
                Navigator.pop(context);
              }
            } else {
              WzToast.show(
                context,
                message: AppLocalizations.of(
                  context,
                )!.translate('error_identify_photo'),
                type: WzToastType.error,
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> _setAsProfilePhoto(String photoId) async {
    if (!mounted) return false;

    final provider = context.read<ProfileProvider>();
    final success = await provider.setProfilePhoto(photoId);

    if (!mounted) return false;

    if (success) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.refreshUser();
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.profilePhotoUpdated,
        type: WzToastType.success,
      );
      return true;
    } else {
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.failedUpdateProfilePhoto,
        type: WzToastType.error,
      );
      return false;
    }
  }

  Future<bool> _deletePhoto(String photoId) async {
    if (!mounted) return false;

    final provider = context.read<ProfileProvider>();
    final success = await provider.deletePhoto(photoId);

    if (!mounted) return false;

    if (success) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.refreshUser();
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('photo_deleted_success'),
        type: WzToastType.success,
      );
      return true;
    } else {
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.translate('photo_delete_failed'),
        type: WzToastType.error,
      );
      return false;
    }
  }

  void _navigateToPhotoManager() {
    Navigator.pushNamed(context, AppRoutes.profilePhotos);
  }

  void _navigateToEdit(String section) {
    final routeMap = {
      'basic': AppRoutes.editBasicDetails,
      'about': AppRoutes.editAbout,
      'additional': AppRoutes.editAdditionalDetails,
      'location': AppRoutes.editLocation,
      'family': AppRoutes.editFamily,
      'education': AppRoutes.editEducation,
      'career': AppRoutes.editEducation,
      'astro': AppRoutes.editReligious,
      'religious': AppRoutes.editReligious,
      'lifestyle': AppRoutes.editLifestyle,
      'habits': AppRoutes.editHabits,
      'assets': AppRoutes.editProperty,
      'property': AppRoutes.editProperty,
      'contact': AppRoutes.editContact,
    };

    final route = routeMap[section];
    if (route != null) {
      Navigator.pushNamed(context, route, arguments: {'isEditMode': true});
    }
  }

  String _formatRange(num? min, num? max, String suffix) {
    final l10n = AppLocalizations.of(context)!;
    if (min == null && max == null) return l10n.translate('does_not_matter');
    if (min != null && max != null) return '$min - $max $suffix';
    if (min != null) return '> $min $suffix';
    if (max != null) return '< $max $suffix';
    return l10n.translate('does_not_matter');
  }

  String _formatHeightRange(String? min, String? max) {
    final l10n = AppLocalizations.of(context)!;
    if (min == null && max == null) return l10n.translate('does_not_matter');
    if (min != null && max != null) return '$min - $max';
    if (min != null) return '> $min';
    if (max != null) return '< $max';
    return l10n.translate('does_not_matter');
  }
}

class _ProfileSlidingUnderlinePainter extends CustomPainter {
  final double animationProgress;
  final int fromTabIndex;
  final int toTabIndex;
  final List<GlobalKey> tabKeys;

  _ProfileSlidingUnderlinePainter({
    required this.animationProgress,
    required this.fromTabIndex,
    required this.toTabIndex,
    required this.tabKeys,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF2F55)
      ..style = PaintingStyle.fill;

    final tabPositions = <double>[];
    final tabWidths = <double>[];

    double currentX = 0;
    for (int i = 0; i < tabKeys.length; i++) {
      final key = tabKeys[i];
      final context = key.currentContext;

      double tabWidth = 120;

      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          tabWidth = renderBox.size.width;
        }
      }

      tabPositions.add(currentX);
      tabWidths.add(tabWidth);
      currentX += tabWidth + 32;
    }

    if (tabPositions.isEmpty ||
        fromTabIndex >= tabPositions.length ||
        toTabIndex >= tabPositions.length) {
      return;
    }

    final fromPosition = tabPositions[fromTabIndex];
    final toPosition = tabPositions[toTabIndex];
    final fromWidth = tabWidths[fromTabIndex];
    final toWidth = tabWidths[toTabIndex];

    final currentPosition =
        fromPosition + (toPosition - fromPosition) * animationProgress;
    final currentWidth = fromWidth + (toWidth - fromWidth) * animationProgress;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(currentPosition, 0, currentWidth, 2),
        const Radius.circular(1),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _ProfileSlidingUnderlinePainter &&
        (oldDelegate.animationProgress != animationProgress ||
            oldDelegate.fromTabIndex != fromTabIndex ||
            oldDelegate.toTabIndex != toTabIndex);
  }
}
