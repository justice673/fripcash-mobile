import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Typed pickup-code entry for proximity handoff (API requires match).
Future<String?> showPickupCodeHandoffDialog({
  required BuildContext context,
}) {
  final t = AppLocalizations.of(context)!;
  return showDialog<String>(
    context: context,
    builder: (ctx) => _PickupCodeHandoffDialog(
      title: t.confirmHandoff,
      description: t.sellerPickupCodeHint,
      hint: t.pickupCodeLabel,
      confirmLabel: t.confirmHandoff,
      cancelLabel: t.cancel,
    ),
  );
}

class _PickupCodeHandoffDialog extends StatefulWidget {
  const _PickupCodeHandoffDialog({
    required this.title,
    required this.description,
    required this.hint,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String description;
  final String hint;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_PickupCodeHandoffDialog> createState() =>
      _PickupCodeHandoffDialogState();
}

class _PickupCodeHandoffDialogState extends State<_PickupCodeHandoffDialog> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.length < 4) return;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              height: 1.4,
              color: AppColors.textPrimary.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: widget.hint,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            widget.cancelLabel,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        FilledButton(
          onPressed: _controller.text.trim().length >= 4 ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            widget.confirmLabel,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
