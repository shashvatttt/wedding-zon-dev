import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../core/theme/wz_text_styles.dart';
import '../providers/franchise_form_provider.dart';

class FranchiseLocationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const FranchiseLocationForm({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseFormProvider>(
      builder: (context, provider, _) {
        final isIndia = provider.formData['country'] == 'India';

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
                    'Location',
                    style: WzTextStyles.heading3.copyWith(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  Text(
                    'Country *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: provider.formData['country'],
                      decoration: InputDecoration(
                        hintText: 'Select country',
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
                          ['India', 'USA', 'UK', 'Canada', 'Australia', 'Other']
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
                          v == null ? 'Please select country' : null,
                      onChanged: (v) {
                        provider.updateField('country', v);
                        if (v != 'India') provider.updateField('state', null);
                      },
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'State *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: isIndia
                        ? DropdownButtonFormField<String>(
                            value: provider.formData['state'],
                            decoration: InputDecoration(
                              hintText: 'Select state',
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
                                      'Delhi',
                                      'Jammu and Kashmir',
                                      'Ladakh',
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
                                v == null ? 'Please select state' : null,
                            onChanged: (v) => provider.updateField('state', v),
                          )
                        : TextFormField(
                            initialValue: provider.formData['state'],
                            decoration: InputDecoration(
                              hintText: 'Enter state',
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
                            style: WzTextStyles.body2.copyWith(
                              color: WzColors.text,
                            ),
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'State is required' : null,
                            onChanged: (v) => provider.updateField('state', v),
                          ),
                  ),
                  const SizedBox(height: 24.0),

                  Text(
                    'City *',
                    style: WzTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WzColors.text,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: _inputContainerDecoration(),
                    child: TextFormField(
                      initialValue: provider.formData['city'],
                      decoration: InputDecoration(
                        hintText: 'Enter city',
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
                          v?.isEmpty ?? true ? 'City is required' : null,
                      onChanged: (v) => provider.updateField('city', v),
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
