import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../features/vendor/providers/vendor_registration_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/wz_toast.dart';

class VendorListingSocialLinksScreenUI extends StatefulWidget {
  const VendorListingSocialLinksScreenUI({super.key});

  @override
  State<VendorListingSocialLinksScreenUI> createState() =>
      _VendorListingSocialLinksScreenUIState();
}

class _VendorListingSocialLinksScreenUIState
    extends State<VendorListingSocialLinksScreenUI> {
  late TextEditingController _instagramController;
  late TextEditingController _youtubeController;
  late TextEditingController _facebookController;
  late TextEditingController _twitterController;
  String? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VendorRegistrationProvider>();
    _instagramController = TextEditingController(text: provider.instagramLink);
    _youtubeController = TextEditingController(text: provider.youtubeLink);
    _facebookController = TextEditingController(text: provider.facebookLink);
    _twitterController = TextEditingController(text: provider.twitterLink);
    _selectedPhoto = provider.profilePhoto;

    _instagramController.addListener(() {
      provider.updateSocialLinks(instagram: _instagramController.text);
    });
    _youtubeController.addListener(() {
      provider.updateSocialLinks(youtube: _youtubeController.text);
    });
    _facebookController.addListener(() {
      provider.updateSocialLinks(facebook: _facebookController.text);
    });
    _twitterController.addListener(() {
      provider.updateSocialLinks(twitter: _twitterController.text);
    });
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowCompression: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedPhoto = file.path;
          });

          final provider = context.read<VendorRegistrationProvider>();
          provider.updateSocialLinks(photo: _selectedPhoto);
        }
      }
    } catch (e) {
      WzToast.show(
        context,
        message: 'Error picking photo: $e',
        type: WzToastType.error,
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
    });
    final provider = context.read<VendorRegistrationProvider>();
    provider.updateSocialLinks(photo: null);
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final provider = context.read<VendorRegistrationProvider>();

    debugPrint('');
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ [VENDOR_REG] 📝 SUBMITTING VENDOR REGISTRATION             ║',
    );
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    final success = await provider.submitRegistration();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    if (success) {
      debugPrint('[VENDOR_REG] ✅ Registration successful!');
      debugPrint('[VENDOR_REG] 🔄 Refreshing user data...');

      final authProvider = context.read<AuthProvider>();
      await authProvider.refreshUser();

      debugPrint(
        '[VENDOR_REG] 📊 Current user vendor status: ${authProvider.currentUser?.vendorStatus}',
      );

      if (!mounted) return;

      WzToast.show(
        context,
        message: l10n.vendorRegistrationSuccess,
        type: WzToastType.success,
      );

      debugPrint('[VENDOR_REG] 🚀 Navigating to Franchise Payment Screen...');
      debugPrint('[VENDOR_REG] 📍 Target Route: /franchise/payment');

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/franchise/payment',
        (route) => false,
      );

      debugPrint('[VENDOR_REG] ✅ Navigation complete');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');
    } else {
      debugPrint('[VENDOR_REG] ❌ Registration failed');
      debugPrint('[VENDOR_REG] 🔴 Error: ${provider.error}');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');

      WzToast.show(
        context,
        message: '${l10n.submissionFailed}${provider.error ?? "Unknown error"}',
        type: WzToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Consumer<VendorRegistrationProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vendor Listing',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Social Links',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          hint: 'Instagram Link',
                          controller: _instagramController,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          hint: 'Youtube Link',
                          controller: _youtubeController,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          hint: 'Facebook Link',
                          controller: _facebookController,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          hint: 'Twitter Link',
                          controller: _twitterController,
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Profile Photo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _selectedPhoto != null
                                    ? null
                                    : _pickPhoto,
                                child: Container(
                                  height: 36,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedPhoto != null
                                        ? WzColors.primary.withValues(
                                            alpha: 0.5,
                                          )
                                        : WzColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: WzColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Choose File',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _selectedPhoto == null
                                      ? AppLocalizations.of(
                                          context,
                                        )!.noFileChosen
                                      : AppLocalizations.of(context)!
                                            .translate('files_selected')
                                            .replaceAll('{count}', '1'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: _selectedPhoto == null
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '*Add 1 profile photo (${_selectedPhoto != null ? 1 : 0}/1)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),

                        if (_selectedPhoto != null) ...[
                          const SizedBox(height: 16),
                          _buildSelectedPhoto(),
                        ],
                        const SizedBox(height: 120),

                        Center(
                          child: GestureDetector(
                            onTap: provider.isLoading ? null : _onSubmit,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                              ),
                              decoration: BoxDecoration(
                                color: provider.isLoading
                                    ? WzColors.primary.withValues(alpha: 0.6)
                                    : WzColors.primary,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: WzColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: provider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.url,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPhoto() {
    if (_selectedPhoto == null) return const SizedBox.shrink();

    final file = File(_selectedPhoto!);
    final fileName = _selectedPhoto!.split('/').last.split('\\').last;
    final fileExists = file.existsSync();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (fileExists)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  file,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(
                        Icons.image,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.image,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                fileName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),

            GestureDetector(
              onTap: _removePhoto,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
