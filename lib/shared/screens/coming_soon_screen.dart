import 'package:flutter/material.dart';
import '../widgets/scaffold_with_background.dart';
import '../../ui_clone/widgets/wz_bottom_nav_bar.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final int? navBarIndex;

  const ComingSoonScreen({
    super.key,
    this.title = 'Coming Soon',
    this.navBarIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      bottomNavigationBar: navBarIndex != null
          ? WzBottomNavBar(currentIndex: navBarIndex!)
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/decorations.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.asset(
                  'assets/coming soon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
