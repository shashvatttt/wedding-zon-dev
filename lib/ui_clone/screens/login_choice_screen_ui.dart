import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_button_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/shared/widgets/scaffold_with_background.dart';
import '../widgets/language_selector_button.dart';

class LoginChoiceScreenUI extends StatelessWidget {
  const LoginChoiceScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: WzSpacing.space24,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
                                child: Image.asset(
                                  'assets/logo_weddingzon.png',
                                  width: 177,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            const Spacer(),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: WzTextStyles.heading1.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 37 / 32,
                                  color: WzColors.textDefault,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.loginTaglinePart1,
                                  ),
                                  TextSpan(
                                    text:
                                        '${AppLocalizations.of(context)!.loginTaglinePart2} ',
                                    style: const TextStyle(
                                      color: Color(0xFFEF2F55),
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.loginTaglinePart3,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 100),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.mobileLogin,
                                        );
                                      },
                                style: WzButtonStyles.primaryButtonAuth(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/ui_clone/icons/ic_phone.svg',
                                      width: 24,
                                      height: 24,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.continueWithOtp,
                                      style: WzTextStyles.button.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () {
                                        auth.signInWithGoogle(isSignup: false);
                                      },
                                style: WzButtonStyles.secondaryButtonAuth(),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFEF2F55),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/ui_clone/icons/ic_google.svg',
                                            width: 24,
                                            height: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.continueWithGoogle,
                                            style: WzTextStyles.button.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFFEF2F55),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.usernameLogin,
                                        );
                                      },
                                style: WzButtonStyles.secondaryButtonAuth(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 24,
                                      color: Color(0xFFEF2F55),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.loginWithUsernamePassword,
                                      style: WzTextStyles.button.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFEF2F55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 100),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: WzTextStyles.small.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  height: 14 / 10,
                                  color: WzColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.termsAgreementPart1,
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.termsAndConditions,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      color: WzColors.textDefault,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.and,
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.privacyPolicy,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      color: WzColors.textDefault,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.termsAgreementPart2,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: WzSpacing.space24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LanguageSelectorButton(
                      iconColor: Colors.black,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
