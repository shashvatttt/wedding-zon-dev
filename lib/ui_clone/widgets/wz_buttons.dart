import 'package:flutter/material.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import '../../core/theme/wz_spacing.dart';
import '../../core/theme/wz_button_styles.dart';
import '../../shared/widgets/wz_loading.dart';

class WzPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final bool isAuthPage;

  const WzPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.isAuthPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: isAuthPage ? 50 : 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: isAuthPage
            ? WzButtonStyles.primaryButtonAuth(width: width)
            : WzButtonStyles.primaryButton(width: width),
        child: isLoading
            ? const WzLoadingSmall(color: Colors.white)
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: WzSpacing.space8),
                  ],
                  Text(
                    text,
                    style: WzTextStyles.button.copyWith(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}

class WzSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final bool isAuthPage;

  const WzSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.isAuthPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: isAuthPage ? 50 : 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: isAuthPage
            ? WzButtonStyles.secondaryButtonAuth(width: width)
            : WzButtonStyles.secondaryButton(width: width),
        child: isLoading
            ? const WzLoadingSmall(color: Color(0xFFEF2F55))
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: WzSpacing.space8),
                  ],
                  Text(
                    text,
                    style: WzTextStyles.button.copyWith(
                      color: const Color(0xFFEF2F55),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class WzTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final bool underline;

  const WzTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textStyle,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle =
        textStyle ??
        WzTextStyles.body1.copyWith(
          color: const Color(0xFFEF2F55),
          decoration: underline ? TextDecoration.underline : null,
        );

    return TextButton(
      onPressed: onPressed,
      style: WzButtonStyles.textButton(),
      child: Text(text, style: effectiveTextStyle),
    );
  }
}

class WzIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const WzIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 64,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? WzColors.surface.withValues(alpha: 0.28),
        shape: const CircleBorder(
          side: BorderSide(color: WzColors.border, width: 1),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: iconColor ?? WzColors.iconDefault,
                size: size * 0.5,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
