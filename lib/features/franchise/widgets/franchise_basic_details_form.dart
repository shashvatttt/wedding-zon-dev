import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/wz_colors.dart';
import '../../../core/theme/wz_text_styles.dart';
import '../providers/franchise_form_provider.dart';

class FranchiseBasicDetailsForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const FranchiseBasicDetailsForm({super.key, required this.formKey});

  @override
  State<FranchiseBasicDetailsForm> createState() =>
      _FranchiseBasicDetailsFormState();
}

class _FranchiseBasicDetailsFormState extends State<FranchiseBasicDetailsForm> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseFormProvider>(
      builder: (context, provider, _) {
        return Form(
          key: widget.formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Basic Details',
                style: WzTextStyles.heading4.copyWith(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: WzColors.text,
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Profile Created For *'),
              const SizedBox(height: 8.0),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  value: provider.formData['created_for'],
                  decoration: _inputDecoration(),
                  items:
                      [
                            'Self',
                            'Son',
                            'Daughter',
                            'Brother',
                            'Sister',
                            'Friend',
                            'Relative',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => provider.updateField('created_for', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24.0),

              _buildLabel('First Name *'),
              const SizedBox(height: 8.0),
              Container(
                decoration: _inputContainerDecoration(),
                child: TextFormField(
                  initialValue: provider.formData['first_name'],
                  decoration: _inputDecoration(),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'First name is required' : null,
                  onChanged: (v) => provider.updateField('first_name', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24.0),

              _buildLabel('Last Name *'),
              const SizedBox(height: 8.0),
              Container(
                decoration: _inputContainerDecoration(),
                child: TextFormField(
                  initialValue: provider.formData['last_name'],
                  decoration: _inputDecoration(),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Last name is required' : null,
                  onChanged: (v) => provider.updateField('last_name', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24.0),

              _buildLabel('Phone Number'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: TextFormField(
                  initialValue: provider.formData['phone']?.replaceFirst(
                    '+91',
                    '',
                  ),
                  decoration: _inputDecoration().copyWith(
                    hintText: '9876543210',
                    prefixText: '+91 ',
                    prefixStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      if (v.length != 10) {
                        return 'Enter 10 digit phone number';
                      }
                    }
                    return null;
                  },
                  onChanged: (v) => provider.updateField('phone', '+91$v'),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Email'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: TextFormField(
                  initialValue: provider.formData['email'],
                  decoration: _inputDecoration().copyWith(
                    hintText: 'example@email.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      if (!RegExp(
                        r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                      ).hasMatch(v)) {
                        return 'Enter a valid email address';
                      }
                    }
                    return null;
                  },
                  onChanged: (v) => provider.updateField('email', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Date of Birth *'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: TextFormField(
                  readOnly: true,
                  decoration: _inputDecoration().copyWith(
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text:
                        _selectedDate != null ||
                            provider.formData['dob'] != null
                        ? (provider.formData['dob'] as String?)?.split(
                                'T',
                              )[0] ??
                              ''
                        : '',
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now().subtract(
                        const Duration(days: 18 * 365),
                      ),
                      helpText: 'Select Date of Birth',
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      provider.updateField('dob', picked.toIso8601String());
                      setState(() {});
                    }
                  },
                  validator: (v) => provider.formData['dob'] == null
                      ? 'Date of Birth is required'
                      : null,
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Gender *'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.formData['gender'],
                  decoration: _inputDecoration(),
                  items: ['Male', 'Female', 'Other']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => provider.updateField('gender', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Height*'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.formData['height'],
                  decoration: _inputDecoration(),
                  items:
                      [
                            '4\'6"',
                            '4\'8"',
                            '4\'10"',
                            '5\'0"',
                            '5\'2"',
                            '5\'4"',
                            '5\'6"',
                            '5\'8"',
                            '5\'10"',
                            '6\'0"',
                            '6\'2"',
                            '6\'4"',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => provider.updateField('height', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Marital Status *'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.formData['marital_status'],
                  decoration: _inputDecoration(),
                  items:
                      [
                            'Never Married',
                            'Divorced',
                            'Widowed',
                            'Awaiting Divorce',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => provider.updateField('marital_status', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Mother Tongue*'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.formData['mother_tongue'],
                  decoration: _inputDecoration(),
                  items:
                      [
                            'Hindi',
                            'English',
                            'Marathi',
                            'Tamil',
                            'Telugu',
                            'Bengali',
                            'Gujarati',
                            'Kannada',
                            'Malayalam',
                            'Punjabi',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => provider.updateField('mother_tongue', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('About Me *'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: TextFormField(
                  initialValue: provider.formData['about_me'],
                  decoration: _inputDecoration().copyWith(
                    hintText:
                        'Write a brief description about yourself (minimum 50 characters)',
                    helperText: 'Minimum 50 characters required',
                  ),
                  maxLines: 5,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'About Me is required';
                    }
                    final charCount = v.trim().length;
                    if (charCount < 50) {
                      return 'Please write at least 50 characters';
                    }
                    return null;
                  },
                  onChanged: (v) => provider.updateField('about_me', v),
                  style: _inputTextStyle(),
                ),
              ),
            ],
          ),
        );
      },
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
}
