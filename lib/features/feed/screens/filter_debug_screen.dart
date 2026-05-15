import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/feed_filters_provider.dart';
import '../../../shared/widgets/wz_toast.dart';

class FilterDebugScreen extends StatefulWidget {
  const FilterDebugScreen({super.key});

  @override
  State<FilterDebugScreen> createState() => _FilterDebugScreenState();
}

class _FilterDebugScreenState extends State<FilterDebugScreen> {
  bool _isLoading = false;
  String _output = '';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _output = 'Running diagnostics...\n\n';
    });

    final buffer = StringBuffer();

    try {
      buffer.writeln('═══════════════════════════════════════════════════════');
      buffer.writeln('🔍 FILTER DIAGNOSTICS');
      buffer.writeln(
        '═══════════════════════════════════════════════════════\n',
      );

      final feedFiltersProvider = context.read<FeedFiltersProvider>();

      buffer.writeln('📱 Testing FeedFiltersProvider...');
      await feedFiltersProvider.loadFilters(forceRefresh: true);

      buffer.writeln('✅ Load complete\n');

      buffer.writeln('📊 Results:');
      buffer.writeln(
        '  - Total filters: ${feedFiltersProvider.filters.length}',
      );
      buffer.writeln(
        '  - Sections: ${feedFiltersProvider.sections.join(', ')}',
      );
      buffer.writeln('  - Error: ${feedFiltersProvider.error ?? 'None'}\n');

      if (feedFiltersProvider.filters.isNotEmpty) {
        buffer.writeln('📋 Filter Details:\n');

        for (final section in feedFiltersProvider.sections) {
          final sectionFilters = feedFiltersProvider.getFiltersForSection(
            section,
          );
          buffer.writeln(
            '📂 Section: $section (${sectionFilters.length} filters)',
          );

          for (final filter in sectionFilters) {
            buffer.writeln('  ├─ ${filter.label}');
            buffer.writeln('  │  Key: ${filter.key}');
            buffer.writeln('  │  Type: ${filter.type.name}');
            buffer.writeln('  │  Visible: ${filter.isVisible}');
            buffer.writeln('  │  Required: ${filter.isRequired}');
            buffer.writeln('  │  Order: ${filter.order}');
            if (filter.options.isNotEmpty) {
              buffer.writeln('  │  Options: ${filter.options.join(', ')}');
            }
            buffer.writeln('  │');
          }
          buffer.writeln('');
        }
      } else {
        buffer.writeln('⚠️ No filters loaded!\n');
        buffer.writeln('Possible reasons:');
        buffer.writeln('  1. API endpoint not accessible');
        buffer.writeln('  2. Authentication issue');
        buffer.writeln('  3. No filters in database');
        buffer.writeln('  4. All filters have isVisible: false');
        buffer.writeln('  5. Parsing error\n');
      }

      buffer.writeln('═══════════════════════════════════════════════════════');
      buffer.writeln('💡 NEXT STEPS');
      buffer.writeln(
        '═══════════════════════════════════════════════════════\n',
      );

      if (feedFiltersProvider.filters.isEmpty) {
        buffer.writeln('1. Check Flutter console for detailed debug logs');
        buffer.writeln('2. Look for [FiltersRepo] messages');
        buffer.writeln('3. Copy the curl command from logs and test API');
        buffer.writeln('4. Compare API response with web frontend');
        buffer.writeln('5. Verify filters exist in admin panel');
      } else {
        buffer.writeln('✅ Filters loaded successfully!');
        buffer.writeln('If they\'re not showing in the filter modal:');
        buffer.writeln('1. Check if correct section is selected');
        buffer.writeln('2. Try pull-to-refresh in the modal');
        buffer.writeln('3. Restart the app');
      }

      buffer.writeln('\n📋 Copy this output when reporting issues');
    } catch (e, stackTrace) {
      buffer.writeln('\n❌ ERROR DURING DIAGNOSTICS:');
      buffer.writeln(e.toString());
      buffer.writeln('\nStack trace:');
      buffer.writeln(stackTrace.toString());
    }

    setState(() {
      _isLoading = false;
      _output = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Diagnostics'),
        backgroundColor: const Color(0xFFEF2F55),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostics,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'Copy to Clipboard',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFEF2F55)),
                  SizedBox(height: 16),
                  Text('Running diagnostics...'),
                  SizedBox(height: 8),
                  Text(
                    'Check console for detailed logs',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFFFF1F4),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFEF2F55)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Debug Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF2F55),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Check Flutter console for detailed logs',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _output,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Output'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF2F55),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _runDiagnostics,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF2F55),
                            side: const BorderSide(color: Color(0xFFEF2F55)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _output));
    WzToast.show(
      context,
      message: 'Output copied to clipboard',
      type: WzToastType.success,
    );
  }
}
