import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_filters_provider.dart';
import '../widgets/dynamic_filter_widget_factory.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/wz_loading.dart';

class DynamicFeedFiltersModal extends StatefulWidget {
  const DynamicFeedFiltersModal({super.key});

  @override
  State<DynamicFeedFiltersModal> createState() =>
      _DynamicFeedFiltersModalState();
}

class _DynamicFeedFiltersModalState extends State<DynamicFeedFiltersModal> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FeedFiltersProvider>();
      provider.loadFilters(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          Expanded(
            child: Consumer<FeedFiltersProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: WzLoading());
                }

                if (provider.error != null) {
                  return _buildErrorState(provider);
                }

                if (provider.filters.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildSplitView(provider);
              },
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('search_filters_title'),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Consumer<FeedFiltersProvider>(
            builder: (context, provider, _) {
              return TextButton(
                onPressed: provider.activeFilterCount > 0
                    ? () => provider.clearAllFilters()
                    : null,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '${AppLocalizations.of(context)!.translate('clear_all')} ${provider.activeFilterCount > 0 ? '(${provider.activeFilterCount})' : ''}',
                  style: TextStyle(
                    color: provider.activeFilterCount > 0
                        ? const Color(0xFFEF2F55)
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSplitView(FeedFiltersProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            border: Border(
              right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: _buildSectionList(provider),
        ),

        Expanded(child: _buildFilterInputs(provider)),
      ],
    );
  }

  Widget _buildSectionList(FeedFiltersProvider provider) {
    final sections = provider.sections;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final isSelected = provider.selectedSection == section;
        final sectionFilters = provider.getFiltersForSection(section);
        final activeCount = sectionFilters
            .where((f) => provider.isFilterActive(f.key))
            .length;

        return InkWell(
          onTap: () => provider.setSelectedSection(section),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected
                      ? const Color(0xFFEF2F55)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _formatSectionName(section),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFFEF2F55)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
                if (activeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF2F55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      activeCount.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterInputs(FeedFiltersProvider provider) {
    final sectionFilters = provider.getFiltersForSection(
      provider.selectedSection,
    );

    if (sectionFilters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No filters available for this section',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => provider.loadFilters(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Filters'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF2F55),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadFilters(forceRefresh: true),
      color: const Color(0xFFEF2F55),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sectionFilters.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final filter = sectionFilters[index];
          return DynamicFilterWidgetFactory.buildFilter(
            filter: filter,
            currentFilters: provider.currentFilters,
            onUpdate: (key, value) => provider.updateFilter(key, value),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF2F55),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.translate('apply_filters'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(FeedFiltersProvider provider) {
    final is404 =
        provider.error?.contains('404') == true ||
        provider.error?.contains('not found') == true;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              is404 ? Icons.cloud_off : Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              is404 ? 'Endpoint Not Found' : 'Error Loading Filters',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            if (is404) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Backend Setup Required',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The /filters endpoint needs to be created on the backend. '
                      'Please ensure the FilterConfig model and endpoint are set up.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.loadFilters(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF2F55),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No filters available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    final provider = context.read<FeedFiltersProvider>();
    final queryParams = provider.getQueryParameters();

    Navigator.pop(context, queryParams);
  }

  String _formatSectionName(String section) {
    return section
        .replaceAllMapped(RegExp(r'[_\s]+'), (match) => ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
