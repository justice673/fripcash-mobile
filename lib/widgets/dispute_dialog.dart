import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Opens the buyer dispute form. Returns the reason text, or `null` if cancelled.
///
/// Owns the [TextEditingController] inside a [StatefulWidget] so it is never
/// disposed while the dialog route (or exit animation) still has dependents.
Future<String?> showOpenDisputeDialog({
  required BuildContext context,
  required String orderId,
}) {
  final t = AppLocalizations.of(context)!;
  return showDialog<String>(
    context: context,
    builder: (ctx) => _OpenDisputeDialog(
      title: t.disputeDialogTitle,
      description: t.disputeDialogBody(orderId),
      whatHappened: t.disputeWhatHappened,
      hint: t.disputeReasonHint,
      footer: t.disputeReasonFooter,
      confirmLabel: t.disputeSendToAdmin,
      cancelLabel: t.cancel,
    ),
  );
}

class _OpenDisputeDialog extends StatefulWidget {
  const _OpenDisputeDialog({
    required this.title,
    required this.description,
    required this.whatHappened,
    required this.hint,
    required this.footer,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String description;
  final String whatHappened;
  final String hint;
  final String footer;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_OpenDisputeDialog> createState() => _OpenDisputeDialogState();
}

class _OpenDisputeDialogState extends State<_OpenDisputeDialog> {
  late final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
      content: SingleChildScrollView(
        child: Column(
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
            Text(
              widget.whatHappened,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.footer,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
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
          onPressed: () => Navigator.of(context).pop(_reasonController.text),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
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
