import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';
import '../widgets/conversation_tile.dart';
import '../../../core/theme/wz_colors.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: WzColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with customers',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadConversations(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = provider.conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: conversation,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
