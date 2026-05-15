import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';

class FranchiseRegistrationScreen extends StatefulWidget {
  const FranchiseRegistrationScreen({super.key});

  @override
  State<FranchiseRegistrationScreen> createState() =>
      _FranchiseRegistrationScreenState();
}

class _FranchiseRegistrationScreenState
    extends State<FranchiseRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final _contactPersonController = TextEditingController();
  final _franchiseNameController = TextEditingController();
  final _yearsController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceRangeTextController = TextEditingController();

  String _countryCode = '+91';
  String? _country = 'India';
  String? _state;
  String? _accountType = 'Savings';
  double _priceRange = 50000;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _priceRangeTextController.text = _priceRange.toInt().toString();

    _priceRangeTextController.addListener(() {
      final value = double.tryParse(_priceRangeTextController.text);
      if (value != null && value >= 1000 && value <= 500000) {
        setState(() {
          _priceRange = value;
        });
      }
    });
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      if (user.email != null && user.email!.isNotEmpty) {
        _emailController.text = user.email!;
      }

      if (user.phone != null && user.phone!.isNotEmpty) {
        String phone = user.phone!;

        if (phone.startsWith('+91')) {
          phone = phone.substring(3);
        } else if (phone.startsWith('91') && phone.length > 10) {
          phone = phone.substring(2);
        }
        _mobileController.text = phone;
      }

      if (user.firstName != null || user.lastName != null) {
        final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'
            .trim();
        if (fullName.isNotEmpty) {
          _contactPersonController.text = fullName;
        }
      }

      debugPrint('[FRANCHISE_REG] 📥 Pre-populated user data:');
      debugPrint('[FRANCHISE_REG] Email: ${user.email}');
      debugPrint('[FRANCHISE_REG] Phone: ${user.phone}');
      debugPrint('[FRANCHISE_REG] Name: ${user.firstName} ${user.lastName}');
    }
  }

  @override
  void dispose() {
    _contactPersonController.dispose();
    _franchiseNameController.dispose();
    _yearsController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _startingPriceController.dispose();
    _descriptionController.dispose();
    _priceRangeTextController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      WzToast.show(
        context,
        message: 'Please fill all required fields',
        type: WzToastType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();

      final franchiseData = {
        'role': 'franchise',
        'franchise_status': 'pending_payment',
        'franchise_details': {
          'contact_person_name': _contactPersonController.text.trim(),
          'business_name': _franchiseNameController.text.trim(),
          'years_as_franchise': _yearsController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': '$_countryCode${_mobileController.text.trim()}',
          'country': _country,
          'state': _state,
          'address': _addressController.text.trim(),
          'price_range': _priceRange.toInt(),
          'bank_details': {
            'account_holder_name': _accountHolderController.text.trim(),
            'account_number': _accountNumberController.text.trim(),
            'bank_name': _bankNameController.text.trim(),
            'ifsc_code': _ifscController.text.trim(),
            'account_type': _accountType,
            'upi_id': _upiController.text.trim(),
          },
          'social_links': {
            'instagram': _instagramController.text.trim(),
            'youtube': _youtubeController.text.trim(),
            'facebook': _facebookController.text.trim(),
            'twitter': _twitterController.text.trim(),
          },
          'starting_price': _startingPriceController.text.trim(),
          'description': _descriptionController.text.trim(),
        },
      };

      debugPrint('[FRANCHISE_REG] 📤 Submitting franchise registration');
      debugPrint('[FRANCHISE_REG] 📋 Data keys: ${franchiseData.keys}');

      final success = await authProvider.updateProfile(franchiseData);

      if (!mounted) return;

      if (success) {
        debugPrint('[FRANCHISE_REG] ✅ Registration successful');
        WzToast.show(
          context,
          message: 'Registration successful! Proceed to payment.',
          type: WzToastType.success,
        );

        await authProvider.refreshUser();

        if (!mounted) return;

        Navigator.of(context).pushReplacementNamed(AppRoutes.franchisePayment);
      } else {
        debugPrint('[FRANCHISE_REG] ❌ Registration failed');
        WzToast.show(
          context,
          message: authProvider.error ?? 'Registration failed',
          type: WzToastType.error,
        );
      }
    } catch (e) {
      debugPrint('[FRANCHISE_REG] ❌ Error: $e');
      if (mounted) {
        WzToast.show(
          context,
          message: 'An error occurred: $e',
          type: WzToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('franchise_listing'),
                      style: WzTextStyles.heading2.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppLocalizations.of(context)!.translate('basic_details'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTextField(
                      '${AppLocalizations.of(context)!.translate('contact_person_name')}*',
                      _contactPersonController,
                      required: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTextField(
                      '${AppLocalizations.of(context)!.translate('franchise_name')}*',
                      _franchiseNameController,
                      required: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTextField(
                      AppLocalizations.of(
                        context,
                      )!.translate('years_as_franchise'),
                      _yearsController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.translate('email_id'),
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
                  ),
                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppLocalizations.of(context)!.translate('price_range'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
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
                                  value: _priceRange,
                                  min: 1000,
                                  max: 500000,
                                  divisions: 499,
                                  onChanged: (value) {
                                    setState(() {
                                      _priceRange = value;
                                      _priceRangeTextController.text = value
                                          .toInt()
                                          .toString();
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _priceRange >= 100000
                                  ? '₹${(_priceRange / 100000).toStringAsFixed(1)}L'
                                  : _priceRange >= 1000
                                  ? '₹${(_priceRange / 1000).toStringAsFixed(0)}k'
                                  : '₹${_priceRange.toStringAsFixed(0)}',
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
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
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
                        controller: _priceRangeTextController,
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
                          hintText: 'Enter amount',
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              child: const Center(
                                child: Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
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
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  enabled: false,
                                  maxLength: 10,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF6B7280),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.translate('mobile_no'),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          value: _country,
                          items: const ['India', 'USA', 'UK', 'Canada'],
                          onChanged: (val) {
                            setState(() {
                              _country = val;
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
                          value: _state,
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
                              _state = val;
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('local_address'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 9),
                        _buildTextField(
                          AppLocalizations.of(
                            context,
                          )!.translate('local_address'),
                          _addressController,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppLocalizations.of(context)!.translate('bank_details'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 39),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          AppLocalizations.of(
                            context,
                          )!.translate('account_holder_name'),
                          _accountHolderController,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          AppLocalizations.of(
                            context,
                          )!.translate('account_number'),
                          _accountNumberController,
                          keyboardType: TextInputType.number,
                          maxLength: 18,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          AppLocalizations.of(context)!.translate('bank_name'),
                          _bankNameController,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          AppLocalizations.of(context)!.translate('ifsc_code'),
                          _ifscController,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('account_type'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 9),
                        _buildAccountTypeDropdown(),
                        const SizedBox(height: 18),
                        _buildTextField(
                          AppLocalizations.of(context)!.translate('upi_id'),
                          _upiController,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppLocalizations.of(context)!.translate('social_links'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 39),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          AppLocalizations.of(
                            context,
                          )!.translate('instagram_link'),
                          _instagramController,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          AppLocalizations.of(
                            context,
                          )!.translate('youtube_link'),
                          _youtubeController,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          AppLocalizations.of(
                            context,
                          )!.translate('facebook_link'),
                          _facebookController,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          AppLocalizations.of(
                            context,
                          )!.translate('twitter_link'),
                          _twitterController,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('working_details'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 39),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          AppLocalizations.of(
                            context,
                          )!.translate('starting_price'),
                          _startingPriceController,
                          keyboardType: TextInputType.number,
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
                            controller: _descriptionController,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Center(
                    child: GestureDetector(
                      onTap: _isSubmitting ? null : _submitForm,
                      child: Container(
                        width: 120,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isSubmitting
                              ? WzColors.primary.withValues(alpha: 0.6)
                              : WzColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.translate('submit'),
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
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    int? maxLength,
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
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
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
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

  Widget _buildAccountTypeDropdown() {
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
        value: _accountType,
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
        items: ['Savings', 'Current', 'Salary', 'Fixed Deposit'].map((
          String value,
        ) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() => _accountType = newValue);
        },
      ),
    );
  }
}
