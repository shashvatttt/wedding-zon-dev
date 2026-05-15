import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/models/photo_model.dart';
import '../../features/feed/models/feed_user.dart';
import '../../features/profile/repositories/user_repository.dart';
import '../../features/connections/providers/connections_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/profile_helpers.dart';
import '../../shared/widgets/image_viewer.dart';
import '../../shared/widgets/scaffold_with_background.dart';
import '../../shared/widgets/wz_toast.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/wz_loading.dart';

class UserProfileViewUI extends StatefulWidget {
  final String username;
  final bool showNavBar;

  const UserProfileViewUI({
    super.key,
    required this.username,
    this.showNavBar = true,
  });

  @override
  State<UserProfileViewUI> createState() => _UserProfileViewUIState();
}

class _UserProfileViewUIState extends State<UserProfileViewUI> {
  FeedUser? _user;
  bool _isLoading = true;
  String? _error;
  final PageController _photoController = PageController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile({bool refresh = false}) async {
    if (!refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final apiService = context.read<ApiService>();
      final connectionsProvider = context.read<ConnectionsProvider>();
      final userRepository = UserRepository(apiService);

      final response = await userRepository.getUserByUsername(widget.username);

      if (response.success && response.data != null) {
        final userData = response.data!;

        debugPrint(
          '[UserProfileViewUI] Raw userData photos: ${userData['photos']}',
        );
        debugPrint(
          '[UserProfileViewUI] Raw userData profilePhoto: ${userData['profilePhoto']}',
        );

        final feedUser = FeedUser.fromJson(userData);

        debugPrint(
          '[UserProfileViewUI] Parsed photos count: ${feedUser.photos.length}',
        );
        debugPrint(
          '[UserProfileViewUI] Parsed profilePhoto: ${feedUser.profilePhoto}',
        );
        for (var p in feedUser.photos) {
          debugPrint(
            '[UserProfileViewUI] Photo: url=${p.url.substring(0, p.url.length.clamp(0, 50))}..., isProfile=${p.isProfile}',
          );
        }

        await connectionsProvider.fetchStatus(widget.username);

        if (feedUser.id.isNotEmpty) {
          await userRepository.recordProfileView(feedUser.id);
        }

        if (mounted) {
          setState(() {
            _user = feedUser;
            _isLoading = false;
            _error = null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            if (response.message?.toLowerCase().contains('not found') ??
                false) {
              _error = 'USER_NOT_FOUND';
            } else {
              _error =
                  response.message ??
                  AppLocalizations.of(
                    context,
                  )!.translate('something_went_wrong');
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('[UserProfileViewUI] Error loading profile: $e');
      if (mounted) {
        setState(() {
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('socket') ||
              errorString.contains('network') ||
              errorString.contains('connection') ||
              errorString.contains('timeout')) {
            _error = 'NETWORK_ERROR';
          } else if (errorString.contains('not found') ||
              errorString.contains('404')) {
            _error = 'USER_NOT_FOUND';
          } else {
            _error = 'UNKNOWN_ERROR';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: WzLoading()));
    }

    if (_error != null) {
      return Scaffold(body: _buildErrorScreen());
    }

    if (_user == null) {
      return Scaffold(body: _buildUserNotFoundScreen());
    }

    return ScaffoldWithBackground(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _loadUserProfile(refresh: true),
            color: const Color(0xFFEF2F55),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(_user!),

                  SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        _buildAboutMeContent(_user!),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildFloatingActionBar(),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    IconData errorIcon;
    String errorTitle;
    String errorMessage;

    switch (_error) {
      case 'NETWORK_ERROR':
        errorIcon = Icons.wifi_off;
        errorTitle = AppLocalizations.of(context)!.translate('network_error');
        errorMessage = AppLocalizations.of(context)!.translate('network_error');
        break;
      case 'USER_NOT_FOUND':
        return _buildUserNotFoundScreen();
      case 'UNKNOWN_ERROR':
        errorIcon = Icons.error_outline;
        errorTitle = AppLocalizations.of(
          context,
        )!.translate('something_went_wrong');
        errorMessage = AppLocalizations.of(
          context,
        )!.translate('something_went_wrong');
        break;
      default:
        errorIcon = Icons.error_outline;
        errorTitle = AppLocalizations.of(context)!.translate('error');
        errorMessage =
            _error ??
            AppLocalizations.of(context)!.translate('something_went_wrong');
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              errorTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _loadUserProfile(refresh: true),
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context)!.translate('retry')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF2F55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/feed', (route) => false);
                  },
                  icon: const Icon(Icons.home),
                  label: Text(
                    AppLocalizations.of(context)!.translate('go_to_feed'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF2F55),
                    side: const BorderSide(color: Color(0xFFEF2F55)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserNotFoundScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.translate('user_not_found'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.translate('user_not_found_msg'),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/feed', (route) => false);
              },
              icon: const Icon(Icons.home),
              label: Text(
                AppLocalizations.of(context)!.translate('go_to_feed'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF2F55),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(FeedUser user) {
    final topPadding = MediaQuery.of(context).padding.top;

    List<Photo> photos;
    if (user.photos.isNotEmpty) {
      photos = user.photos;
    } else if (user.profilePhoto != null && user.profilePhoto!.isNotEmpty) {
      photos = [
        Photo(
          url: user.profilePhoto!,
          publicId: null,
          isProfile: true,
          restricted: false,
        ),
      ];
    } else {
      photos = [];
    }

    debugPrint('[UserProfileViewUI] Header photos count: ${photos.length}');

    return Container(
      height: 480 + topPadding,
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photos.isEmpty)
              Container(
                color: Colors.grey[300],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 80, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('no_photos_available'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              PageView.builder(
                controller: _photoController,
                itemCount: photos.length,
                onPageChanged: (_) {},
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  final shouldBlur = _shouldBlurPhoto(photo);

                  return GestureDetector(
                    onTap: () => _handlePhotoTap(index),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: photo.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[300]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),

                        if (shouldBlur)
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.35),
                                child: const Center(
                                  child: Icon(
                                    Icons.lock,
                                    size: 56,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

            Positioned(
              top: 16 + topPadding,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16 + topPadding,
              right: 16,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    if (value == 'remove') {
                      _handleRemoveConnection();
                    } else if (value == 'report') {
                      _handleReportUser();
                    } else if (value == 'block') {
                      _handleBlockUser();
                    } else if (value == 'share') {
                      _shareProfile();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final connectionsProvider = context
                        .read<ConnectionsProvider>();
                    final connectionStatus = connectionsProvider
                        .getConnectionStatus(widget.username);

                    return [
                      if (connectionStatus == 'accepted')
                        PopupMenuItem<String>(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_remove,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.translate('remove_connection'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      PopupMenuItem<String>(
                        value: 'share',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.share,
                              color: Colors.black87,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.translate('share_profile'),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'report',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Colors.black87,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.translate('report_user'),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'block',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.block,
                              color: Colors.black87,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.translate('block_user'),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ),
            ),

            if (photos.length > 1)
              Positioned(
                top: 60 + topPadding,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    photos.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              top: 311 + topPadding,
              left: 0,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      user.fullName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                            color: Color.fromARGB(150, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 10,
                      top: 4,
                      bottom: 4,
                    ),
                    child: Text(
                      ProfileHelpers.getProfileManagedByText(
                        user.profileManagedBy,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2.0,
                            color: Color.fromARGB(100, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Consumer<ConnectionsProvider>(
              builder: (context, connectionsProvider, _) {
                final connectionStatus = connectionsProvider
                    .getConnectionStatus(widget.username);

                if (connectionStatus == 'accepted') {
                  return Positioned(
                    bottom: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _handleChat,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/chat.svg',
                                width: 32,
                                height: 32,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionBar() {
    return Consumer<ConnectionsProvider>(
      builder: (context, connectionsProvider, _) {
        final connectionStatus = connectionsProvider.getConnectionStatus(
          widget.username,
        );

        if (connectionStatus == 'accepted') {
          return const SizedBox.shrink();
        }

        final bottomPadding = MediaQuery.of(context).padding.bottom;

        return Positioned(
          left: 0,
          right: 0,
          bottom: bottomPadding > 0 ? bottomPadding + 10 : 20,
          child: Center(child: _buildEmbeddedActionButtons()),
        );
      },
    );
  }

  bool _shouldBlurPhoto(dynamic photo) {
    if (photo.isProfile) {
      return false;
    }

    final connectionsProvider = context.read<ConnectionsProvider>();
    final photoStatus = connectionsProvider.getStatus(widget.username);
    final connectionStatus = connectionsProvider.getConnectionStatus(
      widget.username,
    );

    if (connectionStatus == 'accepted' || photoStatus == 'granted') {
      return false;
    }

    return true;
  }

  void _handlePhotoTap(int index) {
    final connectionsProvider = context.read<ConnectionsProvider>();
    final photoStatus = connectionsProvider.getStatus(widget.username);
    final photo = _user!.photos[index];

    if (photo.isProfile || photoStatus == 'accepted') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewer(
            photos: _user!.photos,
            initialIndex: index,
            hasAccess: photoStatus == 'accepted',
            canSetProfile: false,
            canDelete: false,
          ),
        ),
      );
    } else {
      _showPhotoAccessDialog(photoStatus);
    }
  }

  void _showPhotoAccessDialog(String photoStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('photos_locked')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                photoStatus == 'pending'
                    ? AppLocalizations.of(
                        context,
                      )!.translate('photo_access_pending')
                    : AppLocalizations.of(
                        context,
                      )!.translate('request_access_view_photos'),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.translate('close')),
            ),
            if (photoStatus == 'none')
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleRequestPhotoAccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF2F55),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('request_access'),
                ),
              )
            else if (photoStatus == 'pending')
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleCancelPhotoRequest();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('cancel_request'),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmbeddedActionButtons() {
    return Consumer<ConnectionsProvider>(
      builder: (context, connectionsProvider, child) {
        final connectionStatus = connectionsProvider.getConnectionStatus(
          widget.username,
        );

        if (connectionStatus == 'accepted') {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 40,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProfileActionButton(
                    icon: Icons.close,
                    isLoading: connectionsProvider.isCancellingRequest(
                      widget.username,
                    ),
                    onTap: () => _handleCrossButton(connectionStatus),
                    isEnabled: connectionStatus == 'pending',
                  ),
                  const SizedBox(width: 40),

                  _ProfileActionButton(
                    icon:
                        connectionStatus == 'pending' ||
                            connectionStatus == 'accepted'
                        ? Icons.favorite
                        : Icons.favorite_border,
                    isLoading: false,
                    onTap: () => _handleHeartButton(connectionStatus),
                    isEnabled: true,
                  ),
                  const SizedBox(width: 40),

                  _ProfileActionButton(
                    iconPath: 'assets/icons/chat.svg',
                    isLoading: false,
                    onTap: () {},
                    isEnabled: false,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCrossButton(String connectionStatus) async {
    if (connectionStatus == 'pending') {
      await _handleCancelRequest();
    }
  }

  Future<void> _handleHeartButton(String connectionStatus) async {
    if (connectionStatus == 'none') {
      await _handleConnect();
    } else if (connectionStatus == 'pending') {
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.requestAlreadyPending,
      );
    }
  }

  Widget _buildIconActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70),
            ),
            child: isLoading
                ? const WzLoadingSmall(color: Colors.white)
                : Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton(String connectionStatus) {
    final connectionsProvider = context.read<ConnectionsProvider>();
    final isLoading = connectionsProvider.isSendingInterest(widget.username);

    String label = AppLocalizations.of(context)!.translate('connect');
    IconData icon = Icons.favorite_border;
    VoidCallback? onPressed = _handleConnect;
    Color bgColor = const Color(0xFFEF2F55);

    if (connectionStatus == 'pending') {
      label = AppLocalizations.of(context)!.translate('cancel_request');
      icon = Icons.favorite;
      bgColor = Colors.grey[700]!;
      onPressed = _handleCancelRequest;
    } else if (connectionStatus == 'accepted') {
      return GestureDetector(
        onTap: _handleChat,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/chat.svg',
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isLoading) {
      label = AppLocalizations.of(context)!.translate('processing');
      onPressed = null;
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const WzLoadingSmall(color: Colors.white)
          : Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: const StadiumBorder(),
      ),
    );
  }

  Widget _buildAboutMeContent(FeedUser user) {
    final connectionsProvider = context.read<ConnectionsProvider>();
    final detailsStatus = connectionsProvider.getDetailsStatus(widget.username);
    final connectionStatus = connectionsProvider.getConnectionStatus(
      widget.username,
    );

    final isConnected = connectionsProvider.myConnections.any(
      (conn) => conn['username'] == widget.username || conn['_id'] == user.id,
    );

    final hasAccess =
        isConnected ||
        connectionStatus == 'accepted' ||
        detailsStatus == 'granted';

    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        children: [
          if (hasAccess) ...[
            _buildSection(
              title: l10n.basicDetailsTitle,
              children: [
                if (user.firstName != null || user.lastName != null)
                  _buildDetailRow(
                    Icons.person,
                    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                    label: l10n.translate('full_name'),
                  ),
                if (user.username.isNotEmpty)
                  _buildDetailRow(
                    Icons.alternate_email,
                    user.username,
                    label: l10n.translate('username'),
                  ),
                _buildDetailRow(
                  Icons.cake,
                  '${_calculateAge(user.dob)} (${_formatDate(user.dob)})',
                  label: l10n.translate('age_dob'),
                ),
                if (user.gender != null)
                  _buildDetailRow(
                    Icons.wc,
                    user.gender!,
                    label: l10n.translate('gender'),
                  ),
                if (user.height != null)
                  _buildDetailRow(
                    Icons.height,
                    user.height!,
                    label: l10n.translate('height'),
                  ),
                if (user.maritalStatus != null)
                  _buildDetailRow(
                    Icons.favorite,
                    user.maritalStatus!,
                    label: l10n.translate('marital_status_label'),
                  ),
                if (user.physicalStatus != null)
                  _buildDetailRow(
                    Icons.accessibility,
                    user.physicalStatus!,
                    label: l10n.translate('physical_status'),
                  ),
                if (user.appearance != null)
                  _buildDetailRow(
                    Icons.face,
                    user.appearance!,
                    label: l10n.translate('appearance'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: l10n.aboutMeTitle,
              children: [
                Text(
                  user.aboutMe ?? l10n.noBio,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: l10n.locationDetailsTitle,
              children: [
                if (user.city != null)
                  _buildDetailRow(
                    Icons.location_city,
                    user.city!,
                    label: l10n.translate('city'),
                  ),
                if (user.state != null)
                  _buildDetailRow(
                    Icons.map,
                    user.state!,
                    label: l10n.translate('state'),
                  ),
                if (user.country != null)
                  _buildDetailRow(
                    Icons.flag,
                    user.country!,
                    label: l10n.translate('country'),
                  ),
                if (user.livingStatus != null)
                  _buildDetailRow(
                    Icons.home_work,
                    user.livingStatus!,
                    label: l10n.translate('living_status'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: l10n.religiousCulturalTitle,
              children: [
                if (user.religion != null)
                  _buildDetailRow(
                    Icons.church,
                    user.religion!,
                    label: l10n.translate('religion_label'),
                  ),
                if (user.community != null)
                  _buildDetailRow(
                    Icons.people,
                    user.community!,
                    label: l10n.translate('community'),
                  ),
                if (user.subCommunity != null)
                  _buildDetailRow(
                    Icons.group,
                    user.subCommunity!,
                    label: l10n.translate('subcommunity'),
                  ),
                if (user.motherTongue != null)
                  _buildDetailRow(
                    Icons.language,
                    user.motherTongue!,
                    label: l10n.translate('mother_tongue_label'),
                  ),
                if (user.manglikStatus != null)
                  _buildDetailRow(
                    Icons.auto_awesome,
                    user.manglikStatus!,
                    label: l10n.translate('manglik_status'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: l10n.educationCareerTitle,
              children: [
                if (user.highestEducation != null)
                  _buildDetailRow(
                    Icons.school,
                    user.highestEducation!,
                    label: l10n.translate('highest_education_label'),
                  ),
                if (user.educationalDetails != null &&
                    user.educationalDetails!.isNotEmpty)
                  _buildDetailRow(
                    Icons.description,
                    user.educationalDetails!,
                    label: l10n.translate('edu_details_label'),
                  ),
                if (user.occupation != null)
                  _buildDetailRow(
                    Icons.work,
                    user.occupation!,
                    label: l10n.translate('occupation_label'),
                  ),
                if (user.employedIn != null && user.employedIn!.isNotEmpty)
                  _buildDetailRow(
                    Icons.business,
                    user.employedIn!,
                    label: l10n.translate('employed_in'),
                  ),
                if (user.workingSector != null &&
                    user.workingSector!.isNotEmpty)
                  _buildDetailRow(
                    Icons.category,
                    user.workingSector!,
                    label: l10n.translate('working_sector'),
                  ),
                if (user.workingLocation != null &&
                    user.workingLocation!.isNotEmpty)
                  _buildDetailRow(
                    Icons.location_on,
                    user.workingLocation!,
                    label: l10n.translate('working_location'),
                  ),
                if (user.personalIncome != null)
                  _buildDetailRow(
                    Icons.attach_money,
                    '₹${user.personalIncome}',
                    label: l10n.translate('personal_income'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: l10n.familyTitle,
              children: [
                if (user.familyType != null)
                  _buildDetailRow(
                    Icons.family_restroom,
                    user.familyType!,
                    label: l10n.translate('family_type'),
                  ),
                if (user.familyStatus != null)
                  _buildDetailRow(
                    Icons.home,
                    user.familyStatus!,
                    label: l10n.translate('family_status'),
                  ),
                if (user.familyValues != null)
                  _buildDetailRow(
                    Icons.favorite,
                    user.familyValues!,
                    label: l10n.translate('family_values'),
                  ),
                if (user.fatherStatus != null)
                  _buildDetailRow(
                    Icons.person,
                    user.fatherStatus!,
                    label: l10n.translate('father'),
                  ),
                if (user.motherStatus != null)
                  _buildDetailRow(
                    Icons.person,
                    user.motherStatus!,
                    label: l10n.translate('mother'),
                  ),
                _buildDetailRow(
                  Icons.people,
                  '${user.brothers ?? 0} ${l10n.brothers}, ${user.sisters ?? 0} ${l10n.sisters}',
                  label: l10n.translate('siblings'),
                ),
                if (user.familyLocation != null &&
                    user.familyLocation!.isNotEmpty)
                  _buildDetailRow(
                    Icons.location_city,
                    user.familyLocation!,
                    label: l10n.translate('family_location'),
                  ),
                if (user.annualIncome != null)
                  _buildDetailRow(
                    Icons.account_balance,
                    '₹${user.annualIncome}',
                    label: l10n.translate('family_income'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: l10n.lifestyleTitle,
              children: [
                if (user.eatingHabits != null)
                  _buildDetailRow(
                    Icons.restaurant,
                    user.eatingHabits!,
                    label: l10n.translate('diet'),
                  ),
                if (user.drinkingHabits != null)
                  _buildDetailRow(
                    Icons.local_bar,
                    user.drinkingHabits!,
                    label: l10n.translate('drinking'),
                  ),
                if (user.smokingHabits != null)
                  _buildDetailRow(
                    Icons.smoking_rooms,
                    user.smokingHabits!,
                    label: l10n.translate('smoking'),
                  ),
                if (user.hobbies != null && user.hobbies!.isNotEmpty)
                  _buildDetailRow(
                    Icons.interests,
                    user.hobbies!.join(', '),
                    label: l10n.translate('hobbies'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: l10n.assetsTitle,
              children: [
                if (user.propertyType != null && user.propertyType!.isNotEmpty)
                  _buildDetailRow(
                    Icons.home,
                    user.propertyType!,
                    label: l10n.translate('property_type'),
                  ),
                if (user.propertyPossessionType != null &&
                    user.propertyPossessionType!.isNotEmpty)
                  _buildDetailRow(
                    Icons.key,
                    user.propertyPossessionType!,
                    label: l10n.translate('possession'),
                  ),
                if (user.landArea != null && user.landArea!.isNotEmpty)
                  _buildDetailRow(
                    Icons.square_foot,
                    user.landArea!,
                    label: l10n.translate('land_area'),
                  ),
                if (user.landTypes != null && user.landTypes!.isNotEmpty)
                  _buildDetailRow(
                    Icons.landscape,
                    user.landTypes!.join(', '),
                    label: l10n.translate('land_types'),
                  ),
                if (user.houseTypes != null && user.houseTypes!.isNotEmpty)
                  _buildDetailRow(
                    Icons.house,
                    user.houseTypes!.join(', '),
                    label: l10n.translate('house_types'),
                  ),
                if (user.businessTypes != null &&
                    user.businessTypes!.isNotEmpty)
                  _buildDetailRow(
                    Icons.business,
                    user.businessTypes!.join(', '),
                    label: l10n.translate('business_types'),
                  ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Colors.black45,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('full_profile_locked'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('profile_locked_message'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _handleRequestDetailsAccess,
                    icon: const Icon(Icons.description, size: 20),
                    label: Text(l10n.translate('request_details')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF2F55),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String value, {String? label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFEF2F55)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                if (label != null) const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String? dob) {
    final l10n = AppLocalizations.of(context)!;
    if (dob == null) return l10n.translate('na');
    try {
      final date = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) {
        age--;
      }
      return '$age${l10n.translate('years_label')}';
    } catch (e) {
      return l10n.translate('na');
    }
  }

  String _formatDate(String? dob) {
    if (dob == null) return '';
    try {
      final date = DateTime.parse(dob);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  Future<void> _handleConnect() async {
    final connectionsProvider = context.read<ConnectionsProvider>();

    try {
      await connectionsProvider.sendInterest(widget.username);
    } catch (e) {
      debugPrint('[UserProfileViewUI] Error sending connection request: $e');
    }
  }

  Future<void> _handleCancelRequest() async {
    final connectionsProvider = context.read<ConnectionsProvider>();

    try {
      await connectionsProvider.cancelConnectionRequest(widget.username);
    } catch (e) {
      debugPrint('[UserProfileViewUI] Error cancelling connection request: $e');
    }
  }

  void _handleChat() {
    if (_user == null) {
      debugPrint('[UserProfileViewUI] Cannot navigate to chat: user is null');
      return;
    }

    if (_user!.id.isEmpty) {
      debugPrint(
        '[UserProfileViewUI] Cannot navigate to chat: userId is empty',
      );
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.unableStartChat,
        type: WzToastType.error,
      );
      return;
    }

    debugPrint(
      '[UserProfileViewUI] Navigating to chat with userId: ${_user!.id}, username: ${_user!.username}',
    );

    Navigator.pushNamed(
      context,
      '/ui-clone/chat-conversation',
      arguments: {
        'userId': _user!.id,
        'username': _user!.username,
        'firstName': _user!.firstName,
        'lastName': _user!.lastName,
        'profilePhoto': _user!.profilePhoto,
      },
    );
  }

  Future<void> _handleRequestDetailsAccess() async {
    final connectionsProvider = context.read<ConnectionsProvider>();

    try {
      await connectionsProvider.requestDetailsAccess(widget.username);
    } catch (e) {
      debugPrint('[UserProfileViewUI] Error requesting details access: $e');
    }
  }

  Future<void> _handleRequestPhotoAccess() async {
    final connectionsProvider = context.read<ConnectionsProvider>();

    try {
      await connectionsProvider.requestAccess(widget.username);
    } catch (e) {
      debugPrint('[UserProfileViewUI] Error requesting photo access: $e');
    }
  }

  Future<void> _handleCancelPhotoRequest() async {
    final connectionsProvider = context.read<ConnectionsProvider>();

    try {
      await connectionsProvider.cancelPhotoAccessRequest(widget.username);
    } catch (e) {
      debugPrint('[UserProfileViewUI] Error canceling photo request: $e');
    }
  }

  Future<void> _handleCancelDetailsRequest() async {
    final connectionsProvider = context.read<ConnectionsProvider>();

    try {
      await connectionsProvider.cancelDetailsAccessRequest(widget.username);
    } catch (e) {
      debugPrint('[UserProfileViewUI] Error canceling details request: $e');
    }
  }

  void _shareProfile() {
    if (_user == null) {
      debugPrint('[UserProfileViewUI] Cannot share profile: user is null');
      return;
    }

    final profileUrl = AppConstants.getProfileDeepLink(_user!.username);

    final l10n = AppLocalizations.of(context)!;
    final shareText =
        '${l10n.shareProfileMessage(_user!.fullName)}\n$profileUrl';
    final subject = l10n.shareProfileSubject(_user!.fullName);

    Share.share(shareText, subject: subject);

    debugPrint('[UserProfileViewUI] Sharing profile: ${_user!.username}');
  }

  Future<void> _handleRemoveConnection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.translate('remove_connection'),
          ),
          content: Text(
            AppLocalizations.of(
              context,
            )!.translate('remove_connection_confirmation'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF2F55),
              ),
              child: Text(AppLocalizations.of(context)!.translate('remove')),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) return;

    final connectionsProvider = context.read<ConnectionsProvider>();

    try {
      await connectionsProvider.removeConnection(widget.username);

      debugPrint('[UserProfileViewUI] Connection removed successfully');
    } catch (e) {
      debugPrint('[UserProfileViewUI] Error removing connection: $e');
    }
  }

  Future<void> _handleBlockUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('block_user')),
        content: Text(
          AppLocalizations.of(context)!.translate('block_user_confirmation'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.translate('block')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    if (_user == null) {
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.userDataNotLoaded,
        type: WzToastType.error,
      );
      return;
    }

    final connectionsProvider = context.read<ConnectionsProvider>();
    await connectionsProvider.blockUser(_user!.id);

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/feed', (route) => false);
  }

  Future<void> _handleReportUser() async {
    final reasonController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('report_user')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.translate('report_user_reason')),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('reason'),
                hintText: AppLocalizations.of(
                  context,
                )!.translate('reason_hint'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.translate('description_optional'),
                hintText: AppLocalizations.of(
                  context,
                )!.translate('description_hint'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                WzToast.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  )!.translate('provide_reason_error'),
                  type: WzToastType.error,
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF2F55),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.translate('report')),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;
    if (_user == null) {
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.userDataNotLoaded,
        type: WzToastType.error,
      );
      return;
    }

    final connectionsProvider = context.read<ConnectionsProvider>();
    await connectionsProvider.reportUser(
      _user!.id,
      reasonController.text.trim(),
      descriptionController.text.trim().isNotEmpty
          ? descriptionController.text.trim()
          : null,
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final bool isLoading;
  final VoidCallback onTap;
  final bool isEnabled;

  const _ProfileActionButton({
    this.icon,
    this.iconPath,
    this.isLoading = false,
    required this.onTap,
    this.isEnabled = true,
  }) : assert(
         icon != null || iconPath != null,
         'Either icon or iconPath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && !isLoading ? onTap : null,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFFEF2F55).withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFEF2F55).withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isEnabled
                  ? const Color(0xFFEF2F55).withValues(alpha: 0.1)
                  : Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: isLoading
                  ? const WzLoadingSmall()
                  : iconPath != null
                  ? SvgPicture.asset(
                      iconPath!,
                      width: 28,
                      height: 28,
                      colorFilter: ColorFilter.mode(
                        isEnabled
                            ? const Color(0xFFEF2F55)
                            : Colors.grey.withValues(alpha: 0.4),
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      icon!,
                      size: 28,
                      color: isEnabled
                          ? const Color(0xFFEF2F55)
                          : Colors.grey.withValues(alpha: 0.4),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
