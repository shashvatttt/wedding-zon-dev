import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/onboarding/providers/onboarding_provider.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/services/location_service.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/constants/profile_constants.dart';
import 'package:weddingzon/features/profile/widgets/edit_profile_navigation.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfileLocationUI extends StatefulWidget {
  final bool isEditMode;

  const ProfileLocationUI({super.key, this.isEditMode = false});

  @override
  State<ProfileLocationUI> createState() => _ProfileLocationUIState();
}

class _ProfileLocationUIState extends State<ProfileLocationUI> {
  final _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();
  bool _isLoadingLocation = false;

  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  DateTime? _lastTypingTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final isEditFlow = args?['isEditFlow'] ?? false;

      if (!widget.isEditMode && isEditFlow) {
        final authProvider = context.read<AuthProvider>();
        final currentUser = authProvider.currentUser;
        if (currentUser != null) {
          final provider = context.read<OnboardingProvider>();
          provider.prepopulateFromUser(currentUser);
        }
      }

      final provider = context.read<OnboardingProvider>();
      if (provider.formData['city'] != null) {
        _cityController.text = provider.formData['city'];
      }

      if (provider.formData['state'] != null &&
          provider.formData['country'] != 'India') {
        _stateController.text = provider.formData['state'];
      }
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  String _getTranslatedCountry(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key = 'country_${value.toLowerCase().replaceAll(' ', '_')}';
    return appLoc.translate(key);
  }

  String _getTranslatedState(String value, AppLocalizations? appLoc) {
    if (appLoc == null) return value;
    final key = 'state_${value.toLowerCase().replaceAll(' ', '_')}';

    final translated = appLoc.translate(key);
    return translated != key ? translated : value;
  }

  Future<void> _debounceGeocode(String? city, String? pincode) async {
    _lastTypingTime = DateTime.now();
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted ||
        DateTime.now().difference(_lastTypingTime!) <
            const Duration(milliseconds: 1000)) {
      return;
    }

    final query = [city].where((s) => s != null && s.isNotEmpty).join(', ');
    if (query.length < 4) return;

