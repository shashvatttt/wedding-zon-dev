import 'package:flutter/foundation.dart';
import 'dart:convert';

class FilterDebugHelper {
  static void debugApiResponse(dynamic response) {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔍 FILTER API RESPONSE DEBUG');
    debugPrint('═══════════════════════════════════════════════════════');

    if (response == null) {
      debugPrint('❌ Response is NULL');
      return;
    }

    debugPrint('📦 Response Type: ${response.runtimeType}');
    debugPrint(
      '📦 Response Keys: ${response is Map ? response.keys.toList() : 'N/A'}',
    );

    try {
      final jsonString = jsonEncode(response);
      debugPrint('📄 Full JSON Response:');
      debugPrint(jsonString);

      final prettyJson = const JsonEncoder.withIndent('  ').convert(response);
      debugPrint('📄 Pretty JSON:');
      debugPrint(prettyJson);
    } catch (e) {
      debugPrint('⚠️ Could not encode to JSON: $e');
      debugPrint('📄 Raw Response: $response');
    }

    if (response is Map) {
      debugPrint('\n🔍 Analyzing Map Structure:');
      debugPrint('  - Has "success" key: ${response.containsKey('success')}');
      debugPrint('  - Has "data" key: ${response.containsKey('data')}');
      debugPrint('  - Has "message" key: ${response.containsKey('message')}');

      if (response.containsKey('data')) {
        final data = response['data'];
        debugPrint('  - Data type: ${data.runtimeType}');
        if (data is List) {
          debugPrint('  - Data length: ${data.length}');
          if (data.isNotEmpty) {
            debugPrint('  - First item: ${data.first}');
            debugPrint(
              '  - First item keys: ${data.first is Map ? (data.first as Map).keys.toList() : 'N/A'}',
            );
          }
        }
      }
    } else if (response is List) {
      debugPrint('\n🔍 Analyzing List Structure:');
      debugPrint('  - List length: ${response.length}');
      if (response.isNotEmpty) {
        debugPrint('  - First item: ${response.first}');
        debugPrint('  - First item type: ${response.first.runtimeType}');
        if (response.first is Map) {
          debugPrint(
            '  - First item keys: ${(response.first as Map).keys.toList()}',
          );
        }
      }
    }

    debugPrint('═══════════════════════════════════════════════════════\n');
  }

  static void debugFilterParsing(
    Map<String, dynamic> filterJson, {
    String? error,
  }) {
    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('🔍 FILTER PARSING DEBUG');
    debugPrint('───────────────────────────────────────────────────────');

    debugPrint('📋 Filter JSON:');
    try {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(filterJson);
      debugPrint(prettyJson);
    } catch (e) {
      debugPrint('$filterJson');
    }

    debugPrint('\n🔑 Key Fields:');
    debugPrint(
      '  - label: ${filterJson['label']} (${filterJson['label']?.runtimeType})',
    );
    debugPrint(
      '  - key: ${filterJson['key']} (${filterJson['key']?.runtimeType})',
    );
    debugPrint(
      '  - type: ${filterJson['type']} (${filterJson['type']?.runtimeType})',
    );
    debugPrint(
      '  - section: ${filterJson['section']} (${filterJson['section']?.runtimeType})',
    );
    debugPrint(
      '  - isVisible: ${filterJson['isVisible']} (${filterJson['isVisible']?.runtimeType})',
    );
    debugPrint(
      '  - order: ${filterJson['order']} (${filterJson['order']?.runtimeType})',
    );
    debugPrint(
      '  - options: ${filterJson['options']} (${filterJson['options']?.runtimeType})',
    );

    if (error != null) {
      debugPrint('\n❌ PARSING ERROR:');
      debugPrint('  $error');
    }

    debugPrint('───────────────────────────────────────────────────────\n');
  }

  static void compareResponses({
    required String webResponse,
    required String flutterResponse,
  }) {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔍 WEB vs FLUTTER RESPONSE COMPARISON');
    debugPrint('═══════════════════════════════════════════════════════');

    debugPrint('\n🌐 WEB RESPONSE:');
    debugPrint(webResponse);

    debugPrint('\n📱 FLUTTER RESPONSE:');
    debugPrint(flutterResponse);

    debugPrint('\n🔍 DIFFERENCES:');
    if (webResponse == flutterResponse) {
      debugPrint('  ✅ Responses are identical');
    } else {
      debugPrint('  ❌ Responses differ');
      debugPrint('  - Web length: ${webResponse.length}');
      debugPrint('  - Flutter length: ${flutterResponse.length}');
    }

    debugPrint('═══════════════════════════════════════════════════════\n');
  }

