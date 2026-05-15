import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/filter_model.dart';
import '../providers/dynamic_filters_provider.dart';
import './dynamic_field_builder.dart';

class DynamicFieldsSection extends StatelessWidget {
  final String? sectionName;
  final List<FilterModel>? filters;
  final Map<String, dynamic> formData;
  final Function(String key, dynamic value) onFieldChanged;

  const DynamicFieldsSection({
    super.key,
    this.sectionName,
    this.filters,
    required this.formData,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    DynamicFieldBuilder.setContext(context);

    return Consumer<DynamicFiltersProvider>(
      builder: (context, provider, _) {
        List<FilterModel> fieldsToRender;

        if (filters != null) {
          fieldsToRender = filters!;
        } else if (sectionName != null) {
          fieldsToRender = provider.filtersBySection[sectionName] ?? [];
        } else {
          fieldsToRender = provider.filters;
        }

        if (fieldsToRender.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: fieldsToRender.map((filter) {
            return DynamicFieldBuilder.buildField(
              filter: filter,
              formData: formData,
              extraDetails: provider.extraDetails,
              onChanged: (key, value) {
                provider.updateField(key, value);

                onFieldChanged(key, value);
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class DynamicFieldsSectionedView extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Function(String key, dynamic value) onFieldChanged;
  final List<String>? sectionsToShow;
  final bool showSectionHeaders;

  const DynamicFieldsSectionedView({
    super.key,
    required this.formData,
    required this.onFieldChanged,
    this.sectionsToShow,
    this.showSectionHeaders = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DynamicFiltersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: Color(0xFFEF2F55)),
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadFilters(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF2F55),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final sections = provider.filtersBySection;
        final sectionsToRender = sectionsToShow ?? sections.keys.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sectionsToRender.map((sectionName) {
            final sectionFilters = sections[sectionName] ?? [];
            if (sectionFilters.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSectionHeaders) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    child: Text(
                      _formatSectionName(sectionName),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
                DynamicFieldsSection(
                  filters: sectionFilters,
                  formData: formData,
                  onFieldChanged: onFieldChanged,
                ),
              ],
            );
          }).toList(),
        );
      },
    );
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
