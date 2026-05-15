import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/auth/providers/auth_provider.dart';

class HomeLandingScreenUI extends StatelessWidget {
  const HomeLandingScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // Smoothly exit the app when back is pressed on the root screen
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main Content
            CustomScrollView(
              slivers: [
                _buildModernHeroSection(context),
                _buildFeaturedVendors(context),
                _buildMatrimonyDiscovery(context),
                _buildFeaturedProfiles(context),
                _buildWhyWeddingZon(context),
                _buildTestimonials(context),
                _buildDownloadApp(context),
                const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom spacing for CTA
              ],
            ),

            // Bottom CTA
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomCTA(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeroSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 650,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Background Image (unnamed.png / hero_mobile.png)
            Positioned.fill(
              child: Image.asset(
                'assets/landing/hero_mobile.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),

            // Top Gradient for Logo Visibility
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content Container
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Weddingzon Logo Text (Matching Website Serif Style)
                    Text(
                      "Weddingzon",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: WzColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "India's leading wedding platform connecting couples with the best vendors and matrimonial matches.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF111827),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 2x2 Pillar Button Grid
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 32,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildPillarButton(
                            context,
                            'assets/landing/pillar_matrimony.png',
                            AppRoutes.feed,
                          ),
                          _buildPillarButton(
                            context,
                            'assets/landing/pillar_franchise.png',
                            AppRoutes.franchiseLogin,
                          ),
                          _buildPillarButton(
                            context,
                            'assets/landing/pillar_vendors.png',
                            AppRoutes.vendors,
                          ),
                          _buildPillarButton(
                            context,
                            'assets/landing/pillar_shopping.png',
                            AppRoutes.shop,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarButton(BuildContext context, String assetPath, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            assetPath,
            width: 140,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildCircularCategory(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String image,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 140,
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.network(image, fit: BoxFit.cover, width: double.infinity),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [color.withOpacity(0.9), color.withOpacity(0.1)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatrimonyDiscovery(BuildContext context) {
    final professions = [
      {'label': 'MNC Job', 'icon': Icons.business_rounded, 'color': Colors.indigo},
      {'label': 'Businessman', 'icon': Icons.storefront_rounded, 'color': Colors.deepOrange},
      {'label': 'NRI', 'icon': Icons.public_rounded, 'color': Colors.teal},
      {'label': 'Govt Job', 'icon': Icons.account_balance_rounded, 'color': Colors.brown},
      {'label': 'Farmer', 'icon': Icons.agriculture_rounded, 'color': Colors.lightGreen},
      {'label': 'Doctor', 'icon': Icons.medical_services_rounded, 'color': Colors.red},
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Find Matches by Profession",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: professions.length,
                itemBuilder: (context, index) {
                  final prof = professions[index];
                  return _buildCircularCategory(
                    context,
                    label: prof['label'] as String,
                    icon: prof['icon'] as IconData,
                    color: prof['color'] as Color,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.feed,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedVendors(BuildContext context) {
    final vendors = [
      {
        'name': 'Royal Orchid Venues',
        'category': 'Venue',
        'rating': '4.9',
        'price': '₹1,50,000',
        'image': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=400',
      },
      {
        'name': 'Studio Memories',
        'category': 'Photography',
        'rating': '4.8',
        'price': '₹80,000',
        'image': 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?q=80&w=400',
      },
      {
        'name': 'Blush & Bloom',
        'category': 'Makeup',
        'rating': '5.0',
        'price': '₹25,000',
        'image': 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?q=80&w=400',
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Vendors",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.vendors),
                    child: const Text("View All"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: vendors.length,
                itemBuilder: (context, index) {
                  final vendor = vendors[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            vendor['image']!,
                            height: 120,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendor['name']!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    vendor['category']!,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      Text(
                                        vendor['rating']!,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProfiles(BuildContext context) {
    final profiles = [
      {
        'name': 'Ananya S.',
        'details': '26, 5\'4", Doctor',
        'location': 'Mumbai, India',
        'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=400',
      },
      {
        'name': 'Rahul K.',
        'details': '29, 5\'11", Engineer',
        'location': 'Bangalore, India',
        'image': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=400',
      },
      {
        'name': 'Priya M.',
        'details': '24, 5\'3", Software Engineer',
        'location': 'Delhi, India',
        'image': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=400',
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Premium Matches",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.feed),
                    child: Text(
                      "View All",
                      style: TextStyle(color: WzColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return GestureDetector(
                    // Guests can tap to browse the feed; gating happens within feed on actions
                    onTap: () => Navigator.pushNamed(context, AppRoutes.feed),
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              profile['image']!,
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile['name']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile['details']!,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.grey, size: 12),
                                    Expanded(
                                      child: Text(
                                        profile['location']!,
                                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a premium bottom sheet "gate" prompting the user to log in.
  void _showLoginPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: WzColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_open_rounded, color: WzColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Join Weddingzon',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Log in or create a free account to connect with matches, send interest, and chat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.mobileLogin);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WzColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.signupChoice);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: WzColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Create Free Account',
                  style: TextStyle(color: WzColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyWeddingZon(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7F9),
        ),
        child: Stack(
          children: [
            // Background Image (Transparent overlay)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/landing/why_wz_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                    children: [
                      const TextSpan(text: "Why "),
                      TextSpan(
                        text: "Weddingzon",
                        style: TextStyle(color: WzColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Trusted by couples & vendors across India",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 48),

                // Features Grid (2x2)
                GridView.count(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildWhyCard('assets/landing/why_wz_1.png'),
                    _buildWhyCard('assets/landing/why_wz_2.png'),
                    _buildWhyCard('assets/landing/why_wz_3.png'),
                    _buildWhyCard('assets/landing/why_wz_4.png'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyCard(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTestimonials(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Text(
              "Success Stories",
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTestimonialCard(
                  "Mr. & Mrs. Kapoor",
                  "Match found on WeddingZon",
                  "Weddingzon made our wedding planning stress-free. We found amazing vendors easily.",
                  "https://images.unsplash.com/photo-1583939003579-730e3918a45a?auto=format&fit=crop&q=80&w=600&h=600",
                ),
                _buildTestimonialCard(
                  "Varuna",
                  "Makeup Artist, Chandigarh",
                  "After registering as a verified vendor, my business grew quickly. Thanks to Weddingzon.",
                  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=400&h=400",
                ),
                _buildTestimonialCard(
                  "Mr. & Mrs. Gupta",
                  "Match found on WeddingZon",
                  "Weddingzon made our wedding planning stress-free. We found amazing vendors, compared options easily.",
                  "https://images.unsplash.com/photo-1621112904887-419379ce6824?auto=format&fit=crop&q=80&w=600&h=450",
                ),
                _buildTestimonialCard(
                  "Dhanush",
                  "Mehndi Artist, Delhi",
                  "The exposure I've received through Weddingzon has been phenomenal. The leads are high quality.",
                  "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400&h=400",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(String name, String role, String text, String imageUrl) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.format_quote_rounded, color: WzColors.primary.withOpacity(0.2), size: 32),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
              Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
              Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
              Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
              Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadApp(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF5F7),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF4D3DA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Download the WeddingZon App",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your perfect wedding starts here.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              // QR Code and Store Buttons Placeholder
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Use one of the download links below",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/landing/google_play_badge.png',
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/landing/apple_store_badge.png',
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    const Text(
                      "Or get the download link on your SMS/Email",
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // iPhone Mockup
              Container(
                height: 300,
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/landing/iphone_mockup.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context) {
    final isAuthenticated = context.read<AuthProvider>().isAuthenticated;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: isAuthenticated
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WzColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.dashboard_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Go to Dashboard',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.loginChoice),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: WzColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Log In', style: TextStyle(color: WzColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signupChoice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WzColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Create Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }
}
