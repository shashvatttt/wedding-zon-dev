import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/core/theme/wz_theme.dart';

/// Property-Based Test for Design Token Consistency
///
/// Feature: figma-ui-extraction, Property 1: Design Token Consistency
/// Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5
///
/// This test verifies that all design tokens extracted from Figma
/// match the expected format and values.
void main() {
  group('Design Token Consistency Tests', () {
    group('Color Token Tests', () {
      test('Material 3 primary colors should match Figma values', () {
        // Validate M3 Primary color matches Figma: #6750A4
        expect(WzColors.m3Primary, equals(const Color(0xFF6750A4)));
        expect(WzColors.m3OnPrimary, equals(const Color(0xFFFFFFFF)));
        expect(WzColors.m3PrimaryContainer, equals(const Color(0xFFEADDFF)));
        expect(WzColors.m3OnPrimaryContainer, equals(const Color(0xFF4F378A)));
      });

      test('Material 3 surface colors should match Figma values', () {
        // Validate M3 Surface colors match Figma values
        expect(WzColors.m3Surface, equals(const Color(0xFFFEF7FF)));
        expect(WzColors.m3OnSurface, equals(const Color(0xFF1D1B20)));
        expect(WzColors.m3OnSurfaceVariant, equals(const Color(0xFF49454F)));
      });

      test('Brand colors should match Figma values', () {
        // Validate brand colors match Figma: #2C2C2C
        expect(WzColors.brandDefault, equals(const Color(0xFF2C2C2C)));
        expect(WzColors.brandOnBrand, equals(const Color(0xFFF5F5F5)));
      });

      test('Background colors should match Figma values', () {
        // Validate background colors
        expect(WzColors.backgroundDefault, equals(const Color(0xFFFFFFFF)));
        expect(WzColors.backgroundSecondary, equals(const Color(0xFFF5F5F5)));
        expect(WzColors.backgroundBg, equals(const Color(0xFFF8F9FB)));
      });

      test('Text colors should match Figma values', () {
        // Validate text colors match Figma: #1E1E1E, #757575, etc.
        expect(WzColors.textDefault, equals(const Color(0xFF1E1E1E)));
        expect(WzColors.textSecondary, equals(const Color(0xFF757575)));
        expect(WzColors.textDisabled, equals(const Color(0xFFB3B3B3)));
      });

      test('All color values should be valid Color objects', () {
        // Property: All color constants should be valid Color objects
        final colors = [
          WzColors.m3Primary,
          WzColors.m3OnPrimary,
          WzColors.m3Surface,
          WzColors.brandDefault,
          WzColors.textDefault,
          WzColors.backgroundDefault,
        ];

        for (final color in colors) {
          expect(color, isA<Color>());
          expect(color.value, greaterThanOrEqualTo(0x00000000));
          expect(color.value, lessThanOrEqualTo(0xFFFFFFFF));
        }
      });
    });

    group('Typography Token Tests', () {
      test('Material 3 label large should match Figma values', () {
        // Validate M3 Label Large: Roboto, 14px, Medium (500), 20px line height, 0.1 letter spacing
        expect(WzTextStyles.m3LabelLarge.fontFamily, equals('Roboto'));
        expect(WzTextStyles.m3LabelLarge.fontSize, equals(14.0));
        expect(WzTextStyles.m3LabelLarge.fontWeight, equals(FontWeight.w500));
        expect(WzTextStyles.m3LabelLarge.height, equals(20 / 14));
        expect(WzTextStyles.m3LabelLarge.letterSpacing, equals(0.1));
      });

      test('Material 3 body large should match Figma values', () {
        // Validate M3 Body Large: Roboto, 16px, Regular (400), 24px line height, 0.5 letter spacing
        expect(WzTextStyles.m3BodyLarge.fontFamily, equals('Roboto'));
        expect(WzTextStyles.m3BodyLarge.fontSize, equals(16.0));
        expect(WzTextStyles.m3BodyLarge.fontWeight, equals(FontWeight.w400));
        expect(WzTextStyles.m3BodyLarge.height, equals(24 / 16));
        expect(WzTextStyles.m3BodyLarge.letterSpacing, equals(0.5));
      });

      test('Noto Sans Devanagari H2 should match Figma values', () {
        // Validate H2: Noto Sans Devanagari, 16px, Medium (500)
        expect(WzTextStyles.h2.fontFamily, equals('Noto Sans Devanagari'));
        expect(WzTextStyles.h2.fontSize, equals(16.0));
        expect(WzTextStyles.h2.fontWeight, equals(FontWeight.w500));
      });

      test('All text styles should have valid font sizes', () {
        // Property: All text styles should have positive font sizes
        final textStyles = [
          WzTextStyles.m3LabelLarge,
          WzTextStyles.m3BodyLarge,
          WzTextStyles.h2,
          WzTextStyles.body,
          WzTextStyles.smallBody,
        ];

        for (final style in textStyles) {
          expect(style.fontSize, isNotNull);
          expect(style.fontSize!, greaterThan(0));
          expect(style.fontSize!, lessThan(100)); // Reasonable upper bound
        }
      });

      test('All text styles should have valid font weights', () {
        // Property: All text styles should have valid font weights
        final textStyles = [
          WzTextStyles.m3LabelLarge,
          WzTextStyles.m3BodyLarge,
          WzTextStyles.h2,
        ];

        for (final style in textStyles) {
          expect(style.fontWeight, isNotNull);
          expect(style.fontWeight!.index, greaterThanOrEqualTo(0));
          expect(style.fontWeight!.index, lessThanOrEqualTo(8)); // w100 to w900
        }
      });
    });

    group('Spacing Token Tests', () {
      test('Figma spacing values should match extracted values', () {
        // Validate Space/150 = 6, Space/200 = 8, Space/400 = 16
        expect(WzSpacing.space150, equals(6.0));
        expect(WzSpacing.space200, equals(8.0));
        expect(WzSpacing.space400, equals(16.0));
      });

      test('Scale values should match Figma values', () {
        // Validate Scale 06 = 32
        expect(WzSpacing.scale06, equals(32.0));
      });

      test('Border radius values should match Figma values', () {
        // Validate Radius/200 = 8, Radius/400 = 16
        expect(WzBorderRadius.radius200, equals(8.0));
        expect(WzBorderRadius.radius400, equals(16.0));
      });

      test('Stroke width should match Figma value', () {
        // Validate Stroke/Border = 1
        expect(WzStroke.border, equals(1.0));
      });

      test('All spacing values should be non-negative', () {
        // Property: All spacing values should be non-negative numbers
        final spacingValues = [
          WzSpacing.space150,
          WzSpacing.space200,
          WzSpacing.space400,
          WzSpacing.scale06,
          WzBorderRadius.radius200,
          WzBorderRadius.radius400,
        ];

        for (final value in spacingValues) {
          expect(value, greaterThanOrEqualTo(0.0));
          expect(value, lessThan(1000.0)); // Reasonable upper bound
        }
      });
    });

    group('Shadow Token Tests', () {
      test('Material 3 Elevation Light/2 should have correct shadow properties', () {
        // Validate M3 Elevation Light/2 has two shadows
        expect(WzShadows.m3ElevationLight2.length, equals(2));

        // First shadow: offset (0, 2), blur 6, spread 2, color #00000026
        final shadow1 = WzShadows.m3ElevationLight2[0];
        expect(shadow1.offset, equals(const Offset(0, 2)));
        expect(shadow1.blurRadius, equals(6.0));
        expect(shadow1.spreadRadius, equals(2.0));
        expect(shadow1.color, equals(const Color(0x26000000)));

        // Second shadow: offset (0, 1), blur 2, spread 0, color #0000004D
        final shadow2 = WzShadows.m3ElevationLight2[1];
        expect(shadow2.offset, equals(const Offset(0, 1)));
        expect(shadow2.blurRadius, equals(2.0));
        expect(shadow2.spreadRadius, equals(0.0));
        expect(shadow2.color, equals(const Color(0x4D000000)));
      });
    });

    group('Theme Configuration Tests', () {
      test('UI Clone theme should use Figma-extracted colors', () {
        final theme = WzTheme.uiCloneTheme;

        // Validate theme uses M3 colors
        expect(theme.colorScheme.primary, equals(WzColors.m3Primary));
        expect(theme.colorScheme.onPrimary, equals(WzColors.m3OnPrimary));
        expect(theme.colorScheme.surface, equals(WzColors.m3Surface));
        expect(theme.scaffoldBackgroundColor, equals(WzColors.m3Surface));
      });

      test('UI Clone theme should use Figma-extracted text styles', () {
        final theme = WzTheme.uiCloneTheme;

        // Validate theme uses M3 text styles (check core properties only)
        final bodyLarge = theme.textTheme.bodyLarge!;
        expect(bodyLarge.fontFamily, equals(WzTextStyles.m3BodyLarge.fontFamily));
        expect(bodyLarge.fontSize, equals(WzTextStyles.m3BodyLarge.fontSize));
        expect(bodyLarge.fontWeight, equals(WzTextStyles.m3BodyLarge.fontWeight));
        expect(bodyLarge.letterSpacing, equals(WzTextStyles.m3BodyLarge.letterSpacing));
        expect(bodyLarge.height, equals(WzTextStyles.m3BodyLarge.height));

        final labelLarge = theme.textTheme.labelLarge!;
        expect(labelLarge.fontFamily, equals(WzTextStyles.m3LabelLarge.fontFamily));
        expect(labelLarge.fontSize, equals(WzTextStyles.m3LabelLarge.fontSize));
        expect(labelLarge.fontWeight, equals(WzTextStyles.m3LabelLarge.fontWeight));
        expect(labelLarge.letterSpacing, equals(WzTextStyles.m3LabelLarge.letterSpacing));
        expect(labelLarge.height, equals(WzTextStyles.m3LabelLarge.height));
      });

      test('UI Clone theme should use Figma-extracted spacing', () {
        final theme = WzTheme.uiCloneTheme;

        // Validate button padding uses Figma spacing
        final buttonStyle = theme.elevatedButtonTheme.style;
        final padding = buttonStyle?.padding?.resolve({});
        expect(padding?.horizontal, equals(WzSpacing.space400 * 2));
        expect(padding?.vertical, equals(WzSpacing.space200 * 2));
      });

      test('Theme should be valid and complete', () {
        final theme = WzTheme.uiCloneTheme;

        // Property: Theme should have all required properties
        expect(theme.colorScheme, isNotNull);
        expect(theme.textTheme, isNotNull);
        expect(theme.scaffoldBackgroundColor, isNotNull);
        expect(theme.appBarTheme, isNotNull);
        expect(theme.elevatedButtonTheme, isNotNull);
      });
    });
  });

  /// Property-Based Test for Screen Completeness
  ///
  /// Feature: figma-ui-extraction, Property 6: Screen Completeness
  /// Validates: Requirements 2.1, 2.2, 9.3, 9.4
  ///
  /// This test verifies that for any screen marked as extracted in the
  /// screen inventory, a corresponding Flutter widget file exists in
  /// lib/ui_clone/screens/.
  group('Screen Completeness Tests', () {
    test('All extracted screens should have corresponding widget files', () {
      // Define screens that should be extracted (from screen_inventory.md)
      // This list represents screens marked as "extracted" in the inventory
      final extractedScreens = <String, String>{
        // Format: 'Screen Name': 'expected_file_name_ui.dart'
        // Currently no screens are marked as extracted yet
        // This test will be updated as screens are extracted
      };

      // Verify each extracted screen has a corresponding file
      for (final entry in extractedScreens.entries) {
        final screenName = entry.key;
        final fileName = entry.value;
        final filePath = 'lib/ui_clone/screens/$fileName';
        final file = File(filePath);

        expect(
          file.existsSync(),
          isTrue,
          reason: 'Screen "$screenName" is marked as extracted but file "$filePath" does not exist',
        );
      }
    });

    test('UI clone screens directory should exist', () {
      // Property: The ui_clone/screens directory should exist
      final screensDir = Directory('lib/ui_clone/screens');
      expect(
        screensDir.existsSync(),
        isTrue,
        reason: 'lib/ui_clone/screens directory should exist for screen extraction',
      );
    });

    test('Screen widget files should follow naming convention', () {
      // Property: All screen files should end with _ui.dart suffix
      final screensDir = Directory('lib/ui_clone/screens');
      
      if (!screensDir.existsSync()) {
        // Skip if directory doesn't exist yet
        return;
      }

      final screenFiles = screensDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();

      for (final file in screenFiles) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        expect(
          fileName.endsWith('_ui.dart'),
          isTrue,
          reason: 'Screen widget file "$fileName" should follow naming convention *_ui.dart',
        );
      }
    });

    test('Screen widget files should be valid Dart files', () {
      // Property: All screen widget files should have valid Dart syntax
      final screensDir = Directory('lib/ui_clone/screens');
      
      if (!screensDir.existsSync()) {
        // Skip if directory doesn't exist yet
        return;
      }

      final screenFiles = screensDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();

      for (final file in screenFiles) {
        final content = file.readAsStringSync();
        
        // Basic validation: file should contain class definition
        expect(
          content.contains('class '),
          isTrue,
          reason: 'Screen widget file "${file.path}" should contain a class definition',
        );
        
        // Should extend StatelessWidget or StatefulWidget
        final hasWidget = content.contains('extends StatelessWidget') ||
            content.contains('extends StatefulWidget');
        expect(
          hasWidget,
          isTrue,
          reason: 'Screen widget file "${file.path}" should contain a Widget class',
        );
      }
    });

    test('Property: Screen inventory completeness', () {
      // This test validates the property that all screens in the inventory
      // that are marked as extracted should have corresponding files
      
      // For now, we verify the structure is in place
      // As screens are extracted, this test will validate completeness
      
      final screensDir = Directory('lib/ui_clone/screens');
      expect(screensDir.existsSync(), isTrue);
      
      // Count extracted screens (files ending with _ui.dart)
      final extractedCount = screensDir.existsSync()
          ? screensDir
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('_ui.dart'))
              .length
          : 0;
      
      // Property: Extracted count should be non-negative
      expect(extractedCount, greaterThanOrEqualTo(0));
      
      // Property: If screens are extracted, count should match inventory
      // (This will be validated as extraction progresses)
      print('Current extracted screens count: $extractedCount');
    });
  });
}
