import 'package:flutter/material.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import '../../core/theme/wz_spacing.dart';

class WzProfileCard extends StatefulWidget {
  final String fullName;
  final int? age;
  final String? location;
  final String? occupation;
  final String? religion;
  final String? aboutMe;
  final List<String> photoUrls;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final bool readOnly;

  const WzProfileCard({
    super.key,
    required this.fullName,
    this.age,
    this.location,
    this.occupation,
    this.religion,
    this.aboutMe,
    this.photoUrls = const [],
    this.onTap,
    this.onShare,
    this.readOnly = false,
  });

  @override
  State<WzProfileCard> createState() => _WzProfileCardState();
}

class _WzProfileCardState extends State<WzProfileCard> {
  final PageController _photoController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoCarousel(),
            Padding(
              padding: const EdgeInsets.all(WzSpacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameAndAge(),
                  const SizedBox(height: WzSpacing.space8),
                  if (widget.location != null) _buildLocation(),
                  if (widget.location != null)
                    const SizedBox(height: WzSpacing.space8),
                  if (widget.occupation != null) _buildOccupation(),
                  if (widget.occupation != null)
                    const SizedBox(height: WzSpacing.space8),
                  if (widget.religion != null) _buildReligion(),
                  if (widget.religion != null)
                    const SizedBox(height: WzSpacing.space12),
                  if (widget.aboutMe != null) _buildAboutMe(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCarousel() {
    if (widget.photoUrls.isEmpty) {
      return _buildPlaceholderPhoto();
    }

    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          PageView.builder(
            controller: _photoController,
            itemCount: widget.photoUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPhotoIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  widget.photoUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: WzColors.surface,
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 64,
                          color: WzColors.muted,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          if (widget.onShare != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: WzColors.white),
                  onPressed: widget.onShare,
                  tooltip: 'Share Profile',
                ),
              ),
            ),

          if (widget.photoUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.photoUrls.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: WzSpacing.space4,
                      ),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPhotoIndex == index
                            ? WzColors.white
                            : WzColors.white.withOpacity(0.54),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        height: 400,
        color: WzColors.surface,
        child: const Center(
          child: Icon(Icons.person, size: 100, color: WzColors.muted),
        ),
      ),
    );
  }

  Widget _buildNameAndAge() {
    return Row(
      children: [
        Expanded(child: Text(widget.fullName, style: WzTextStyles.heading2)),
        if (widget.age != null)
          Text('${widget.age}', style: WzTextStyles.heading3),
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: WzColors.muted),
        const SizedBox(width: WzSpacing.space4),
        Text(
          widget.location!,
          style: WzTextStyles.body2.copyWith(color: WzColors.muted),
        ),
      ],
    );
  }

  Widget _buildOccupation() {
    return Row(
      children: [
        const Icon(Icons.work, size: 16, color: WzColors.muted),
        const SizedBox(width: WzSpacing.space4),
        Text(
          widget.occupation!,
          style: WzTextStyles.body2.copyWith(color: WzColors.muted),
        ),
      ],
    );
  }

  Widget _buildReligion() {
    return Row(
      children: [
        const Icon(Icons.church, size: 16, color: WzColors.muted),
        const SizedBox(width: WzSpacing.space4),
        Text(
          widget.religion!,
          style: WzTextStyles.body2.copyWith(color: WzColors.muted),
        ),
      ],
    );
  }

  Widget _buildAboutMe() {
    return Text(
      widget.aboutMe!,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: WzTextStyles.body2,
    );
  }
}

class WzUserCard extends StatelessWidget {
  final String fullName;
  final int? age;
  final String? location;
  final String? aboutMe;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final bool showChevron;

