import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../repositories/vendor_repository.dart';
import '../models/vendor_details.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/indian_states.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../shared/widgets/wz_loading.dart';
import '../../../shared/widgets/wz_toast.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadharController = TextEditingController();
  final _mobileController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _mapLinkController = TextEditingController();

  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();
  final _linkedMobileController = TextEditingController();
  final _gstinController = TextEditingController();

  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _twitterController = TextEditingController();

  final _workingHoursController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedServiceType;
  String? _selectedProduct;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedAccountType;

  String? _businessGlanceFileName;
  String? _businessGlanceUrl;

  bool _isLoading = false;
  bool _isFetchingData = false;

  final List<String> _priceRanges = ['\$', '\$\$', '\$\$\$', '\$\$\$\$'];

  @override
  void initState() {
    super.initState();
    _fetchExistingData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _aadharController.dispose();
    _mobileController.dispose();
    _priceRangeController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _mapLinkController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    _linkedMobileController.dispose();
    _gstinController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _youtubeController.dispose();
    _twitterController.dispose();
    _workingHoursController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingData() async {
    setState(() {
      _isFetchingData = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final repository = VendorRepository(apiService);
      final response = await repository.getVendorProfile();

      if (response['user'] != null) {
        final user = response['user'];
        final vendorDetailsMap =
            user['vendor_details'] as Map<String, dynamic>?;

        if (vendorDetailsMap != null) {
          debugPrint('[VENDOR_REG] 📥 Pre-populating vendor details');
          final vendorDetails = VendorDetails.fromJson(vendorDetailsMap);

          setState(() {
            _nameController.text = vendorDetails.name ?? '';
            _companyNameController.text = vendorDetails.businessName ?? '';
            _emailController.text = vendorDetails.email ?? user['email'] ?? '';
            _aadharController.text = vendorDetails.aadharNumber ?? '';
            _mobileController.text =
                vendorDetails.mobileNo ?? user['phone'] ?? '';
            _priceRangeController.text = vendorDetails.priceRange ?? '';
            _addressController.text = vendorDetails.businessAddress ?? '';
            _pincodeController.text = vendorDetails.pincode ?? '';
            _mapLinkController.text = vendorDetails.embeddedMapLink ?? '';

            _selectedServiceType = vendorDetails.serviceType;
            _selectedProduct = vendorDetails.product;
            _selectedCountry = vendorDetails.country;
            _selectedState = vendorDetails.state;

            _accountHolderController.text =
                vendorDetails.accountHolderName ?? '';
            _bankNameController.text = vendorDetails.bankName ?? '';
            _accountNumberController.text = vendorDetails.accountNumber ?? '';
            _ifscController.text = vendorDetails.ifscCode ?? '';
            _upiController.text = vendorDetails.upiId ?? '';
            _linkedMobileController.text =
                vendorDetails.linkedMobileNumber ?? '';
            _gstinController.text = vendorDetails.gstin ?? '';
            _selectedAccountType = vendorDetails.accountType;

            _instagramController.text = vendorDetails.instagramLink ?? '';
            _facebookController.text = vendorDetails.facebookLink ?? '';
            _youtubeController.text = vendorDetails.youtubeLink ?? '';
            _twitterController.text = vendorDetails.twitterLink ?? '';
            _businessGlanceUrl = vendorDetails.businessGlance;

            _workingHoursController.text = vendorDetails.workingHours ?? '';
            _descriptionController.text = vendorDetails.description ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('[VENDOR_REG] ⚠️ Error fetching existing data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingData = false;
        });
      }
    }
  }

  Future<void> _pickBusinessGlance() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _businessGlanceFileName = file.name;
        });

        if (file.path != null) {
          final apiService = context.read<ApiService>();
          final repository = VendorRepository(apiService);
          final url = await repository.uploadDocument(file.path!);
          setState(() {
            _businessGlanceUrl = url;
          });
        }
      }
    } catch (e) {
      debugPrint('[VENDOR_REG] ❌ Error picking file: $e');
      if (mounted) {
        WzToast.show(
          context,
          message: 'Failed to upload file: $e',
          type: WzToastType.error,
        );
      }
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    debugPrint('');
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint(
      '║ [VENDOR_REG] 📝 REGISTRATION SUBMIT CLICKED                ║',
    );
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final vendorDetails = VendorDetails(
        name: _nameController.text.trim(),
        businessName: _companyNameController.text.trim(),
        email: _emailController.text.trim(),
        aadharNumber: _aadharController.text.trim(),
        mobileNo: _mobileController.text.trim(),
        priceRange: _priceRangeController.text.trim(),
        businessAddress: _addressController.text.trim(),
        pincode: _pincodeController.text.trim(),
        serviceType: _selectedServiceType,
        product: _selectedProduct,
        embeddedMapLink: _mapLinkController.text.trim(),
        country: _selectedCountry ?? 'India',
        state: _selectedState,

        accountHolderName: _accountHolderController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        accountType: _selectedAccountType,
        upiId: _upiController.text.trim(),
        linkedMobileNumber: _linkedMobileController.text.trim(),
        gstin: _gstinController.text.trim(),

        instagramLink: _instagramController.text.trim(),
        facebookLink: _facebookController.text.trim(),
        youtubeLink: _youtubeController.text.trim(),
        twitterLink: _twitterController.text.trim(),
        businessGlance: _businessGlanceUrl,

        workingHours: _workingHoursController.text.trim(),
        description: _descriptionController.text.trim(),
      ).toJson();

      debugPrint('[VENDOR_REG] 📦 Vendor Details:');
      vendorDetails.forEach((key, value) {
        debugPrint('[VENDOR_REG]   - $key: $value');
      });
      debugPrint('[VENDOR_REG] ========================================');

      final apiService = context.read<ApiService>();
      final repository = VendorRepository(apiService);

      debugPrint('[VENDOR_REG] 🌐 Calling registerAsVendor API...');
      await repository.registerAsVendor(vendorDetails);

      debugPrint('[VENDOR_REG] ✅ Registration successful!');
      debugPrint('[VENDOR_REG] 🔄 Refreshing auth status...');

      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAuthStatus(autoRoute: false);

      debugPrint('[VENDOR_REG] 📊 Current user:');
      final user = authProvider.currentUser;
      if (user != null) {
        debugPrint('[VENDOR_REG]   - ID: ${user.id}');
        debugPrint('[VENDOR_REG]   - vendor_status: ${user.vendorStatus}');
        debugPrint('[VENDOR_REG]   - vendor_details: ${user.vendorDetails}');
      }
      debugPrint('[VENDOR_REG] ========================================');

      if (mounted) {
        if (user != null) {
          debugPrint('[VENDOR_REG] 🚀 Routing user based on status...');
          authProvider.routeUser(user);
        } else {
          debugPrint(
            '[VENDOR_REG] ⚠️ No user found, routing to payment screen',
          );
          Navigator.of(context).pushReplacementNamed(AppRoutes.vendorPayment);
        }

        WzToast.show(
          context,
          message: 'Vendor registration successful!',
          type: WzToastType.success,
        );
      }

      debugPrint('[VENDOR_REG] ✅ Process complete');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');
    } catch (e) {
      debugPrint('[VENDOR_REG] ========================================');
      debugPrint('[VENDOR_REG] ❌❌❌ EXCEPTION CAUGHT ❌❌❌');
      debugPrint('[VENDOR_REG] Error Type: ${e.runtimeType}');
      debugPrint('[VENDOR_REG] Error Message: $e');
      debugPrint('[VENDOR_REG] ========================================');
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
      debugPrint('');

      if (mounted) {
        WzToast.show(
          context,
          message: 'Registration failed: $e',
          type: WzToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: WzColors.textDefault,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label*' : label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WzColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WzColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WzColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator:
          validator ??
          (required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: required ? '$label*' : label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WzColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WzColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WzColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(item.toString()));
      }).toList(),
      onChanged: onChanged,
      validator: required
          ? (value) {
              if (value == null) {
                return 'Please select $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required String label,
    bool required = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: WzColors.border),
            borderRadius: BorderRadius.circular(8),
            color: WzColors.surface,
          ),
          child: const Center(
            child: Text(
              '+91',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: WzColors.textDefault,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: controller,
            label: label,
            hint: 'Mobile number',
            required: required,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (required && (value == null || value.trim().isEmpty)) {
                return 'Required';
              }
              if (value != null && value.isNotEmpty && value.length != 10) {
                return 'Invalid mobile number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('vendor_listing')),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: WzColors.textDefault,
      ),
      body: _isFetchingData
          ? const Center(child: WzLoading())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('complete_vendor_profile'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: WzColors.textDefault,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('vendor_profile_desc'),
                      style: TextStyle(
                        fontSize: 14,
                        color: WzColors.textSecondary,
                      ),
                    ),

                    _buildSectionHeader(
                      AppLocalizations.of(context)!.translate('basic_details'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _nameController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('name'),
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _companyNameController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('company_name'),
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _emailController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('email_id'),
                            required: true,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.translate('email_required');
                              }
                              if (!value.contains('@')) {
                                return AppLocalizations.of(
                                  context,
                                )!.translate('invalid_email');
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _aadharController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('aadhar_number'),
                            keyboardType: TextInputType.number,
                            maxLength: 12,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPhoneField(
                      controller: _mobileController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('mobile_no'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<String>(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('price_range'),
                            value: _priceRangeController.text.isEmpty
                                ? null
                                : _priceRangeController.text,
                            items: _priceRanges,
                            onChanged: (value) {
                              setState(() {
                                _priceRangeController.text = value ?? '';
                              });
                            },
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _pincodeController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('pincode'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('local_address'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<String>(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('select_services'),
                            value: _selectedServiceType,
                            items: IndianStates.serviceCategories,
                            onChanged: (value) {
                              setState(() {
                                _selectedServiceType = value;
                              });
                            },
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown<String>(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('product'),
                            value: _selectedProduct,
                            items: IndianStates.serviceCategories,
                            onChanged: (value) {
                              setState(() {
                                _selectedProduct = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _mapLinkController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('embedded_map_link'),
                      hint: AppLocalizations.of(
                        context,
                      )!.translate('google_maps_hint'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<String>(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('country'),
                            value: _selectedCountry,
                            items: IndianStates.countries,
                            onChanged: (value) {
                              setState(() {
                                _selectedCountry = value;
                              });
                            },
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown<String>(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('state'),
                            value: _selectedState,
                            items: IndianStates.states,
                            onChanged: (value) {
                              setState(() {
                                _selectedState = value;
                              });
                            },
                            required: true,
                          ),
                        ),
                      ],
                    ),

                    _buildSectionHeader(
                      AppLocalizations.of(context)!.translate('bank_details'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _accountHolderController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('account_holder_name'),
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _bankNameController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('bank_name'),
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _accountNumberController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('account_number'),
                            required: true,
                            keyboardType: TextInputType.number,
                            maxLength: 18,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _ifscController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('ifsc_code'),
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<String>(
                            label: AppLocalizations.of(
                              context,
                            )!.translate('account_type'),
                            value: _selectedAccountType,
                            items: IndianStates.accountTypes,
                            onChanged: (value) {
                              setState(() {
                                _selectedAccountType = value;
                              });
                            },
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _upiController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('upi_id'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPhoneField(
                            controller: _linkedMobileController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('linked_mobile_number'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _gstinController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('gstin'),
                          ),
                        ),
                      ],
                    ),

                    _buildSectionHeader(
                      AppLocalizations.of(context)!.translate('social_links'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _instagramController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('instagram_link'),
                            hint: 'https://instagram.com/...',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _facebookController,
                            label: AppLocalizations.of(
                              context,
                            )!.translate('facebook_link'),
                            hint: 'https://facebook.com/...',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _youtubeController,
                            label: 'Youtube Link',
                            hint: 'https://youtube.com/...',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _twitterController,
                            label: 'Twitter Link',
                            hint: 'https://twitter.com/...',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Glance',
                          style: TextStyle(
                            fontSize: 14,
                            color: WzColors.textDefault,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickBusinessGlance,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: WzColors.border),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.upload_file,
                                  color: WzColors.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _businessGlanceFileName ?? 'Choose File',
                                    style: TextStyle(
                                      color: _businessGlanceFileName != null
                                          ? WzColors.textDefault
                                          : WzColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    _buildSectionHeader('Working Details'),
                    _buildTextField(
                      controller: _workingHoursController,
                      label: 'Working Hours',
                      hint: 'e.g., Mon-Sat 9:00 AM - 6:00 PM',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'What best describes your work?',
                      maxLines: 4,
                      required: true,
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WzColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const WzLoadingSmall(color: Colors.white)
                            : const Text(
                                'Complete Registration',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
