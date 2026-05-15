import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../feed/providers/feed_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/deep_link_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final startTime = DateTime.now();
    final authProvider = context.read<AuthProvider>();
    final deepLinkService = context.read<DeepLinkService>();

    debugPrint('[SPLASH] ========================================');
    debugPrint('[SPLASH] SPLASH SCREEN INITIALIZATION');
    debugPrint('[SPLASH] ========================================');

    debugPrint('[SPLASH] Step 1: Checking auth status...');
    await authProvider.checkAuthStatus(autoRoute: false);
    final isAuthenticated = authProvider.isAuthenticated;
    debugPrint(
      '[SPLASH] Auth check complete: isAuthenticated = $isAuthenticated',
    );

    debugPrint('[SPLASH] Step 2: Initializing deep link service...');
    debugPrint(
      '[SPLASH] Passing isAuthenticated = $isAuthenticated to deep link service',
    );
    if (mounted) {
      await deepLinkService.initialize(isAuthenticated: isAuthenticated);
      debugPrint(
        '[SPLASH] Deep link service initialized with correct auth status',
      );
    } else {
      debugPrint('[SPLASH] ⚠️ Widget not mounted, skipping deep link init');
      return;
    }

    deepLinkService.updateAuthStatus(authProvider.isAuthenticated);

    if (authProvider.isAuthenticated) {
      debugPrint('[SPLASH] ========================================');
      debugPrint('[SPLASH] USER IS AUTHENTICATED');
      debugPrint(
        '[SPLASH] Pending deep link: ${deepLinkService.pendingUsername}',
      );
      debugPrint('[SPLASH] ========================================');

      if (mounted) {
        final feedProvider = context.read<FeedProvider>();
        feedProvider.loadFeed();
      }

      final elapsed = DateTime.now().difference(startTime);
      final minDuration = const Duration(seconds: 2);
      final remaining = minDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      if (!mounted) return;

      debugPrint(
        '[SPLASH] Routing user (will handle pending deep link if present)',
      );
      authProvider.routeCurrentUser();
    } else {
      debugPrint('[SPLASH] ========================================');
      debugPrint('[SPLASH] USER NOT AUTHENTICATED');
      debugPrint(
        '[SPLASH] Pending deep link: ${deepLinkService.pendingUsername}',
      );
      debugPrint('[SPLASH] ========================================');

      if (deepLinkService.pendingUsername != null) {
        debugPrint('[SPLASH] ⚠️ Deep link detected but user not authenticated');
        debugPrint('[SPLASH] Will navigate to auth screen');
        debugPrint(
          '[SPLASH] After login, will auto-navigate to: ${deepLinkService.pendingUsername}',
        );
      }

      final elapsed = DateTime.now().difference(startTime);
      final minDuration = const Duration(seconds: 2);
      final remaining = minDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      if (!mounted) return;
      debugPrint('[SPLASH] Routing to Landing/Auth screen');
      Navigator.pushReplacementNamed(context, AppRoutes.landing);
    }

    debugPrint('[SPLASH] ========================================');
    debugPrint('[SPLASH] SPLASH INITIALIZATION COMPLETE');
    debugPrint('[SPLASH] ========================================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100, style: FlutterLogoStyle.markOnly),
            const SizedBox(height: 24),
            Text(
              'WeddingZon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
