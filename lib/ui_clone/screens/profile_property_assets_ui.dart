import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/routes/app_routes.dart';
import 'package:weddingzon/features/onboarding/providers/onboarding_provider.dart';
import 'package:weddingzon/features/auth/providers/auth_provider.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';
import 'package:weddingzon/core/constants/profile_constants.dart';
import 'package:weddingzon/features/profile/widgets/edit_profile_navigation.dart';
import 'package:weddingzon/shared/widgets/wz_toast.dart';
import '../widgets/wz_buttons.dart';

class ProfilePropertyAssetsUI extends StatefulWidget {
  final bool isEditMode;

  const ProfilePropertyAssetsUI({super.key, this.isEditMode = false});

  @override
  State<ProfilePropertyAssetsUI> createState() =>
      _ProfilePropertyAssetsUIState();
}

class _ProfilePropertyAssetsUIState extends State<ProfilePropertyAssetsUI> {
  final _formKey = GlobalKey<FormState>();
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  final _landAreaController = TextEditingController();
  String? _selectedLandType;
  String? _selectedLandUnit;
  String? _selectedHouseType;

  List<String> get _landTypes => ProfileConstants.landTypes;
  List<String> get _landUnits => ProfileConstants.landUnits;
  List<String> get _houseTypes => ProfileConstants.houseTypes;

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
      if (provider.formData['land_area'] != null) {
        final landAreaStr = provider.formData['land_area'] as String;
        final parts = landAreaStr.split(' ');
        if (parts.length >= 2) {
          _landAreaController.text = parts[0];
          final unit = parts.sublist(1).join(' ');
          if (_landUnits.contains(unit)) {
            setState(() => _selectedLandUnit = unit);
          } else if (unit == 'Ghaz' && _landUnits.contains('Gazh')) {
            setState(() => _selectedLandUnit = 'Gazh');
          }
        } else {
          _landAreaController.text = landAreaStr;
        }
      }
      if (provider.formData['land_types'] != null) {
        final val = provider.formData['land_types'];
        if (val is List && val.isNotEmpty) {
          setState(() => _selectedLandType = val.first.toString());
        } else if (val is String) {
          setState(() => _selectedLandType = val);
        }
      }
      if (provider.formData['house_types'] != null) {
        final val = provider.formData['house_types'];
        if (val is List && val.isNotEmpty) {
          setState(() => _selectedHouseType = val.first.toString());
        } else if (val is String) {
          setState(() => _selectedHouseType = val);
        }
      }
    });
  }

  @override
  void dispose() {
    _landAreaController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedLandType == null ||
          _selectedHouseType == null ||
          _selectedLandUnit == null) {
        WzToast.show(
          context,
          message: l10n.selectLandHouseError,
          type: WzToastType.error,
        );
        return;
      }

      if (widget.isEditMode) {
        final provider = context.read<OnboardingProvider>();
        final response = await provider.submitProfile();
        if (response.success && response.data != null && mounted) {
          context.read<AuthProvider>().updateUser(response.data!);
        } else if (mounted) {
          WzToast.show(
            context,
            message: response.message ?? l10n.profileUpdateFailed,
            type: WzToastType.error,
          );
        }
      } else {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final isEditFlow = args?['isEditFlow'] ?? false;

        Navigator.pushNamed(
          context,
          AppRoutes.profileContact,
          arguments: {'isEditFlow': isEditFlow},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: EditProfileProgressIndicator(currentSection: 'assets'),
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
                                  ? l10n.editProfile
                                  : l10n.createProfile,
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
                              l10n.propertyAssetsTitle,
                              style: WzTextStyles.heading4.copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: WzColors.text,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel('${l10n.landAreaLabel}*'),
                          const SizedBox(height: 8.0),
                          Container(
                            decoration: _inputContainerDecoration(),
                            child: TextFormField(
                              controller: _landAreaController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: _inputDecoration(
                                hint: l10n.landAreaHint,
                              ),
                              validator: (v) =>
                                  v?.isEmpty ?? true ? l10n.required : null,
                              style: _inputTextStyle(),
                              onChanged: (val) {
                                if (_selectedLandUnit != null &&
                                    val.isNotEmpty) {
                                  provider.updateField(
                                    'land_area',
                                    '$val $_selectedLandUnit',
                                  );
                                } else {
                                  provider.updateField('land_area', val);
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel('${l10n.landAreaLabel} Unit*'),
                          const SizedBox(height: 8.0),
                          _buildDropdown(
                            value: _selectedLandUnit,
                            hint: l10n.selectUnit,
                            items: _landUnits,
                            labelBuilder: (item) {
                              if (item == 'Sq Feet')
                                return l10n.translate('unit_sq_feet');
                              if (item == 'Acres')
                                return l10n.translate('unit_acres');
                              if (item == 'Bigha')
                                return l10n.translate('unit_bigha');
                              if (item == 'Gazh')
                                return l10n.translate('unit_gazh');
                              return item;
                            },
                            onChanged: (unit) {
                              setState(() => _selectedLandUnit = unit);
                              if (_landAreaController.text.isNotEmpty &&
                                  unit != null) {
                                provider.updateField(
                                  'land_area',
                                  '${_landAreaController.text} $unit',
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel('${l10n.landTypesLabel}*'),
                          const SizedBox(height: 8.0),
                          _buildDropdown(
                            value: _selectedLandType,
                            hint: l10n.selectLandTypesHint,
                            items: _landTypes,
                            onChanged: (val) {
                              setState(() => _selectedLandType = val);
                              provider.updateField('land_types', [val]);
                            },
                            labelBuilder: (item) {
                              if (item == 'Agricultural') {
                                return l10n.landAgricultural;
                              }
                              if (item == 'Commercial')
                                return l10n.landCommercial;
                              if (item == 'Residential')
                                return l10n.landResidential;
                              if (item == 'Plot') return l10n.landPlot;
                              if (item == 'Orchard') return l10n.landOrchard;
                              if (item == 'None') return l10n.landNone;
                              return item;
                            },
                          ),

                          const SizedBox(height: 30.0),

                          _buildLabel('${l10n.houseTypesLabel}*'),
                          const SizedBox(height: 8.0),
                          _buildDropdown(
                            value: _selectedHouseType,
                            hint: l10n.selectHouseTypesHint,
                            items: _houseTypes,
                            onChanged: (val) {
                              setState(() => _selectedHouseType = val);
                              provider.updateField('house_types', [val]);
                            },
                            labelBuilder: (item) {
                              if (item == 'Own House') return l10n.houseOwn;
                              if (item == 'Rented') return l10n.houseRented;
                              if (item == 'Apartment')
                                return l10n.houseApartment;
                              if (item == 'Villa') return l10n.houseVilla;
                              if (item == 'Bungalow') return l10n.houseBungalow;
                              if (item == 'Farmhouse')
                                return l10n.houseFarmhouse;
                              return item;
                            },
                          ),

                          const SizedBox(height: 40.0),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (widget.isEditMode)
              EditProfileNavigationButtons(
                currentSection: 'assets',
                onSave: _onNext,
              ),
            if (!widget.isEditMode)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: WzPrimaryButton(
                  text: l10n.next,
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

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
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
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? labelBuilder,
  }) {
    final validValue = value != null && items.contains(value) ? value : null;

    return Container(
      height: 48.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: WzColors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validValue,
          hint: Text(
            hint,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.0,
              color: Color(0xFF6B7280),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                labelBuilder?.call(item) ?? item,
                style: _inputTextStyle(),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
