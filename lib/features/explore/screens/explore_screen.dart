import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../matches/providers/match_provider.dart';
import '../widgets/advanced_filter_bottom_sheet.dart';
import '../widgets/user_card_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {}

  void _onSearchTextChanged() {
    setState(() {});
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      debugPrint('[EXPLORE] Search query: $query');
      final provider = context.read<MatchProvider>();
      final filters = Map<String, dynamic>.from(provider.activeFilters);

      if (query.isNotEmpty) {
        filters['name'] = query;
      } else {
        filters.remove('name');
      }

      provider.search(filters);
    });
  }

  void _showFilters() {
    final provider = context.read<MatchProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilterBottomSheet(
        initialFilters: provider.activeFilters,
        onApply: (filters) {
          if (_searchController.text.isNotEmpty) {
            filters['name'] = _searchController.text;
          }
          provider.search(filters);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Explore', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Consumer<MatchProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilters,
                  ),
                  if (provider.activeFilters.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF2F55),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search by name, ID...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            Consumer<MatchProvider>(
              builder: (context, provider, child) {
                if (provider.activeFilters.isEmpty) {
                  return const SizedBox.shrink();
                }

                return SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children:
                        provider.activeFilters.entries.map((entry) {
                          if (entry.key == 'name') {
                            return const SizedBox.shrink();
                          }

                          String label = '${entry.key}: ${entry.value}';
                          if (entry.key == 'sortBy') {
                            label = 'Sort: ${entry.value}';
                          } else if (entry.key == 'minAge' ||
                              entry.key == 'maxAge') {
                            return _buildFilterChip(
                              label,
                              () => provider.removeFilter(entry.key),
                            );
                          }

                          return _buildFilterChip(
                            label,
                            () => provider.removeFilter(entry.key),
                          );
                        }).toList() +
                        [
                          TextButton(
                            onPressed: provider.clearSearch,
                            child: const Text(
                              'Clear All',
                              style: TextStyle(color: Color(0xFFEF2F55)),
                            ),
                          ),
                        ],
                  ),
                );
              },
            ),

            Expanded(
              child: Consumer<MatchProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final results = provider.searchResults;

                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.activeFilters.isNotEmpty ||
                                    _searchController.text.isNotEmpty
                                ? 'No matches found'
                                : 'Start searching to find matches',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return UserCardWidget(
                        user: results[index].toJson(),
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDelete,
        backgroundColor: Colors.pink.shade50,
        labelStyle: const TextStyle(
          color: Color(0xFFEF2F55),
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
      ),
    );
  }
}
