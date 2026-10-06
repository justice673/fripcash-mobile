import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

class ConsentCheckboxes extends StatelessWidget {
  const ConsentCheckboxes({
    super.key,
    required this.marketingAccepted,
    required this.termsAccepted,
    required this.onMarketingChanged,
    required this.onTermsChanged,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final bool marketingAccepted;
  final bool termsAccepted;
  final ValueChanged<bool> onMarketingChanged;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  static final _labelStyle = AppTypography.style(
    fontSize: 14,
    height: 1.45,
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        _ConsentRow(
          value: marketingAccepted,
          onChanged: onMarketingChanged,
          child: Text(
            t.marketingConsentText,
            style: _labelStyle,
          ),
        ),
        const SizedBox(height: 16),
        _ConsentRow(
          value: termsAccepted,
          onChanged: onTermsChanged,
          child: RichText(
            text: TextSpan(
              style: _labelStyle,
              children: [
                TextSpan(
                  text: t.termsPrefix,
                ),
                TextSpan(
                  text: t.termsAndConditions,
                  style: TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppTypography.fontFamily,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                ),
                TextSpan(text: t.termsMiddle),
                TextSpan(
                  text: t.privacyPolicy,
                  style: TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppTypography.fontFamily,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
                ),
                TextSpan(
                  text: t.termsSuffix,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.value,
    required this.onChanged,
    required this.child,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.white;
            }),
            checkColor: Colors.white,
            side: BorderSide(color: AppColors.textPrimary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }
}
