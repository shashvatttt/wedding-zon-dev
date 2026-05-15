import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';

class ExploreScreenUI extends StatelessWidget {
  const ExploreScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: -75,
            top: -3,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/ui_clone/images/backgrounds/background_pattern_1.jpg',
                width: 512,
                height: 958,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),

                const SizedBox(height: 16),

                _buildFilterChips(context),

                const SizedBox(height: 39),

                Expanded(child: _buildProfileCardsList(context)),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myMatches,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    height: 22 / 24,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${l10n.asPer} ',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        height: 22 / 14,
                      ),
                    ),
                    Text(
                      l10n.partnerPreferences,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF2F55),
                        height: 22 / 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/ui_clone/icons/ic_edit.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF111827),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 39),

                SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.notifications,
                    size: 24,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 32),

                SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.settings,
                    size: 24,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.filterNew,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.filterNearby,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_list, size: 24, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.filterFilters,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCardsList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        _buildProfileCard(
          context,
          name: 'Shawty Mishra',
          age: 25,
          height: '4ft 11in',
          location: 'New Delhi',
          community: 'Bania-Rauniyar',
          occupation: 'Education Professional',
          income: 'Rs. 8-10 lakh p.a.',
          education: 'MBA/PGDM, LLB',
          maritalStatus: 'Never Married',
          activityStatus: l10n.activeToday,
          photoCount: 7,
          managedBy: '${l10n.profileManagedBy} Parents',
          hasGoldBadge: false,
          imagePath:
              'assets/ui_clone/images/profile_photos/profile_photo_placeholder.png',
        ),

        const SizedBox(height: 70),

        _buildProfileCard(
          context,
          name: 'Shawty Mishra',
          age: 25,
          height: '4ft 11in',
          location: 'New Delhi',
          community: 'Bania-Rouniyar',
          occupation: 'Education Professional',
          income: 'Rs. 8-10 lakh p.a.',
          education: 'MBA/PGDM, LLB',
          maritalStatus: 'Never Married',
          activityStatus: l10n.activeToday,
          photoCount: 7,
          managedBy: '${l10n.profileManagedBy} Parents',
          hasGoldBadge: false,
          imagePath:
              'assets/ui_clone/images/profile_photos/profile_photo_placeholder.png',
        ),

        const SizedBox(height: 70),

        _buildProfileCard(
          context,
          name: 'Cutie Kumari',
          age: 25,
          height: '4ft 11in',
          location: 'New Delhi',
          community: 'Bania-Rauniyar',
          occupation: 'Education Professional',
          income: 'Rs. 8-10 lakh p.a.',
          education: 'MBA/PGDM, LLB',
          maritalStatus: 'Never Married',
          activityStatus: l10n.activeToday,
          photoCount: 7,
          managedBy: '${l10n.profileManagedBy} Parents',
          hasGoldBadge: true,
          isBlurred: true,
          imagePath:
              'assets/ui_clone/images/profile_photos/profile_photo_placeholder.png',
        ),

        const SizedBox(height: 70),

        _buildProfileCard(
          context,
          name: 'Cutie Kumari',
          age: 25,
          height: '4ft 11in',
          location: 'New Delhi',
          community: 'Bania-Rauniyar',
          occupation: 'Education Professional',
          income: 'Rs. 8-10 lakh p.a.',
          education: 'MBA/PGDM, LLB',
          maritalStatus: 'Never Married',
          activityStatus: l10n.activeToday,
          photoCount: 7,
          managedBy: '${l10n.profileManagedBy} Parents',
          hasGoldBadge: true,
          imagePath:
              'assets/ui_clone/images/profile_photos/profile_photo_placeholder.png',
        ),

        const SizedBox(height: 70),

        _buildProfileCard(
          context,
          name: 'Pookie Singh',
          age: 25,
          height: '4ft 11in',
          location: 'New Delhi',
          community: 'Bania-Rauniyar',
          occupation: 'Education Professional',
          income: 'Rs. 8-10 lakh p.a.',
          education: 'MBA/PGDM, LLB',
          maritalStatus: 'Never Married',
          activityStatus: l10n.activeToday,
          photoCount: 7,
          managedBy: '${l10n.profileManagedBy} Parents',
          hasGoldBadge: false,
          imagePath:
              'assets/ui_clone/images/profile_photos/profile_photo_placeholder.png',
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String name,
    required int age,
    required String height,
    required String location,
    required String community,
    required String occupation,
    required String income,
    required String education,
    required String maritalStatus,
    required String activityStatus,
    required int photoCount,
    required String managedBy,
    required bool hasGoldBadge,
    bool isBlurred = false,
    required String imagePath,
  }) {
    return Container(
      width: 348,
      height: 578,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasGoldBadge && !isBlurred
            ? Border.all(color: const Color(0xFFEF2F55), width: 4)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 3.7,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            if (isBlurred)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14.2, sigmaY: 14.2),
                    child: Container(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 170,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),

            if (!isBlurred)
              Positioned(
                top: 16,
                right: 30,
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.11),
                    border: Border.all(color: const Color(0xFFFBC3CF)),
                    borderRadius: BorderRadius.circular(38),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        photoCount.toString(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (hasGoldBadge && !isBlurred)
              Positioned(
                top: 316,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF2F55), Color(0xFF891B31)],
                    ),
                    border: Border.all(color: const Color(0xFFFBC3CF)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.goldBadge,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            Positioned(
              top: hasGoldBadge && !isBlurred ? 320 : 329,
              left: hasGoldBadge && !isBlurred ? 90 : 24,
              child: Text(
                activityStatus,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFEF2F55),
                ),
              ),
            ),

            Positioned(
              left: hasGoldBadge && !isBlurred ? 20 : 24,
              right: 20,
              bottom: 135,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name, $age',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        '$height   $location   $community',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.work_outline,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$occupation   $income',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        education,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.favorite_border,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        maritalStatus,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 443,
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    managedBy,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            if (isBlurred)
              Positioned(
                top: 206,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.proMembershipViewPhoto,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.upgradeToView,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Positioned(
              left: hasGoldBadge && !isBlurred ? 42 : 46,
              bottom: hasGoldBadge && !isBlurred ? 482 : 486,
              child: Row(
                children: [
                  _buildActionButton(icon: Icons.close, size: 32),

                  const SizedBox(width: 32),

                  _buildActionButton(icon: Icons.favorite, size: 35),

                  const SizedBox(width: 32),

                  _buildActionButton(icon: Icons.chat_bubble, size: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required double size}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0x47757575),
        border: Border.all(color: const Color(0xFFFBC3CF)),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, size: size, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFEF2F55),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18.3,
            spreadRadius: 9,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.store, AppLocalizations.of(context)!.navVendors),
          _buildNavItem(
            Icons.chat_bubble,
            AppLocalizations.of(context)!.navChats,
          ),
          _buildNavItem(Icons.favorite, AppLocalizations.of(context)!.navHome),
          _buildNavItem(
            Icons.shopping_bag,
            AppLocalizations.of(context)!.navShopping,
          ),
          _buildNavItem(Icons.person, AppLocalizations.of(context)!.navProfile),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: Colors.white),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
