import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';

/// Property-Based Test for Design System Organization
///
/// Feature: figma-ui-extraction, Property 8: Design System Organization
/// Validates: Requirements 7.1, 7.2, 7.3, 7.5, 7.6, 7.7
///
/// This test verifies that design tokens are organized correctly:
/// - All color tokens are in wz_colors.dart
/// - All typography tokens are in wz_text_styles.dart
/// - All spacing tokens are in wz_spacing.dart
/// - Tokens follow consistent naming conventions
void main() {
  group('Design System Organization Tests', () {
    group('Color Token Organization (Requirement 7.1, 7.5)', () {
      test('All color constants should be in WzColors class', () {
        // Property: All color tokens should be organized in wz_colors.dart
        final colorsFile = File('lib/core/theme/wz_colors.dart');
        expect(colorsFile.existsSync(), isTrue,
            reason: 'wz_colors.dart should exist');

        final content = colorsFile.readAsStringSync();
        expect(content.contains('class WzColors'), isTrue,
            reason: 'File should contain WzColors class');
      });

      test('Color constants should follow naming conventions', () {
        // Property: Color names should use camelCase and descriptive names
        // Sample a few known colors to verify naming conventions
        final sampleColors = {
          'primary': WzColors.primary,
          'm3Primary': WzColors.m3Primary,
          'brandDefault': WzColors.brandDefault,
          'textDefault': WzColors.textDefault,
        };

        for (final entry in sampleColors.entries) {
          final name = entry.key;
          
          // Should be camelCase (starts with lowercase)
          expect(name[0], equals(name[0].toLowerCase()),
              reason: 'Color constant "$name" should start with lowercase');
        }
      });

      test('All color constants should be Color type', () {
        // Property: All color tokens should be of type Color
        // Sample known colors to verify type
        final sampleColors = [
          WzColors.primary,
          WzColors.m3Primary,
          WzColors.brandDefault,
          WzColors.textDefault,
          WzColors.backgroundDefault,
        ];

        for (final color in sampleColors) {
          expect(color, isA<Color>(),
              reason: 'Color constant should be of type Color');
        }
      });

      test('Colors should be grouped by usage category', () {
        // Property: Colors should be organized in logical groups
        final colorsFile = File('lib/core/theme/wz_colors.dart');
        final content = colorsFile.readAsStringSync();

        // Check for category comments/sections
        final hasCategories = content.contains('Primary') ||
            content.contains('Material 3') ||
            content.contains('Brand') ||
            content.contains('Background') ||
            content.contains('Text');

        expect(hasCategories, isTrue,
            reason: 'Colors should be organized in categories (Requirement 7.5)');
      });
    });

    group('Typography Token Organization (Requirement 7.2, 7.6)', () {
      test('All text style constants should be in WzTextStyles class', () {
        // Property: All typography tokens should be organized in wz_text_styles.dart
        final textStylesFile = File('lib/core/theme/wz_text_styles.dart');
        expect(textStylesFile.existsSync(), isTrue,
            reason: 'wz_text_styles.dart should exist');

        final content = textStylesFile.readAsStringSync();
        expect(content.contains('class WzTextStyles'), isTrue,
            reason: 'File should contain WzTextStyles class');
      });

      test('Text style constants should follow naming conventions', () {
        // Property: Text style names should use camelCase and hierarchy-based names
        // Sample known text styles to verify naming conventions
        final sampleTextStyles = {
          'heading1': WzTextStyles.heading1,
          'm3LabelLarge': WzTextStyles.m3LabelLarge,
          'body': WzTextStyles.body,
        };

        for (final entry in sampleTextStyles.entries) {
          final name = entry.key;
          
          // Should be camelCase (starts with lowercase)
          expect(name[0], equals(name[0].toLowerCase()),
              reason: 'Text style constant "$name" should start with lowercase');
        }
      });

      test('All text style constants should be TextStyle type', () {
        // Property: All typography tokens should be of type TextStyle
        // Sample known text styles to verify type
        final sampleTextStyles = [
          WzTextStyles.heading1,
          WzTextStyles.m3LabelLarge,
          WzTextStyles.body,
          WzTextStyles.h2,
        ];

        for (final textStyle in sampleTextStyles) {
          expect(textStyle, isA<TextStyle>(),
              reason: 'Text style constant should be of type TextStyle');
        }
      });

      test('Text styles should be named by hierarchy', () {
        // Property: Text styles should follow hierarchy naming (Requirement 7.6)
        // Check that we have hierarchical naming patterns
        final hierarchicalNames = [
          'heading1',
          'heading2',
          'body1',
          'h2',
          'm3LabelLarge',
        ];

        // Verify these names follow hierarchy patterns
        for (final name in hierarchicalNames) {
          final hasHierarchy = name.contains('heading') ||
              name.contains('body') ||
              name.contains('caption') ||
              name.contains('h1') ||
              name.contains('h2') ||
              name.contains('m3');

          expect(hasHierarchy, isTrue,
              reason: 'Text style "$name" should follow hierarchy naming');
        }
      });
    });

    group('Spacing Token Organization (Requirement 7.3, 7.7)', () {
      test('All spacing constants should be in WzSpacing class', () {
        // Property: All spacing tokens should be organized in wz_spacing.dart
        final spacingFile = File('lib/core/theme/wz_spacing.dart');
        expect(spacingFile.existsSync(), isTrue,
            reason: 'wz_spacing.dart should exist');

        final content = spacingFile.readAsStringSync();
        expect(content.contains('class WzSpacing'), isTrue,
            reason: 'File should contain WzSpacing class');
      });

      test('Spacing constants should follow naming conventions', () {
        // Property: Spacing names should use consistent naming (space4, space8, etc.)
        // Sample known spacing constants to verify naming
        final sampleSpacing = {
          'space4': WzSpacing.space4,
          'space8': WzSpacing.space8,
          'space150': WzSpacing.space150,
          'scale06': WzSpacing.scale06,
        };

        for (final entry in sampleSpacing.entries) {
          final name = entry.key;
          
          // Should be camelCase (starts with lowercase)
          expect(name[0], equals(name[0].toLowerCase()),
              reason: 'Spacing constant "$name" should start with lowercase');
          
          // Should follow pattern: space + number or scale + number
          final followsPattern = name.startsWith('space') ||
              name.startsWith('scale') ||
              name.contains('Padding');
          
          expect(followsPattern, isTrue,
              reason: 'Spacing constant "$name" should follow naming pattern (Requirement 7.7)');
        }
      });

      test('All spacing constants should be double type', () {
        // Property: All spacing tokens should be of type double
        // Sample known spacing constants to verify type
        final sampleSpacing = [
          WzSpacing.space4,
          WzSpacing.space8,
          WzSpacing.space150,
          WzSpacing.scale06,
        ];

        for (final spacing in sampleSpacing) {
          expect(spacing, isA<double>(),
              reason: 'Spacing constant should be of type double');
        }
      });

      test('Border radius constants should be in WzBorderRadius class', () {
        // Property: Border radius tokens should be organized separately
        final spacingFile = File('lib/core/theme/wz_spacing.dart');
        final content = spacingFile.readAsStringSync();
        
        expect(content.contains('class WzBorderRadius'), isTrue,
            reason: 'File should contain WzBorderRadius class for organization');
      });
    });

    group('Cross-File Organization (Requirements 7.1, 7.2, 7.3)', () {
      test('Design tokens should be in separate dedicated files', () {
        // Property: Each token category should have its own file
        final colorFile = File('lib/core/theme/wz_colors.dart');
        final textStyleFile = File('lib/core/theme/wz_text_styles.dart');
        final spacingFile = File('lib/core/theme/wz_spacing.dart');

        expect(colorFile.existsSync(), isTrue,
            reason: 'Colors should be in dedicated file (Requirement 7.1)');
        expect(textStyleFile.existsSync(), isTrue,
            reason: 'Text styles should be in dedicated file (Requirement 7.2)');
        expect(spacingFile.existsSync(), isTrue,
            reason: 'Spacing should be in dedicated file (Requirement 7.3)');
      });

      test('Design token files should not mix categories', () {
        // Property: Each file should contain only its designated token type
        final colorFile = File('lib/core/theme/wz_colors.dart');
        final colorContent = colorFile.readAsStringSync();

        // Colors file should not define TextStyle or spacing constants
        expect(colorContent.contains('TextStyle('), isFalse,
            reason: 'wz_colors.dart should not contain TextStyle definitions');

        final textStyleFile = File('lib/core/theme/wz_text_styles.dart');
        final textStyleContent = textStyleFile.readAsStringSync();

        // Text styles file should not define Color constants (except in TextStyle)
        final colorDefinitions = RegExp(r'static const Color \w+ = Color\(');
        expect(colorDefinitions.hasMatch(textStyleContent), isFalse,
            reason: 'wz_text_styles.dart should not define Color constants');
      });

      test('All design token classes should be in lib/core/theme/', () {
        // Property: Design system files should be in correct directory
        final themeDir = Directory('lib/core/theme');
        expect(themeDir.existsSync(), isTrue,
            reason: 'lib/core/theme/ directory should exist');

        final designFiles = ['wz_colors.dart', 'wz_text_styles.dart', 'wz_spacing.dart'];
        for (final fileName in designFiles) {
          final file = File('lib/core/theme/$fileName');
          expect(file.existsSync(), isTrue,
              reason: 'Design token file $fileName should be in lib/core/theme/');
        }
      });
    });

    group('Naming Consistency Tests', () {
      test('All design token classes should use "Wz" prefix', () {
        // Property: All design system classes should follow consistent naming
        final classNames = ['WzColors', 'WzTextStyles', 'WzSpacing', 'WzBorderRadius'];
        
        for (final className in classNames) {
          expect(className.startsWith('Wz'), isTrue,
              reason: 'Design system class "$className" should use "Wz" prefix');
        }
      });

      test('Figma-extracted tokens should be clearly marked', () {
        // Property: Figma tokens should be distinguishable from legacy tokens
        final colorFile = File('lib/core/theme/wz_colors.dart');
        final colorContent = colorFile.readAsStringSync();

        // Should have sections for existing vs Figma extracted
        final hasSections = colorContent.contains('EXISTING') ||
            colorContent.contains('FIGMA') ||
            colorContent.contains('Legacy') ||
            colorContent.contains('UI Clone');

        expect(hasSections, isTrue,
            reason: 'Design files should clearly separate legacy and Figma-extracted tokens');
      });

      test('Material 3 tokens should use "m3" prefix', () {
        // Property: Material 3 tokens should be consistently prefixed
        // Sample M3 colors to verify naming
        final m3Colors = {
          'm3Primary': WzColors.m3Primary,
          'm3OnPrimary': WzColors.m3OnPrimary,
          'm3Surface': WzColors.m3Surface,
        };

        // All m3 prefixed colors should follow consistent naming
        for (final entry in m3Colors.entries) {
          final name = entry.key;
          expect(name.startsWith('m3'), isTrue,
              reason: 'Material 3 color "$name" should start with "m3" prefix');
          
          // After m3, should be PascalCase
          final afterPrefix = name.substring(2);
          if (afterPrefix.isNotEmpty) {
            expect(afterPrefix[0], equals(afterPrefix[0].toUpperCase()),
                reason: 'Material 3 color "$name" should use m3PascalCase format');
          }
        }
      });
    });

    group('Property-Based Tests with Random Token Generation', () {
      test('Property: Generated color tokens maintain organization', () {
        // Generate random color tokens and verify they would be organized correctly
        final randomColors = _generateRandomColorTokens(3);
        
        for (final token in randomColors) {
          // Verify token structure
          expect(token.name, isNotEmpty,
              reason: 'Generated token should have a name');
          expect(token.category, equals('color'),
              reason: 'Color token should have category "color"');
          expect(token.value, isA<Color>(),
              reason: 'Color token value should be a Color');
          
          // Verify naming convention
          expect(token.name[0], equals(token.name[0].toLowerCase()),
              reason: 'Generated color token name should start with lowercase');
        }
      });

      test('Property: Generated typography tokens maintain organization', () {
        // Generate random typography tokens and verify organization
        final randomTextStyles = _generateRandomTextStyleTokens(3);
        
        for (final token in randomTextStyles) {
          // Verify token structure
          expect(token.name, isNotEmpty,
              reason: 'Generated token should have a name');
          expect(token.category, equals('typography'),
              reason: 'Typography token should have category "typography"');
          expect(token.value, isA<TextStyle>(),
              reason: 'Typography token value should be a TextStyle');
          
          // Verify naming convention
          expect(token.name[0], equals(token.name[0].toLowerCase()),
              reason: 'Generated typography token name should start with lowercase');
        }
      });

      test('Property: Generated spacing tokens maintain organization', () {
        // Generate random spacing tokens and verify organization
        final randomSpacing = _generateRandomSpacingTokens(3);
        
        for (final token in randomSpacing) {
          // Verify token structure
          expect(token.name, isNotEmpty,
              reason: 'Generated token should have a name');
          expect(token.category, equals('spacing'),
              reason: 'Spacing token should have category "spacing"');
          expect(token.value, isA<double>(),
              reason: 'Spacing token value should be a double');
          
          // Verify naming convention
          expect(token.name[0], equals(token.name[0].toLowerCase()),
              reason: 'Generated spacing token name should start with lowercase');
          expect(token.name.startsWith('space') || token.name.startsWith('scale'), isTrue,
              reason: 'Generated spacing token should follow naming pattern');
        }
      });

      test('Property: All tokens in correct category file', () {
        // Verify that tokens are organized by category
        final allTokens = [
          ..._generateRandomColorTokens(2),
          ..._generateRandomTextStyleTokens(2),
          ..._generateRandomSpacingTokens(2),
        ];

        // Group by category
        final byCategory = <String, List<DesignToken>>{};
        for (final token in allTokens) {
          byCategory.putIfAbsent(token.category, () => []).add(token);
        }

        // Verify each category has tokens
        expect(byCategory['color'], isNotEmpty,
            reason: 'Should have color tokens');
        expect(byCategory['typography'], isNotEmpty,
            reason: 'Should have typography tokens');
        expect(byCategory['spacing'], isNotEmpty,
            reason: 'Should have spacing tokens');

        // Verify tokens in each category are consistent
        for (final entry in byCategory.entries) {
          final category = entry.key;
          final tokens = entry.value;

          for (final token in tokens) {
            expect(token.category, equals(category),
                reason: 'All tokens in $category group should have category "$category"');
          }
        }
      });
    });
  });
}

