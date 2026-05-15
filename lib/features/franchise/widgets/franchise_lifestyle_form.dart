import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import '../providers/franchise_form_provider.dart';

class FranchiseLifestyleForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const FranchiseLifestyleForm({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseFormProvider>(
      builder: (context, provider, _) {
        return Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Lifestyle & Appearance',
                style: WzTextStyles.heading4.copyWith(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: WzColors.text,
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Appearance*'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.formData['appearance'],
                  decoration: _inputDecoration(),
                  items: ['Fair', 'Wheatish', 'Dark', 'Very Fair']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => provider.updateField('appearance', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Living Status*'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.formData['living_status'],
                  decoration: _inputDecoration(),
                  items: ['With Family', 'Alone', 'With Roommates']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => provider.updateField('living_status', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Eating Habits*'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.formData['eating_habits'],
                  decoration: _inputDecoration(),
                  items: ['Vegetarian', 'Non-Vegetarian', 'Eggetarian', 'Vegan']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  validator: (v) => v == null ? 'Required' : null,
                  onChanged: (v) => provider.updateField('eating_habits', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Smoking Habits'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.formData['smoking_habits'],
                  decoration: _inputDecoration(),
                  items: ['No', 'Occasionally', 'Yes']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => provider.updateField('smoking_habits', v),
                  style: _inputTextStyle(),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Drinking Habits'),
              const SizedBox(height: 8),
              Container(
                decoration: _inputContainerDecoration(),
                child: DropdownButtonFormField<String>(
                  initialValue: provider.formData['drinking_habits'],
                  decoration: _inputDecoration(),
                  items: ['No', 'Occasionally', 'Yes']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => provider.updateField('drinking_habits', v),
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
