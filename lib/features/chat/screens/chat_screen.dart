import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/theme/wz_colors.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

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
    context.read<ChatProvider>().closeChat();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.conversation.displayName;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: WzColors.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.conversation.profilePhoto != null
                  ? NetworkImage(widget.conversation.profilePhoto!)
                  : null,
              child: widget.conversation.profilePhoto == null
                  ? Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 16),
                    )
                  : null,
            ),
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
                    ),
                  ),
                  Consumer<ChatProvider>(
                    builder: (context, provider, _) {
                      if (provider.isOtherUserTyping) {
                        return const Text(
                          'typing...',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet\nStart the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: false,
                  itemCount:
                      provider.messages.length +
                      (provider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0 && provider.isLoadingMore) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final messageIndex = provider.isLoadingMore
                        ? index - 1
                        : index;
                    final message = provider.messages[messageIndex];
                    final isMe = message.senderId == provider.myUserId;

                    return MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),

          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return MessageInput(
                onSendMessage: (message) {
                  provider.sendMessage(widget.conversation.userId, message);
                  _scrollToBottom();
                },
                onSendImages: (files) async {
                  await provider.sendImages(widget.conversation.userId, files);
                  _scrollToBottom();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
