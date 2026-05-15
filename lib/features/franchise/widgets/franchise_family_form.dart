import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../core/theme/wz_text_styles.dart';
import '../providers/franchise_form_provider.dart';

class FranchiseFamilyForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const FranchiseFamilyForm({super.key, required this.formKey});

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
                    'Family Background',
                    style: WzTextStyles.heading3.copyWith(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  Text(
                    "Father's Status *",
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['father_status'],
                      decoration: InputDecoration(
                        hintText: "Select father's status",
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
                      items: ['Employed', 'Business', 'Retired', 'Passed Away']
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
                          v == null ? "Please select father's status" : null,
                      onChanged: (v) =>
                          provider.updateField('father_status', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    "Mother's Status *",
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['mother_status'],
                      decoration: InputDecoration(
                        hintText: "Select mother's status",
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
                                'Homemaker',
                                'Employed',
                                'Business',
                                'Retired',
                                'Passed Away',
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
                          v == null ? "Please select mother's status" : null,
                      onChanged: (v) =>
                          provider.updateField('mother_status', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Number of Brothers',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: TextFormField(
                      initialValue:
                          provider.formData['brothers']?.toString() ?? '0',
                      decoration: InputDecoration(
                        hintText: 'Enter number of brothers',
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
                      keyboardType: TextInputType.number,
                      onChanged: (v) => provider.updateField(
                        'brothers',
                        int.tryParse(v) ?? 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Number of Sisters',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: TextFormField(
                      initialValue:
                          provider.formData['sisters']?.toString() ?? '0',
                      decoration: InputDecoration(
                        hintText: 'Enter number of sisters',
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
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          provider.updateField('sisters', int.tryParse(v) ?? 0),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Family Status *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['family_status'],
                      decoration: InputDecoration(
                        hintText: 'Select family status',
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
                                'Middle Class',
                                'Upper Middle Class',
                                'Rich',
                                'Affluent',
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
                          v == null ? 'Please select family status' : null,
                      onChanged: (v) =>
                          provider.updateField('family_status', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Family Type *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['family_type'],
                      decoration: InputDecoration(
                        hintText: 'Select family type',
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
                      items: ['Nuclear', 'Joint']
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
                          v == null ? 'Please select family type' : null,
                      onChanged: (v) => provider.updateField('family_type', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Family Values *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['family_values'],
                      decoration: InputDecoration(
                        hintText: 'Select family values',
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
                      items: ['Traditional', 'Moderate', 'Liberal']
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
                          v == null ? 'Please select family values' : null,
                      onChanged: (v) =>
                          provider.updateField('family_values', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Family Annual Income',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['annual_income'],
                      decoration: InputDecoration(
                        hintText: 'Select family income range',
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
                                'Less than 5 LPA',
                                '5-10 LPA',
                                '10-20 LPA',
                                '20-50 LPA',
                                '50 LPA - 1 Crore',
                                'Above 1 Crore',
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
                      onChanged: (v) =>
                          provider.updateField('annual_income', v),
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
