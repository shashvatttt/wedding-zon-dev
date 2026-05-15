import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/language_selector_button.dart';

class AuthChoiceScreenUI extends StatelessWidget {
  const AuthChoiceScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/login_bg.png', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.5, 0.75],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Image.asset(
                        'assets/login_bg.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 400,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Image.asset(
                          'assets/logo_weddingzon.png',
                          width: 177,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const Positioned(
                        right: 16,
                        top: 16,
                        child: LanguageSelectorButton(),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    WzSpacing.space24,
                    0,
                    WzSpacing.space24,
                    WzSpacing.space32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: WzTextStyles.heading1.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 37 / 32,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(text: l10n.oneStop),
                            TextSpan(
                              text: l10n.wedding,
                              style: TextStyle(color: WzColors.primary),
                            ),
                            TextSpan(text: l10n.solution),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.loginChoice);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WzColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.login,
                            style: WzTextStyles.button.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.googleSignup,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            l10n.signUp,
                            style: WzTextStyles.button.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: WzTextStyles.small.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            height: 1.4,
                            color: Colors.white70,
                          ),
                          children: [
                            TextSpan(text: l10n.agreeToTerms),
                            TextSpan(
                              text: l10n.terms,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(text: l10n.and),
                            TextSpan(
                              text: l10n.privacy,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(text: l10n.termsAgreementPart2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
