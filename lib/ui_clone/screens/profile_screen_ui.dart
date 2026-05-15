import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import '../../core/theme/wz_spacing.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/wz_bottom_nav_bar.dart';
import 'partner_preferences_edit_ui.dart';

class ProfileScreenUI extends StatelessWidget {
  final bool showNavBar;

  const ProfileScreenUI({super.key, this.showNavBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: WzColors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                offset: Offset(0, 0),
              ),
            ],
          ),
          padding: const EdgeInsets.all(WzSpacing.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.settings,
                style: WzTextStyles.heading3.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: WzColors.black,
                ),
              ),

              const SizedBox(height: WzSpacing.space24),

              _buildProfileSection(),

              const SizedBox(height: WzSpacing.space24),

              _buildUpgradeMembershipSection(context),

              const SizedBox(height: WzSpacing.space24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.edit_outlined,
                        label: AppLocalizations.of(
                          context,
                        )!.translate('edit_profile'),
                        onTap: () {},
                      ),
                      const SizedBox(height: 13),
                      _buildMenuItem(
                        icon: Icons.contact_phone_outlined,
                        label: AppLocalizations.of(
                          context,
                        )!.translate('phonebook'),
                        onTap: () {},
                      ),
                      const SizedBox(height: 13),
                      _buildMenuItem(
                        icon: Icons.favorite_border,
                        label: AppLocalizations.of(
                          context,
                        )!.translate('partner_preferences'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PartnerPreferencesEditUI(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 13),
                      _buildMenuItem(
                        icon: Icons.security_outlined,
                        label: AppLocalizations.of(
                          context,
                        )!.translate('safety_and_security'),
                        onTap: () {},
                      ),
                      const SizedBox(height: 13),
                      _buildMenuItem(
                        icon: Icons.auto_awesome_outlined,
                        label: AppLocalizations.of(
                          context,
                        )!.translate('astrology'),
                        onTap: () {},
                      ),
                      const SizedBox(height: 13),
                      _buildMenuItem(
                        icon: Icons.headset_mic_outlined,
                        label: AppLocalizations.of(
                          context,
                        )!.translate('help_and_support'),
                        onTap: () {},
                      ),
                      const SizedBox(height: 13),
                      _buildMenuItem(
                        icon: Icons.touch_app_outlined,
                        label: AppLocalizations.of(
                          context,
                        )!.translate('get_the_app'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: showNavBar
          ? const WzBottomNavBar(currentIndex: 4)
          : null,
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        final name = '${user.firstName} ${user.lastName}'.trim();
        final location = '${user.city ?? ''}, ${user.country ?? ''}'.trim();
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WzColors.surface,
                border: Border.all(color: WzColors.border, width: 2),
              ),
              child: ClipOval(
                child:
                    user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.profilePhoto!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            initial,
                            style: WzTextStyles.heading3.copyWith(
                              color: WzColors.primary,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initial,
                          style: WzTextStyles.heading3.copyWith(
                            color: WzColors.primary,
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(width: WzSpacing.space16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty
                        ? name
                        : AppLocalizations.of(
                            context,
                          )!.translate('user_default'),
                    style: WzTextStyles.heading4.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: WzColors.black,
                    ),
                  ),
                  if (location.replaceFirst(',', '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      location.startsWith(',')
                          ? location.substring(1).trim()
                          : location,
                      style: WzTextStyles.caption.copyWith(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: WzColors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpgradeMembershipSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 238,
          decoration: BoxDecoration(
            color: WzColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(
            AppLocalizations.of(context)!.upgradeMembership,
            textAlign: TextAlign.center,
            style: WzTextStyles.body1.copyWith(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: WzColors.white,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: 238,
          child: Text(
            AppLocalizations.of(context)!.flatOffer,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w300,
              color: WzColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            Icon(icon, size: 16, color: WzColors.black),

            const SizedBox(width: 7),

            Expanded(
              child: Text(
                label,
                style: WzTextStyles.body1.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  color: WzColors.black,
                  fontSize: 16,
                ),
              ),
            ),

            const Icon(Icons.chevron_right, size: 24, color: WzColors.black),
          ],
        ),
      ),
    );
  }
}
