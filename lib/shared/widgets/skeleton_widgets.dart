import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonWidget extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonWidget({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class FeedProfileSkeleton extends StatelessWidget {
  const FeedProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonWidget(
            height: 400,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonWidget(width: 200, height: 24),
                const SizedBox(height: 8),

                const SkeletonWidget(width: 150, height: 16),
                const SizedBox(height: 8),

                const SkeletonWidget(width: 180, height: 16),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SkeletonWidget(
                        height: 48,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SkeletonWidget(
                        height: 48,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VendorCardSkeleton extends StatelessWidget {
  const VendorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonWidget(
            height: 200,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonWidget(width: 180, height: 20),
                const SizedBox(height: 8),

                const SkeletonWidget(width: 120, height: 16),
                const SizedBox(height: 8),

                const SkeletonWidget(width: 140, height: 16),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const SkeletonWidget(width: 80, height: 16),
                    const SizedBox(width: 8),
                    const SkeletonWidget(width: 60, height: 16),
                  ],
                ),
                const SizedBox(height: 12),

                const SkeletonWidget(width: 100, height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatItemSkeleton extends StatelessWidget {
  const ChatItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SkeletonWidget(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(28),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonWidget(width: 140, height: 16),
                const SizedBox(height: 6),

                const SkeletonWidget(width: 200, height: 14),
              ],
            ),
          ),

          const SkeletonWidget(width: 40, height: 12),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final Widget skeletonItem;
  final int itemCount;
  final EdgeInsets? padding;

  const SkeletonList({
    super.key,
    required this.skeletonItem,
    this.itemCount = 3,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) => skeletonItem,
    );
  }
}
