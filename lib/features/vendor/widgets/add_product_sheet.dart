import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/image_upload_widget.dart';
import '../../../shared/widgets/wz_loading.dart';
import '../../../shared/widgets/wz_toast.dart';

class AddProductSheet extends StatefulWidget {
  const AddProductSheet({super.key});

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  List<String> _selectedImagePaths = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createProduct() async {
    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════════╗');
    debugPrint('║ [ADD_PRODUCT_SHEET] 🎬 CREATE PRODUCT INITIATED           ║');
    debugPrint('╚═══════════════════════════════════════════════════════════╝');

    if (!_formKey.currentState!.validate()) {
      debugPrint('[ADD_PRODUCT_SHEET] ❌ Form validation FAILED');
      debugPrint('[ADD_PRODUCT_SHEET] ℹ️ Please check form fields');
      return;
    }

    debugPrint('[ADD_PRODUCT_SHEET] ✅ Form validation PASSED');
    debugPrint('[ADD_PRODUCT_SHEET] 📋 FORM DATA:');
    debugPrint(
      '[ADD_PRODUCT_SHEET]    📝 Name: ${_nameController.text.trim()}',
    );
    debugPrint('[ADD_PRODUCT_SHEET]    🏷️ Category: $_selectedCategory');
    debugPrint(
      '[ADD_PRODUCT_SHEET]    💰 Price: ${_priceController.text.trim()}',
    );
    debugPrint(
      '[ADD_PRODUCT_SHEET]    📄 Description length: ${_descriptionController.text.trim().length} chars',
    );
    debugPrint(
      '[ADD_PRODUCT_SHEET]    🖼️ Selected images: ${_selectedImagePaths.length}',
    );
    debugPrint('[ADD_PRODUCT_SHEET]    📸 Image paths: $_selectedImagePaths');

    setState(() {
      _isLoading = true;
    });
    debugPrint('[ADD_PRODUCT_SHEET] 📦 UI State: isLoading = true');

    try {
      final vendorProvider = Provider.of<VendorProvider>(
        context,
        listen: false,
      );

      debugPrint('[ADD_PRODUCT_SHEET] 📤 Step 1/2: Uploading images...');
      List<String> imageUrls = [];
      if (_selectedImagePaths.isNotEmpty) {
        debugPrint(
          '[ADD_PRODUCT_SHEET] 📸 Uploading ${_selectedImagePaths.length} images',
        );
        imageUrls = await vendorProvider.uploadProductImages(
          _selectedImagePaths,
        );
        debugPrint('[ADD_PRODUCT_SHEET] ✅ Images uploaded successfully');
        debugPrint('[ADD_PRODUCT_SHEET] 🔗 Image URLs: $imageUrls');
      } else {
        debugPrint(
          '[ADD_PRODUCT_SHEET] ℹ️ No images selected, skipping upload',
        );
      }

      debugPrint('[ADD_PRODUCT_SHEET] 📤 Step 2/2: Creating product...');
      final success = await vendorProvider.addProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory!,
        images: imageUrls,
      );

      if (success && mounted) {
        debugPrint('[ADD_PRODUCT_SHEET] 🎉 Product creation SUCCESS');
        debugPrint('[ADD_PRODUCT_SHEET] 🚪 Closing bottom sheet');
        Navigator.of(context).pop();
        WzToast.show(
          context,
          message: 'Product created successfully!',
          type: WzToastType.success,
        );
        debugPrint('[ADD_PRODUCT_SHEET] ✅ Success message shown to user');
      } else if (mounted) {
        debugPrint('[ADD_PRODUCT_SHEET] ❌ Product creation FAILED');
        debugPrint('[ADD_PRODUCT_SHEET] 🔴 Error: ${vendorProvider.error}');
        WzToast.show(
          context,
          message: vendorProvider.error ?? 'Failed to create product',
          type: WzToastType.error,
        );
        debugPrint('[ADD_PRODUCT_SHEET] ⚠️ Error message shown to user');
      }
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint(
        '╔═══════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ [ADD_PRODUCT_SHEET] ❌ EXCEPTION IN CREATE PRODUCT        ║',
      );
      debugPrint(
        '╚═══════════════════════════════════════════════════════════╝',
      );
      debugPrint('[ADD_PRODUCT_SHEET] 🔴 Exception Type: ${e.runtimeType}');
      debugPrint('[ADD_PRODUCT_SHEET] 🔴 Exception Message: $e');
      debugPrint('[ADD_PRODUCT_SHEET] 📍 Stack Trace (first 10 lines):');
      debugPrint(stackTrace.toString().split('\n').take(10).join('\n'));
      debugPrint(
        '╚═══════════════════════════════════════════════════════════╝',
      );

      if (mounted) {
        WzToast.show(context, message: 'Error: $e', type: WzToastType.error);
        debugPrint('[ADD_PRODUCT_SHEET] ⚠️ Exception message shown to user');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('[ADD_PRODUCT_SHEET] 📦 UI State: isLoading = false');
      }
      debugPrint(
        '╔═══════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ [ADD_PRODUCT_SHEET] 🏁 CREATE PRODUCT FLOW COMPLETE      ║',
      );
      debugPrint(
        '╚═══════════════════════════════════════════════════════════╝',
      );
      debugPrint('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g., Silk Saree',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CategoryDropdown(
                      value: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price (₹)',
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your product...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Product Images',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ImageUploadWidget(
                imageUrls: const [],
                onImagesSelected: (paths) {
                  setState(() {
                    _selectedImagePaths = paths;
                  });
                },
                maxImages: 5,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const WzLoadingSmall(color: Colors.white)
                        : const Text('Create Product'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