  static void testVisibilityParsing(dynamic isVisibleValue) {
    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('🔍 VISIBILITY PARSING TEST');
    debugPrint('───────────────────────────────────────────────────────');

    debugPrint('Input value: $isVisibleValue');
    debugPrint('Input type: ${isVisibleValue.runtimeType}');

    bool result;
    if (isVisibleValue == null) {
      result = true;
      debugPrint('Result: true (null defaults to true)');
    } else if (isVisibleValue is bool) {
      result = isVisibleValue;
      debugPrint('Result: $result (direct bool)');
    } else if (isVisibleValue is String) {
      final lower = isVisibleValue.toLowerCase();
      result = lower == 'true' || lower == '1' || lower == 'yes';
      debugPrint('Result: $result (parsed from string "$isVisibleValue")');
    } else if (isVisibleValue is num) {
      result = isVisibleValue != 0;
      debugPrint('Result: $result (parsed from number $isVisibleValue)');
    } else {
      result = true;
      debugPrint('Result: true (unknown type, defaulting to true)');
    }

    debugPrint('Final visibility: $result');
    debugPrint('───────────────────────────────────────────────────────\n');
  }

  static String generateCurlCommand({
    required String baseUrl,
    String? authToken,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════════════════');
    buffer.writeln('🔧 TEST API ENDPOINT WITH CURL');
    buffer.writeln('═══════════════════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('Copy and run this command in your terminal:');
    buffer.writeln();
    buffer.write('curl -X GET "$baseUrl/filters"');

    if (authToken != null && authToken.isNotEmpty) {
      buffer.write(' \\\n  -H "Authorization: Bearer $authToken"');
    }

    buffer.write(' \\\n  -H "Content-Type: application/json"');
    buffer.writeln();
    buffer.writeln();
    buffer.writeln('Or test in browser:');
    buffer.writeln('$baseUrl/filters');
    buffer.writeln('═══════════════════════════════════════════════════════');

    return buffer.toString();
  }

  static void printDiagnosticReport({
    required String baseUrl,
    required int filterCount,
    required int visibleFilterCount,
    required List<String> sections,
    required Map<String, int> filtersBySection,
    String? error,
  }) {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('📊 FILTER DIAGNOSTIC REPORT');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🌐 API Base URL: $baseUrl');
    debugPrint('📋 Total Filters: $filterCount');
    debugPrint('👁️ Visible Filters: $visibleFilterCount');
    debugPrint('📂 Sections: ${sections.join(', ')}');
    debugPrint('\n📊 Filters by Section:');
    filtersBySection.forEach((section, count) {
      debugPrint('  - $section: $count filters');
    });

    if (error != null) {
      debugPrint('\n❌ ERROR: $error');
    }

    debugPrint('\n💡 TROUBLESHOOTING TIPS:');
    if (filterCount == 0) {
      debugPrint('  ⚠️ No filters received from API');
      debugPrint('  1. Check if API endpoint is correct');
      debugPrint('  2. Verify authentication token is valid');
      debugPrint('  3. Check if filters exist in admin panel');
      debugPrint('  4. Test API endpoint directly (see curl command above)');
    } else if (visibleFilterCount == 0) {
      debugPrint('  ⚠️ Filters received but none are visible');
      debugPrint('  1. Check isVisible field in admin panel');
      debugPrint('  2. Verify isVisible is set to true');
      debugPrint('  3. Check if visibility parsing is working');
    } else {
      debugPrint('  ✅ Filters loaded successfully!');
      debugPrint('  - If filters still not showing in UI:');
      debugPrint('    1. Check if correct section is selected');
      debugPrint('    2. Verify filter types are supported');
      debugPrint('    3. Check for UI rendering issues');
    }

    debugPrint('═══════════════════════════════════════════════════════\n');
  }
}
