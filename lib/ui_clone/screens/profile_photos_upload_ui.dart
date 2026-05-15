import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/profile/repositories/user_repository.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';
import '../../core/models/photo_model.dart';
import '../../shared/widgets/wz_loading.dart';

class PhotoItem {
  final File? file;
  final Photo? photo;

  PhotoItem({this.file, this.photo});

  bool get isLocal => file != null;
  bool get isServer => photo != null;
}

class ProfilePhotosUploadUI extends StatefulWidget {
  final bool isOnboarding;

  const ProfilePhotosUploadUI({super.key, this.isOnboarding = false});

  @override
  State<ProfilePhotosUploadUI> createState() => _ProfilePhotosUploadUIState();
}

class _ProfilePhotosUploadUIState extends State<ProfilePhotosUploadUI> {
  final ImagePicker _picker = ImagePicker();
  final List<PhotoItem> _selectedPhotos = [];
  bool _isSubmitting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPhotos();
  }

  Future<void> _loadExistingPhotos() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();

      await authProvider.refreshUser();
      final user = authProvider.currentUser;

      if (user != null && user.photos.isNotEmpty) {
        final existingPhotos = user.photos
            .map((p) => PhotoItem(photo: p))
            .toList();

        if (user.profilePhoto != null) {
          final profileIndex = existingPhotos.indexWhere(
            (p) => p.photo?.url == user.profilePhoto,
          );
          if (profileIndex != -1) {
            final profilePhoto = existingPhotos.removeAt(profileIndex);
            existingPhotos.insert(0, profilePhoto);
          }
        }

        setState(() {
          _selectedPhotos.addAll(existingPhotos);
        });
      }
    } catch (e) {
      debugPrint('Error loading existing photos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhotos() async {
    final appLoc = AppLocalizations.of(context);
    try {
      if (_selectedPhotos.length >= 10) {
        WzToast.show(
          context,
          message:
              appLoc?.translate('max_photos_allowed') ??
              'Maximum 10 photos allowed',
          type: WzToastType.normal,
        );
        return;
      }

      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
        limit: 10 - _selectedPhotos.length,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(
            pickedFiles.map((f) => PhotoItem(file: File(f.path))),
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (!mounted) return;
      WzToast.show(
        context,
        message:
            '${appLoc?.translate('pick_image_error') ?? 'Failed to pick image: '}$e',
        type: WzToastType.error,
      );
    }
  }

  Future<void> _removePhoto(int index) async {
    final appLoc = AppLocalizations.of(context);
    final item = _selectedPhotos[index];

    if (item.isLocal) {
      setState(() {
        _selectedPhotos.removeAt(index);
      });
    } else if (item.isServer) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            appLoc?.translate('delete_photo_title') ?? 'Delete Photo?',
          ),
          content: Text(
            appLoc?.translate('delete_photo_confirm') ??
                'Are you sure you want to delete this photo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(appLoc?.translate('cancel') ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                appLoc?.translate('delete_button') ?? 'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _deleteServerPhoto(item.photo!.publicId!, index);
      }
    }
  }

  Future<void> _deleteServerPhoto(String photoId, int index) async {
    setState(() => _isSubmitting = true);
    try {
      final userRepo = context.read<UserRepository>();
      final response = await userRepo.deletePhoto(photoId);

      if (response.success) {
        setState(() {
          _selectedPhotos.removeAt(index);
        });

        if (!mounted) return;
        await context.read<AuthProvider>().refreshUser();
        if (mounted) {
          WzToast.show(
            context,
            message:
                AppLocalizations.of(
                  context,
                )?.translate('photo_deleted_success') ??
                'Photo deleted successfully',
            type: WzToastType.success,
          );
        }
      } else {
        throw Exception('Failed to delete photo');
      }
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      if (mounted) {
        WzToast.show(
          context,
          message:
              '${AppLocalizations.of(context)?.translate('error_deleting_photo') ?? 'Error deleting photo'}: $e',
          type: WzToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _onSave() async {
    setState(() => _isSubmitting = true);
    final appLoc = AppLocalizations.of(context);

    try {
      final authProvider = context.read<AuthProvider>();

      debugPrint(
        '[PHOTO_UPLOAD] Skipping profile completion, will be done in preferences screen',
      );

      final newPhotos = _selectedPhotos
          .where((item) => item.isLocal)
          .map((item) => item.file!)
          .toList();

      if (newPhotos.isNotEmpty) {
        debugPrint('[PHOTO_UPLOAD] Uploading ${newPhotos.length} new photos');
        if (!mounted) return;
        final userRepo = context.read<UserRepository>();
        final uploadResponse = await userRepo.uploadPhotos(newPhotos);

        if (uploadResponse.success && uploadResponse.data!.isNotEmpty) {
          final currentUser = authProvider.currentUser;
          if (currentUser?.profilePhoto == null) {
            final firstPhotoId = uploadResponse.data!.first.publicId;
            if (firstPhotoId != null) {
              await userRepo.setAsProfilePhoto(firstPhotoId);
              debugPrint('[PHOTO_UPLOAD] Set first photo as profile photo');
            }
          }
        } else {
          debugPrint(
            '[PHOTO_UPLOAD] Photo upload failed: ${uploadResponse.message}',
          );
        }
      }

      debugPrint('[PHOTO_UPLOAD] Photos processed, continuing to preferences');

      if (!mounted) return;

      if (widget.isOnboarding) {
        debugPrint(
          '[PHOTO_UPLOAD] Onboarding mode: navigating to partner preferences',
        );
        Navigator.pushNamed(context, AppRoutes.profilePartnerPreferences);
      } else {
        debugPrint(
          '[PHOTO_UPLOAD] Profile editing mode: staying on current screen',
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('[PROFILE_UPLOAD_ERROR] Error in _onSave: $e');
      debugPrint('[PROFILE_UPLOAD_ERROR] StackTrace: $stackTrace');
      if (mounted) {
        WzToast.show(
          context,
          message: '${appLoc?.translate('upload_error') ?? 'Error: '}$e',
          type: WzToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: WzLoading()));
    }

    final appLoc = AppLocalizations.of(context);
    final hasProfilePhoto = _selectedPhotos.isNotEmpty;
    final galleryPhotos = _selectedPhotos.length > 1
        ? _selectedPhotos.sublist(1)
        : <PhotoItem>[];

    return Scaffold(
      backgroundColor: WzColors.white,
      appBar: AppBar(
        backgroundColor: WzColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  appLoc?.translate('photos_title') ?? 'Photos',
                  style: WzTextStyles.heading3.copyWith(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: WzColors.text,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

              const SizedBox(height: 34.0),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLoc?.translate('photos_title') ?? 'Photos',
                      style: WzTextStyles.heading4.copyWith(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: WzColors.text,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedPhotos.length} / 10 Selected',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30.0),

              Text(
                appLoc?.translate('profile_photo_label') ?? 'Profile Photo',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4E4E4E),
                ),
              ),
              const SizedBox(height: 8.0),

              GestureDetector(
                onTap: _pickPhotos,
                child: _buildPhotoUploadBox(
                  width: 180.0,
                  height: 120.0,
                  item: hasProfilePhoto ? _selectedPhotos[0] : null,
                  isProfile: true,
                  onRemove: hasProfilePhoto ? () => _removePhoto(0) : null,
                ),
              ),

              const SizedBox(height: 30.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appLoc?.translate('gallery_optional_label') ??
                        'Gallery (Optional)',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4E4E4E),
                    ),
                  ),
                  if (_selectedPhotos.length < 10)
                    TextButton.icon(
                      onPressed: _pickPhotos,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(appLoc?.translate('add_more') ?? 'Add More'),
                      style: TextButton.styleFrom(
                        foregroundColor: WzColors.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8.0),

              if (galleryPhotos.isEmpty && !hasProfilePhoto)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Add photos to complete your profile',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else if (galleryPhotos.isEmpty && hasProfilePhoto)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Add more photos to your gallery',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: galleryPhotos.length,
                  itemBuilder: (context, index) {
                    return _buildPhotoTile(galleryPhotos[index], index + 1);
                  },
                ),

              const SizedBox(height: 40.0),

              WzPrimaryButton(
                text: _isSubmitting
                    ? (appLoc?.translate('saving') ?? 'Saving...')
                    : (appLoc?.translate('save') ?? 'Save'),
                onPressed: _isSubmitting ? null : _onSave,
                width: double.infinity,
              ),

              if (_isSubmitting)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Center(child: WzLoading()),
                ),

              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUploadBox({
    required double width,
    required double height,
    PhotoItem? item,
    bool isProfile = false,
    VoidCallback? onRemove,
  }) {
    ImageProvider? imageProvider;
    if (item != null) {
      if (item.isLocal) {
        imageProvider = FileImage(item.file!);
      } else if (item.isServer) {
        imageProvider = CachedNetworkImageProvider(item.photo!.url);
      }
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: WzColors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        borderRadius: BorderRadius.circular(6.0),
        image: imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (item == null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32.0,
                  color: isProfile ? WzColors.primary : const Color(0xFF9CA3AF),
                ),
                if (isProfile) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to Select',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          if (item != null && onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(PhotoItem item, int index) {
    ImageProvider? imageProvider;
    if (item.isLocal) {
      imageProvider = FileImage(item.file!);
    } else if (item.isServer) {
      imageProvider = CachedNetworkImageProvider(item.photo!.url);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        image: imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
