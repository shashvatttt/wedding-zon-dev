import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/theme/wz_colors.dart';

class WzLoading extends StatelessWidget {
  final double size;
  final Color? color;
  final SpinKitType type;

  const WzLoading({
    super.key,
    this.size = 50.0,
    this.color,
    this.type = SpinKitType.circle,
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? WzColors.primary;

    switch (type) {
      case SpinKitType.circle:
        return SpinKitCircle(color: loadingColor, size: size);
      case SpinKitType.fadingCircle:
        return SpinKitFadingCircle(color: loadingColor, size: size);
      case SpinKitType.wave:
        return SpinKitWave(color: loadingColor, size: size);
      case SpinKitType.threeBounce:
        return SpinKitThreeBounce(color: loadingColor, size: size);
      case SpinKitType.doubleBounce:
        return SpinKitDoubleBounce(color: loadingColor, size: size);
      case SpinKitType.pulse:
        return SpinKitPulse(color: loadingColor, size: size);
      case SpinKitType.ring:
        return SpinKitRing(color: loadingColor, size: size, lineWidth: 4.0);
      case SpinKitType.ripple:
        return SpinKitRipple(color: loadingColor, size: size);
      case SpinKitType.spinningCircle:
        return SpinKitSpinningCircle(color: loadingColor, size: size);
      case SpinKitType.foldingCube:
        return SpinKitFoldingCube(color: loadingColor, size: size);
    }
  }
}

class WzLoadingSmall extends StatelessWidget {
  final Color? color;

  const WzLoadingSmall({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return WzLoading(size: 24, color: color, type: SpinKitType.threeBounce);
  }
}

class WzLoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const WzLoadingOverlay({super.key, this.message, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WzLoading(size: 60),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum SpinKitType {
  circle,
  fadingCircle,
  wave,
  threeBounce,
  doubleBounce,
  pulse,
  ring,
  ripple,
  spinningCircle,
  foldingCube,
}
