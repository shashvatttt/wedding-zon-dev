import 'package:flutter/material.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/franchise_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/theme/wz_colors.dart';
import '../../../shared/widgets/wz_loading.dart';
import '../../../shared/widgets/wz_toast.dart';

class FranchiseDashboard extends StatefulWidget {
  const FranchiseDashboard({super.key});

  @override
  State<FranchiseDashboard> createState() => _FranchiseDashboardState();
}

class _FranchiseDashboardState extends State<FranchiseDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FranchiseProvider>().loadProfiles();
    });
  }

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final franchiseName =
        authProvider.currentUser?.franchiseDetails?.businessName ??
        authProvider.currentUser?.fullName ??
        'Franchise';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(franchiseName),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 14, color: Color(0xFFFFD700)),
                SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.translate('verified_franchise'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
        backgroundColor: WzColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FranchiseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.profiles.isEmpty) {
            return const Center(child: WzLoading());
          }

          final totalMembers = provider.profiles.length;
          final activeProfiles = provider.profiles
              .where((p) => p.status == 'active')
              .length;
          final pendingActions = provider.profiles
              .where(
                (p) =>
                    p.photos.isEmpty || p.aboutMe == null || p.aboutMe!.isEmpty,
              )
              .length;

          if (provider.profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.translate('no_members_yet'),
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.translate('add_first_member'),
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStatsCard(
                      'Total Members',
                      totalMembers.toString(),
                      Icons.people,
                      const Color(0xFFEF2F55),
                    ),
                    const SizedBox(width: 8),
                    _buildStatsCard(
                      'Active Profiles',
                      activeProfiles.toString(),
                      Icons.check_circle,
                      const Color(0xFFEF2F55),
                    ),
                    const SizedBox(width: 8),
                    _buildStatsCard(
                      'Pending Actions',
                      pendingActions.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadProfiles();
                  },
                  color: const Color(0xFFEF2F55),
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.profiles.length,
                    itemBuilder: (context, index) {
                      final member = provider.profiles[index];
                      final age = _calculateAge(member.dob);
                      final isIncomplete =
                          member.photos.isEmpty ||
                          member.aboutMe == null ||
                          member.aboutMe!.isEmpty;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.manageMember,
                              arguments: member,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundImage:
                                          member.profilePhoto != null
                                          ? NetworkImage(member.profilePhoto!)
                                          : null,
                                      child: member.profilePhoto == null
                                          ? Text(
                                              (member.firstName?.isNotEmpty ??
                                                      false)
                                                  ? member.firstName![0]
                                                        .toUpperCase()
                                                  : 'U',
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                    if (member.status == 'active')
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              member.fullName ?? 'Unknown',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (member.createdFor != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFEF2F55,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                member.createdFor!,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFFEF2F55),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.badge_outlined,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            member.username ??
                                                member.id.substring(0, 8),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.cake_outlined,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$age years',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              member.city ?? 'Location not set',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isIncomplete) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.warning_amber_rounded,
                                                size: 14,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Profile Incomplete',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.orange[800],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.grey[600],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  itemBuilder: (context) =>
                                      <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'feed',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility, size: 20),
                                              SizedBox(width: 12),
                                              Text('View Feed'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 12),
                                              Text('Edit Profile'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'preferences',
                                          child: Row(
                                            children: [
                                              Icon(Icons.favorite, size: 20),
                                              SizedBox(width: 12),
                                              Text('Preferences'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'pdf',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.picture_as_pdf,
                                                size: 20,
                                              ),
                                              SizedBox(width: 12),
                                              Text('Download PDF'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuDivider(),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                  onSelected: (value) async {
                                    if (value == 'feed') {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.viewAsFeed,
                                        arguments: {
                                          'viewAs': member.id,
                                          'viewAsName':
                                              member.fullName ?? 'Member',
                                        },
                                      );
                                    } else if (value == 'edit') {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.franchiseAddMember,
                                        arguments: member,
                                      );
                                    } else if (value == 'preferences') {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.partnerPreferences,
                                        arguments: member.id,
                                      );
                                    } else if (value == 'pdf') {
                                      final pdfPath = await provider
                                          .downloadMatchPdf(
                                            member.id,
                                            language: 'english',
                                          );
                                      if (pdfPath != null && context.mounted) {
                                        await OpenFile.open(pdfPath);
                                      }
                                    } else if (value == 'delete') {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Member'),
                                          content: Text(
                                            'Are you sure you want to delete ${member.fullName ?? "this member"}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(
                                                  0xFFEF2F55,
                                                ),
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true &&
                                          context.mounted) {
                                        WzToast.show(
                                          context,
                                          message: '${member.fullName} deleted',
                                          type: WzToastType.success,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.franchiseAddMember);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Member'),
      ),
    );
  }
}
