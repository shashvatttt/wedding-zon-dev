import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wz_colors.dart';
import 'wz_text_styles.dart';
import 'wz_spacing.dart';

class WzTheme {
  WzTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: WzColors.primary,
        onPrimary: WzColors.white,
        secondary: WzColors.matrimony,
        onSecondary: WzColors.white,
        error: WzColors.error,
        onError: WzColors.white,
        surface: WzColors.white,
        onSurface: WzColors.text,
      ),
      scaffoldBackgroundColor: WzColors.white,

      appBarTheme: AppBarTheme(
        backgroundColor: WzColors.white,
        foregroundColor: WzColors.text,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.12),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: WzTextStyles.heading3,
        centerTitle: false,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WzColors.primary,
          foregroundColor: WzColors.white,
          textStyle: WzTextStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: WzSpacing.buttonPaddingHorizontal,
            vertical: WzSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(borderRadius: WzBorderRadius.medium),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WzColors.primary,
          textStyle: WzTextStyles.button.copyWith(color: WzColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: WzSpacing.buttonPaddingHorizontal,
            vertical: WzSpacing.buttonPaddingVertical,
          ),
          side: const BorderSide(color: WzColors.primary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: WzBorderRadius.medium),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: WzColors.primary,
          textStyle: WzTextStyles.button.copyWith(color: WzColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: WzSpacing.space16,
            vertical: WzSpacing.space8,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        fillColor: WzColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: WzSpacing.space12,
          vertical: WzSpacing.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: WzBorderRadius.medium,
          borderSide: const BorderSide(color: WzColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: WzBorderRadius.medium,
          borderSide: const BorderSide(color: WzColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: WzBorderRadius.medium,
          borderSide: const BorderSide(color: WzColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: WzBorderRadius.medium,
          borderSide: const BorderSide(color: WzColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: WzBorderRadius.medium,
          borderSide: const BorderSide(color: WzColors.error, width: 2),
        ),
        hintStyle: WzTextStyles.body1.copyWith(color: WzColors.muted),
        labelStyle: WzTextStyles.caption.copyWith(color: WzColors.text),
      ),

      cardTheme: CardThemeData(
        color: WzColors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: WzBorderRadius.large),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: WzColors.border,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: WzColors.white,
        selectedItemColor: WzColors.primary,
        unselectedItemColor: WzColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      textTheme: TextTheme(
        displayLarge: WzTextStyles.heading1,
        displayMedium: WzTextStyles.heading2,
        displaySmall: WzTextStyles.heading3,
        headlineMedium: WzTextStyles.heading4,
        bodyLarge: WzTextStyles.body1,
        bodyMedium: WzTextStyles.body2,
        bodySmall: WzTextStyles.caption,
        labelLarge: WzTextStyles.button,
        labelSmall: WzTextStyles.small,
      ),
    );
  }

  static ThemeData get uiCloneTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: WzColors.m3Primary,
        onPrimary: WzColors.m3OnPrimary,
        primaryContainer: WzColors.m3PrimaryContainer,
        onPrimaryContainer: WzColors.m3OnPrimaryContainer,
        inversePrimary: WzColors.m3InversePrimary,
        secondaryContainer: WzColors.m3SecondaryContainer,
        onSecondaryContainer: WzColors.m3OnSecondaryContainer,
        surface: WzColors.m3Surface,
        onSurface: WzColors.m3OnSurface,
        onSurfaceVariant: WzColors.m3OnSurfaceVariant,
        outlineVariant: WzColors.m3OutlineVariant,
      ),
      scaffoldBackgroundColor: WzColors.m3Surface,

      appBarTheme: AppBarTheme(
        backgroundColor: WzColors.m3Surface,
        foregroundColor: WzColors.m3OnSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: WzTextStyles.m3LabelLarge,
        centerTitle: false,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WzColors.m3Primary,
          foregroundColor: WzColors.m3OnPrimary,
          textStyle: WzTextStyles.m3LabelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: WzSpacing.space400,
            vertical: WzSpacing.space200,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: WzBorderRadius.radius200Circular,
          ),
          elevation: 2,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WzColors.m3SurfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: WzSpacing.space400,
          vertical: WzSpacing.space200,
        ),
        border: OutlineInputBorder(
          borderRadius: WzBorderRadius.radius200Circular,
          borderSide: BorderSide(color: WzColors.m3OutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: WzBorderRadius.radius200Circular,
          borderSide: BorderSide(color: WzColors.m3OutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: WzBorderRadius.radius200Circular,
          borderSide: BorderSide(color: WzColors.m3Primary, width: 2),
        ),
        hintStyle: WzTextStyles.m3BodyLarge.copyWith(
          color: WzColors.m3OnSurfaceVariant,
        ),
        labelStyle: WzTextStyles.m3LabelLarge.copyWith(
          color: WzColors.m3OnSurface,
        ),
      ),

      cardTheme: CardThemeData(
        color: WzColors.m3SurfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: WzBorderRadius.radius400Circular,
        ),
        margin: EdgeInsets.zero,
      ),

      textTheme: TextTheme(
        bodyLarge: WzTextStyles.m3BodyLarge,
        labelLarge: WzTextStyles.m3LabelLarge,
      ),
    );
  }
}
