import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Simple confirm / cancel dialog matching thriftcash ConfirmDialog UX.
Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String description,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
  Widget? child,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
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
              description,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                height: 1.4,
                color: AppColors.textPrimary.withValues(alpha: 0.75),
              ),
            ),
            if (child != null) ...[
              const SizedBox(height: 16),
              child,
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              cancelLabel,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  destructive ? const Color(0xFFDC2626) : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
  return result == true;
}
