import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connections_provider.dart';
import '../widgets/interest_card.dart';

class InterestsTab extends StatefulWidget {
  const InterestsTab({super.key});

  @override
  State<InterestsTab> createState() => _InterestsTabState();
}

class _InterestsTabState extends State<InterestsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectionsProvider>().loadSentRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSent && provider.sentRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        debugPrint(
          '🔍 [INTEREST_TAB] Total sent requests: ${provider.sentRequests.length}',
        );
        for (var i = 0; i < provider.sentRequests.length; i++) {
          final req = provider.sentRequests[i];
          debugPrint('🔍 [INTEREST_TAB] Request $i: ${req.toString()}');
          debugPrint('🔍 [INTEREST_TAB] Request $i status: ${req['status']}');
          debugPrint('🔍 [INTEREST_TAB] Request $i type: ${req['type']}');
        }

        final pendingRequests = provider.sentRequests.where((request) {
          final status = request['status'] as String?;
          debugPrint(
            '🔍 [INTEREST_TAB] Checking status: $status == pending? ${status == 'pending'}',
          );
          return status == 'pending';
        }).toList();

        debugPrint(
          '🔍 [INTEREST_TAB] Filtered pending requests: ${pendingRequests.length}',
        );

        if (pendingRequests.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadSentRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              final toUser = request['toUser'] as Map<String, dynamic>?;
              final username = toUser?['username'] as String?;
              final type = request['type'] as String? ?? 'connection';

              return InterestCard(
                request: request,
                isLoading: provider.isCancellingRequest(username ?? ''),
                onCancel: () {
                  if (username == null) return;

                  if (type == 'connection') {
                    provider.cancelConnectionRequest(username);
                  } else if (type == 'photo') {
                    provider.cancelPhotoAccessRequest(username);
                  } else if (type == 'details') {
                    provider.cancelDetailsAccessRequest(username);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No sent interests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Go to feed to find matches!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
