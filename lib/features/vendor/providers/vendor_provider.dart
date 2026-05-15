import 'package:flutter/material.dart';
import '../repositories/vendor_repository.dart';
import '../models/product_model.dart';
import '../../../core/services/api_service.dart';

class VendorProvider extends ChangeNotifier {
  late final VendorRepository _repository;

  VendorProvider(ApiService apiService) {
    _repository = VendorRepository(apiService);
  }

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalProducts => _products.length;
  int get totalViews =>
      _products.fold(0, (sum, product) => sum + (product.numReviews ?? 0));

  Future<void> loadProducts() async {
    try {
      debugPrint('[VENDOR_PROVIDER] 📦 Loading products...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _repository.getMyProducts();

      _isLoading = false;
      notifyListeners();
      debugPrint('[VENDOR_PROVIDER] ✅ Loaded ${_products.length} products');
    } catch (e) {
      _error = 'Failed to load products: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('[VENDOR_PROVIDER] ❌ Error loading products: $e');
    }
  }

  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    required List<String> images,
  }) async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('[VENDOR_PROVIDER] 🚀 ADD PRODUCT STARTED');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('[VENDOR_PROVIDER] 📋 PRODUCT DETAILS:');
    debugPrint('[VENDOR_PROVIDER]    📝 Name: $name');
    debugPrint('[VENDOR_PROVIDER]    🏷️ Category: $category');
    debugPrint('[VENDOR_PROVIDER]    💰 Price: ₹$price');
    debugPrint(
      '[VENDOR_PROVIDER]    📄 Description: ${description.length > 50 ? "${description.substring(0, 50)}..." : description}',
    );
    debugPrint('[VENDOR_PROVIDER]    🖼️ Images count: ${images.length}');
    debugPrint('[VENDOR_PROVIDER]    📸 Image URLs: $images');
    debugPrint('═══════════════════════════════════════════════════════════');

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      debugPrint('[VENDOR_PROVIDER] 📦 State updated: isLoading = true');

      final productData = {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'images': images,
      };

      debugPrint('[VENDOR_PROVIDER] 📤 Sending data to repository...');
      debugPrint('[VENDOR_PROVIDER] 📊 Payload: $productData');

      final product = await _repository.createProduct(productData);

      debugPrint('[VENDOR_PROVIDER] ✅ SUCCESS! Product created');
      debugPrint('[VENDOR_PROVIDER] 📦 Response Product Details:');
      debugPrint('[VENDOR_PROVIDER]    🆔 ID: ${product.id}');
      debugPrint('[VENDOR_PROVIDER]    📝 Name: ${product.name}');
      debugPrint('[VENDOR_PROVIDER]    💰 Price: ₹${product.price}');
      debugPrint('[VENDOR_PROVIDER]    🏷️ Category: ${product.category}');
      debugPrint('[VENDOR_PROVIDER]    🖼️ Images: ${product.images.length}');
      debugPrint(
        '[VENDOR_PROVIDER]    ⭐ Rating: ${product.averageRating ?? "No rating"}',
      );
      debugPrint('[VENDOR_PROVIDER]    🔢 Reviews: ${product.numReviews ?? 0}');

      _products.insert(0, product);
      debugPrint('[VENDOR_PROVIDER] 📊 Product added to list at position 0');
      debugPrint(
        '[VENDOR_PROVIDER] 📈 Total products now: ${_products.length}',
      );

      _isLoading = false;
      notifyListeners();
      debugPrint('[VENDOR_PROVIDER] 📦 State updated: isLoading = false');

      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('[VENDOR_PROVIDER] 🎉 ADD PRODUCT COMPLETED SUCCESSFULLY');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('');
      return true;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint(
        '╔═══════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ [VENDOR_PROVIDER] ❌ ADD PRODUCT FAILED                    ║',
      );
      debugPrint(
        '╚═══════════════════════════════════════════════════════════╝',
      );
      debugPrint('[VENDOR_PROVIDER] 🔴 ERROR TYPE: ${e.runtimeType}');
      debugPrint('[VENDOR_PROVIDER] 🔴 ERROR MESSAGE:');
      debugPrint('[VENDOR_PROVIDER]    $e');
      debugPrint('[VENDOR_PROVIDER] 📍 STACK TRACE:');
      debugPrint(
        '[VENDOR_PROVIDER]    ${stackTrace.toString().split('\n').take(5).join('\n    ')}',
      );
      debugPrint(
        '╔═══════════════════════════════════════════════════════════╗',
      );
      debugPrint('');

      _error = 'Failed to add product: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(
        '[VENDOR_Provider] 📦 State updated: isLoading = false, error set',
      );

      return false;
    }
  }

  Future<bool> editProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? images,
  }) async {
    try {
      debugPrint('[VENDOR_PROVIDER] ✏️ Editing product: $productId');
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (category != null) updates['category'] = category;
      if (images != null) updates['images'] = images;

      final updatedProduct = await _repository.updateProduct(
        productId,
        updates,
      );

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      _isLoading = false;
      notifyListeners();

      debugPrint('[VENDOR_PROVIDER] ✅ Product updated successfully');
      return true;
    } catch (e) {
      _error = 'Failed to update product: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('[VENDOR_PROVIDER] ❌ Error editing product: $e');
      return false;
    }
  }

  Future<bool> removeProduct(String productId) async {
    try {
      debugPrint('[VENDOR_PROVIDER] 🗑️ Removing product: $productId');
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);

      _isLoading = false;
      notifyListeners();

      debugPrint('[VENDOR_PROVIDER] ✅ Product removed successfully');
      return true;
    } catch (e) {
      _error = 'Failed to remove product: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('[VENDOR_PROVIDER] ❌ Error removing product: $e');
      return false;
    }
  }

  Future<List<String>> uploadProductImages(List<String> filePaths) async {
    try {
      debugPrint(
        '[VENDOR_PROVIDER] 📸 Uploading ${filePaths.length} images...',
      );

      final urls = await _repository.uploadMultipleImages(filePaths);

      debugPrint('[VENDOR_PROVIDER] ✅ Images uploaded successfully');
      return urls;
    } catch (e) {
      _error = 'Failed to upload images: $e';
      notifyListeners();
      debugPrint('[VENDOR_PROVIDER] ❌ Error uploading images: $e');
      rethrow;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
