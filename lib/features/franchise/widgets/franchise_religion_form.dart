import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../core/theme/wz_text_styles.dart';
import '../providers/franchise_form_provider.dart';

class FranchiseReligionForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const FranchiseReligionForm({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseFormProvider>(
      builder: (context, provider, _) {
        return Container(
          color: WzColors.white,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),

                  Text(
                    'Religious Background',
                    style: WzTextStyles.heading3.copyWith(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  Text(
                    'Religion *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['religion'],
                      decoration: InputDecoration(
                        hintText: 'Select religion',
                        hintStyle: WzTextStyles.body2.copyWith(
                          color: WzColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: WzColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items:
                          [
                                'Hindu',
                                'Muslim',
                                'Christian',
                                'Sikh',
                                'Buddhist',
                                'Jain',
                                'Other',
                              ]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: WzTextStyles.body2.copyWith(
                                      color: WzColors.text,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      validator: (v) =>
                          v == null ? 'Please select religion' : null,
                      onChanged: (v) => provider.updateField('religion', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Community / Caste *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: TextFormField(
                      initialValue: provider.formData['community'],
                      decoration: InputDecoration(
                        hintText: 'Enter community or caste',
                        hintStyle: WzTextStyles.body2.copyWith(
                          color: WzColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: WzColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: WzTextStyles.body2.copyWith(color: WzColors.text),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Community is required' : null,
                      onChanged: (v) => provider.updateField('community', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Sub Community',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: TextFormField(
                      initialValue: provider.formData['sub_community'],
                      decoration: InputDecoration(
                        hintText: 'Enter sub community (optional)',
                        hintStyle: WzTextStyles.body2.copyWith(
                          color: WzColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: WzColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: WzTextStyles.body2.copyWith(color: WzColors.text),
                      onChanged: (v) =>
                          provider.updateField('sub_community', v),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        );
      },
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
}
