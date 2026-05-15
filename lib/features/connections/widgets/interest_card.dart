import 'package:flutter/material.dart';

class InterestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final bool isLoading;
  final VoidCallback onCancel;

  const InterestCard({
    super.key,
    required this.request,
    required this.isLoading,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final toUser =
        request['toUser'] as Map<String, dynamic>? ??
        request['to'] as Map<String, dynamic>? ??
        request['receiver'] as Map<String, dynamic>? ??
        {};

    final username = toUser['username'] as String? ?? 'Unknown';
    final firstName = toUser['first_name'] ?? toUser['firstName'] ?? 'Unknown';
    final lastName = toUser['last_name'] ?? toUser['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final profilePhoto =
        toUser['profilePhoto'] ?? toUser['profile_photo'] as String?;
    final requestType = request['type'] as String? ?? 'connection';

    String requestLabel;
    IconData requestIcon;
    Color iconColor;

    switch (requestType) {
      case 'photo':
        requestLabel = 'Photo Access Request';
        requestIcon = Icons.photo_library;
        iconColor = Colors.blue;
        break;
      case 'details':
        requestLabel = 'Details Access Request';
        requestIcon = Icons.description;
        iconColor = Colors.purple;
        break;
      default:
        requestLabel = 'Connection Request';
        requestIcon = Icons.favorite;
        iconColor = const Color(0xFFEF2F55);
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              backgroundImage: profilePhoto != null
                  ? NetworkImage(profilePhoto)
                  : null,
              child: profilePhoto == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isNotEmpty ? fullName : username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(requestIcon, size: 14, color: iconColor),
                      const SizedBox(width: 4),
                      Text(
                        requestLabel,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: isLoading ? null : onCancel,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
