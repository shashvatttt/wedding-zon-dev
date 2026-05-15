import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import '../../core/theme/wz_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/wz_navigation.dart';
import '../widgets/wz_buttons.dart';

import 'package:weddingzon/core/localization/app_localizations.dart';

class LoginScreenUI extends StatelessWidget {
  const LoginScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '📍 [SCREEN] ========== LOGIN SCREEN ========== [ROUTE: ${AppRoutes.landing}]',
    );
    return Scaffold(
      backgroundColor: WzColors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/login_bg.png', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.4, 0.6],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Stack(
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Image.asset(
                      'assets/login_bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  Container(color: WzColors.primarySoftBg.withOpacity(0.2)),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const WzStatusBar(),

                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Container(
                      width: 177,
                      height: 80,
                      decoration: BoxDecoration(
                        color: WzColors.primarySoftBg.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'WEDDINGZON',
                          style: WzTextStyles.heading3.copyWith(
                            color: WzColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    WzSpacing.space24,
                    0,
                    WzSpacing.space24,
                    WzSpacing.space24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: WzTextStyles.heading1.copyWith(
                            color: WzColors.text,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.translate('login_tagline_part1'),
                              style: const TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.translate('login_tagline_part2'),
                              style: TextStyle(color: WzColors.primary),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.translate('login_tagline_part3'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: WzSpacing.space32),

                      WzPrimaryButton(
                        text: AppLocalizations.of(
                          context,
                        )!.translate('continue_with_otp'),
                        onPressed: () {},
                        width: double.infinity,
                        icon: const Icon(
                          Icons.phone,
                          size: 20,
                          color: WzColors.white,
                        ),
                      ),

                      const SizedBox(height: WzSpacing.space16),

                      WzSecondaryButton(
                        text: AppLocalizations.of(
                          context,
                        )!.translate('continue_with_google'),
                        onPressed: () {},
                        width: double.infinity,
                        icon: Icon(
                          Icons.g_mobiledata,
                          size: 24,
                          color: WzColors.primary,
                        ),
                      ),

                      const SizedBox(height: WzSpacing.space16),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.usernameLogin);
                        },
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('login_with_username_password'),
                          style: WzTextStyles.body2.copyWith(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: WzSpacing.space32),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: WzSpacing.space16,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: WzTextStyles.small.copyWith(
                              color: WzColors.muted,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(
                                  context,
                                )!.translate('terms_agreement_part1'),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(
                                  context,
                                )!.translate('terms_and_conditions'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(
                                  context,
                                )!.translate('and'),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(
                                  context,
                                )!.translate('privacy_policy'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(
                                  context,
                                )!.translate('terms_agreement_part2'),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
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
