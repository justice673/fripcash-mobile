import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Large digit tiles for neighborhood-shop pickup codes (buyer + boutiquier).
class PickupCodeDigits extends StatelessWidget {
  const PickupCodeDigits({
    super.key,
    required this.code,
    this.compact = false,
  });

  final String code;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final chars = code.replaceAll(' ', '').characters.toList();
    final size = compact ? 40.0 : 56.0;
    final fontSize = compact ? 22.0 : 30.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < chars.length; i++) ...[
          if (i > 0) SizedBox(width: compact ? 6 : 10),
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              chars[i],
              style: AppTypography.display(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> sharePickupCode(BuildContext context, String code) async {
  final t = AppLocalizations.of(context)!;
  await Clipboard.setData(ClipboardData(text: code));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(t.pickupCodeCopied(code)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
