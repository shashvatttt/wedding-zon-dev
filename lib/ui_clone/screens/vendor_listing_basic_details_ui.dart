import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/routes/app_routes.dart';
import '../../features/vendor/providers/vendor_registration_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/theme/wz_colors.dart';
import '../../shared/widgets/wz_toast.dart';

class VendorListingBasicDetailsScreenUI extends StatefulWidget {
  const VendorListingBasicDetailsScreenUI({super.key});

  @override
  State<VendorListingBasicDetailsScreenUI> createState() =>
      _VendorListingBasicDetailsScreenUIState();
}

class _VendorListingBasicDetailsScreenUIState
    extends State<VendorListingBasicDetailsScreenUI> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyNameController;
  late TextEditingController _aadharController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _addressController;
  late TextEditingController _pinCodeController;

  @override
  void initState() {
    super.initState();
    debugPrint(
      '📍 [SCREEN] ========== VENDOR LISTING BASIC DETAILS ========== [ROUTE: ${AppRoutes.vendorRegistration}]',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      final provider = context.read<VendorRegistrationProvider>();

      if (currentUser != null) {
        if (provider.name.isEmpty &&
            currentUser.fullName != null &&
            currentUser.fullName!.isNotEmpty) {
          _nameController.text = currentUser.fullName!;
          provider.updateBasicDetails(name: currentUser.fullName!);
        }
        if (provider.email.isEmpty && currentUser.email != null) {
          _emailController.text = currentUser.email!;
          provider.updateBasicDetails(email: currentUser.email!);
        }
        if (provider.mobileNumber.isEmpty && currentUser.phone != null) {
          _mobileController.text = currentUser.phone!;
          provider.updateBasicDetails(mobileNumber: currentUser.phone!);
        }
      }
    });

    final provider = context.read<VendorRegistrationProvider>();
    _nameController = TextEditingController(text: provider.name);
    _companyNameController = TextEditingController(text: provider.companyName);
    _aadharController = TextEditingController(text: provider.aadharNumber);
    _emailController = TextEditingController(text: provider.email);
    _mobileController = TextEditingController(text: provider.mobileNumber);
    _addressController = TextEditingController(text: provider.address);
    _pinCodeController = TextEditingController(text: provider.pinCode);

    _nameController.addListener(() {
      provider.updateBasicDetails(name: _nameController.text);
    });
    _companyNameController.addListener(() {
      provider.updateBasicDetails(companyName: _companyNameController.text);
    });
    _aadharController.addListener(() {
      provider.updateBasicDetails(aadharNumber: _aadharController.text);
    });
    _emailController.addListener(() {
      provider.updateBasicDetails(email: _emailController.text);
    });
    _mobileController.addListener(() {
      provider.updateBasicDetails(mobileNumber: _mobileController.text);
    });
    _addressController.addListener(() {
      provider.updateBasicDetails(address: _addressController.text);
    });
    _pinCodeController.addListener(() {
      provider.updateBasicDetails(pinCode: _pinCodeController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _aadharController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  void _onNext() {
    debugPrint('[VENDOR_LISTING_UI] 🔘 Next button clicked');
    debugPrint(
      '[VENDOR_LISTING_UI] Form valid: ${_formKey.currentState?.validate()}',
    );

    if (!_formKey.currentState!.validate()) {
      debugPrint('[VENDOR_LISTING_UI] ❌ Form validation failed');
      return;
    }

    final provider = context.read<VendorRegistrationProvider>();
    debugPrint('[VENDOR_LISTING_UI] Service Type: "${provider.serviceType}"');
    debugPrint('[VENDOR_LISTING_UI] Product Type: "${provider.productType}"');

    if (provider.serviceType.isEmpty || provider.productType.isEmpty) {
      debugPrint('[VENDOR_LISTING_UI] ❌ Service or Product type is empty');
      WzToast.show(
        context,
        message: AppLocalizations.of(context)!.fillAllRequiredFields,
        type: WzToastType.error,
      );
      return;
    }

    debugPrint(
      '[VENDOR_LISTING_UI] ✅ Validation passed, navigating to bank details',
    );
    Navigator.pushNamed(context, '/ui-clone/vendor-listing-bank-details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Consumer<VendorRegistrationProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vendor Listing',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Basic Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            hint: 'Name*',
                            controller: _nameController,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            hint: 'Company Name*',
                            controller: _companyNameController,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            hint: 'Aadhar Number*',
                            controller: _aadharController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            hint: 'Email ID*',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Select Services*',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            value: provider.serviceType.isEmpty
                                ? null
                                : provider.serviceType,
                            hint: 'Select Select Services',
                            items: const [
                              'Photography',
                              'Venue',
                              'Catering',
                              'Makeup Artist',
                              'Decorator',
                              'Other',
                            ],
                            onChanged: (val) => provider.updateBasicDetails(
                              serviceType: val ?? '',
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Product',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            value: provider.productType.isEmpty
                                ? null
                                : provider.productType,
                            hint: 'Select Product',
                            items: const [
                              'Portrait/Landscape',
                              'Digital Products',
                              'Physical Goods',
                            ],
                            onChanged: (val) => provider.updateBasicDetails(
                              productType: val ?? '',
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Price Range',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: WzColors.primary,
                                        inactiveTrackColor: const Color(
                                          0xFFE5E7EB,
                                        ),
                                        thumbColor: WzColors.primary,
                                        trackHeight: 4,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 8,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                              overlayRadius: 16,
                                            ),
                                        rangeThumbShape:
                                            const RoundRangeSliderThumbShape(
                                              enabledThumbRadius: 8,
                                            ),
                                      ),
                                      child: RangeSlider(
                                        values: RangeValues(
                                          double.tryParse(
                                                provider.priceRangeStart,
                                              ) ??
                                              10000,
                                          double.tryParse(
                                                provider.priceRangeEnd,
                                              ) ??
                                              50000,
                                        ),
                                        min: 10000,
                                        max: 100000000,
                                        divisions: 1000,
                                        onChanged: (RangeValues values) {
                                          provider.updateBasicDetails(
                                            priceRangeStart: values.start
                                                .round()
                                                .toString(),
                                            priceRangeEnd: values.end
                                                .round()
                                                .toString(),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _formatPriceRange(
                                      double.tryParse(
                                            provider.priceRangeStart,
                                          ) ??
                                          10000,
                                      double.tryParse(provider.priceRangeEnd) ??
                                          50000,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    initialValue: provider.priceRangeStart,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Min amount',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      final numValue = double.tryParse(value);
                                      if (numValue != null &&
                                          numValue >= 10000 &&
                                          numValue <= 100000000) {
                                        provider.updateBasicDetails(
                                          priceRangeStart: value,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    initialValue: provider.priceRangeEnd,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Max amount',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      final numValue = double.tryParse(value);
                                      if (numValue != null &&
                                          numValue >= 10000 &&
                                          numValue <= 100000000) {
                                        provider.updateBasicDetails(
                                          priceRangeEnd: value,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Mobile No.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '+91',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: _buildTextField(
                                  hint: 'Mobile no.',
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Country',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            value: provider.country.isEmpty
                                ? 'India'
                                : provider.country,
                            items: const ['India', 'USA', 'UK', 'Canada'],
                            onChanged: (val) => provider.updateBasicDetails(
                              country: val ?? 'India',
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'State',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            value: provider.state.isEmpty
                                ? null
                                : provider.state,
                            hint: 'Select State',
                            items: const [
                              'Andhra Pradesh',
                              'Arunachal Pradesh',
                              'Assam',
                              'Bihar',
                              'Chhattisgarh',
                              'Goa',
                              'Gujarat',
                              'Haryana',
                              'Himachal Pradesh',
                              'Jharkhand',
                              'Karnataka',
                              'Kerala',
                              'Madhya Pradesh',
                              'Maharashtra',
                              'Manipur',
                              'Meghalaya',
                              'Mizoram',
                              'Nagaland',
                              'Odisha',
                              'Punjab',
                              'Rajasthan',
                              'Sikkim',
                              'Tamil Nadu',
                              'Telangana',
                              'Tripura',
                              'Uttar Pradesh',
                              'Uttarakhand',
                              'West Bengal',
                              'Andaman and Nicobar Islands',
                              'Chandigarh',
                              'Dadra and Nagar Haveli and Daman and Diu',
                              'Delhi',
                              'Jammu and Kashmir',
                              'Ladakh',
                              'Lakshadweep',
                              'Puducherry',
                            ],
                            onChanged: (val) =>
                                provider.updateBasicDetails(state: val ?? ''),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Local Address',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  hint: 'Local Address',
                                  controller: _addressController,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: _buildTextField(
                                  hint: 'Pin Code*',
                                  controller: _pinCodeController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WzColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor: WzColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF3F4F6) : Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: readOnly ? const Color(0xFF6B7280) : const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  String _formatPriceRange(double start, double end) {
    String formatPrice(double price) {
      if (price >= 10000000) {
        return '₹${(price / 10000000).toStringAsFixed(1)}Cr';
      } else if (price >= 100000) {
        return '₹${(price / 100000).toStringAsFixed(1)}L';
      } else {
        return '₹${(price / 1000).toStringAsFixed(0)}k';
      }
    }

    return '${formatPrice(start)}-${formatPrice(end)}';
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? hint,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint != null
              ? Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                )
              : null,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Color(0xFF6B7280),
          ),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF111827),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
