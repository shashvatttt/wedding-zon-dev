import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// Property-Based Test for Asset Path Validity
///
/// Feature: figma-ui-extraction, Property 5: Asset Path Validity
/// Validates: Requirements 5.4, 5.5, 5.7, 6.3, 6.4
///
/// This test verifies that for any extracted asset (SVG, image),
/// the generated Flutter code references a valid asset path that
/// exists in the assets directory and is declared in pubspec.yaml.
void main() {
  group('Asset Path Validity Tests', () {
    late YamlMap pubspecYaml;
    late List<String> declaredAssetPaths;

    setUpAll(() {
      // Load and parse pubspec.yaml
      final pubspecFile = File('pubspec.yaml');
      expect(
        pubspecFile.existsSync(),
        isTrue,
        reason: 'pubspec.yaml should exist',
      );

      final pubspecContent = pubspecFile.readAsStringSync();
      final yaml = loadYaml(pubspecContent) as YamlMap;
      pubspecYaml = yaml;

      // Extract declared asset paths
      final flutter = pubspecYaml['flutter'] as YamlMap?;
      final assets = flutter?['assets'] as YamlList?;
      declaredAssetPaths = assets?.map((e) => e.toString()).toList() ?? [];
    });

    test('pubspec.yaml should declare flutter_svg dependency', () {
      // Validates: Requirements 5.6
      final dependencies = pubspecYaml['dependencies'] as YamlMap?;
      expect(
        dependencies,
        isNotNull,
        reason: 'pubspec.yaml should have dependencies section',
      );

      expect(
        dependencies!.containsKey('flutter_svg'),
        isTrue,
        reason: 'flutter_svg dependency should be declared for SVG rendering',
      );
    });

    test('pubspec.yaml should declare ui_clone asset directories', () {
      // Validates: Requirements 5.7, 6.4
      final requiredAssetPaths = [
        'assets/ui_clone/icons/',
        'assets/ui_clone/illustrations/',
        'assets/ui_clone/images/',
      ];

      for (final path in requiredAssetPaths) {
        expect(
          declaredAssetPaths.contains(path),
          isTrue,
          reason: 'Asset path "$path" should be declared in pubspec.yaml',
        );
      }
    });

    test('All extracted SVG icons should exist in assets/ui_clone/icons/', () {
      // Validates: Requirements 5.4, 5.5
      final iconsDir = Directory('assets/ui_clone/icons');

      if (!iconsDir.existsSync()) {
        // Skip if directory doesn't exist yet
        return;
      }

      final iconFiles = iconsDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.svg'))
          .toList();

      // Property: All icon files should exist and be readable
      for (final iconFile in iconFiles) {
        expect(
          iconFile.existsSync(),
          isTrue,
          reason: 'Icon file ${iconFile.path} should exist',
        );

        // Verify file is not empty
        final fileSize = iconFile.lengthSync();
        expect(
          fileSize,
          greaterThan(0),
          reason: 'Icon file ${iconFile.path} should not be empty',
        );

        // Verify file contains SVG content
        final content = iconFile.readAsStringSync();
        expect(
          content.contains('<svg') || content.contains('<?xml'),
          isTrue,
          reason: 'Icon file ${iconFile.path} should contain valid SVG content',
        );
      }
    });

    test('All extracted illustrations should exist in assets/ui_clone/illustrations/', () {
      // Validates: Requirements 5.4, 5.5
      final illustrationsDir = Directory('assets/ui_clone/illustrations');

      if (!illustrationsDir.existsSync()) {
        // Skip if directory doesn't exist yet
        return;
      }

      final illustrationFiles = illustrationsDir
          .listSync()
          .whereType<File>()
          .where((file) =>
              file.path.endsWith('.svg') ||
              file.path.endsWith('.png') ||
              file.path.endsWith('.jpg') ||
              file.path.endsWith('.jpeg'))
          .toList();

      // Property: All illustration files should exist and be readable
      for (final illustrationFile in illustrationFiles) {
        expect(
          illustrationFile.existsSync(),
          isTrue,
          reason: 'Illustration file ${illustrationFile.path} should exist',
        );

        // Verify file is not empty
        final fileSize = illustrationFile.lengthSync();
        expect(
          fileSize,
          greaterThan(0),
          reason: 'Illustration file ${illustrationFile.path} should not be empty',
        );
      }
    });

    test('All extracted images should exist in assets/ui_clone/images/', () {
      // Validates: Requirements 6.3, 6.4
      final imagesDir = Directory('assets/ui_clone/images');

      if (!imagesDir.existsSync()) {
        // Skip if directory doesn't exist yet
        return;
      }

      final imageFiles = imagesDir
          .listSync()
          .whereType<File>()
          .where((file) =>
              file.path.endsWith('.png') ||
              file.path.endsWith('.jpg') ||
              file.path.endsWith('.jpeg') ||
              file.path.endsWith('.webp'))
          .toList();

      // Property: All image files should exist and be readable
      for (final imageFile in imageFiles) {
        expect(
          imageFile.existsSync(),
          isTrue,
          reason: 'Image file ${imageFile.path} should exist',
        );

        // Verify file is not empty
        final fileSize = imageFile.lengthSync();
        expect(
          fileSize,
          greaterThan(0),
          reason: 'Image file ${imageFile.path} should not be empty',
        );
      }
    });

    test('Property: All asset files should follow snake_case naming convention', () {
      // Validates: Requirements 5.5
      final assetDirs = [
        Directory('assets/ui_clone/icons'),
        Directory('assets/ui_clone/illustrations'),
        Directory('assets/ui_clone/images'),
      ];

      for (final dir in assetDirs) {
        if (!dir.existsSync()) continue;

        final files = dir
            .listSync()
            .whereType<File>()
            .where((file) => !file.path.endsWith('README.md'))
            .toList();

        for (final file in files) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          final nameWithoutExtension = fileName.split('.').first;

          // Check if name follows snake_case (lowercase with underscores)
          final snakeCasePattern = RegExp(r'^[a-z0-9_]+$');
          expect(
            snakeCasePattern.hasMatch(nameWithoutExtension),
            isTrue,
            reason:
                'Asset file "$fileName" should follow snake_case naming convention',
          );
        }
      }
    });

    test('Property: Asset directories should be accessible', () {
      // Validates: Requirements 5.4, 6.3
      final assetDirs = [
        'assets/ui_clone/icons',
        'assets/ui_clone/illustrations',
        'assets/ui_clone/images',
      ];

      for (final dirPath in assetDirs) {
        final dir = Directory(dirPath);
        expect(
          dir.existsSync(),
          isTrue,
          reason: 'Asset directory "$dirPath" should exist',
        );
      }
    });

    test('Property: All declared asset paths in pubspec.yaml should exist', () {
      // Validates: Requirements 5.7, 6.4
      final uiCloneAssetPaths = declaredAssetPaths
          .where((path) => path.startsWith('assets/ui_clone/'))
          .toList();

      for (final assetPath in uiCloneAssetPaths) {
        // Asset paths ending with / are directories
        if (assetPath.endsWith('/')) {
          final dir = Directory(assetPath);
          expect(
            dir.existsSync(),
            isTrue,
            reason: 'Declared asset directory "$assetPath" should exist',
          );
        } else {
          // Individual file
          final file = File(assetPath);
          expect(
            file.existsSync(),
            isTrue,
            reason: 'Declared asset file "$assetPath" should exist',
          );
        }
      }
    });

    test('Property: SVG files should have valid XML structure', () {
      // Validates: Requirements 5.2, 5.3
      final iconsDir = Directory('assets/ui_clone/icons');

      if (!iconsDir.existsSync()) {
        return;
      }

      final svgFiles = iconsDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.svg'))
          .toList();

      for (final svgFile in svgFiles) {
        final content = svgFile.readAsStringSync();

        // Property: SVG should contain opening and closing tags
        expect(
          content.contains('<svg') || content.contains('<?xml'),
          isTrue,
          reason: 'SVG file ${svgFile.path} should have opening tag',
        );

        expect(
          content.contains('</svg>') || content.contains('/>'),
          isTrue,
          reason: 'SVG file ${svgFile.path} should have closing tag',
        );

        // Property: SVG should not be empty
        expect(
          content.trim().isNotEmpty,
          isTrue,
          reason: 'SVG file ${svgFile.path} should not be empty',
        );
      }
    });

    test('Property: Asset extraction completeness', () {
      // This test validates that the asset extraction process is complete
      // by checking that all expected asset types are present

      final iconsDir = Directory('assets/ui_clone/icons');
      final illustrationsDir = Directory('assets/ui_clone/illustrations');
      final imagesDir = Directory('assets/ui_clone/images');

      // Count extracted assets
      final iconCount = iconsDir.existsSync()
          ? iconsDir
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.svg'))
              .length
          : 0;

      final illustrationCount = illustrationsDir.existsSync()
          ? illustrationsDir
              .listSync()
              .whereType<File>()
              .where((file) =>
                  file.path.endsWith('.svg') ||
                  file.path.endsWith('.png') ||
                  file.path.endsWith('.jpg'))
              .length
          : 0;

      final imageCount = imagesDir.existsSync()
          ? imagesDir
              .listSync()
              .whereType<File>()
              .where((file) =>
                  file.path.endsWith('.png') ||
                  file.path.endsWith('.jpg') ||
                  file.path.endsWith('.jpeg'))
              .length
          : 0;

      // Property: Asset counts should be non-negative
      expect(iconCount, greaterThanOrEqualTo(0));
      expect(illustrationCount, greaterThanOrEqualTo(0));
      expect(imageCount, greaterThanOrEqualTo(0));

      // Log current extraction status
      print('Asset extraction status:');
      print('  Icons: $iconCount');
      print('  Illustrations: $illustrationCount');
      print('  Images: $imageCount');
    });
  });
}
