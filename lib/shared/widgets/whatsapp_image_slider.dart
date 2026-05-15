import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'whatsapp_full_screen_viewer.dart';

class WhatsAppImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final bool isMe;

  const WhatsAppImageSlider({
    super.key,
    required this.imageUrls,
    required this.isMe,
  });

  @override
  State<WhatsAppImageSlider> createState() => _WhatsAppImageSliderState();
}

class _WhatsAppImageSliderState extends State<WhatsAppImageSlider> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WhatsAppFullScreenViewer(
          imageUrls: widget.imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.70;

    final double height = 250.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,

            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openFullScreen(index),
                child: Hero(
                  tag: widget.imageUrls[index],
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              );
            },
          ),

          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.imageUrls.length,
                  effect: const ScrollingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white54,
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotScale: 1.5,
                    spacing: 8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