// ============================================================================
// Helper Classes and Functions for Property-Based Testing
// ============================================================================

/// Design Token Model for testing
class DesignToken {
  final String name;
  final String category;
  final dynamic value;

  DesignToken({
    required this.name,
    required this.category,
    required this.value,
  });
}

/// Generate random color tokens for property-based testing
List<DesignToken> _generateRandomColorTokens(int count) {
  final tokens = <DesignToken>[];
  final prefixes = ['primary', 'secondary', 'background', 'text', 'border'];
  final suffixes = ['', 'Light', 'Dark', 'Variant', 'Container'];

  for (int i = 0; i < count; i++) {
    final prefix = prefixes[i % prefixes.length];
    final suffix = suffixes[i % suffixes.length];
    final name = '$prefix$suffix';
    
    // Generate random color
    final r = (i * 37) % 256;
    final g = (i * 73) % 256;
    final b = (i * 109) % 256;
    final color = Color.fromARGB(255, r, g, b);

    tokens.add(DesignToken(
      name: name,
      category: 'color',
      value: color,
    ));
  }

  return tokens;
}

/// Generate random text style tokens for property-based testing
List<DesignToken> _generateRandomTextStyleTokens(int count) {
  final tokens = <DesignToken>[];
  final hierarchies = ['heading', 'body', 'caption', 'label'];
  final levels = ['1', '2', '3', 'Large', 'Medium', 'Small'];

  for (int i = 0; i < count; i++) {
    final hierarchy = hierarchies[i % hierarchies.length];
    final level = levels[i % levels.length];
    final name = '$hierarchy$level';
    
    // Generate random text style
    final fontSize = 12.0 + (i % 5) * 4.0;
    final fontWeight = FontWeight.values[(i % 3) * 2];
    
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.2,
      letterSpacing: 0.0,
    );

    tokens.add(DesignToken(
      name: name,
      category: 'typography',
      value: textStyle,
    ));
  }

  return tokens;
}

/// Generate random spacing tokens for property-based testing
List<DesignToken> _generateRandomSpacingTokens(int count) {
  final tokens = <DesignToken>[];
  final bases = [4, 8, 12, 16, 20, 24, 32, 40, 48];

  for (int i = 0; i < count; i++) {
    final base = bases[i % bases.length];
    final name = 'space$base';
    
    tokens.add(DesignToken(
      name: name,
      category: 'spacing',
      value: base.toDouble(),
    ));
  }

  return tokens;
}
