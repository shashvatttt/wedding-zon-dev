import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../provider/chat_provider.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../core/models/message_model.dart';
import 'package:intl/intl.dart';

class ChatScreenNew extends StatefulWidget {
  final Conversation conversation;

  const ChatScreenNew({super.key, required this.conversation});

  @override
  State<ChatScreenNew> createState() => _ChatScreenNewState();
}

class _ChatScreenNewState extends State<ChatScreenNew> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      provider.openChat(
        widget.conversation.userId,
        username: widget.conversation.username,
        profilePhoto: widget.conversation.profilePhoto,
      );
      _scrollToBottom();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      context.read<ChatProvider>().loadMoreMessages();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    context.read<ChatProvider>().closeChat();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<ChatProvider>();
    provider.sendMessage(widget.conversation.userId, text);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.conversation.displayName;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(displayName),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: WzColors.primary),
                  );
                }

                if (provider.messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    final isMe = message.senderId == provider.myUserId;
                    final showAvatar = _shouldShowAvatar(
                      provider.messages,
                      index,
                      isMe,
                    );
                    final showTimestamp = _shouldShowTimestamp(
                      provider.messages,
                      index,
                    );

                    return _buildMessageBubble(
                      message,
                      isMe,
                      showAvatar,
                      showTimestamp,
                    );
                  },
                );
              },
            ),
          ),
          _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String displayName) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          _buildAvatar(widget.conversation.profilePhoto, displayName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Consumer<ChatProvider>(
                  builder: (context, provider, _) {
                    if (provider.isOtherUserTyping) {
                      return const Text(
                        'typing...',
                        style: TextStyle(
                          fontSize: 12,
                          color: WzColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    return const Text(
                      'Active',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAvatar(String? photoUrl, String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: WzColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: photoUrl != null
            ? CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: WzColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: WzColors.primary.withValues(alpha: 0.1),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: WzColors.primary,
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                color: WzColors.primary.withValues(alpha: 0.1),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: WzColors.primary,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (!provider.isOtherUserTyping) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _buildAvatar(
                widget.conversation.profilePhoto,
                widget.conversation.displayName,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypingDot(0),
                    const SizedBox(width: 4),
                    _buildTypingDot(1),
                    const SizedBox(width: 4),
                    _buildTypingDot(2),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        final opacity = (animValue * 2).clamp(0.3, 1.0);

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withValues(alpha: opacity),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildMessageBubble(
    Message message,
    bool isMe,
    bool showAvatar,
    bool showTimestamp,
  ) {
    return Column(
      children: [
        if (showTimestamp) _buildTimestampDivider(message.createdAt),
        Padding(
          padding: EdgeInsets.only(bottom: 4, top: showTimestamp ? 8 : 4),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && showAvatar)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildAvatar(
                    widget.conversation.profilePhoto,
                    widget.conversation.displayName,
                  ),
                )
              else if (!isMe)
                const SizedBox(width: 48),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? WzColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.mediaUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: message.mediaUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: WzColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (message.message.isNotEmpty)
                          const SizedBox(height: 8),
                      ],
                      if (message.message.isNotEmpty)
                        Text(
                          message.message,
                          style: TextStyle(
                            fontSize: 15,
                            color: isMe ? Colors.white : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: isMe
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : Colors.grey[600],
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: 16,
                              color: message.isRead
                                  ? const Color(0xFF4FC3F7)
                                  : Colors.white.withValues(alpha: 0.8),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe && showAvatar)
                const SizedBox(width: 8)
              else if (isMe)
                const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampDivider(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.grey[600]),
                onPressed: () {},
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (text) {},
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: WzColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowAvatar(List<Message> messages, int index, bool isMe) {
    if (index == messages.length - 1) return true;

    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];

    return currentMessage.senderId != nextMessage.senderId;
  }

  bool _shouldShowTimestamp(List<Message> messages, int index) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final diff = currentMessage.createdAt.difference(previousMessage.createdAt);
    return diff.inMinutes > 30;
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(timestamp);
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }
}
