import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/feed/providers/feed_provider.dart';
import '../../core/services/deep_link_service.dart';
import 'package:weddingzon/core/routes/app_routes.dart';

class SplashScreenUI extends StatefulWidget {
  const SplashScreenUI({super.key});

  @override
  State<SplashScreenUI> createState() => _SplashScreenUIState();
}

class _SplashScreenUIState extends State<SplashScreenUI> {
  bool _showMatrimonyOptions = false;
  bool _showFranchiseOptions = false;
  bool _showVendorOptions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
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
    if (mounted) {
      await deepLinkService.initialize(isAuthenticated: isAuthenticated);
    } else {
      return;
    }

    deepLinkService.updateAuthStatus(authProvider.isAuthenticated);

    if (authProvider.isAuthenticated) {
      if (mounted) {
        final feedProvider = context.read<FeedProvider>();
        feedProvider.loadFeed();
      }
    }

    // Handled deep-link for authenticated users: skip splash, go straight to profile
    if (authProvider.isAuthenticated &&
        deepLinkService.pendingUsername != null) {
      debugPrint('[SPLASH] Authenticated + deep link → routing directly');
      if (!mounted) return;
      authProvider.routeCurrentUser();
      return;
    }

    debugPrint('[SPLASH] Initialization complete. Waiting for user interaction.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: (_showMatrimonyOptions || _showFranchiseOptions || _showVendorOptions)
            ? const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/landing/hero_mobile.png'),
                  fit: BoxFit.cover,
                  opacity: 0.6,
                ),
              )
            : null,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_showMatrimonyOptions && !_showFranchiseOptions && !_showVendorOptions) ...[
                      // Main Weddingzon Logo Text
                      Text(
                        "Weddingzon",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: WzColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Main flow buttons
                      _buildFlowButton(
                        context,
                        label: "Matrimony",
                        onPressed: () =>
                            setState(() => _showMatrimonyOptions = true),
                      ),
                      const SizedBox(height: 16),
                      _buildFlowButton(
                        context,
                        label: "Franchise",
                        onPressed: () =>
                            setState(() => _showFranchiseOptions = true),
                      ),
                      const SizedBox(height: 16),
                      _buildFlowButton(
                        context,
                        label: "Vendors",
                        onPressed: () =>
                            setState(() => _showVendorOptions = true),
                      ),
                      const SizedBox(height: 16),
                      _buildFlowButton(
                        context,
                        label: "Shopping",
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.shop),
                      ),
                    ] else if (_showMatrimonyOptions) ...[
                      // Matrimony Sub-menu Header
                      Text(
                        "Find Your Lifetime Partner",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "The most trusted matrimony platform helping you find the perfect match within your community and values.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Options Grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildOptionButton(
                              "Businessman", {'occupation': 'Businessman'}),
                          _buildOptionButton(
                              "MNC Job", {'occupation': 'MNC Job'}),
                          _buildOptionButton("Farmer", {'occupation': 'Farmer'}),
                          _buildOptionButton(
                              "Government Job", {'occupation': 'Government Job'}),
                          _buildOptionButton(
                              "Private Job", {'occupation': 'Private Job'}),
                          _buildOptionButton("Doctor", {'occupation': 'Doctor'}),
                          _buildOptionButton("NRI", {'occupation': 'NRI'}),
                          _buildOptionButton(
                              "Divorcee", {'marital_status': 'Divorced'}),
                          _buildOptionButton(
                              "Widowed", {'marital_status': 'Widowed'}),
                          _buildOptionButton("Other", {}),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              "SEARCH NOW",
                              () => _navigateToMatrimony({}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              "ADVANCED FILTER",
                              () => _navigateToMatrimony({}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Back Button
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showMatrimonyOptions = false),
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        label: const Text(
                          "Go Back",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ] else if (_showVendorOptions) ...[
                      // Vendor Sub-menu Header
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: "Find the Perfect\n"),
                            TextSpan(
                              text: "Wedding Vendor",
                              style: TextStyle(color: WzColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Browse over 360,000 wedding vendors — photographers, caterers, decorators and more.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Vendor Category Grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildVendorCategoryButton(
                              Icons.camera_alt, "Photography", "Photography"),
                          _buildVendorCategoryButton(
                              Icons.location_city, "Venues", "Venue"),
                          _buildVendorCategoryButton(
                              Icons.restaurant, "Catering", "Catering"),
                          _buildVendorCategoryButton(
                              Icons.face, "Makeup Artist", "Makeup Artist"),
                          _buildVendorCategoryButton(
                              Icons.celebration, "Decorator", "Decorator"),
                          _buildVendorCategoryButton(
                              Icons.music_note, "Music/DJ", "Music"),
                          _buildVendorCategoryButton(
                              Icons.checkroom, "Fashion", "Clothing"),
                          _buildVendorCategoryButton(
                              Icons.diamond, "Jewellery", "Jewelry"),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Search Now button
                      SizedBox(
                        width: double.infinity,
                        child: _buildActionButton(
                          "SEARCH ALL VENDORS",
                          () => _navigateToVendors(null),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Back Button
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showVendorOptions = false),
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        label: const Text(
                          "Go Back",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ] else if (_showFranchiseOptions) ...[
                      // Franchise Sub-menu Header
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: "Manage Your "),
                            TextSpan(
                              text: "Business",
                              style: TextStyle(color: WzColors.primary),
                            ),
                            const TextSpan(text: "\nExpand Your "),
                            TextSpan(
                              text: "Network",
                              style: TextStyle(color: WzColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Select your portal to continue. Access your member profile or manage your franchise dashboard.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Franchise Portal Cards
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFranchiseCard(
                              title: "Login as Member",
                              description:
                                  "Access your personal profile, view matches, and manage your account.",
                              linkText: "Member Login",
                              icon: Icons.person_outline,
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.franchiseLogin),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFranchiseCard(
                              title: "Franchise Admin",
                              description:
                                  "Manage your franchise, add members, view analytics, and control settings.",
                              linkText: "Admin Panel",
                              icon: Icons.grid_view_rounded,
                              isPrimary: true,
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.franchiseAdminLogin),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Back Button
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showFranchiseOptions = false),
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        label: const Text(
                          "Go Back",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToMatrimony(Map<String, dynamic> filters) {
    Navigator.pushNamed(context, AppRoutes.home, arguments: filters);
  }

  void _navigateToVendors(String? category) {
    if (category != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.vendors,
        arguments: {'initialCategory': category},
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.vendors);
    }
  }

  Widget _buildVendorCategoryButton(
      IconData icon, String label, String categoryKey) {
    return GestureDetector(
      onTap: () => _navigateToVendors(categoryKey),
      child: Container(
        width: (MediaQuery.of(context).size.width - 80) / 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: WzColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: WzColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 12, color: WzColors.primary.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: WzColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildOptionButton(String label, Map<String, dynamic> filters) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      child: ElevatedButton(
        onPressed: () => _navigateToMatrimony(filters),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: WzColors.primary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: WzColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildFranchiseCard({
    required String title,
    required String description,
    required String linkText,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 280, // Fixed height to match cards
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? WzColors.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: isPrimary
              ? Border.all(color: WzColors.primary.withOpacity(0.1), width: 1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary
                    ? WzColors.primary.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isPrimary ? WzColors.primary : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  linkText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: WzColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: WzColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
