import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import '../../shared/widgets/scaffold_with_background.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/profile/providers/photo_upload_provider.dart';
import '../../features/profile/models/photo_upload_item.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/models/photo_model.dart';
import '../../shared/widgets/image_viewer.dart';
import '../../core/services/api_service.dart';
import '../../shared/widgets/wz_toast.dart';

class PhotoManagerScreenUI extends StatefulWidget {
  const PhotoManagerScreenUI({super.key});

  @override
  State<PhotoManagerScreenUI> createState() => _PhotoManagerScreenUIState();
}

class _PhotoManagerScreenUIState extends State<PhotoManagerScreenUI> {
  final ImagePicker _picker = ImagePicker();
  bool _wasUploading = false;
  late final PhotoUploadProvider _uploadProvider;
  Map<String, String> _authHeaders = {};

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _uploadProvider = context.read<PhotoUploadProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uploadProvider.clearCompleted();
      _loadAuthHeaders();
    });

    _uploadProvider.addListener(_onUploadStateChanged);
  }

  Future<void> _loadAuthHeaders() async {
    try {
      final apiService = context.read<ApiService>();
      final cookieString = await apiService.getCookieString();
      if (cookieString.isNotEmpty && mounted) {
        setState(() {
          _authHeaders = {'Cookie': cookieString};
        });
      }
    } catch (e) {
      debugPrint('Error getting auth headers: $e');
    }
  }

  @override
  void dispose() {
    _uploadProvider.removeListener(_onUploadStateChanged);
    super.dispose();
  }

  void _onUploadStateChanged() {
    final isUploadingNow = _uploadProvider.queue.any(
      (i) =>
          i.status == UploadStatus.pending ||
          i.status == UploadStatus.uploading,
    );

    if (_wasUploading && !isUploadingNow) {
      debugPrint('[PHOTO_MANAGER] Batch upload finished. Refreshing user...');
      if (mounted) {
        context.read<AuthProvider>().refreshUser().then((_) {
          _uploadProvider.clearCompleted();
        });
      }
    }

    _wasUploading = isUploadingNow;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer2<AuthProvider, PhotoUploadProvider>(
          builder: (context, authProvider, uploadProvider, child) {
            final user = authProvider.currentUser;

            if (user == null) {
              return Center(child: Text(l10n.notLoggedIn));
            }

            final serverPhotos = user.photos;
            final uploadQueue = uploadProvider.queue;

            final validQueueCount = uploadQueue
                .where((i) => i.status != UploadStatus.error)
                .length;
            final totalPhotos = serverPhotos.length + validQueueCount;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: WzColors.text,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.photoManagerTitle,
                          style: WzTextStyles.heading3,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          color: WzColors.text,
                        ),
                        onPressed: _showPhotoGuidelines,
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WzColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.photosCountLabel}: $totalPhotos / 10',
                            style: WzTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalPhotos == 0
                                ? l10n.addAtLeastOnePhoto
                                : l10n.addMorePhotosHint.replaceFirst(
                                    '{count}',
                                    '${10 - totalPhotos}',
                                  ),
                            style: WzTextStyles.body2.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (totalPhotos < 10)
                        ElevatedButton.icon(
                          onPressed: () =>
                              _pickAndUploadPhotos(10 - totalPhotos),
                          icon: const Icon(Icons.add_photo_alternate, size: 20),
                          label: Text(l10n.addBtn),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WzColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: (serverPhotos.isEmpty && uploadQueue.isEmpty)
                      ? _buildEmptyState()
                      : GridView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          children: [
                            ...serverPhotos.asMap().entries.map((entry) {
                              return _buildServerPhotoCard(entry.value);
                            }),

                            ...uploadQueue.map((item) {
                              return _buildUploadCard(item);
                            }),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: WzColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_library,
              size: 60,
              color: WzColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.noPhotosTitle, style: WzTextStyles.heading4),
          const SizedBox(height: 8),
          Text(
            l10n.noPhotosDesc,
            style: WzTextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _pickAndUploadPhotos(10),
            icon: const Icon(Icons.add_photo_alternate),
            label: Text(l10n.addPhotosBtn),
            style: ElevatedButton.styleFrom(
              backgroundColor: WzColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerPhotoCard(Photo photo) {
    final isProfilePhoto =
        photo.isProfile ||
        (context.read<AuthProvider>().currentUser?.profilePhoto == photo.url);

    return InkWell(
      onTap: () {
        _openImageViewer(photo);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: photo.url,
                httpHeaders: _authHeaders,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => _buildErrorWidget(),
              ),
            ),
            if (isProfilePhoto)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: WzColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.profileBadge,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(PhotoUploadItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(item.file, fit: BoxFit.cover),
          ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          Center(child: _buildStatusIndicator(item)),

          if (item.status == UploadStatus.error)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => _uploadProvider.retry(item.id),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: WzColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => _uploadProvider.remove(item.id),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(PhotoUploadItem item) {
    switch (item.status) {
      case UploadStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.white, size: 32);
      case UploadStatus.uploading:
        return const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        );
      case UploadStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green, size: 48);
      case UploadStatus.error:
        return const Icon(Icons.error, color: Colors.red, size: 48);
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 32),
          SizedBox(height: 8),
          Text(
            l10n.failedToLoad,
            style: TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openImageViewer(Photo photo) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final unrestrictedPhotos = user.photos
        .map((p) => p.copyWith(restricted: false, isProfile: false))
        .toList();
    final currentIndex = unrestrictedPhotos.indexWhere(
      (p) => p.url == photo.url,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          photos: unrestrictedPhotos,
          initialIndex: currentIndex >= 0 ? currentIndex : 0,
          hasAccess: true,
          canSetProfile: true,
          canDelete: true,
          currentProfileImageUrl: user.profilePhoto,
          httpHeaders: _authHeaders,
          onSetAsProfile: (index) async {
            final photo = user.photos[index];
            final photoId = photo.publicId;
            if (photoId != null) {
              final success = await _setAsProfilePhoto(photoId);
              if (success && mounted) {
                Navigator.pop(context);
              }
            } else {
              WzToast.show(
                context,
                message: l10n.errorIdentifyPhoto,
                type: WzToastType.error,
              );
            }
          },
          onDelete: (index) async {
            final photo = user.photos[index];
            final photoId = photo.publicId;
            if (photoId != null) {
              final success = await _deletePhoto(photoId, index);
              if (success && mounted) {
                Navigator.pop(context);
              }
            } else {
              WzToast.show(
                context,
                message: l10n.errorIdentifyPhoto,
                type: WzToastType.error,
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> _deletePhoto(String photoId, int index) async {
    if (!mounted) return false;

    final provider = context.read<ProfileProvider>();
    final success = await provider.deletePhoto(photoId);

    if (!mounted) return false;

    if (success) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.refreshUser();
      WzToast.show(
        context,
        message: l10n.photoDeletedSuccess,
        type: WzToastType.success,
      );
      return true;
    } else {
      WzToast.show(
        context,
        message: l10n.photoDeleteFailed,
        type: WzToastType.error,
      );
      return false;
    }
  }

  Future<void> _pickAndUploadPhotos(int maxPhotos) async {
    try {
      if (maxPhotos <= 0) {
        WzToast.show(
          context,
          message: l10n.maxPhotosWarning,
          type: WzToastType.normal,
        );
        return;
      }

      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        limit: maxPhotos,
      );

      if (pickedFiles.isEmpty) return;

      final filesToUpload = pickedFiles.take(maxPhotos).toList();
      if (filesToUpload.length < pickedFiles.length) {
        WzToast.show(
          context,
          message: l10n.photosAddedLimit.replaceFirst(
            '{count}',
            '${filesToUpload.length}',
          ),
          type: WzToastType.normal,
        );
      }

      final files = filesToUpload.map((xFile) => File(xFile.path)).toList();

      if (mounted) {
        _uploadProvider.addFiles(files);
      }
    } catch (e) {
      debugPrint('[PHOTO_MANAGER] Error picking/uploading: $e');
      WzToast.show(
        context,
        message: l10n.errorPickingPhotos,
        type: WzToastType.error,
      );
    }
  }

  Future<bool> _setAsProfilePhoto(String photoId) async {
    if (!mounted) return false;

    final provider = context.read<ProfileProvider>();
    final success = await provider.setProfilePhoto(photoId);

    if (!mounted) return false;

    if (success) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.refreshUser();
      WzToast.show(
        context,
        message: l10n.profilePhotoUpdatedSuccess,
        type: WzToastType.success,
      );
      return true;
    } else {
      WzToast.show(
        context,
        message: l10n.profilePhotoUpdateFailed,
        type: WzToastType.error,
      );
      return false;
    }
  }

  void _showPhotoGuidelines() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.photoGuidelinesTitle, style: WzTextStyles.heading4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuidelineItem(l10n.guidelineClearRecent),
            _buildGuidelineItem(l10n.guidelineFaceVisible),
            _buildGuidelineItem(l10n.guidelineNoGroup),
            _buildGuidelineItem(l10n.guidelineMaxPhotos),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: WzColors.primary),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: WzColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: WzTextStyles.body2.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
