import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum WzToastType { normal, success, error }

class WzToastDebugButton extends StatelessWidget {
  const WzToastDebugButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Positioned(
      bottom: 100,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: const Color(0xFFEF2F55),
        onPressed: () => _showToastMenu(context),
        child: const Icon(Icons.notifications, color: Colors.white, size: 20),
      ),
    );
  }

  void _showToastMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Toast Simulator',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Test both WzToast and ToastService implementations',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            const Text(
              'WzToast (Original)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildWzToastButton(
              context,
              'Normal Toast',
              'This is a normal WzToast message',
              WzToastType.normal,
              Colors.grey,
            ),
            const SizedBox(height: 8),
            _buildWzToastButton(
              context,
              'Success Toast',
              'Profile saved successfully!',
              WzToastType.success,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildWzToastButton(
              context,
              'Error Toast',
              'Failed to update profile',
              WzToastType.error,
              Colors.red,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            const Text(
              'ToastService (New)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildToastServiceButton(
              context,
              'General Message',
              'This is a ToastService general message',
              'show',
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildToastServiceButton(
              context,
              'Success Message',
              'ToastService success message!',
              'success',
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildToastServiceButton(
              context,
              'Error Message',
              'ToastService error message',
              'error',
              Colors.red,
            ),
            const SizedBox(height: 8),
            _buildToastServiceButton(
              context,
              'Long Message',
              'This is a very long ToastService message to test how it handles multiple lines of text and overflow behavior',
              'show',
              Colors.orange,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWzToastButton(
    BuildContext context,
    String label,
    String message,
    WzToastType type,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        WzToast.show(context, message: message, type: type);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildToastServiceButton(
    BuildContext context,
    String label,
    String message,
    String method,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        switch (method) {
          case 'success':
            WzToast.show(context, message: message, type: WzToastType.success);
            break;
          case 'error':
            WzToast.show(context, message: message, type: WzToastType.error);
            break;
          case 'show':
          default:
            WzToast.show(context, message: message, type: WzToastType.normal);
            break;
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flash_on, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class WzToast {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
    WzToastType type = WzToastType.normal,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) {
      debugPrint('[WzToast] Context not mounted, skipping toast');
      return;
    }

    _showWithRetry(context, message, type, duration, 0);
  }

  static void _showWithRetry(
    BuildContext context,
    String message,
    WzToastType type,
    Duration duration,
    int retryCount,
  ) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      if (retryCount < 3) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            _showWithRetry(context, message, type, duration, retryCount + 1);
          }
        });
        return;
      } else {
        debugPrint(
          '[WzToast] No overlay found after retries, skipping toast: $message',
        );
        return;
      }
    }

    _currentToast?.remove();
    _currentToast = null;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _WzToastWidget(
        message: message,
        type: type,
        onDismiss: () {
          overlayEntry.remove();
          _currentToast = null;
        },
      ),
    );

    _currentToast = overlayEntry;
    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (_currentToast == overlayEntry) {
        overlayEntry.remove();
        _currentToast = null;
      }
    });
  }
}

class _WzToastWidget extends StatefulWidget {
  final String message;
  final WzToastType type;
  final VoidCallback onDismiss;

  const _WzToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_WzToastWidget> createState() => _WzToastWidgetState();
}

class _WzToastWidgetState extends State<_WzToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case WzToastType.success:
        return const Color(0xFF10B981).withValues(alpha: 0.95);
      case WzToastType.error:
        return const Color(0xFFFFF7F9);
      case WzToastType.normal:
        return const Color(0xFFFFF7F9);
    }
  }

  Color get _borderColor {
    switch (widget.type) {
      case WzToastType.success:
        return const Color(0xFF10B981);
      case WzToastType.error:
        return const Color(0xFFFBC3CF);
      case WzToastType.normal:
        return const Color(0xFFFBC3CF);
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case WzToastType.success:
        return Colors.white;
      case WzToastType.error:
        return const Color(0xFFEF2F55);
      case WzToastType.normal:
        return Colors.black;
    }
  }

  IconData? get _icon {
    switch (widget.type) {
      case WzToastType.success:
        return Icons.check_circle;
      case WzToastType.error:
        return Icons.error;
      case WzToastType.normal:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  border: Border.all(color: _borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_icon != null) ...[
                      Icon(_icon, color: _textColor, size: 22),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textColor,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
