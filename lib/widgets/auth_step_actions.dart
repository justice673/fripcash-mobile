import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Circular back control: white fill, green border, green arrow.
class AuthCircleBackButton extends StatelessWidget {
  const AuthCircleBackButton({
    super.key,
    required this.onPressed,
    this.size = 52,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.primary, width: 1.6),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 22,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Back circle + primary pill (with forward arrow), matching signup/login CTAs.
class AuthStepActions extends StatelessWidget {
  const AuthStepActions({
    super.key,
    required this.onBack,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final VoidCallback onBack;
  final String primaryLabel;
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AuthCircleBackButton(onPressed: onBack),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.4),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                elevation: 0,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                textStyle: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(primaryLabel),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
