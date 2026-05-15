import 'package:flutter/material.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_button_styles.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';

import '../../core/routes/app_routes.dart';

class UsernameLoginScreenUI extends StatefulWidget {
  const UsernameLoginScreenUI({super.key});

  @override
  State<UsernameLoginScreenUI> createState() => _UsernameLoginScreenUIState();
}

class _UsernameLoginScreenUIState extends State<UsernameLoginScreenUI> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('enter_username_password_error'),
        type: WzToastType.error,
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithPassword(username, password);

    if (!mounted) return;

    if (success) {
      final user = auth.user;
      if (user != null) {
        auth.routeUser(user);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.feed);
      }
    } else {
      WzToast.show(
        context,
        message:
            auth.error ??
            AppLocalizations.of(context)!.translate('login_failed'),
        type: WzToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.black,
                      ),
                      const SizedBox(height: 40),

                      Center(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('welcome_back'),
                          style: WzTextStyles.heading2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('login_with_credentials'),
                          style: WzTextStyles.body2.copyWith(
                            color: WzColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('username_label'),
                        style: WzTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _usernameController,
                          decoration: WzButtonStyles.inputDecorationAuth(
                            hintText: AppLocalizations.of(
                              context,
                            )!.translate('username_hint'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('password_label'),
                        style: WzTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: WzButtonStyles.inputDecorationAuth(
                            hintText: AppLocalizations.of(
                              context,
                            )!.translate('password_hint'),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: WzColors.muted,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          style: WzButtonStyles.primaryButtonAuth(),
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.login,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
