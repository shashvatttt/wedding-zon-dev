import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/wz_toast.dart';

class SettingsScreenUI extends StatelessWidget {
  const SettingsScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.settings,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildProfileSection(context, user),
                  const SizedBox(height: 25),

                  _buildUpgradeBanner(context),
                  const SizedBox(height: 25),

                  _buildMenuItems(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(BuildContext context, dynamic user) {
    return Row(
      children: [
        FutureBuilder<Map<String, String>>(
          future: _getAuthHeaders(user),
          builder: (context, snapshot) {
            final headers = snapshot.data ?? {};

            return ClipOval(
              child:
                  (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: user!.profilePhoto!,
                      httpHeaders: headers,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
            );
          },
        ),
        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.firstName != null
                    ? '${user.firstName} ${user.lastName ?? ""}'
                    : AppLocalizations.of(context)!.guestUser,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                user?.city ?? AppLocalizations.of(context)!.locationUnavailable,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Map<String, String>> _getAuthHeaders(dynamic user) async {
    try {
      return {};
    } catch (e) {
      debugPrint('Error getting auth headers: $e');
      return {};
    }
  }

  Widget _buildUpgradeBanner(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _handleUpgradeMembership(context),
          child: Container(
            width: 238,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF2F55),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              AppLocalizations.of(context)!.upgradeMembership,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.flatOffer,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildMenuItem(
          context: context,
          iconPath: 'assets/ui_clone/icons/ic_edit.svg',
          label: l10n.editProfile,
          key: 'edit_profile',
        ),
        const SizedBox(height: 13),
        _buildMenuItem(
          context: context,
          iconPath: 'assets/ui_clone/icons/ic_phone.svg',
          label: l10n.phonebook,
          key: 'phonebook',
        ),
        const SizedBox(height: 13),
        _buildMenuItem(
          context: context,
          iconPath: 'assets/ui_clone/icons/ic_settings.svg',
          label: l10n.partnerPreferences,
          key: 'partner_preferences',
        ),
        const SizedBox(height: 13),
        _buildMenuItem(
          context: context,
          iconPath: 'assets/ui_clone/icons/ic_info.svg',
          label: l10n.safetyAndSecurity,
          key: 'safety_security',
        ),
        const SizedBox(height: 13),
        _buildMenuItem(
          context: context,
          iconPath: 'assets/ui_clone/icons/ic_star.svg',
          label: l10n.astrology,
          key: 'astrology',
        ),
        const SizedBox(height: 13),

        _buildLanguageMenuItem(context),
        const SizedBox(height: 13),
        _buildMenuItem(
          context: context,
          iconPath: 'assets/ui_clone/icons/ic_info.svg',
          label: l10n.helpAndSupport,
          key: 'help_support',
        ),
        const SizedBox(height: 13),
        _buildMenuItem(
          context: context,
          iconPath: 'assets/ui_clone/icons/ic_settings.svg',
          label: l10n.clearCache,
          key: 'clear_cache',
        ),
        const SizedBox(height: 13),
        _buildLogoutButton(context),
      ],
    );
  }

  Widget _buildLanguageMenuItem(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    String languageName;
    switch (currentLocale.languageCode) {
      case 'hi':
        languageName = 'Hindi';
        break;
      case 'pa':
        languageName = 'Punjabi';
        break;
      default:
        languageName = 'English';
    }

    return GestureDetector(
      onTap: () => _handleLanguageSelection(context),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            const Icon(Icons.language, size: 16, color: Colors.black),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                l10n.language,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              languageName,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 24, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String iconPath,
    required String label,
    required String key,
  }) {
    return GestureDetector(
      onTap: () => _handleMenuItemTap(context, key),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, width: 16, height: 16),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, size: 24, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleLogout(context),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            const Icon(Icons.logout, size: 16, color: Colors.red),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.logout,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, size: 24, color: Colors.red),
          ],
        ),
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, String key) {
    switch (key) {
      case 'edit_profile':
        Navigator.pushNamed(
          context,
          AppRoutes.profileBasicDetails,
          arguments: {'isEditFlow': true},
        );
        break;
      case 'partner_preferences':
        Navigator.pushNamed(context, AppRoutes.userPartnerPreferences);
        break;
      case 'clear_cache':
        _handleClearCache(context);
        break;
      case 'phonebook':
      case 'safety_security':
      case 'astrology':
      case 'help_support':
        WzToast.show(
          context,
          message: '$key - Yet to be implemented',
          type: WzToastType.normal,
        );
        break;
      default:
        break;
    }
  }

  Future<void> _handleClearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearCacheTitle),
        content: Text(AppLocalizations.of(context)!.clearCacheMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF2F55),
            ),
            child: Text(AppLocalizations.of(context)!.clear),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await CachedNetworkImage.evictFromCache('');
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        if (context.mounted) {
          Navigator.pop(context);

          WzToast.show(
            context,
            message: 'Cache cleared successfully',
            type: WzToastType.success,
            duration: const Duration(seconds: 4),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          WzToast.show(
            context,
            message: 'Failed to clear cache',
            type: WzToastType.error,
          );
        }
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logoutTitle),
        content: Text(AppLocalizations.of(context)!.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.landing,
          (route) => false,
        );
      }
    }
  }

  void _handleUpgradeMembership(BuildContext context) {
    Navigator.pushNamed(context, '/ui-clone/membership-plans');
  }

  void _handleLanguageSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentLocale = Localizations.localeOf(context);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Language',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                context,
                'English',
                const Locale('en'),
                currentLocale,
              ),
              _buildLanguageOption(
                context,
                'Hindi',
                const Locale('hi'),
                currentLocale,
              ),
              _buildLanguageOption(
                context,
                'Punjabi',
                const Locale('pa'),
                currentLocale,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    Locale locale,
    Locale currentLocale,
  ) {
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? const Color(0xFFEF2F55) : Colors.black,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFFEF2F55))
          : null,
      onTap: () {
        Navigator.pop(context);
        WzToast.show(
          context,
          message: 'Language changed to $label',
          type: WzToastType.success,
        );
      },
    );
  }
}
