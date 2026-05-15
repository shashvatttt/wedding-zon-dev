import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../notifications/providers/notifications_provider.dart';
import 'notifications_tab.dart';

class ConnectionsScreen extends StatefulWidget {
  final int initialIndex;

  const ConnectionsScreen({super.key, this.initialIndex = 0});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const NotificationsTab(),
    );
  }
}
