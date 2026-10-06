import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Digits only — for local phone fields after the country code.
final phoneDigitsOnly = FilteringTextInputFormatter.digitsOnly;

/// Digits, spaces and + — for full international phone fields.
final phoneNumberInputFormatter =
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'));

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.style(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.textAlignVertical,
    this.enabled = true,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final TextAlignVertical? textAlignVertical;
  final bool enabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final multiline = (maxLines ?? 1) > 1 || (minLines ?? 1) > 1;
    // prefixIcon on multiline TextFields expands and steals taps — skip it.
    final effectivePrefix = multiline ? null : prefixIcon;
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType ??
          (multiline ? TextInputType.multiline : TextInputType.text),
      textInputAction:
          multiline ? TextInputAction.newline : TextInputAction.done,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      textAlignVertical: textAlignVertical ??
          (multiline ? TextAlignVertical.top : TextAlignVertical.center),
      style: AppTypography.style(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.style(
          fontSize: 16,
          color: AppColors.textPrimary.withValues(alpha: 0.45),
        ),
        prefixIcon: effectivePrefix,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: multiline ? 14 : 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class AuthDropdownField<T> extends StatelessWidget {
  const AuthDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: hintText == null
              ? null
              : Text(
                  hintText!,
                  style: AppTypography.style(fontSize: 16),
                ),
          items: items,
          onChanged: onChanged,
          style: AppTypography.style(fontSize: 16),
        ),
      ),
    );
  }
}

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Text('🇬🇳', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '+224',
                  style: AppTypography.style(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [phoneDigitsOnly],
              style: AppTypography.style(fontSize: 16),
              decoration: InputDecoration(
                hintText: t.phoneNumberHintLocal,
                hintStyle: AppTypography.style(fontSize: 16),
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