    try {
      final position = await _locationService.getCoordinatesFromAddress(query);
      if (position != null && mounted) {
        final provider = context.read<OnboardingProvider>();
        provider.updateField('latitude', position.latitude);
        provider.updateField('longitude', position.longitude);
        debugPrint(
          '[LOCATION_UI] Geocoded "$query" -> ${position.latitude}, ${position.longitude}',
        );
      }
    } catch (e) {
      debugPrint('[LOCATION_UI] Geocode error: $e');
    }
  }

  Future<void> _getMyLocation() async {
    setState(() => _isLoadingLocation = true);
    final appLoc = AppLocalizations.of(context);

    try {
      final address = await _locationService.getCurrentLocationAddress();
      if (!mounted) return;

      if (address.isEmpty) {
        WzToast.show(
          context,
          message:
              appLoc?.translate('get_location_error') ??
              'Could not get location. Enable location services.',
          type: WzToastType.error,
        );
        return;
      }

      final provider = context.read<OnboardingProvider>();
      if (address['country'] != null) {
        provider.updateField('country', address['country']);
      }
      if (address['state'] != null) {
        provider.updateField('state', address['state']);
        if (address['country'] != 'India') {
          _stateController.text = address['state']!;
        }
      }
      if (address['city'] != null) {
        provider.updateField('city', address['city']);
        _cityController.text = address['city']!;
      }

      WzToast.show(
        context,
        message:
            appLoc?.translate('location_populated_success') ??
            'Location populated successfully!',
        type: WzToastType.success,
      );
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _onNext() async {
    final appLoc = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = context.read<OnboardingProvider>();
      if (provider.formData['country'] != 'India') {
        provider.updateField('state', _stateController.text);
      }

      if (widget.isEditMode) {
        final response = await provider.submitProfile();
        if (response.success && response.data != null && mounted) {
          context.read<AuthProvider>().updateUser(response.data!);
        } else if (mounted) {
          WzToast.show(
            context,
            message:
                response.message ??
                (appLoc?.translate('profile_update_failed') ??
                    'Failed to update profile'),
            type: WzToastType.error,
          );
        }
      } else {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final isEditFlow = args?['isEditFlow'] ?? false;

        Navigator.pushNamed(
          context,
          AppRoutes.profileFamily,
          arguments: {'isEditFlow': isEditFlow},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: WzColors.white,
      appBar: AppBar(
        backgroundColor: WzColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: widget.isEditMode
            ? const PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: EditProfileProgressIndicator(currentSection: 'location'),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer<OnboardingProvider>(
                  builder: (context, provider, _) {
                    final isIndia = provider.formData['country'] == 'India';

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.isEditMode
                                  ? (appLoc?.translate('edit_profile') ??
                                        'Edit Profile')
                                  : (appLoc?.translate('create_profile') ??
                                        'Create Profile'),
                              style: WzTextStyles.heading3.copyWith(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 38.0),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              appLoc?.translate('location_details_title') ??
                                  'Location Details',
                              style: WzTextStyles.heading4.copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isLoadingLocation
                                  ? null
                                  : _getMyLocation,
                              icon: _isLoadingLocation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.my_location),
                              label: Text(
                                _isLoadingLocation
                                    ? (appLoc?.translate('getting_location') ??
                                          'Getting Location...')
                                    : (appLoc?.translate('get_my_location') ??
                                          'Get My Location'),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: const BorderSide(color: WzColors.primary),
                                foregroundColor: WzColors.primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel(
                            appLoc?.translate('country_label') ?? 'Country',
                          ),
                          const SizedBox(height: 8.0),
                          _buildDropdownField(
                            hintText:
                                appLoc?.translate('select_country_hint') ??
                                'Select Country',
                            value: provider.formData['country'],
                            items: ProfileConstants.countries,
                            itemLabelBuilder: (item) =>
                                _getTranslatedCountry(item, appLoc),
                            onChanged: (val) {
                              provider.updateField('country', val);
                              if (val != 'India') {
                                provider.updateField('state', null);
                              }
                            },
                          ),

                          const SizedBox(height: 26.0),

                          _buildLabel(
                            appLoc?.translate('state_label') ?? 'State',
                          ),
                          const SizedBox(height: 8.0),
                          if (isIndia)
                            _buildDropdownField(
                              hintText:
                                  appLoc?.translate('select_state_hint') ??
                                  'Select State',
                              value: provider.formData['state'],
                              items: ProfileConstants.indianStates,
                              itemLabelBuilder: (item) =>
                                  _getTranslatedState(item, appLoc),
                              onChanged: (val) =>
                                  provider.updateField('state', val),
                            )
                          else
                            Container(
                              decoration: _inputContainerDecoration(),
                              child: TextFormField(
                                controller: _stateController,
                                decoration: _inputDecoration(),
                                validator: (v) =>
                                    v?.isEmpty ?? true ? 'Required' : null,
                                style: _inputTextStyle(),
                                onChanged: (val) =>
                                    provider.updateField('state', val),
                              ),
                            ),

                          const SizedBox(height: 26.0),

                          _buildLabel(
                            appLoc?.translate('city_label') ?? 'City',
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            decoration: _inputContainerDecoration(),
                            child: TextFormField(
                              controller: _cityController,
                              decoration: _inputDecoration(),
                              validator: (v) => v?.isEmpty ?? true
                                  ? appLoc?.translate('required') ?? 'Required'
                                  : null,
                              style: _inputTextStyle(),
                              onChanged: (val) {
                                provider.updateField('city', val);
                                _debounceGeocode(val, null);
                              },
                            ),
                          ),

                          const SizedBox(height: 26.0),

                          const SizedBox(height: 48.0),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (widget.isEditMode)
              EditProfileNavigationButtons(
                currentSection: 'location',
                onSave: _onNext,
              ),
            if (!widget.isEditMode)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: WzPrimaryButton(
                  text: appLoc?.translate('next') ?? 'Next',
                  onPressed: _onNext,
                  width: double.infinity,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: Color(0xCF4E4E4E),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 12.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: WzColors.primarySoftBg),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: WzColors.primarySoftBg),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: WzColors.primary),
      ),
      fillColor: WzColors.white,
      filled: true,
    );
  }

  BoxDecoration _inputContainerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4),
      ],
    );
  }

  TextStyle _inputTextStyle() {
    return const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: WzColors.text,
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String Function(String)? itemLabelBuilder,
  }) {
    final validValue = value != null && items.contains(value) ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: WzColors.white,
        border: Border.all(color: const Color(0xFFFBC3CF), width: 1.0),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          key: ValueKey('${hintText}_$validValue'),
          value: validValue,
          isExpanded: true,
          hint: Text(
            hintText,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                itemLabelBuilder != null ? itemLabelBuilder(item) : item,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.0,
                  color: WzColors.text,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (v) => v == null
              ? AppLocalizations.of(context)?.translate('required') ??
                    'Required'
              : null,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
