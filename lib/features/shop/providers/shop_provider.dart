import 'package:flutter/material.dart';
import '../repositories/shop_repository.dart';
import '../../vendor/models/product_model.dart';

enum SortOption { priceLowToHigh, priceHighToLow, nameAtoZ, nameZtoA }

class ShopProvider extends ChangeNotifier {
  late final ShopRepository _repository;

  ShopProvider(apiService) {
    _repository = ShopRepository(apiService);
  }

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  final Set<String> _selectedCategories = {};
  double _minPrice = 0;
  double _maxPrice = 1000000;
  SortOption _sortOption = SortOption.nameAtoZ;

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Set<String> get selectedCategories => _selectedCategories;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  SortOption get sortOption => _sortOption;

  List<String> get availableCategories {
    return _allProducts.map((p) => p.category).toSet().toList()..sort();
  }

  Future<void> loadProducts() async {
    debugPrint('[SHOP_PROVIDER] 🛍️ Loading all products...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allProducts = await _repository.getAllProducts();
      debugPrint('[SHOP_PROVIDER] ✅ Loaded ${_allProducts.length} products');

      _applyFiltersAndSort();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[SHOP_PROVIDER] ❌ Error loading products: $e');
      _error = 'Failed to load products: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    debugPrint('[SHOP_PROVIDER] 🔍 Search query: "$query"');
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void toggleCategory(String category) {
    debugPrint('[SHOP_PROVIDER] 🏷️ Toggle category: $category');
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setPriceRange(double min, double max) {
    debugPrint('[SHOP_PROVIDER] 💰 Price range: ₹$min - ₹$max');
    _minPrice = min;
    _maxPrice = max;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    debugPrint('[SHOP_PROVIDER] 🔄 Sort option: $option');
    _sortOption = option;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilters() {
    debugPrint('[SHOP_PROVIDER] 🧹 Clearing all filters');
    _searchQuery = '';
    _selectedCategories.clear();
    _minPrice = 0;
    _maxPrice = 1000000;
    _sortOption = SortOption.nameAtoZ;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    try {
      debugPrint('[SHOP_PROVIDER] 📊 Applying filters and sorting...');
      debugPrint('[SHOP_PROVIDER] 📋 Current State:');
      debugPrint('[SHOP_PROVIDER]   - Total Products: ${_allProducts.length}');
      debugPrint('[SHOP_PROVIDER]   - Search Query: "$_searchQuery"');
      debugPrint(
        '[SHOP_PROVIDER]   - Selected Categories: $_selectedCategories',
      );
      debugPrint('[SHOP_PROVIDER]   - Price Range: ₹$_minPrice - ₹$_maxPrice');
      debugPrint('[SHOP_PROVIDER]   - Sort Option: $_sortOption');

      List<Product> filtered = List.from(_allProducts);

      if (_searchQuery.isNotEmpty) {
        try {
          filtered = filtered.where((product) {
            return product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.category.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
          debugPrint(
            '[SHOP_PROVIDER] 🔍 After search: ${filtered.length} products',
          );
        } catch (e) {
          debugPrint('[SHOP_PROVIDER] ❌ Error in search filter: $e');
        }
      }

      if (_selectedCategories.isNotEmpty) {
        try {
          filtered = filtered.where((product) {
            return _selectedCategories.contains(product.category);
          }).toList();
          debugPrint(
            '[SHOP_PROVIDER] 🏷️ After category filter: ${filtered.length} products',
          );
        } catch (e) {
          debugPrint('[SHOP_PROVIDER] ❌ Error in category filter: $e');
        }
      }

      try {
        filtered = filtered.where((product) {
          return product.price >= _minPrice && product.price <= _maxPrice;
        }).toList();
        debugPrint(
          '[SHOP_PROVIDER] 💰 After price filter: ${filtered.length} products',
        );
      } catch (e) {
        debugPrint('[SHOP_PROVIDER] ❌ Error in price filter: $e');
      }

      try {
        switch (_sortOption) {
          case SortOption.priceLowToHigh:
            filtered.sort((a, b) => a.price.compareTo(b.price));
            debugPrint('[SHOP_PROVIDER] 🔄 Sorted: Price Low to High');
            break;
          case SortOption.priceHighToLow:
            filtered.sort((a, b) => b.price.compareTo(a.price));
            debugPrint('[SHOP_PROVIDER] 🔄 Sorted: Price High to Low');
            break;
          case SortOption.nameAtoZ:
            filtered.sort((a, b) => a.name.compareTo(b.name));
            debugPrint('[SHOP_PROVIDER] 🔄 Sorted: Name A to Z');
            break;
          case SortOption.nameZtoA:
            filtered.sort((a, b) => b.name.compareTo(a.name));
            debugPrint('[SHOP_PROVIDER] 🔄 Sorted: Name Z to A');
            break;
        }
      } catch (e) {
        debugPrint('[SHOP_PROVIDER] ❌ Error in sorting: $e');
      }

      _filteredProducts = filtered;
      debugPrint(
        '[SHOP_PROVIDER] ✅ Final filtered products: ${_filteredProducts.length}',
      );
      debugPrint('');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('╔════════════════════════════════════════════════════════╗');
      debugPrint('║ [SHOP_PROVIDER] ❌ CRITICAL FILTER ERROR               ║');
      debugPrint('╚════════════════════════════════════════════════════════╝');
      debugPrint('[SHOP_PROVIDER] 🔴 Error Type: ${e.runtimeType}');
      debugPrint('[SHOP_PROVIDER] 🔴 Error Message: $e');
      debugPrint('[SHOP_PROVIDER] 📚 Stack Trace:');
      debugPrint(stackTrace.toString().split('\n').take(15).join('\n'));
      debugPrint('╚════════════════════════════════════════════════════════╝');
      debugPrint('');

      _filteredProducts = List.from(_allProducts);
      _error = 'Filter error: $e';
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
