import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../models/product_model.dart';
import 'package:http_parser/http_parser.dart';

class VendorRepository {
  final ApiService _apiService;

  VendorRepository(this._apiService);

  Future<Map<String, dynamic>> registerAsVendor(
    Map<String, dynamic> registrationData,
  ) async {
    try {
      debugPrint('');
      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ [VENDOR_REPO] 🚀 SENDING REGISTRATION TO BACKEND          ║',
      );
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('[VENDOR_REPO] 📡 Endpoint: POST /auth/register-details');
      debugPrint('[VENDOR_REPO] 📦 Request Body (JSON):');

      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(registrationData);
      jsonString.split('\n').forEach((line) {
        debugPrint('[VENDOR_REPO]   $line');
      });

      debugPrint('[VENDOR_REPO] ⏳ Sending request...');

      final response = await _apiService.dio.post(
        '/auth/register-details',
        data: registrationData,
      );

      debugPrint('');
      debugPrint('[VENDOR_REPO] ✅ REGISTRATION SUCCESSFUL');
      debugPrint('[VENDOR_REPO] 📊 Response Status: ${response.statusCode}');
      debugPrint('[VENDOR_REPO] 📦 Response Body:');

      final responseJsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(response.data);
      responseJsonString.split('\n').forEach((line) {
        debugPrint('[VENDOR_REPO]   $line');
      });

      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');

      return response.data;
    } catch (e) {
      debugPrint('');
      debugPrint('[VENDOR_REPO] ❌ REGISTRATION FAILED');
      debugPrint('[VENDOR_REPO] 🔴 Error: $e');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateVendorProfile(
    Map<String, dynamic> vendorDetails,
  ) async {
    try {
      debugPrint('[VENDOR_REPO] 📝 Updating vendor profile...');

      final response = await _apiService.dio.post(
        '/auth/register-details',
        data: {'role': 'vendor', 'vendor_details': vendorDetails},
      );

      debugPrint('[VENDOR_REPO] ✅ Vendor profile updated');
      return response.data;
    } catch (e) {
      debugPrint('[VENDOR_REPO] ❌ Error updating vendor profile: $e');
      rethrow;
    }
  }

  Future<void> updateVendorStatus(String status) async {
    try {
      debugPrint('[VENDOR_REPO] 📝 Updating vendor status to: $status');

      await _apiService.dio.patch('/users/me', data: {'vendor_status': status});

      debugPrint('[VENDOR_REPO] ✅ Vendor status updated to: $status');
    } catch (e) {
      debugPrint('[VENDOR_REPO] ❌ Error updating vendor status: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getVendorProfile() async {
    try {
      debugPrint('[VENDOR_REPO] 📝 Fetching vendor profile...');

      final response = await _apiService.dio.get('/auth/me');

      debugPrint('[VENDOR_REPO] ✅ Vendor profile fetched');
      return response.data;
    } catch (e) {
      debugPrint('[VENDOR_REPO] ❌ Error fetching vendor profile: $e');
      rethrow;
    }
  }

  Future<String> uploadDocument(String filePath) async {
    try {
      debugPrint('[VENDOR_REPO] 📄 Uploading document: $filePath');

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          filePath,
          contentType: MediaType('application', 'pdf'),
        ),
      });

      final response = await _apiService.dio.post('/uploads', data: formData);

      final documentUrl = response.data['url'];
      debugPrint('[VENDOR_REPO] ✅ Document uploaded: $documentUrl');
      return documentUrl;
    } catch (e) {
      debugPrint('[VENDOR_REPO] ❌ Error uploading document: $e');
      rethrow;
    }
  }

