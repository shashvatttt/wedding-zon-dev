import 'package:flutter/material.dart';

class WzButtonStyles {
  WzButtonStyles._();

  static ButtonStyle primaryButton({double? width, double? height}) {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFEF2F55),
      foregroundColor: Colors.white,
      disabledBackgroundColor: Colors.grey[300],
      disabledForegroundColor: Colors.grey[600],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 0,
      minimumSize: width != null || height != null
          ? Size(width ?? 0, height ?? 48)
          : null,
    );
  }

  static ButtonStyle primaryButtonAuth({double? width, double? height}) {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFEF2F55),
      foregroundColor: Colors.white,
      disabledBackgroundColor: Colors.grey[300],
      disabledForegroundColor: Colors.grey[600],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 0,
      minimumSize: width != null || height != null
          ? Size(width ?? 0, height ?? 50)
          : null,
    );
  }

  static ButtonStyle secondaryButton({double? width, double? height}) {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFFEF2F55),
      disabledForegroundColor: Colors.grey[400],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      minimumSize: width != null || height != null
          ? Size(width ?? 0, height ?? 48)
          : null,
    );
  }

  static ButtonStyle secondaryButtonAuth({double? width, double? height}) {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFFEF2F55),
      disabledForegroundColor: Colors.grey[400],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      minimumSize: width != null || height != null
          ? Size(width ?? 0, height ?? 50)
          : null,
    );
  }

  static ButtonStyle textButton() {
    return TextButton.styleFrom(
      foregroundColor: const Color(0xFFEF2F55),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static BoxDecoration chipSelected() {
    return BoxDecoration(
      color: const Color(0xFFEF2F55),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEF2F55), width: 1.5),
    );
  }

  static BoxDecoration chipUnselected() {
    return BoxDecoration(
      color: const Color(0xFFFFF7F9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFBC3CF), width: 1.5),
    );
  }

  static TextStyle chipTextSelected() {
    return const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFFFFFFFF),
      height: 1.4,
    );
  }

  static TextStyle chipTextUnselected() {
    return const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF000000),
      height: 1.4,
    );
  }

  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontFamily: 'Inter', color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF2F55), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  static InputDecoration inputDecorationAuth({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontFamily: 'Inter', color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF2F55), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
