import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/models/message_model.dart';
import '../../../../shared/widgets/whatsapp_full_screen_viewer.dart';

class GroupedImageMessageBubble extends StatelessWidget {
  final List<Message> messages;
  final bool isMe;
  final bool showTimestamp;

  const GroupedImageMessageBubble({
    super.key,
    required this.messages,
    required this.isMe,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final bubbleMeColor = const Color(0xFFFDE2E8);
    final bubbleOtherColor = const Color(0xFFEF2F55);

    final imageUrls = messages
        .map((m) => m.mediaUrl)
        .where((url) => url != null && url.isNotEmpty)
        .map((url) => url!)
        .toList();

    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final lastMessage = messages.last;

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
          if (imageUrls.length == 1)
            _buildSingleImage(
              context,
              imageUrls[0],
              0,
              imageUrls,
              bubbleMeColor,
              bubbleOtherColor,
            )
          else if (imageUrls.length == 2)
            _buildTwoImages(context, imageUrls, bubbleMeColor, bubbleOtherColor)
          else if (imageUrls.length == 3)
            _buildThreeImages(
              context,
              imageUrls,
              bubbleMeColor,
              bubbleOtherColor,
            )
          else
            _buildMultipleImages(
              context,
              imageUrls,
              bubbleMeColor,
              bubbleOtherColor,
            ),
        ],
      ),
    );
  }

  Widget _buildSingleImage(
    BuildContext context,
    String imageUrl,
    int index,
    List<String> allUrls,
    Color bubbleMeColor,
    Color bubbleOtherColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isMe ? bubbleMeColor : bubbleOtherColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMe ? 12 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _openFullScreen(context, allUrls, index),
          child: Hero(
            tag: imageUrl,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoImages(
    BuildContext context,
    List<String> imageUrls,
    Color bubbleMeColor,
    Color bubbleOtherColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isMe ? bubbleMeColor : bubbleOtherColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMe ? 12 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      child: Row(
        children: [
          Expanded(child: _buildImageTile(context, imageUrls[0], 0, imageUrls)),
          const SizedBox(width: 4),
          Expanded(child: _buildImageTile(context, imageUrls[1], 1, imageUrls)),
        ],
      ),
    );
  }

  Widget _buildThreeImages(
    BuildContext context,
    List<String> imageUrls,
    Color bubbleMeColor,
    Color bubbleOtherColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isMe ? bubbleMeColor : bubbleOtherColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMe ? 12 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      child: Column(
        children: [
          _buildImageTile(context, imageUrls[0], 0, imageUrls, height: 150),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildImageTile(
                  context,
                  imageUrls[1],
                  1,
                  imageUrls,
                  height: 100,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildImageTile(
                  context,
                  imageUrls[2],
                  2,
                  imageUrls,
                  height: 100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleImages(
    BuildContext context,
    List<String> imageUrls,
    Color bubbleMeColor,
    Color bubbleOtherColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isMe ? bubbleMeColor : bubbleOtherColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMe ? 12 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildImageTile(
                  context,
                  imageUrls[0],
                  0,
                  imageUrls,
                  height: 100,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildImageTile(
                  context,
                  imageUrls[1],
                  1,
                  imageUrls,
                  height: 100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildImageTile(
                  context,
                  imageUrls[2],
                  2,
                  imageUrls,
                  height: 100,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildImageTile(
                  context,
                  imageUrls[3],
                  3,
                  imageUrls,
                  height: 100,
                  showOverlay: imageUrls.length > 4,
                  overlayCount: imageUrls.length - 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(
    BuildContext context,
    String imageUrl,
    int index,
    List<String> allUrls, {
    double? height,
    bool showOverlay = false,
    int overlayCount = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        onTap: () => _openFullScreen(context, allUrls, index),
        child: Stack(
          children: [
            Hero(
              tag: imageUrl,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: height ?? 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: height ?? 120,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: height ?? 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 30),
                ),
              ),
            ),
            if (showOverlay && overlayCount > 0)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Text(
                      '+$overlayCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openFullScreen(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WhatsAppFullScreenViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
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
