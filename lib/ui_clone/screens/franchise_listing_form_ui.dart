import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';

class FranchiseListingFormScreenUI extends StatefulWidget {
  const FranchiseListingFormScreenUI({super.key});

  @override
  State<FranchiseListingFormScreenUI> createState() =>
      _FranchiseListingFormScreenUIState();
}

class _FranchiseListingFormScreenUIState
    extends State<FranchiseListingFormScreenUI> {
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  double _priceValue = 50000;
  String _selectedCountry = 'India';
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    debugPrint(
      '📍 [SCREEN] ========== FRANCHISE LISTING FORM ========== [ROUTE: ${AppRoutes.franchiseProfileForm}]',
    );
    _priceController.text = _formatPrice(_priceValue);
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      if (_contactPersonNameController.text.isEmpty &&
          currentUser.fullName != null) {
        _contactPersonNameController.text = currentUser.fullName!;
      }

      if (_emailController.text.isEmpty && currentUser.email != null) {
        _emailController.text = currentUser.email!;
      }

      if (_mobileController.text.isEmpty && currentUser.phone != null) {
        _mobileController.text = currentUser.phone!;
      }
    }
  }

  @override
  void dispose() {
    _contactPersonNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                Text(
                  AppLocalizations.of(context)!.translate('franchise_listing'),
                  style: WzTextStyles.heading2.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  AppLocalizations.of(context)!.translate('basic_details'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 38),
                _buildTextField(
                  '${AppLocalizations.of(context)!.translate('contact_person_name')}*',
                  controller: _contactPersonNameController,
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  '${AppLocalizations.of(context)!.translate('franchise_name')}*',
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  AppLocalizations.of(context)!.translate('years_as_franchise'),
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  AppLocalizations.of(context)!.translate('email_id'),
                  controller: _emailController,
                  readOnly: true,
                ),
                const SizedBox(height: 18),

                Text(
                  AppLocalizations.of(context)!.translate('price_range'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: WzColors.primary,
                              inactiveTrackColor: const Color(0xFFE5E7EB),
                              thumbColor: WzColors.primary,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              trackHeight: 3,
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                            ),
                            child: Slider(
                              value: _priceValue,
                              min: 1000,
                              max: 500000,
                              divisions: 499,
                              onChanged: (value) {
                                setState(() {
                                  _priceValue = value;
                                  _priceController.text = _formatPrice(value);
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatPrice(_priceValue),
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
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter price',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      final numValue = double.tryParse(
                        value.replaceAll(RegExp(r'[^\d]'), ''),
                      );
                      if (numValue != null &&
                          numValue >= 1000 &&
                          numValue <= 500000) {
                        setState(() {
                          _priceValue = numValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  AppLocalizations.of(context)!.translate('mobile_no'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Container(
                      width: 77,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                            color: Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        AppLocalizations.of(context)!.translate('mobile_no'),
                        controller: _mobileController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  AppLocalizations.of(context)!.translate('country'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 9),
                _buildWorkingDropdown(
                  value: _selectedCountry,
                  items: const ['India', 'USA', 'UK', 'Canada'],
                  onChanged: (val) {
                    setState(() {
                      _selectedCountry = val ?? 'India';
                    });
                  },
                ),
                const SizedBox(height: 12),

                Text(
                  AppLocalizations.of(context)!.translate('state'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 9),
                _buildWorkingDropdown(
                  value: _selectedState,
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
                  onChanged: (val) {
                    setState(() {
                      _selectedState = val;
                    });
                  },
                ),
                const SizedBox(height: 15),

                Text(
                  AppLocalizations.of(context)!.translate('local_address'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 9),
                _buildAddressField(context),
                const SizedBox(height: 32),

                Text(
                  AppLocalizations.of(context)!.translate('bank_details'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 39),
                _buildTextField(
                  AppLocalizations.of(
                    context,
                  )!.translate('account_holder_name'),
                ),
                const SizedBox(height: 15),

                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    maxLength: 18,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      )!.translate('account_number'),
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  AppLocalizations.of(context)!.translate('bank_name'),
                ),
                const SizedBox(height: 15),
                _buildVerifyField(
                  AppLocalizations.of(context)!.translate('ifsc_code'),
                  context,
                ),
                const SizedBox(height: 15),
                Text(
                  AppLocalizations.of(context)!.translate('account_type'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 9),
                _buildAccountTypeDropdown(context),
                const SizedBox(height: 18),
                _buildTextField(
                  AppLocalizations.of(context)!.translate('upi_id'),
                ),
                const SizedBox(height: 32),

                Text(
                  AppLocalizations.of(context)!.translate('social_links'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 39),
                _buildTextField(
                  AppLocalizations.of(context)!.translate('instagram_link'),
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  AppLocalizations.of(context)!.translate('youtube_link'),
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  AppLocalizations.of(context)!.translate('facebook_link'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  AppLocalizations.of(context)!.translate('twitter_link'),
                ),
                const SizedBox(height: 32),

                Text(
                  AppLocalizations.of(context)!.translate('working_details'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 39),
                _buildTextField(
                  AppLocalizations.of(context)!.translate('starting_price'),
                ),
                const SizedBox(height: 15),

                Container(
                  height: 117,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    maxLines: 5,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      )!.translate('describe_services_hint'),
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 120,
                      height: 48,
                      decoration: BoxDecoration(
                        color: WzColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.translate('submit'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    bool readOnly = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF3F4F6) : Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
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
        readOnly: readOnly,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: readOnly ? const Color(0xFF6B7280) : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? hint,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7280),
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          size: 24,
          color: Color(0xFF6B7280),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(1)}L';
    } else if (price >= 1000) {
      return '₹${(price / 1000).toStringAsFixed(0)}k';
    } else {
      return '₹${price.toStringAsFixed(0)}';
    }
  }

  Widget _buildAccountTypeDropdown(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7280),
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          size: 24,
          color: Color(0xFF6B7280),
        ),
        hint: Text(
          'Savings',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        items: ['Savings', 'Current', 'Salary', 'Fixed Deposit'].map((
          String value,
        ) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {},
      ),
    );
  }

  Widget _buildAddressField(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(
                  context,
                )!.translate('local_address'),
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: WzColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.translate('pin_on_map'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyField(String hint, BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: WzColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.translate('verify'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
