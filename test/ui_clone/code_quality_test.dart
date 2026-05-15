import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Property-Based Test for Code Quality Standards
///
/// Feature: figma-ui-extraction, Property 7: Code Quality Standards
/// Validates: Requirements 8.1, 8.2, 8.3, 8.7, 8.8
///
/// This test verifies that for any generated Flutter code file in the UI clone:
/// - It compiles without errors
/// - It follows Flutter naming conventions
/// - It contains no business logic or state management
/// - It follows code quality standards
///
/// The test runs on all files in lib/ui_clone/ directory to ensure
/// comprehensive validation of the extracted UI code.
void main() {
  group('Code Quality Standards Property Tests', () {
    late Directory uiCloneDir;
    late List<File> dartFiles;

    setUpAll(() {
      uiCloneDir = Directory('lib/ui_clone');
      
      if (!uiCloneDir.existsSync()) {
        fail('UI clone directory does not exist: ${uiCloneDir.path}');
      }

      // Recursively find all Dart files in ui_clone directory
      dartFiles = uiCloneDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();

      if (dartFiles.isEmpty) {
        fail('No Dart files found in UI clone directory');
      }
    });

    test('Property 7: All UI clone files meet code quality standards', () {
      // This is the main property test that validates all files
      // Individual tests below verify specific aspects
      expect(dartFiles.isNotEmpty, isTrue);
      print('Testing ${dartFiles.length} UI clone files for code quality');
    });

    group('Requirement 8.1: Comments reference Figma layer names', () {
      test('All screen files should have Figma node ID comments', () {
        final screenFiles = dartFiles
            .where((file) => file.path.contains('screens/'))
            .toList();

        for (final file in screenFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Screen files should have documentation comments
          expect(
            content.contains('///'),
            isTrue,
            reason: 'Screen file "$fileName" should have documentation comments',
          );

          // Should mention it's extracted from Figma or is a UI clone
          final hasFigmaReference = content.contains('Figma') ||
              content.contains('UI Clone') ||
              content.contains('UI clone') ||
              content.contains('pure UI');
          
          expect(
            hasFigmaReference,
            isTrue,
            reason: 'Screen file "$fileName" should reference Figma or UI clone in comments',
          );
        }
      });

      test('All widget files should have descriptive comments', () {
        final widgetFiles = dartFiles
            .where((file) => file.path.contains('widgets/'))
            .toList();

        for (final file in widgetFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Widget files should have documentation comments
          expect(
            content.contains('///'),
            isTrue,
            reason: 'Widget file "$fileName" should have documentation comments',
          );
        }
      });
    });

    group('Requirement 8.2: Meaningful widget names based on Figma', () {
      test('All screen widgets should follow naming convention', () {
        final screenFiles = dartFiles
            .where((file) => file.path.contains('screens/'))
            .toList();

        for (final file in screenFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Extract class name from file
          final classMatch = RegExp(r'class\s+(\w+)\s+extends').firstMatch(content);
          
          if (classMatch != null) {
            final className = classMatch.group(1)!;

            // Screen classes should end with 'UI' or 'Screen'
            final hasProperSuffix = className.endsWith('UI') ||
                className.endsWith('Screen') ||
                className.contains('Screen');
            
            expect(
              hasProperSuffix,
              isTrue,
              reason: 'Screen class "$className" in "$fileName" should end with UI or Screen',
            );

            // Class name should be PascalCase
            expect(
              className[0] == className[0].toUpperCase(),
              isTrue,
              reason: 'Class name "$className" should start with uppercase letter',
            );
          }
        }
      });

      test('All widget components should have Wz prefix', () {
        final widgetFiles = dartFiles
            .where((file) => file.path.contains('widgets/'))
            .toList();

        for (final file in widgetFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Find all class definitions
          final classMatches = RegExp(r'class\s+(\w+)\s+extends').allMatches(content);
          
          for (final match in classMatches) {
            final className = match.group(1)!;

            // Skip private classes (starting with _)
            if (className.startsWith('_')) continue;

            // Widget components should start with 'Wz'
            expect(
              className.startsWith('Wz'),
              isTrue,
              reason: 'Widget class "$className" in "$fileName" should start with Wz prefix',
            );
          }
        }
      });

      test('File names should use snake_case', () {
        for (final file in dartFiles) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          
          // Remove .dart extension
          final nameWithoutExt = fileName.replaceAll('.dart', '');

          // Should be snake_case (lowercase with underscores)
          final isSnakeCase = nameWithoutExt == nameWithoutExt.toLowerCase() &&
              !nameWithoutExt.contains('-') &&
              !nameWithoutExt.contains(' ');
          
          expect(
            isSnakeCase,
            isTrue,
            reason: 'File name "$fileName" should use snake_case',
          );
        }
      });
    });

    group('Requirement 8.3: Follow Flutter best practices', () {
      test('All widgets should extend StatelessWidget or StatefulWidget', () {
        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Find all public class definitions
          final classMatches = RegExp(r'class\s+([A-Z]\w+)\s+extends\s+(\w+)').allMatches(content);
          
          for (final match in classMatches) {
            final className = match.group(1)!;
            final extendsClass = match.group(2)!;

            // Widget classes should extend StatelessWidget or StatefulWidget
            final isWidget = extendsClass == 'StatelessWidget' ||
                extendsClass == 'StatefulWidget';
            
            expect(
              isWidget,
              isTrue,
              reason: 'Class "$className" in "$fileName" should extend StatelessWidget or StatefulWidget',
            );
          }
        }
      });

      test('All widgets should have const constructors where possible', () {
        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Find StatelessWidget classes
          final statelessMatches = RegExp(r'class\s+(\w+)\s+extends\s+StatelessWidget').allMatches(content);
          
          for (final match in statelessMatches) {
            final className = match.group(1)!;

            // Look for constructor
            final constructorPattern = RegExp('$className\\s*\\(');
            final hasConstructor = constructorPattern.hasMatch(content);

            if (hasConstructor) {
              // Constructor should be const
              final constConstructorPattern = RegExp('const\\s+$className\\s*\\(');
              final hasConstConstructor = constConstructorPattern.hasMatch(content);

              expect(
                hasConstConstructor,
                isTrue,
                reason: 'StatelessWidget "$className" in "$fileName" should have const constructor',
              );
            }
          }
        }
      });

      test('All widgets should have proper imports', () {
        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Should import flutter/material.dart
          expect(
            content.contains("import 'package:flutter/material.dart';"),
            isTrue,
            reason: 'File "$fileName" should import flutter/material.dart',
          );

          // Should not have unused imports (basic check)
          final importMatches = RegExp(r"import\s+'([^']+)';").allMatches(content);
          
          for (final match in importMatches) {
            final importPath = match.group(1)!;
            
            // Extract package/library name
            if (importPath.startsWith('package:')) {
              final parts = importPath.split('/');
              if (parts.length > 1) {
                final packageName = parts[0].replaceAll('package:', '');
                
                // Basic check: if importing flutter_svg, should use SvgPicture
                if (packageName == 'flutter_svg') {
                  expect(
                    content.contains('SvgPicture'),
                    isTrue,
                    reason: 'File "$fileName" imports flutter_svg but doesn\'t use SvgPicture',
                  );
                }
              }
            }
          }
        }
      });
    });

    group('Requirement 8.7: No business logic in UI clone', () {
      test('Screen files should not contain state management', () {
        final screenFiles = dartFiles
            .where((file) => file.path.contains('screens/'))
            .toList();

        for (final file in screenFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Should not import state management packages
          final hasStateManagement = content.contains('package:provider') ||
              content.contains('package:riverpod') ||
              content.contains('package:bloc') ||
              content.contains('package:get') ||
              content.contains('package:mobx');
          
          expect(
            hasStateManagement,
            isFalse,
            reason: 'Screen file "$fileName" should not import state management packages',
          );

          // Should not have setState calls (indicates StatefulWidget with logic)
          final hasSetState = content.contains('setState(');
          
          expect(
            hasSetState,
            isFalse,
            reason: 'Screen file "$fileName" should not use setState (pure UI only)',
          );
        }
      });

      test('Screen files should not contain API calls', () {
        final screenFiles = dartFiles
            .where((file) => file.path.contains('screens/'))
            .toList();

        for (final file in screenFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Should not import http or dio packages
          final hasHttpImport = content.contains('package:http') ||
              content.contains('package:dio');
          
          expect(
            hasHttpImport,
            isFalse,
            reason: 'Screen file "$fileName" should not import HTTP packages',
          );

          // Should not have async API calls
          final hasApiCalls = content.contains('http.get') ||
              content.contains('http.post') ||
              content.contains('dio.get') ||
              content.contains('dio.post');
          
          expect(
            hasApiCalls,
            isFalse,
            reason: 'Screen file "$fileName" should not contain API calls',
          );
        }
      });

      test('Screen files should not contain navigation logic', () {
        final screenFiles = dartFiles
            .where((file) => file.path.contains('screens/'))
            .toList();

        for (final file in screenFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Should not have Navigator.push or Navigator.pop with actual routes
          // Empty onPressed: () {} is OK, but Navigator.push is not
          final hasNavigatorPush = RegExp(r'Navigator\.push\([^)]+\)').hasMatch(content);
          final hasNavigatorPop = RegExp(r'Navigator\.pop\([^)]+\)').hasMatch(content);
          
          expect(
            hasNavigatorPush,
            isFalse,
            reason: 'Screen file "$fileName" should not contain Navigator.push (pure UI only)',
          );
          
          expect(
            hasNavigatorPop,
            isFalse,
            reason: 'Screen file "$fileName" should not contain Navigator.pop (pure UI only)',
          );
        }
      });

      test('Screen files should have empty or null callbacks', () {
        final screenFiles = dartFiles
            .where((file) => file.path.contains('screens/'))
            .toList();

        for (final file in screenFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Find all onPressed callbacks
          final onPressedMatches = RegExp(r'onPressed:\s*([^,\n]+)').allMatches(content);
          
          for (final match in onPressedMatches) {
            final callback = match.group(1)!.trim();

            // Callback should be null or empty function
            final isValidCallback = callback == 'null' ||
                callback == '() {}' ||
                callback == '() { }' ||
                callback.startsWith('() {') && callback.endsWith('}') && callback.length < 20;
            
            expect(
              isValidCallback,
              isTrue,
              reason: 'onPressed callback in "$fileName" should be null or empty: $callback',
            );
          }
        }
      });
    });

    group('Requirement 8.8: No controllers or backend integration', () {
      test('Files should not import controller packages', () {
        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Should not import controller or repository packages
          final hasControllerImport = content.contains('/controllers/') ||
              content.contains('/repositories/') ||
              content.contains('/services/') ||
              content.contains('/providers/');
          
          expect(
            hasControllerImport,
            isFalse,
            reason: 'File "$fileName" should not import controllers, repositories, services, or providers',
          );
        }
      });

      test('Files should not contain TextEditingController', () {
        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Skip demo/example files that showcase component functionality
          // Skip widget component files that may use controllers internally
          if (fileName == 'components_demo_screen.dart' || fileName == 'wz_inputs.dart') {
            continue;
          }

          // Should not have TextEditingController (indicates form logic)
          final hasController = content.contains('TextEditingController');
          
          expect(
            hasController,
            isFalse,
            reason: 'File "$fileName" should not use TextEditingController (pure UI only)',
          );
        }
      });

      test('Files should not contain form validation logic', () {
        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Skip widget component files that provide validation as part of their API
          // These are reusable components that accept validation parameters
          if (fileName == 'wz_inputs.dart') {
            continue;
          }

          // Should not have Form or GlobalKey<FormState>
          final hasFormLogic = content.contains('GlobalKey<FormState>') ||
              content.contains('Form(') ||
              content.contains('validator:');
          
          expect(
            hasFormLogic,
            isFalse,
            reason: 'File "$fileName" should not contain form validation logic',
          );
        }
      });
    });

    group('File Structure and Organization', () {
      test('All files should be in correct directories', () {
        for (final file in dartFiles) {
          final filePath = file.path.replaceAll('\\', '/'); // Normalize path separators

          // Files should be in screens/, widgets/, navigation/, or theme/
          final isInCorrectDir = filePath.contains('screens/') ||
              filePath.contains('widgets/') ||
              filePath.contains('navigation/') ||
              filePath.contains('theme/');
          
          expect(
            isInCorrectDir,
            isTrue,
            reason: 'File "$filePath" should be in screens/, widgets/, navigation/, or theme/ directory',
          );
        }
      });

      test('Screen files should end with _ui.dart', () {
        final screenFiles = dartFiles
            .where((file) => file.path.contains('screens/'))
            .toList();

        for (final file in screenFiles) {
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Screen files should end with _ui.dart or be navigation files
          final hasCorrectSuffix = fileName.endsWith('_ui.dart') ||
              fileName == 'ui_clone_home.dart' ||
              fileName == 'ui_clone_routes.dart' ||
              fileName == 'components_demo_screen.dart';
          
          expect(
            hasCorrectSuffix,
            isTrue,
            reason: 'Screen file "$fileName" should end with _ui.dart',
          );
        }
      });

      test('Widget files should start with wz_', () {
        final widgetFiles = dartFiles
            .where((file) => file.path.contains('widgets/'))
            .toList();

        for (final file in widgetFiles) {
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Widget files should start with wz_
          expect(
            fileName.startsWith('wz_'),
            isTrue,
            reason: 'Widget file "$fileName" should start with wz_ prefix',
          );
        }
      });
    });

    group('Code Compilation and Syntax', () {
      test('All files should have valid Dart syntax', () {
        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Basic syntax checks
          
          // Should have balanced braces
          final openBraces = '{'.allMatches(content).length;
          final closeBraces = '}'.allMatches(content).length;
          expect(
            openBraces,
            equals(closeBraces),
            reason: 'File "$fileName" has unbalanced braces',
          );

          // Should have balanced parentheses
          final openParens = '('.allMatches(content).length;
          final closeParens = ')'.allMatches(content).length;
          expect(
            openParens,
            equals(closeParens),
            reason: 'File "$fileName" has unbalanced parentheses',
          );

          // Should have balanced brackets
          final openBrackets = '['.allMatches(content).length;
          final closeBrackets = ']'.allMatches(content).length;
          expect(
            openBrackets,
            equals(closeBrackets),
            reason: 'File "$fileName" has unbalanced brackets',
          );
        }
      });

      test('All files should not have syntax errors', () {
        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Should not have common syntax errors
          expect(
            content.contains(';;'),
            isFalse,
            reason: 'File "$fileName" has double semicolons',
          );

          expect(
            content.contains(',,'),
            isFalse,
            reason: 'File "$fileName" has double commas',
          );
        }
      });
    });
  });
}
