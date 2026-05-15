import 'package:flutter/material.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/franchise_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/indian_states.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../franchise/models/franchise_details.dart';
import '../../../shared/widgets/wz_toast.dart';

class FranchiseProfileFormScreen extends StatefulWidget {
  const FranchiseProfileFormScreen({super.key});

  @override
  State<FranchiseProfileFormScreen> createState() =>
      _FranchiseProfileFormScreenState();
}

class _FranchiseProfileFormScreenState
    extends State<FranchiseProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _contactPersonController = TextEditingController();
  final _franchiseNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _yearsController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _mapLinkController = TextEditingController();

  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();

  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();

  final _startingPriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedAccountType;

  bool _isLoading = false;
  bool _isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingData();
  }

  @override
  void dispose() {
    _contactPersonController.dispose();
    _franchiseNameController.dispose();
    _emailController.dispose();
    _yearsController.dispose();
    _priceRangeController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _mapLinkController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _startingPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingData() async {
    setState(() {
      _isFetchingData = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user != null) {
        final franchiseDetails = user.franchiseDetails;

        if (franchiseDetails != null) {
          debugPrint('[FRANCHISE_FORM] 📥 Pre-populating franchise details');
          setState(() {
            _contactPersonController.text =
                franchiseDetails.contactPersonName ?? '';
            _franchiseNameController.text = franchiseDetails.businessName ?? '';
            _emailController.text = user.email ?? '';
            _yearsController.text =
                franchiseDetails.yearsAsFranchise?.toString() ?? '';
            _priceRangeController.text = franchiseDetails.priceRange ?? '';
            _mobileController.text = user.phone ?? '';
            _addressController.text = franchiseDetails.businessAddress ?? '';
            _pincodeController.text = franchiseDetails.pincode ?? '';
            _mapLinkController.text = franchiseDetails.googleMapLink ?? '';

            _selectedCountry = franchiseDetails.country;
            _selectedState = franchiseDetails.state;

            _accountHolderController.text =
                franchiseDetails.accountHolderName ?? '';
            _bankNameController.text = franchiseDetails.bankName ?? '';
            _accountNumberController.text =
                franchiseDetails.accountNumber ?? '';
            _ifscController.text = franchiseDetails.ifscCode ?? '';
            _upiController.text = franchiseDetails.upiId ?? '';
            _selectedAccountType = franchiseDetails.accountType;

            _instagramController.text = franchiseDetails.instagramLink ?? '';
            _youtubeController.text = franchiseDetails.youtubeLink ?? '';
            _facebookController.text = franchiseDetails.facebookLink ?? '';
            _twitterController.text = franchiseDetails.twitterLink ?? '';

            _startingPriceController.text =
                franchiseDetails.startingPrice ?? '';
            _descriptionController.text = franchiseDetails.description ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('[FRANCHISE_FORM] ⚠️ Error fetching existing data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingData = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    debugPrint('');
    debugPrint(
      '╔════════════════════════════════════════════════════════════╗',
    );
    debugPrint('║ [FRANCHISE_FORM] 🚀 SUBMIT BUTTON CLICKED                 ║');
    debugPrint(
      '╚════════════════════════════════════════════════════════════╝',
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final franchiseProvider = context.read<FranchiseProvider>();

      final franchiseDetails = FranchiseDetails(
        contactPersonName: _contactPersonController.text.trim(),
        businessName: _franchiseNameController.text.trim(),

        yearsAsFranchise: int.tryParse(_yearsController.text.trim()),
        priceRange: _priceRangeController.text.trim(),

        businessAddress: _addressController.text.trim(),
        pincode: _pincodeController.text.trim(),
        googleMapLink: _mapLinkController.text.trim(),
        country: _selectedCountry ?? 'India',
        state: _selectedState,

        accountHolderName: _accountHolderController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        accountType: _selectedAccountType,
        upiId: _upiController.text.trim(),

        instagramLink: _instagramController.text.trim(),
        youtubeLink: _youtubeController.text.trim(),
        facebookLink: _facebookController.text.trim(),
        twitterLink: _twitterController.text.trim(),

        startingPrice: _startingPriceController.text.trim(),
        description: _descriptionController.text.trim(),
      ).toJson();

      final payload = {
        'role': 'franchise',
        'first_name': _contactPersonController.text.trim().split(' ').first,
        'last_name': _contactPersonController.text
            .trim()
            .split(' ')
            .skip(1)
            .join(' '),
        'phone': _mobileController.text.trim(),
        'franchise_details': franchiseDetails,
      };

      debugPrint('[FRANCHISE_FORM] 📦 Franchise Details:');
      franchiseDetails.forEach((key, value) {
        debugPrint('[FRANCHISE_FORM]   - $key: $value');
      });

      debugPrint(
        '[FRANCHISE_FORM] 🌐 Calling updateFranchiseOwnerProfile API...',
      );
      final updatedUser = await franchiseProvider.updateFranchiseOwnerProfile(
        payload,
      );

      if (!mounted) return;

      if (updatedUser != null) {
        debugPrint('[FRANCHISE_FORM] ✅ Profile updated successfully');
        authProvider.updateUser(updatedUser);

        Navigator.of(context).pushReplacementNamed(AppRoutes.franchisePayment);

        WzToast.show(
          context,
          message: 'Profile updated successfully!',
          type: WzToastType.success,
        );
      } else {
        throw Exception(
          franchiseProvider.error.isNotEmpty
              ? franchiseProvider.error
              : 'Failed to update profile',
        );
      }
    } catch (e) {
      debugPrint('[FRANCHISE_FORM] ❌ Error: $e');
      if (mounted) {
        WzToast.show(context, message: 'Error: $e', type: WzToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );
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
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
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
          fillColor: readOnly ? WzColors.surface : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
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
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    bool required = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
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
      ),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
        title: Text(
          AppLocalizations.of(context)!.translate('franchise_listing'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: WzColors.textDefault,
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
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
                      )!.translate('complete_franchise_profile'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: WzColors.textDefault,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('franchise_profile_desc'),
                      style: TextStyle(
                        fontSize: 14,
                        color: WzColors.textSecondary,
                      ),
                    ),

                    _buildSectionHeader(
                      AppLocalizations.of(context)!.translate('basic_details'),
                    ),
                    _buildTextField(
                      controller: _contactPersonController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('contact_person_name'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _franchiseNameController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('franchise_name'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
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
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _yearsController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('years_as_franchise'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _priceRangeController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('price_range'),
                      hint: 'e.g., ₹10,000 - ₹50,000',
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
                    _buildTextField(
                      controller: _addressController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('local_address'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _pincodeController,
                      label: AppLocalizations.of(context)!.translate('pincode'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _mapLinkController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('google_map_link'),
                      hint: AppLocalizations.of(
                        context,
                      )!.translate('google_maps_hint'),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<String>(
                      label: AppLocalizations.of(context)!.translate('country'),
                      value: _selectedCountry,
                      items: IndianStates.countries,
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      },
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<String>(
                      label: AppLocalizations.of(context)!.translate('state'),
                      value: _selectedState,
                      items: IndianStates.states,
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                        });
                      },
                      required: true,
                    ),

                    _buildSectionHeader(
                      AppLocalizations.of(context)!.translate('bank_details'),
                    ),
                    _buildTextField(
                      controller: _accountHolderController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('account_holder_name'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bankNameController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('bank_name'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _accountNumberController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('account_number'),
                      required: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ifscController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('ifsc_code'),
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<String>(
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
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _upiController,
                      label: AppLocalizations.of(context)!.translate('upi_id'),
                    ),

                    _buildSectionHeader(
                      AppLocalizations.of(context)!.translate('social_links'),
                    ),
                    _buildTextField(
                      controller: _instagramController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('instagram_link'),
                      hint: 'https://instagram.com/...',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _youtubeController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('youtube_link'),
                      hint: 'https://youtube.com/...',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _facebookController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('facebook_link'),
                      hint: 'https://facebook.com/...',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _twitterController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('twitter_link'),
                      hint: 'https://twitter.com/...',
                    ),

                    _buildSectionHeader(
                      AppLocalizations.of(
                        context,
                      )!.translate('working_details'),
                    ),
                    _buildTextField(
                      controller: _startingPriceController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('starting_price'),
                      hint: 'e.g., ₹10,000',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: AppLocalizations.of(
                        context,
                      )!.translate('description'),
                      hint: AppLocalizations.of(
                        context,
                      )!.translate('describe_services_hint'),
                      maxLines: 4,
                      required: true,
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
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
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Submit & Proceed to Payment',
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
