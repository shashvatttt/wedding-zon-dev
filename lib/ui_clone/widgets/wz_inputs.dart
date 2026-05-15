import 'package:flutter/material.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import '../../core/theme/wz_spacing.dart';

class WzTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const WzTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: WzTextStyles.caption.copyWith(color: WzColors.text),
          ),
          const SizedBox(height: WzSpacing.space8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            style: WzTextStyles.body1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: WzTextStyles.body1.copyWith(color: WzColors.muted),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              errorText: errorText,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: WzSpacing.space12,
                vertical: WzSpacing.space12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WzPasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const WzPasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.onChanged,
    this.validator,
  });

  @override
  State<WzPasswordField> createState() => _WzPasswordFieldState();
}

class _WzPasswordFieldState extends State<WzPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: WzTextStyles.caption.copyWith(color: WzColors.text),
          ),
          const SizedBox(height: WzSpacing.space8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            onChanged: widget.onChanged,
            style: WzTextStyles.body1,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: WzTextStyles.body1.copyWith(color: WzColors.muted),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: WzColors.muted,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              errorText: widget.errorText,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: WzSpacing.space12,
                vertical: WzSpacing.space12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WzDropdown extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? errorText;

  const WzDropdown({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    required this.items,
    this.onChanged,
    this.validator,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: WzTextStyles.caption.copyWith(color: WzColors.text),
          ),
          const SizedBox(height: WzSpacing.space8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: initialValue,
            hint: hint != null
                ? Text(
                    hint!,
                    style: WzTextStyles.body1.copyWith(color: WzColors.muted),
                  )
                : null,
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: WzTextStyles.body1),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            validator: validator,
            style: WzTextStyles.body1,
            decoration: InputDecoration(
              errorText: errorText,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: WzSpacing.space12,
                vertical: WzSpacing.space12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WzDatePicker extends StatelessWidget {
  final String? label;
  final String? hint;
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final String? errorText;
  final String Function(DateTime)? dateFormatter;

  const WzDatePicker({
    super.key,
    this.label,
    this.hint,
    this.selectedDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.errorText,
    this.dateFormatter,
  });

  String _formatDate(DateTime date) {
    if (dateFormatter != null) {
      return dateFormatter!(date);
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: WzTextStyles.caption.copyWith(color: WzColors.text),
          ),
          const SizedBox(height: WzSpacing.space8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
            ],
          ),
          child: TextField(
            readOnly: true,
            controller: TextEditingController(
              text: selectedDate != null ? _formatDate(selectedDate!) : '',
            ),
            style: WzTextStyles.body1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: WzTextStyles.body1.copyWith(color: WzColors.muted),
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: WzColors.muted,
              ),
              errorText: errorText,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: WzSpacing.space12,
                vertical: WzSpacing.space12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: WzColors.error),
              ),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: firstDate ?? DateTime(1900),
                lastDate: lastDate ?? DateTime(2100),
              );
              if (picked != null && onDateSelected != null) {
                onDateSelected!(picked);
              }
            },
          ),
        ),
      ],
    );
  }
}

class WzSearchBar extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const WzSearchBar({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: WzColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: WzTextStyles.body2,
        decoration: InputDecoration(
          hintText: hint ?? 'Search',
          hintStyle: WzTextStyles.body2.copyWith(color: WzColors.muted),
          prefixIcon: const Icon(Icons.search, color: WzColors.muted, size: 20),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: WzColors.muted,
                    size: 20,
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: WzSpacing.space12,
            vertical: WzSpacing.space8,
          ),
        ),
      ),
    );
  }
}
