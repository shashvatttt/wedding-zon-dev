import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/routes/app_routes.dart';
import '../../features/chat/provider/chat_provider.dart';
import '../../features/chat/widgets/message_bubble.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/message_model.dart';
import '../../features/chat/widgets/grouped_image_message_bubble.dart';
import '../../shared/widgets/wz_loading.dart';
import '../../shared/widgets/wz_toast.dart';

class ChatConversationScreenUI extends StatefulWidget {
  const ChatConversationScreenUI({super.key});

  @override
  State<ChatConversationScreenUI> createState() =>
      _ChatConversationScreenUIState();
}

class _ChatConversationScreenUIState extends State<ChatConversationScreenUI> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  ChatProvider? _chatProvider;
  bool _hasText = false;

  late String userId;
  late String username;
  String? firstName;
  String? lastName;
  String? profilePhoto;
  bool isVendor = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint(
      '📍 [SCREEN] ========== CHAT CONVERSATION SCREEN ========== [ROUTE: ${AppRoutes.uiChatConversation}]',
    );
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      userId = args['userId'] ?? '';
      username = args['username'] ?? '';
      firstName = args['firstName'];
      lastName = args['lastName'];
      profilePhoto = args['profilePhoto'];
      isVendor = args['isVendor'] ?? false;

      _initChat();
    }
  }

  void _initChat() {
    if (_chatProvider != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      _chatProvider = provider;
      final displayName = _getDisplayName();

      provider.openChat(
        userId,
        username: displayName,
        profilePhoto: profilePhoto,
      );

      _scrollController.addListener(_onScroll);
    });
  }

  String _getDisplayName() {
    final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return fullName.isNotEmpty ? fullName : username;
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      if (position.pixels < 100) {
        final provider = context.read<ChatProvider>();
        if (provider.hasMoreMessages && !provider.isLoadingMore) {
          provider.loadMoreMessages();
        }
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _chatProvider?.closeChat();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/ui_clone/images/backgrounds/background_pattern_1.jpg',
                    ),
                    fit: BoxFit.cover,
                    opacity: 0.1,
                  ),
                ),
              ),
            ),

            Column(
              children: [
                _buildHeader(context),

                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Consumer<ChatProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading && provider.messages.isEmpty) {
                          return const Center(child: WzLoading());
                        }

                        if (provider.messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/ui_clone/icons/ic_chat.svg',
                                  width: 64,
                                  height: 64,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black12,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.translate('no_messages'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black45,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.translate('start_conversation'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black38,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });

                        final groupedItems = _groupMessages(provider.messages);

                        return Column(
                          children: [
                            if (provider.isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: groupedItems.length,
                                itemBuilder: (context, index) {
                                  final item = groupedItems[index];

                                  final bool isMe;
                                  final DateTime createdAt;

                                  if (item is List<Message>) {
                                    isMe =
                                        item.first.senderId ==
                                        provider.myUserId;
                                    createdAt = item.last.createdAt;
                                  } else if (item is Message) {
                                    isMe = item.senderId == provider.myUserId;
                                    createdAt = item.createdAt;
                                  } else {
                                    return const SizedBox.shrink();
                                  }

                                  bool showTime = false;
                                  if (index == 0) {
                                    showTime = true;
                                  } else {
                                    final prevItem = groupedItems[index - 1];
                                    final DateTime prevCreatedAt;
                                    if (prevItem is List<Message>) {
                                      prevCreatedAt = prevItem.last.createdAt;
                                    } else {
                                      prevCreatedAt =
                                          (prevItem as Message).createdAt;
                                    }

                                    if (createdAt
                                            .difference(prevCreatedAt)
                                            .inMinutes >
                                        5) {
                                      showTime = true;
                                    }
                                  }

                                  if (item is List<Message>) {
                                    return GroupedImageMessageBubble(
                                      messages: item,
                                      isMe: isMe,
                                      showTimestamp: showTime,
                                    );
                                  } else {
                                    return MessageBubble(
                                      message: item as Message,
                                      isMe: isMe,
                                      showTimestamp: showTime,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                Consumer<ChatProvider>(
                  builder: (context, provider, _) {
                    if (provider.isOtherUserTyping) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_getDisplayName()} ${AppLocalizations.of(context)!.translate('is_typing')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 8),

                _buildCustomInput(context),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F4),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/ui_clone/icons/ic_chevron_backward.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            GestureDetector(
              onTap: () {
                if (username.isNotEmpty) {
                  if (isVendor) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.vendorProfile,
                      arguments: username,
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.userProfile,
                      arguments: username,
                    );
                  }
                }
              },
              child: ClipOval(
                child: profilePhoto != null
                    ? CachedNetworkImage(
                        imageUrl: profilePhoto!,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _buildPlaceholderAvatar(),
                      )
                    : _buildPlaceholderAvatar(),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (username.isNotEmpty) {
                    if (isVendor) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.vendorProfile,
                        arguments: username,
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.userProfile,
                        arguments: username,
                      );
                    }
                  }
                },
                child: Text(
                  _getDisplayName(),
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontVariations: [FontVariation('wdth', 100)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                if (username.isNotEmpty) {
                  if (isVendor) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.vendorProfile,
                      arguments: username,
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.userProfile,
                      arguments: username,
                    );
                  }
                }
              },
              child: SvgPicture.asset(
                'assets/ui_clone/icons/ic_info.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFEF2F55),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 8),

            PopupMenuButton<String>(
              icon: SvgPicture.asset(
                'assets/ui_clone/icons/ic_menu_dots.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFEF2F55),
                  BlendMode.srcIn,
                ),
              ),
              onSelected: (value) {
                if (value == 'report') {
                  _showReportDialog();
                } else if (value == 'block') {
                  _showBlockConfirmationDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'report',
                  child: Text(
                    AppLocalizations.of(context)!.translate('report_user_menu'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'block',
                  child: Text(
                    AppLocalizations.of(context)!.translate('block_user_menu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 45,
      height: 45,
      color: Colors.grey.shade300,
      child: const Icon(Icons.person, color: Colors.white),
    );
  }

  Widget _buildCustomInput(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),

                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        icon: SvgPicture.asset(
                          'assets/ui_clone/icons/ic_attachment.svg',
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF636363),
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () =>
                            _pickImages(provider, ImageSource.gallery),
                      ),

                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        icon: SvgPicture.asset(
                          'assets/ui_clone/icons/ic_camera.svg',
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF636363),
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () =>
                            _pickImages(provider, ImageSource.camera),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          onChanged: (val) {
                            setState(() {
                              _hasText = val.trim().isNotEmpty;
                            });
                            if (val.isNotEmpty) {
                              provider.startTyping();
                            } else {
                              provider.stopTyping();
                            }
                          },
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              provider.sendMessage(userId, val.trim());
                              _textController.clear();
                              provider.stopTyping();
                              setState(() {
                                _hasText = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.translate('type_here_hint'),
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: const Color(0xFF636363).withOpacity(0.45),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              GestureDetector(
                onTap: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    provider.sendMessage(userId, text);
                    _textController.clear();
                    provider.stopTyping();
                    setState(() {
                      _hasText = false;
                    });
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _hasText
                        ? const Color(0xFFEF2F55)
                        : const Color(0xFF6B7280),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/ui_clone/icons/ic_send.svg',
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImages(ChatProvider provider, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      List<XFile> images = [];

      if (source == ImageSource.gallery) {
        images = await picker.pickMultiImage(
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
          limit: 10,
        );
      } else {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (image != null) {
          images.add(image);
        }
      }

      if (images.isNotEmpty && mounted) {
        if (images.length > 10) {
          WzToast.show(
            context,
            message: AppLocalizations.of(
              context,
            )!.translate('max_images_error'),
            type: WzToastType.error,
          );
          images = images.take(10).toList();
        }

        final success = await provider.sendImages(
          userId,
          images.map((x) => File(x.path)).toList(),
        );

        if (!success && mounted) {
          WzToast.show(
            context,
            message: AppLocalizations.of(
              context,
            )!.translate('send_images_error'),
            type: WzToastType.error,
          );
        }
      }
    } catch (e) {
      debugPrint('[CHAT_CONV] Error picking images: $e');
    }
  }

  void _showBlockConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('block_user')),
        content: Text(AppLocalizations.of(context)!.translate('block_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (_chatProvider != null) {
                final success = await _chatProvider!.blockUser(userId);
                if (mounted) {
                  if (success) {
                    WzToast.show(
                      context,
                      message: AppLocalizations.of(
                        context,
                      )!.translate('user_blocked'),
                      type: WzToastType.success,
                    );
                    Navigator.pop(context);
                  } else {
                    WzToast.show(
                      context,
                      message: AppLocalizations.of(
                        context,
                      )!.translate('failed_block_user'),
                      type: WzToastType.error,
                    );
                  }
                }
              }
            },
            child: Text(
              AppLocalizations.of(context)!.translate('block'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    String selectedReason = 'Spam';
    final descriptionController = TextEditingController();
    final reasons = ['Spam', 'Harassment', 'Inappropriate Content', 'Other'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.translate('report_user')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.translate('reason'),
                  ),
                  items: reasons.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.translate(reason.toLowerCase().split(' ').first),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.translate('description'),
                    hintText: AppLocalizations.of(
                      context,
                    )!.translate('optional_details_hint'),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.translate('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  final reason = selectedReason;
                  final description = descriptionController.text;
                  Navigator.pop(context);

                  if (_chatProvider != null) {
                    final success = await _chatProvider!.reportUser(
                      userId,
                      reason,
                      description,
                    );

                    if (mounted) {
                      if (success) {
                        WzToast.show(
                          context,
                          message: AppLocalizations.of(
                            context,
                          )!.translate('user_reported'),
                          type: WzToastType.success,
                        );
                      } else {
                        WzToast.show(
                          context,
                          message: AppLocalizations.of(
                            context,
                          )!.translate('failed_report_user'),
                          type: WzToastType.error,
                        );
                      }
                    }
                  }
                },
                child: Text(AppLocalizations.of(context)!.translate('submit')),
              ),
            ],
          );
        },
      ),
    );
  }

  List<dynamic> _groupMessages(List<Message> messages) {
    if (messages.isEmpty) return [];

    final grouped = <dynamic>[];
    List<Message> currentImageGroup = [];

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final isImage =
          message.type == MessageType.image &&
          message.mediaUrl != null &&
          message.mediaUrl!.isNotEmpty;

      if (isImage) {
        if (currentImageGroup.isNotEmpty) {
          final lastInGroup = currentImageGroup.last;

          if (lastInGroup.senderId == message.senderId) {
            currentImageGroup.add(message);
          } else {
            grouped.add(currentImageGroup);
            currentImageGroup = [message];
          }
        } else {
          currentImageGroup = [message];
        }
      } else {
        if (currentImageGroup.isNotEmpty) {
          grouped.add(currentImageGroup);
          currentImageGroup = [];
        }

        grouped.add(message);
      }
    }

    if (currentImageGroup.isNotEmpty) {
      grouped.add(currentImageGroup);
    }

    return grouped;
  }
}