  const WzUserCard({
    super.key,
    required this.fullName,
    this.age,
    this.location,
    this.aboutMe,
    this.avatarUrl,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: WzSpacing.space16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(WzSpacing.space16),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: WzSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: WzTextStyles.heading4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: WzSpacing.space4),
                    if (age != null || location != null) _buildMetadata(),
                    if (aboutMe != null) ...[
                      const SizedBox(height: WzSpacing.space8),
                      Text(
                        aboutMe!,
                        style: WzTextStyles.body2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron)
                const Icon(Icons.chevron_right, color: WzColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: WzColors.surface,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
              style: WzTextStyles.heading2.copyWith(color: WzColors.muted),
            )
          : null,
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        if (age != null) ...[
          const Icon(Icons.cake, size: 16, color: WzColors.muted),
          const SizedBox(width: WzSpacing.space4),
          Text(
            '$age years',
            style: WzTextStyles.body2.copyWith(color: WzColors.muted),
          ),
        ],
        if (age != null && location != null)
          Text(
            ' • ',
            style: WzTextStyles.body2.copyWith(color: WzColors.muted),
          ),
        if (location != null) ...[
          const Icon(Icons.location_on, size: 16, color: WzColors.muted),
          const SizedBox(width: WzSpacing.space4),
          Flexible(
            child: Text(
              location!,
              style: WzTextStyles.body2.copyWith(color: WzColors.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class WzNotificationCard extends StatelessWidget {
  final String name;
  final String action;
  final String typeText;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const WzNotificationCard({
    super.key,
    required this.name,
    required this.action,
    required this.typeText,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: WzSpacing.space12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: WzColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(WzSpacing.space16),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: WzSpacing.space16),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: WzTextStyles.body2.copyWith(
                      color: WzColors.text,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: action),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: typeText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, size: 20, color: WzColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: WzColors.surface,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: WzTextStyles.body1.copyWith(
                color: WzColors.text,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
    );
  }
}

class WzRequestCard extends StatelessWidget {
  final String displayName;
  final String occupation;
  final String requestType;
  final String? avatarUrl;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isLoading;

  const WzRequestCard({
    super.key,
    required this.displayName,
    required this.occupation,
    required this.requestType,
    this.avatarUrl,
    required this.onAccept,
    required this.onReject,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: WzSpacing.space12),
      decoration: BoxDecoration(
        color: WzColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WzColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(WzSpacing.space12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            const SizedBox(width: WzSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeBadge(),
                  const SizedBox(height: WzSpacing.space4),
                  Text(
                    displayName,
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: WzColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    occupation,
                    style: WzTextStyles.caption.copyWith(color: WzColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: WzSpacing.space8),
            Column(
              children: [
                _buildAcceptButton(),
                const SizedBox(height: WzSpacing.space8),
                _buildRejectButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: WzColors.surface,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: WzTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
                color: WzColors.muted,
              ),
            )
          : null,
    );
  }

  Widget _buildTypeBadge() {
    Color bgColor;
    Color textColor;
    String text;

    switch (requestType.toLowerCase()) {
      case 'connection':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFE91E63);
        text = 'Connection';
        break;
      case 'photo':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF2196F3);
        text = 'Photo Access';
        break;
      case 'details':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF2196F3);
        text = 'Details Access';
        break;
      default:
        bgColor = WzColors.surface;
        textColor = WzColors.muted;
        text = 'Request';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WzSpacing.space8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: WzTextStyles.small.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAcceptButton() {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: isLoading ? null : onAccept,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: WzColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: WzSpacing.space16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 16),
            const SizedBox(width: WzSpacing.space4),
            Text(
              'Accept',
              style: WzTextStyles.small.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectButton() {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: isLoading ? null : onReject,
        style: OutlinedButton.styleFrom(
          foregroundColor: WzColors.muted,
          backgroundColor: WzColors.white,
          side: const BorderSide(color: WzColors.border),
          padding: const EdgeInsets.symmetric(horizontal: WzSpacing.space16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close, size: 16),
            const SizedBox(width: WzSpacing.space4),
            Text(
              'Reject',
              style: WzTextStyles.small.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class WzConversationTile extends StatelessWidget {
  final String displayName;
  final String? lastMessage;
  final DateTime? timestamp;
  final int unreadCount;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const WzConversationTile({
    super.key,
    required this.displayName,
    this.lastMessage,
    this.timestamp,
    this.unreadCount = 0,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: WzSpacing.space16,
        vertical: WzSpacing.space4,
      ),
      leading: _buildAvatar(),
      title: Text(
        displayName,
        style: WzTextStyles.body1.copyWith(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: lastMessage != null
          ? Text(
              lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WzTextStyles.body2.copyWith(
                color: hasUnread ? WzColors.text : WzColors.muted,
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (timestamp != null)
            Text(
              _formatTime(timestamp!),
              style: WzTextStyles.small.copyWith(
                color: hasUnread ? WzColors.primary : WzColors.muted,
              ),
            ),
          const SizedBox(height: WzSpacing.space4),
          if (hasUnread) _buildUnreadBadge(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: WzColors.surface,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: WzTextStyles.heading4.copyWith(
                color: WzColors.muted,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WzSpacing.space8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: WzColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: WzTextStyles.small.copyWith(
          color: WzColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
