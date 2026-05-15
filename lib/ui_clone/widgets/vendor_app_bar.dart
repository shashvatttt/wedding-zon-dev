import 'package:flutter/material.dart';

class VendorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String topText;
  final String mainText;
  final String locationText;
  final VoidCallback? onWalletTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLocationTap;
  final bool showWallet;
  final bool showProfile;
  final bool showLocation;
  final double opacity;

  const VendorAppBar({
    super.key,
    this.topText = 'Service ready in',
    this.mainText = '21 minutes',
    this.locationText = 'Select Location',
    this.onWalletTap,
    this.onProfileTap,
    this.onLocationTap,
    this.showWallet = true,
    this.showProfile = true,
    this.showLocation = true,
    this.opacity = 1.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(showLocation ? 160 : 130);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEF2F55),
              Color(0xFFFF6B8A),
              Color(0xFFFFB3C6),
              Color(0xFFFFF0F4),
              Color(0xFFF8F9FB),
            ],
            stops: [0.0, 0.35, 0.60, 0.80, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topText,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            mainText,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (showWallet) ...[
                          _WalletChip(onTap: onWalletTap),
                          const SizedBox(width: 10),
                        ],
                        if (showProfile) _ProfileChip(onTap: onProfileTap),
                      ],
                    ),
                  ],
                ),
                if (showLocation) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onLocationTap,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            locationText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletChip extends StatelessWidget {
  final VoidCallback? onTap;

  const _WalletChip({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33EF2F55),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          color: Color(0xFFEF2F55),
          size: 22,
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final VoidCallback? onTap;

  const _ProfileChip({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33EF2F55),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.person_outline,
          color: Color(0xFFEF2F55),
          size: 22,
        ),
      ),
    );
  }
}
