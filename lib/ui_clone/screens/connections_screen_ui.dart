import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/connections/providers/connections_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/scaffold_with_background.dart';
import '../../shared/widgets/wz_loading.dart';
import '../../core/theme/wz_colors.dart';

class ConnectionsScreenUI extends StatefulWidget {
  const ConnectionsScreenUI({super.key});

  @override
  State<ConnectionsScreenUI> createState() => _ConnectionsScreenUIState();
}

class _ConnectionsScreenUIState extends State<ConnectionsScreenUI> {
  @override
  void initState() {
    super.initState();
    debugPrint(
      '📍 [SCREEN] ========== CONNECTIONS SCREEN ========== [ROUTE: ${AppRoutes.uiConnections}]',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectionsProvider>().loadMyConnections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF111827),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.translate('connections'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Consumer<ConnectionsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoadingConnections) {
                    return const Center(child: WzLoading());
                  }

                  if (provider.myConnections.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.translate('no_connections_yet'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.translate('start_connecting_text'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadMyConnections(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: provider.myConnections.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final connection = provider.myConnections[index];
                        return _buildConnectionCard(connection);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(Map<String, dynamic> connection) {
    final username = connection['username'] as String? ?? '';
    final firstName = connection['first_name'] as String? ?? '';
    final lastName = connection['last_name'] as String? ?? '';
    final profilePhoto = connection['profilePhoto'] as String?;
    final occupation = connection['occupation'] as String?;
    final city = connection['city'] as String?;
    final state = connection['state'] as String?;

    final displayName = firstName.isNotEmpty
        ? '$firstName ${lastName.isNotEmpty ? lastName : ""}'.trim()
        : username;

    final details = [
      if (occupation != null && occupation.isNotEmpty) occupation,
      if (city != null && city.isNotEmpty) city,
      if (state != null && state.isNotEmpty) state,
    ].join(' • ');

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.userProfileView,
        arguments: username,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: profilePhoto != null && profilePhoto.isNotEmpty
                  ? Image.network(
                      profilePhoto,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 35),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 35),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF2F55).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('connected'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF2F55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF111827), size: 24),
          ],
        ),
      ),
    );
  }
}