  Future<String> uploadImage(String filePath) async {
    try {
      debugPrint('[VENDOR_REPO] 📸 Uploading image: $filePath');

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          filePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _apiService.dio.post('/uploads', data: formData);

      final imageUrl = response.data['url'];
      debugPrint('[VENDOR_REPO] ✅ Image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      debugPrint('[VENDOR_REPO] ❌ Error uploading image: $e');
      rethrow;
    }
  }

  Future<List<Product>> getMyProducts() async {
    try {
      debugPrint('[VENDOR_REPO] 📦 Fetching vendor products...');

      final response = await _apiService.dio.get('/products/my/products');

      final products = (response.data['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();

      debugPrint('[VENDOR_REPO] ✅ Fetched ${products.length} products');
      return products;
    } catch (e) {
      debugPrint('[VENDOR_REPO] ❌ Error fetching products: $e');
      rethrow;
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    debugPrint('');
    debugPrint('┌─────────────────────────────────────────────────────────┐');
    debugPrint('│ [VENDOR_REPO] 🏗️ CREATE PRODUCT API CALL               │');
    debugPrint('└─────────────────────────────────────────────────────────┘');
    debugPrint('[VENDOR_REPO] 📡 API Endpoint: POST /products');
    debugPrint('[VENDOR_REPO] 📦 Request Payload:');
    debugPrint('[VENDOR_REPO]    ${productData.toString()}');
    debugPrint('[VENDOR_REPO] 📊 Payload Details:');
    productData.forEach((key, value) {
      if (key == 'images' && value is List) {
        debugPrint('[VENDOR_REPO]    • $key: [${value.length} images]');
        for (var i = 0; i < value.length; i++) {
          debugPrint('[VENDOR_REPO]      [$i]: ${value[i]}');
        }
      } else {
        debugPrint('[VENDOR_REPO]    • $key: $value');
      }
    });
    debugPrint('[VENDOR_REPO] ⏳ Sending request...');

    try {
      final response = await _apiService.dio.post(
        '/products',
        data: productData,
      );

      debugPrint('[VENDOR_REPO] ✅ API RESPONSE RECEIVED');
      debugPrint('[VENDOR_REPO] 📊 Status Code: ${response.statusCode}');
      debugPrint('[VENDOR_REPO] 📦 Response Data: ${response.data}');
      debugPrint(
        '[VENDOR_REPO] 📋 Response Type: ${response.data.runtimeType}',
      );

      if (response.data != null && response.data['data'] != null) {
        final product = Product.fromJson(response.data['data']);
        debugPrint('[VENDOR_REPO] 🎯 Product object created from response');
        debugPrint('[VENDOR_REPO] ✅ Product ID: ${product.id}');
        debugPrint('[VENDOR_REPO] ✅ Product Name: ${product.name}');
        debugPrint(
          '┌─────────────────────────────────────────────────────────┐',
        );
        debugPrint(
          '│ [VENDOR_REPO] 🎉 CREATE PRODUCT SUCCESS                │',
        );
        debugPrint(
          '└─────────────────────────────────────────────────────────┘',
        );
        debugPrint('');
        return product;
      } else {
        debugPrint('[VENDOR_REPO] ⚠️ WARNING: Unexpected response structure');
        debugPrint('[VENDOR_REPO] ⚠️ response.data: ${response.data}');
        throw Exception('Invalid response format: data field missing');
      }
    } on DioException catch (dioError, stackTrace) {
      debugPrint('');
      debugPrint('╔═════════════════════════════════════════════════════════╗');
      debugPrint('║ [VENDOR_REPO] ❌ DIO EXCEPTION - CREATE PRODUCT          ║');
      debugPrint('╚═════════════════════════════════════════════════════════╝');
      debugPrint('[VENDOR_REPO] 🔴 Error Type: ${dioError.type}');
      debugPrint(
        '[VENDOR_REPO] 🔴 Status Code: ${dioError.response?.statusCode}',
      );
      debugPrint('[VENDOR_REPO] 🔴 Error Message: ${dioError.message}');
      debugPrint('[VENDOR_REPO] 📋 Response Data: ${dioError.response?.data}');
      debugPrint(
        '[VENDOR_REPO] 📍 Request URI: ${dioError.requestOptions.uri}',
      );
      debugPrint(
        '[VENDOR_REPO] 📍 Request Method: ${dioError.requestOptions.method}',
      );
      debugPrint(
        '[VENDOR_REPO] 📦 Request Data: ${dioError.requestOptions.data}',
      );
      debugPrint('[VENDOR_REPO] 📚 Stack Trace:');
      debugPrint(stackTrace.toString().split('\n').take(10).join('\n'));
      debugPrint('╚═════════════════════════════════════════════════════════╝');
      debugPrint('');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('╔═════════════════════════════════════════════════════════╗');
      debugPrint('║ [VENDOR_REPO] ❌ GENERAL EXCEPTION - CREATE PRODUCT      ║');
      debugPrint('╚═════════════════════════════════════════════════════════╝');
      debugPrint('[VENDOR_REPO] 🔴 Exception Type: ${e.runtimeType}');
      debugPrint('[VENDOR_REPO] 🔴 Exception Message: $e');
      debugPrint('[VENDOR_REPO] 📚 Stack Trace:');
      debugPrint(stackTrace.toString().split('\n').take(10).join('\n'));
      debugPrint('╚═════════════════════════════════════════════════════════╝');
      debugPrint('');
      rethrow;
    }
  }

  Future<Product> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    try {
      debugPrint('[VENDOR_REPO] ✏️ Updating product: $productId');

      final response = await _apiService.dio.patch(
        '/products/$productId',
        data: updates,
      );

      final product = Product.fromJson(response.data['data']);
      debugPrint('[VENDOR_REPO] ✅ Product updated');
      return product;
    } catch (e) {
      debugPrint('[VENDOR_REPO] ❌ Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      debugPrint('[VENDOR_REPO] 🗑️ Deleting product: $productId');

      await _apiService.dio.delete('/products/$productId');

      debugPrint('[VENDOR_REPO] ✅ Product deleted');
    } catch (e) {
      debugPrint('[VENDOR_REPO] ❌ Error deleting product: $e');
      rethrow;
    }
  }

  Future<List<String>> uploadMultipleImages(List<String> filePaths) async {
    try {
      debugPrint('[VENDOR_REPO] 📸 Uploading ${filePaths.length} images...');

      final uploadTasks = filePaths.map((path) => uploadImage(path)).toList();
      final urls = await Future.wait(uploadTasks);

      debugPrint('[VENDOR_REPO] ✅ All images uploaded successfully');
      return urls;
    } catch (e) {
      debugPrint('[VENDOR_REPO] ❌ Error uploading multiple images: $e');
      rethrow;
    }
  }
}
