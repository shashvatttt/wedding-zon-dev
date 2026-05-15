import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/photo_model.dart';
import '../../../shared/widgets/image_viewer.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showTimestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleMeColor = const Color(0xFFFDE2E8);
    final bubbleOtherColor = const Color(0xFFEF2F55);
    final textMeColor = Colors.black;
    final textOtherColor = Colors.white;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64 : 12,
        right: isMe ? 12 : 64,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isMe ? bubbleMeColor : bubbleOtherColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              child: message.type == MessageType.image
                  ? _buildImageMessage(context)
                  : _buildTextMessage(
                      theme,
                      isMe ? textMeColor : textOtherColor,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(ThemeData theme, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        message.message,
        style: TextStyle(color: textColor, fontSize: 15, fontFamily: 'Inter'),
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    final imageUrl = message.mediaUrl ?? message.message;

    return GestureDetector(
      onTap: () {
        debugPrint('[CHAT_IMAGE] Tapped image message');
        debugPrint('[CHAT_IMAGE] URL: $imageUrl');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewer(
              photos: [
                Photo(url: imageUrl, isProfile: false, restricted: false),
              ],
              hasAccess: true,
              canSetProfile: false,
              canDelete: false,
              initialIndex: 0,
            ),
          ),
        );
      },
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: 220,
        height: 220,
        placeholder: (context, url) => Container(
          width: 220,
          height: 220,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          width: 220,
          height: 220,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';

    if (messageDate == today) {
      return time;
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday $time';
    } else {
      return '${dateTime.day}/${dateTime.month} $time';
    }
  }
}
