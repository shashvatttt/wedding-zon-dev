import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../models/profile_viewer_model.dart';
import '../repositories/user_repository.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/wz_toast.dart';

class ProfileViewersScreen extends StatefulWidget {
  const ProfileViewersScreen({super.key});

  @override
  State<ProfileViewersScreen> createState() => _ProfileViewersScreenState();
}

class _ProfileViewersScreenState extends State<ProfileViewersScreen> {
  late Future<List<ProfileViewer>> _viewersFuture;
  late final UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    final apiService = context.read<ApiService>();
    _userRepository = UserRepository(apiService);
    _loadViewers();
  }

  void _loadViewers() {
    setState(() {
      _viewersFuture = _fetchViewers();
    });
  }

  Future<List<ProfileViewer>> _fetchViewers() async {
    final response = await _userRepository.getProfileViewers();
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(
        response.message ??
            AppLocalizations.of(context)!.translate('failed_load_viewers'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('who_viewed_profile_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<ProfileViewer>>(
        future: _viewersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '${AppLocalizations.of(context)!.translate('upload_error')} ${snapshot.error}',
                  ),
                  TextButton(
                    onPressed: _loadViewers,
                    child: Text(
                      AppLocalizations.of(context)!.translate('retry'),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.translate('no_views_yet'),
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final viewers = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewers.length,
            itemBuilder: (context, index) {
              final viewer = viewers[index];

              final username = viewer.username.trim();
              final fullName = viewer.fullName.trim();
              final isDeleted = username.isEmpty || username == 'deleted_user';
              final displayName = isDeleted
                  ? AppLocalizations.of(context)!.translate('deleted_user')
                  : fullName;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Opacity(
                  opacity: isDeleted ? 0.6 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: isDeleted
                              ? null
                              : () => _navigateToProfile(username),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: viewer.profilePhoto.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    viewer.profilePhoto,
                                  )
                                : null,
                            child: viewer.profilePhoto.isEmpty
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDeleted
                                      ? Colors.grey
                                      : Colors.indigo,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'MMM d, h:mm a',
                                    ).format(viewer.viewedAt.toLocal()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isDeleted
                              ? null
                              : () => _navigateToProfile(username),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDeleted
                                ? Colors.grey.shade200
                                : Colors.pink.shade50,
                            foregroundColor: isDeleted
                                ? Colors.grey
                                : Colors.pink,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isDeleted
                                    ? Colors.grey.shade300
                                    : Colors.pink.shade100,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            isDeleted
                                ? AppLocalizations.of(
                                    context,
                                  )!.translate('unavailable')
                                : AppLocalizations.of(
                                    context,
                                  )!.translate('view_profile'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToProfile(String username) {
    if (username.isEmpty || username == 'deleted_user') {
      WzToast.show(
        context,
        message: AppLocalizations.of(
          context,
        )!.translate('account_unavailable_msg'),
        type: WzToastType.normal,
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.userProfileView,
      arguments: username,
    );
  }
}
