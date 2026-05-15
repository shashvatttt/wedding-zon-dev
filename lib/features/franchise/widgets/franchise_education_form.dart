import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../core/theme/wz_text_styles.dart';
import '../providers/franchise_form_provider.dart';

class FranchiseEducationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const FranchiseEducationForm({super.key, required this.formKey});

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
                    'Education & Career',
                    style: WzTextStyles.heading3.copyWith(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  Text(
                    'Highest Education *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['highest_education'],
                      decoration: InputDecoration(
                        hintText: 'Select education level',
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
                                'High School',
                                'Diploma',
                                "Bachelor's Degree",
                                "Master's Degree",
                                'PhD',
                                'Professional Degree',
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
                          v == null ? 'Please select education level' : null,
                      onChanged: (v) =>
                          provider.updateField('highest_education', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Educational Details',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: TextFormField(
                      initialValue: provider.formData['educational_details'],
                      decoration: InputDecoration(
                        hintText: 'e.g. B.Tech in Computer Science',
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
                          provider.updateField('educational_details', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Occupation *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value:
                          provider.formData['occupation'] != null &&
                              [
                                'Software Engineer',
                                'Doctor',
                                'Teacher',
                                'Business Owner',
                                'Government Employee',
                                'Lawyer',
                                'Accountant',
                                'Engineer',
                                'Other',
                              ].contains(provider.formData['occupation'])
                          ? provider.formData['occupation']
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Select occupation',
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
                                'Software Engineer',
                                'Doctor',
                                'Teacher',
                                'Business Owner',
                                'Government Employee',
                                'Lawyer',
                                'Accountant',
                                'Engineer',
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
                          v == null ? 'Please select occupation' : null,
                      onChanged: (v) => provider.updateField('occupation', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Employed In *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['employed_in'],
                      decoration: InputDecoration(
                        hintText: 'Select employment type',
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
                                'Private',
                                'Government',
                                'Business',
                                'Self Employed',
                                'Not Working',
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
                          v == null ? 'Please select employment type' : null,
                      onChanged: (v) => provider.updateField('employed_in', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Annual Income *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['personal_income'],
                      decoration: InputDecoration(
                        hintText: 'Select income range',
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
                                'Less than 5 Lakhs',
                                '5-10 Lakhs',
                                '10-20 Lakhs',
                                '20-50 Lakhs',
                                '50 Lakhs - 1 Crore',
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
                      validator: (v) =>
                          v == null ? 'Please select income range' : null,
                      onChanged: (v) =>
                          provider.updateField('personal_income', v),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'Working Sector',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: TextFormField(
                      initialValue: provider.formData['working_sector'],
                      decoration: InputDecoration(
                        hintText: 'e.g. IT, Healthcare, Finance',
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
                          provider.updateField('working_sector', v),
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
