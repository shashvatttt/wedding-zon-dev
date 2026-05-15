import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';

class ProfileViewScreenUI extends StatelessWidget {
  const ProfileViewScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: -75,
              top: -3,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/ui_clone/images/backgrounds/background_pattern_1.jpg',
                  width: 512,
                  height: 958,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildProfilePhoto(),
                        const SizedBox(height: 8),

                        _buildProfileInfoCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Matches',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: WzColors.text,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'As per ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Text(
                      'partner prefrences',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: WzColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.settings,
                      size: 16,
                      color: WzColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 15),
                const Icon(Icons.notifications, size: 24, color: Colors.black),
                const SizedBox(width: 32),
                const Icon(Icons.settings, size: 24, color: Colors.black),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 364,
            height: 431,
            color: Colors.grey[300],
            child: const Icon(Icons.person, size: 100, color: Colors.grey),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.grey.withOpacity(0),
                ],
              ),
            ),
            child: const Center(
              child: Text(
                'Profile managed by Parents',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      width: 364,
      height: 278,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 24,
            top: 9,
            child: Text(
              'Active Today',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: WzColors.primary,
              ),
            ),
          ),

          const Positioned(
            left: 24,
            top: 24,
            child: Text(
              'Shawty Mishra, 25',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),

          Positioned(
            left: 24,
            top: 57,
            child: Row(
              children: [
                const Text(
                  '4ft 11in   New Delhi   Bania-Rauniyar',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 20,
            top: 76,
            child: Row(
              children: [
                const Icon(Icons.work, size: 19, color: Colors.grey),
                const SizedBox(width: 2),
                const Text(
                  'Education Professional   Rs. 8-10 lakh p.a.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 20,
            top: 94,
            child: Row(
              children: [
                const Icon(Icons.school, size: 19, color: Colors.grey),
                const SizedBox(width: 2),
                const Text(
                  'MBA/PGDM, LLB',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.favorite, size: 12, color: Colors.grey),
                const SizedBox(width: 3),
                const Text(
                  'Never Married',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 47,
            bottom: 19,
            child: Container(
              width: 270,
              height: 61,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: WzColors.primarySoftBg,
                        width: 1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Transform.scale(
                        scaleY: -1,
                        child: Transform.rotate(
                          angle: 3.14159,
                          child: const Icon(
                            Icons.close,
                            size: 28,
                            color: Color(0xFFEF2F55),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFBC3CF),
                        width: 1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Transform.scale(
                        scaleY: -1,
                        child: Transform.rotate(
                          angle: 3.14159,
                          child: const Icon(
                            Icons.favorite,
                            size: 35,
                            color: Color(0xFFEF2F55),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFBC3CF),
                        width: 1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: const Icon(
                        Icons.chat_bubble,
                        size: 36,
                        color: Color(0xFFEF2F55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: WzColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18.3,
            spreadRadius: 9,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.store, 'Vendors'),
            _buildNavItem(Icons.chat_bubble, 'Chats'),
            _buildNavItem(Icons.home, 'Home'),
            _buildNavItem(Icons.shopping_bag, 'Shopping'),
            _buildNavItem(Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
