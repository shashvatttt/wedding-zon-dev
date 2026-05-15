import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';

class GoogleLoginScreenUI extends StatelessWidget {
  final bool isSignup;

  const GoogleLoginScreenUI({super.key, this.isSignup = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(WzSpacing.space16),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.black,
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: WzSpacing.space24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              'assets/ui_clone/icons/ic_google.svg',
                              width: 64,
                              height: 64,
                            ),
                          ),

                          const SizedBox(height: 40),

                          Text(
                            isSignup
                                ? AppLocalizations.of(
                                    context,
                                  )!.translate('join_with_google')
                                : AppLocalizations.of(
                                    context,
                                  )!.translate('sign_in_with_google'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: WzSpacing.space16,
                            ),
                            child: Text(
                              isSignup
                                  ? AppLocalizations.of(
                                      context,
                                    )!.translate('google_signup_desc')
                                  : AppLocalizations.of(
                                      context,
                                    )!.translate('google_signin_desc'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () => auth.signInWithGoogle(
                                      isSignup: isSignup,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: WzColors.primary,
                                        strokeWidth: 2.5,
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
                                          isSignup
                                              ? AppLocalizations.of(
                                                  context,
                                                )!.translate(
                                                  'signup_with_google_button',
                                                )
                                              : AppLocalizations.of(
                                                  context,
                                                )!.translate(
                                                  'continue_with_google',
                                                ),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: WzSpacing.space16,
                            ),
                            child: Text(
                              isSignup
                                  ? AppLocalizations.of(
                                      context,
                                    )!.translate('google_signup_info')
                                  : AppLocalizations.of(
                                      context,
                                    )!.translate('google_signin_desc'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[500],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
